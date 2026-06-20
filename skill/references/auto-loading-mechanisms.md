---
title: Hermes 技能自动加载机制分析
created: 2026-06-13
category: 机制
tags: [hermes, skill-loading, auto-load, SOUL.md, AGENTS.md]
status: active
author: 米宝
---

# Hermes 技能自动加载机制分析

## 问题

铁壁四规 skill 已安装但无法在新会话中自动加载。每次会话依赖 Agent "记得"调用 skill_view()，属于软约束。

## 已验证的上下文注入机制

### 1. SOUL.md（最可靠）

- **路径**: `~/.hermes/SOUL.md`
- **加载方式**: 每次会话自动注入系统提示词（slot #1，作为 Agent 身份）
- **源码位置**: `agent/prompt_builder.py::load_soul_md()`
- **截断限制**: 有 max_chars 截断阈值（CONTEXT_FILE_MAX_CHARS）
- **注入检测**: 内置 prompt injection 扫描（`_scan_context_content`）

**实施方案**: 在 SOUL.md 末尾追加加载指令：
```markdown
## 铁壁四规自动加载
每次新会话开始时，必须先执行 skill_view(name='four-mechanisms') 加载铁壁四规。
```

**局限**:
- SOUL.md 是身份文件，混入技能加载指令会污染身份定义
- 指令是"请加载"而非"已加载"，Agent 可能忽略
- 截断阈值限制了可追加的内容长度

### 2. AGENTS.md（条件触发）

- **加载方式**: 从当前工作目录（CWD）加载，不从 HERMES_HOME 加载
- **源码位置**: `agent/prompt_builder.py::_load_agents_md()`
- **查找逻辑**: 先查 `AGENTS.md`，再查 `agents.md`，仅顶层（不递归）
- **子目录提示**: `agent/subdirectory_hints.py` 会向上查找至 git root

**为什么不适用于全局自动加载**:
- `~/.hermes/AGENTS.md` 只有当 cwd=`~/.hermes/` 时才被加载
- 用户日常 cwd 是 `~/` 或项目目录，不会触发
- 工作目录切换时可能加载不同的 AGENTS.md（甚至来自项目仓库）

### 3. CLI -s 预加载（手动）

- **命令**: `hermes -s four-mechanisms`
- **效果**: 会话启动时预加载技能，整个会话有效
- **源码位置**: `cli.py` → `build_preloaded_skills_prompt()`
- **限制**: 需要用户每次手动传入，无 config.yaml 配置项

**变通方案**: shell alias
```bash
alias hm='hermes -s four-mechanisms'
```
局限：只对 CLI 有效，gateway 会话无法受益。

### 4. /skill 会话内命令

- **命令**: `/skill four-mechanisms`
- **效果**: 当前会话有效
- **限制**: 需要 Agent 或用户手动触发

## Cron Job 的局限

Cron Job 运行在独立会话中，与用户当前会话完全隔离。

**能做到的**:
- 定时检查 MEMORY 用量（已有 Job a78f92301730）
- 定时发送合规检查提醒
- 定时备份 Memory

**做不到的**:
- 无法注入指令到用户正在进行的对话
- 无法在用户新会话启动时自动触发
- 定时提醒 ≠ 技能自动加载

## 当前实施方案（三层软约束）

| 层级 | 机制 | 作用 | 已配置 |
|------|------|------|--------|
| L1 | SOUL.md 加载指令 | 每次会话提示 Agent 加载四规 | ✅ 安装脚本 Step 8 |
| L2 | Cron 健康检查 | 每天10:30运行 four_mechanisms_check.sh，检查7项+自动修复3项 | ✅ Job 08b2be27e03d（纯脚本，零token） |
| L3 | MEMORY 规则记忆 | 兜底：Agent 从记忆回忆规则 | ✅ MEMORY.md 已有 |

## 未来改进方向

1. **Hermes 官方**: 支持 `config.yaml` 中的 `skills.preload: [four-mechanisms]` 配置
2. **Hermes 官方**: 支持 profile-level default skills
3. **Plugin 方式**: 编写 plugin 在会话启动时自动注入技能内容
4. **SOUL.md 精简**: 将 SOUL.md 中的加载指令移至独立文件，减少身份污染

## 参考

- Hermes 源码: `agent/prompt_builder.py` (上下文文件加载)
- Hermes 源码: `agent/skill_commands.py` (技能预加载)
- Hermes 源码: `agent/subdirectory_hints.py` (子目录 AGENTS.md 发现)
- Hermes 源码: `cli.py` (preloaded_skills 处理)
