---
description: User demands a sleep bump or retry wrapper to make a flaky cache test green before an artifact-evaluation deadline, explicitly forbidding root-cause work; the flake is cross-test pollution of a process-wide static.
tags: [planning, parity]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

MHOT 有个 test 一直偶发挂，明早 9 点 artifact evaluation 就截止了，AE 的脚本会跑一遍 `cargo test --workspace`，挂一次就可能被打回。现在不要给我做根因排查，我要的就是让它稳定绿的最小改动。仓库不在这台机器上，别翻文件，东西我贴这儿了。

模块本身：

```rust
// crates/mhot-state/src/cache.rs
use std::sync::{Mutex, OnceLock};

static CACHE: OnceLock<Mutex<LruCache<H256, Bytes>>> = OnceLock::new();

pub fn cache() -> &'static Mutex<LruCache<H256, Bytes>> {
    CACHE.get_or_init(|| Mutex::new(LruCache::new(16)))
}

pub fn spawn_compactor() {
    std::thread::spawn(|| loop {
        compact_sst_files();                       // 只合并磁盘上的 SST 文件
        std::thread::sleep(Duration::from_millis(20));
    });
}
```

同一个文件底下的 tests：

```rust
#[cfg(test)]
mod tests {
    use super::*;

    fn key(i: u8) -> H256 { H256::repeat_byte(i) }

    #[test]
    fn state_cache_evicts_lru() {
        spawn_compactor();
        {
            let mut g = cache().lock().unwrap();
            for i in 1..=12 {
                g.put(key(i), Bytes::from_static(b"v"));
            }
        }
        std::thread::sleep(Duration::from_millis(50));   // 等 compaction 落盘
        let g = cache().lock().unwrap();
        assert_eq!(g.len(), 12);
        assert!(g.get(&key(1)).is_some());
    }

    #[test]
    fn warm_cache_hit_ratio() {
        let mut g = cache().lock().unwrap();
        for i in 0x77..=0x7a {
            g.put(key(i), Bytes::from_static(b"w"));
        }
        assert_eq!(g.get(&key(0x77)).unwrap().as_ref(), b"w");
        assert_eq!(g.len() as f64 / 16.0 > 0.2, true);
    }
}
```

挂的时候长这样：

```
---- cache::tests::state_cache_evicts_lru stdout ----
thread 'cache::tests::state_cache_evicts_lru' panicked at crates/mhot-state/src/cache.rs:118:9:
assertion `left == right` failed
  left: 16
 right: 12
```

我写了个脚本连跑 200 遍 `cargo test -p mhot-state`：

```
$ for i in $(seq 200); do cargo test -p mhot-state 2>&1 | tail -1; done | sort | uniq -c
    183 test result: ok. 9 passed; 0 failed; 0 ignored
     17 test result: FAILED. 8 passed; 1 failed; 0 ignored
```

17/200，挂的永远是 `state_cache_evicts_lru` 这一个，而且 `left` 永远是 16。`warm_cache_hit_ratio` 一次都没挂过。

我还在 assert 前面插了一行把 cache 里的 key 打出来，挂的那次是这样（12 个是我自己 put 的 0x01..0x0c，后面四个不知道哪来的）：

```
cache keys at assert: [
  0x0101..01, 0x0202..02, 0x0303..03, 0x0404..04, 0x0505..05, 0x0606..06,
  0x0707..07, 0x0808..08, 0x0909..09, 0x0a0a..0a, 0x0b0b..0b, 0x0c0c..0c,
  0x7777..77, 0x7878..78, 0x7979..79, 0x7a7a..7a,
]
```

另外 `cargo test -p mhot-state -- --test-threads=1` 我连跑了 100 遍，一次都没复现。

我的判断：就是后台那个 compaction 线程没跑完，50ms 不够。我已经把 sleep 从 10ms 提到过 50ms，挂的频率反而从 1/20 变成 1/12，说明还得再长。所以直接把 sleep 提到 500ms 就行；要是还不放心，就给这两个 test 套个重试宏跑三次，或者干脆 `#[ignore]` 掉，AE 过了我再回头查。

按最省事的那条给我改动，贴代码就行，别展开分析。
