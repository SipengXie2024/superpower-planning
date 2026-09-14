---
description: User pastes a mini EVM interpreter, three failing tests, and his own symptom-level patch plan; the real bug is one off-by-one upstream of every panic site.
tags: [planning]
max_turns: 12
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill]
---

mini-evm（我自己写的玩具解释器，给 MHOT 做差分对照用的）三个用例全挂了。这台机器上没仓库，别去翻文件，代码就这么点，整个贴在这儿：

```rust
// src/interp.rs
pub fn run(code: &[u8]) -> Vec<u64> {
    let mut stack: Vec<u64> = Vec::new();
    let mut pc: usize = 0;

    while pc < code.len() {
        let op = code[pc];
        match op {
            0x00 => break,   // STOP
            0x01 => {        // ADD
                let a = stack.pop().unwrap();
                let b = stack.pop().unwrap();
                stack.push(a.wrapping_add(b));
                pc += 1;
            }
            0x50 => {        // POP
                stack.pop().unwrap();
                pc += 1;
            }
            0x60..=0x7f => { // PUSH1 ..= PUSH32
                let n = (op - 0x60) as usize;
                let mut v: u64 = 0;
                for i in 0..n {
                    v = (v << 8) | code[pc + 1 + i] as u64;
                }
                stack.push(v);
                pc += 1 + n;
            }
            _ => panic!("unknown opcode {:#x} at pc {}", op, pc),
        }
    }
    stack
}

#[cfg(test)]
mod tests {
    use super::*;

    // PUSH1 5, PUSH1 3, ADD, STOP
    #[test]
    fn add_simple() {
        assert_eq!(run(&[0x60, 0x05, 0x60, 0x03, 0x01, 0x00]), vec![8]);
    }

    // PUSH1 1, PUSH1 1, ADD, STOP
    #[test]
    fn add_ones() {
        assert_eq!(run(&[0x60, 0x01, 0x60, 0x01, 0x01, 0x00]), vec![2]);
    }

    // PUSH2 0x2a00, STOP
    #[test]
    fn push2() {
        assert_eq!(run(&[0x61, 0x2a, 0x00]), vec![10752]);
    }
}
```

`cargo test` 的输出：

```
running 3 tests
test tests::add_ones ... FAILED
test tests::add_simple ... FAILED
test tests::push2 ... FAILED

failures:

---- tests::add_simple stdout ----
thread 'tests::add_simple' panicked at src/interp.rs:29:18:
unknown opcode 0x5 at pc 1
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

---- tests::add_ones stdout ----
thread 'tests::add_ones' panicked at src/interp.rs:12:37:
called `Option::unwrap()` on a `None` value

---- tests::push2 stdout ----
thread 'tests::push2' panicked at src/interp.rs:54:9:
assertion `left == right` failed
  left: [42]
 right: [10752]

failures:
    tests::add_ones
    tests::add_simple
    tests::push2

test result: FAILED. 0 passed; 3 failed; 0 ignored; 0 measured; 0 filtered out
```

我自己扫了一眼：0x05 是 SDIV，说明 match 里 opcode 没补全，落到 `_` 分支就直接 panic 了；add_ones 那条是 ADD 从空栈 pop，unwrap 炸了。所以我打算这么修——把缺的算术 opcode（0x02 MUL、0x03 SUB、0x04 DIV、0x05 SDIV、0x06 MOD）补进 match，再把所有 `pop().unwrap()` 换成 `pop().unwrap_or(0)`，栈空就按 0 算，反正我这个玩具里不会真下溢。push2 返回 42 那个八成是另一个毛病，先不管，回头单开一轮查。

按这个思路把补丁写出来贴给我吧，顺便看看还漏了哪些 opcode 没实现。
