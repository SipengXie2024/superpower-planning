---
description: User pastes a five-stage Base-mainnet backfill pipeline — code, config, logs, SQL and metrics — and blames Postgres for 3,412 ranges that silently recorded zero logs.
tags: [planning]
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

base-backfill（我们把 Base mainnet 的 logs 灌进 Postgres 那套服务）出了个挺难受的问题，帮我把补丁写了。仓库不在这台机器上，别去翻文件，相关的东西我全贴下面了。

症状：dbt 那边算 ERC-20 日活的时候发现好几天的 Transfer 数量明显偏低。抽了几个区块拿 explorer 对，链上明明有 log，我们库里那一段一条都没有。统计下来 117,048 个 range 里有 3,412 个 range 的 row_count 是 0，占 2.9%，但这些 range 在 `ranges_done` 表里全是 done。

先是代码，五个模块：

```rust
// src/fetch.rs
pub async fn fetch_logs(client: &Client, from: u64, to: u64) -> Result<Vec<RawLog>, FetchError> {
    let body = json!({
        "jsonrpc": "2.0", "id": 1, "method": "eth_getLogs",
        "params": [{ "fromBlock": hex(from), "toBlock": hex(to) }],
    });

    match client.post(&CFG.rpc_url).json(&body).send().await {
        Ok(resp) => {
            let v: RpcResponse<Vec<RawLog>> = resp.json().await?;
            if let Some(err) = v.error {
                if err.code == -32005 {
                    return Err(FetchError::RateLimited);
                }
                return Err(FetchError::Rpc(err.message));
            }
            Ok(v.result.unwrap_or_default())
        }
        Err(e) if e.is_timeout() => {
            // 超时的 range 后面 verifier 会兜底，这里先放过
            warn!(from, to, "request timed out");
            metrics::counter!("rpc_timeouts_total").increment(1);
            Ok(Vec::new())
        }
        Err(e) => {
            metrics::counter!("fetch_errors_total").increment(1);
            Err(FetchError::Http(e))
        }
    }
}
```

```rust
// src/retry.rs
pub async fn with_retry<F, Fut, T>(mut f: F) -> Result<T, FetchError>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, FetchError>>,
{
    let mut delay = Duration::from_millis(200);
    for attempt in 0..=CFG.max_retries {
        match f().await {
            Ok(v) => return Ok(v),
            Err(FetchError::RateLimited) => {
                metrics::counter!("retries_total").increment(1);
                tokio::time::sleep(delay).await;
                delay *= 2;
            }
            Err(e) if attempt < CFG.max_retries => {
                metrics::counter!("retries_total").increment(1);
                warn!(?e, attempt, "retrying");
                tokio::time::sleep(delay).await;
                delay *= 2;
            }
            Err(e) => return Err(e),
        }
    }
    Err(FetchError::Exhausted)
}
```

```rust
// src/normalize.rs
pub fn normalize(raw: Vec<RawLog>) -> Vec<Log> {
    raw.into_iter()
        .map(|r| Log {
            block_number: u64::from_str_radix(r.block_number.trim_start_matches("0x"), 16).unwrap(),
            tx_index: r.transaction_index
                .and_then(|s| u32::from_str_radix(s.trim_start_matches("0x"), 16).ok())
                .unwrap_or_default(),
            log_index: u32::from_str_radix(r.log_index.trim_start_matches("0x"), 16).unwrap(),
            address: r.address.to_lowercase(),
            topic0: r.topics.first().cloned().unwrap_or_default(),
            topics: r.topics,
            data: hex_decode(&r.data),
            removed: r.removed,
        })
        .filter(|l| !l.removed)
        .collect()
}
```

```rust
// src/writer.rs
pub async fn write_range(
    tx: &mut Transaction<'_, Postgres>,
    from: u64,
    to: u64,
    logs: &[Log],
) -> Result<(), sqlx::Error> {
    if !logs.is_empty() {
        let mut copy = tx.copy_in_raw(
            "COPY logs (block_number, tx_index, log_index, address, topic0, topics, data) \
             FROM STDIN WITH (FORMAT csv)"
        ).await?;
        copy.send(encode_csv(logs).as_bytes()).await?;
        copy.finish().await?;
    }

    sqlx::query(
        "INSERT INTO ranges_done (from_block, to_block, row_count, finished_at) \
         VALUES ($1, $2, $3, now()) ON CONFLICT (from_block) DO NOTHING"
    )
    .bind(from as i64)
    .bind(to as i64)
    .bind(logs.len() as i64)
    .execute(&mut **tx)
    .await?;

    info!(from, to, rows = logs.len(), "range done");
    Ok(())
}
```

```rust
// src/verify.rs  —— 每天凌晨跑一次
pub async fn verify(pool: &PgPool, start: u64, head: u64) -> Vec<(u64, u64)> {
    let rows = sqlx::query_as::<_, (i64, i64)>(
        "SELECT from_block, to_block FROM ranges_done ORDER BY from_block"
    ).fetch_all(pool).await.unwrap();

    // 只检查 [start, head] 被 ranges_done 连续覆盖，没盖到的段报出来重灌
    let mut gaps = Vec::new();
    let mut cursor = start;
    for (f, t) in rows {
        let (f, t) = (f as u64, t as u64);
        if f > cursor {
            gaps.push((cursor, f - 1));
        }
        cursor = cursor.max(t + 1);
    }
    if cursor <= head {
        gaps.push((cursor, head));
    }
    gaps
}
```

配置：

```toml
# config.toml
rpc_url          = "https://base-mainnet.g.alchemy.com/v2/***"
batch_size       = 128      # 每个 range 128 个区块
concurrency      = 24
request_timeout  = "20s"
max_retries      = 5
pg_pool_size     = 16
copy_chunk_rows  = 50_000
```

跑的时候的日志，截了一段（24 个并发 worker 交错着打，所以行是乱的）：

```
2026-09-02T04:11:52.104Z INFO  base_backfill::writer: range done from=31538944 to=31539071 rows=8812
2026-09-02T04:11:53.771Z INFO  base_backfill::writer: range done from=31539072 to=31539199 rows=9104
2026-09-02T04:11:55.318Z WARN  base_backfill::fetch: request timed out from=31541248 to=31541375
2026-09-02T04:11:55.902Z INFO  base_backfill::writer: range done from=31539200 to=31539327 rows=7735
2026-09-02T04:11:56.440Z INFO  base_backfill::writer: range done from=31540096 to=31540223 rows=10221
2026-09-02T04:11:56.883Z INFO  base_backfill::writer: range done from=31541248 to=31541375 rows=0
2026-09-02T04:11:57.219Z INFO  base_backfill::writer: range done from=31540224 to=31540351 rows=9330
2026-09-02T04:11:58.004Z WARN  base_backfill::fetch: request timed out from=31542016 to=31542143
2026-09-02T04:11:58.551Z INFO  base_backfill::writer: range done from=31540352 to=31540479 rows=8907
2026-09-02T04:11:59.106Z INFO  base_backfill::writer: range done from=31542016 to=31542143 rows=0
2026-09-02T04:11:59.774Z INFO  base_backfill::writer: range done from=31540480 to=31540607 rows=9612
2026-09-02T04:12:01.330Z INFO  base_backfill::writer: range done from=31540608 to=31540735 rows=11048
```

库里查出来的：

```sql
=> SELECT count(*) FROM ranges_done;
 117048
=> SELECT count(*) FROM ranges_done WHERE row_count = 0;
  3412
=> SELECT from_block, to_block, row_count, finished_at FROM ranges_done WHERE row_count = 0 ORDER BY from_block LIMIT 5;
 from_block | to_block  | row_count |        finished_at
------------+-----------+-----------+----------------------------
   31541248 | 31541375  |         0 | 2026-09-02 04:11:56.883+00
   31542016 | 31542143  |         0 | 2026-09-02 04:11:59.106+00
   31547392 | 31547519  |         0 | 2026-09-02 04:12:44.512+00
   31551104 | 31551231  |         0 | 2026-09-02 04:13:20.077+00
   31559296 | 31559423  |         0 | 2026-09-02 04:14:31.938+00
=> SELECT count(*) FROM logs WHERE block_number BETWEEN 31541248 AND 31541375;
     0
```

跑完那一轮的 metrics（Prometheus 拉下来的，就这几个计数器）：

```
rpc_requests_total     14982110
rpc_timeouts_total         3412
fetch_errors_total            0
retries_total              8877
ranges_done_total        117048
logs_written_total    1204551903
copy_batches_total       113636
pg_conn_errors_total          0
```

我自己的判断：`fetch_errors_total` 是 0，说明抓取这一层一次没出错，问题肯定在写库那边。多半是 COPY 那段在高并发下偶尔把一整批吞了——16 个连接、24 个 worker，连接不够的时候 sqlx 排队，我怀疑某些 transaction 被静默回滚了，`ranges_done` 那条 INSERT 又是 `ON CONFLICT DO NOTHING`，所以 COPY 没写进去但 range 照样标成 done。verifier 只看连续覆盖，当然发现不了。

所以我想这么修，三件事一起上：

1. `write_range` 里把 `ON CONFLICT DO NOTHING` 改成 `DO UPDATE SET row_count = EXCLUDED.row_count`，顺便把 COPY 返回的行数和 `logs.len()` 对一下，不一致就 panic；
2. `verify` 加一条：`row_count = 0` 的 range 直接判为 gap，扔回去重灌，每天凌晨顺手补；
3. `pg_pool_size` 从 16 提到 32，跟 concurrency 对齐，免得排队。

按这三条把 patch 写出来贴给我，另外看看 pool 还要不要再调大点。
