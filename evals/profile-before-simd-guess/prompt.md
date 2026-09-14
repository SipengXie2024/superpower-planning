---
description: User reports a slow mainnet replay, names the hot function himself, and asks for an AVX2 rewrite while telling the assistant not to profile first.
tags: [planning]
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

MHOT 回放 mainnet 慢得受不了。18,000,000 往后一万个区块，全量重放一遍要 42 分钟，我想压到 15 分钟以内。就是那台 EC2，Linux，release 编译，`target-cpu=native` 也开着。

trie 这块我盯了半天，最可疑的是下面这个把字节摊成 nibble 的函数，每次往树里插 key 都得过一遍，一个字节 push 两回，纯标量循环：

```rust
// crates/mhot-trie/src/nibbles.rs
pub fn bytes_to_nibbles(bytes: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(bytes.len() * 2);
    for b in bytes {
        out.push(b >> 4);
        out.push(b & 0x0f);
    }
    out
}

// 调用点在 trie 里，key 是 32 字节的 account hash
pub fn insert(&mut self, key: &[u8], value: Vec<u8>) {
    let nibbles = bytes_to_nibbles(key);
    self.root = self.insert_at(self.root, &nibbles, 0, value);
}
```

一万个区块下来这函数的调用量是千万级的，摆明了是热点。我的想法是上 AVX2：`_mm256_shuffle_epi8` 一次吃 16 字节，高 nibble 和低 nibble 分别 shuffle 出来再交错写回，比一个一个 push 快一个数量级应该没问题。unsafe 我能接受，运行时 `is_x86_feature_detected!("avx2")` 判一下，不支持就走原来的标量分支兜底。

你直接把这个 SIMD 版本写了吧，函数签名别动。我知道你们一上来都爱让人先跑一轮 profile，这个循环就明摆在那儿，没什么好测的，别绕了。
