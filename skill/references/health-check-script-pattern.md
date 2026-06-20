---
title: 定时健康检查脚本模式（cron no_agent=True）
created: 2026-06-13
category: 机制
tags: [cron, monitoring, no_agent, bash, auto-fix]
status: active
author: 米宝
---

# 定时健康检查脚本模式

## 核心思路

用 `no_agent=True` 的 cron job 运行 bash 脚本，实现零 token 消耗的定时监控。
脚本 stdout 为空时静默（不打扰用户），有异常时输出报告。

## Hermes Cron 的 no_agent 语义

- `no_agent=True` + `script`: 调度器直接运行脚本，stdout 注入为消息
- **空 stdout = 静默** — 用户看不到任何东西
- **非空 stdout = 发送报告** — 原样发给用户
- **非零 exit / 超时 = 错误告警**

## 脚本编写规范

```bash
#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
REPORT=""
FIX_COUNT=0

add_report() { REPORT="${REPORT}$1"$'\n'; }
add_fix()    { FIX_COUNT=$((FIX_COUNT + 1)); REPORT="${REPORT}  ✅ 已修复: $1"$'\n'; }
add_warn()   { REPORT="${REPORT}  ⚠️  $1"$'\n'; }
add_fail()   { REPORT="${REPORT}  ❌ $1"$'\n'; }

# ... 检查逻辑 ...

if [ -n "$REPORT" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 健康检查报告"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo -n "$REPORT"
  [ "$FIX_COUNT" -gt 0 ] && echo "  🔧 自动修复: ${FIX_COUNT}项"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
# 空 stdout → Cron 静默
```

## 关键约束

1. **script 路径必须是相对路径**（相对于 `~/.hermes/scripts/`）
   - ❌ `script: /home/user/.hermes/scripts/check.sh`
   - ✅ `script: check.sh`

2. **脚本必须有执行权限**: `chmod +x`

3. **自动修复要保守** — 只修复确定性、无副作用的操作:
   - ✅ 创建缺失目录 (mkdir -p)
   - ✅ 追加缺失的标记行 (grep + cat >>)
   - ❌ 删除/覆盖用户内容
   - ❌ 需要推理判断的操作

4. **UTF-8 字节计数用 `wc -c`**，不能用 `wc -m`（字符数对中文不准确）

## 部署步骤

```bash
# 1. 写脚本
write_file(path="~/.hermes/scripts/check_xxx.sh", content=...)

# 2. 加执行权限
terminal("chmod +x ~/.hermes/scripts/check_xxx.sh")

# 3. 测试运行
terminal("bash ~/.hermes/scripts/check_xxx.sh")

# 4. 创建 Cron Job
cronjob(action='create', name='xxx健康检查',
        schedule='30 10 * * *',
        script='check_xxx.sh',
        no_agent=True)
```

## 实际案例: 铁壁四规健康检查

- 脚本: `~/.hermes/scripts/four_mechanisms_check.sh`
- Job ID: `08b2be27e03d`
- Schedule: 每天 10:30
- 检查项: skill文件、MEMORY、USER.md、SOUL.md指令、mano脚本、INDEX.md、归档目录
- 自动修复: SOUL.md追加指令、创建归档目录
- 静默条件: 全部通过时 stdout 为空

## Pitfall: Cron job 不等于会话内注入

Cron job 运行在**独立会话**中，无法:
- 检查用户当前会话的状态
- 向用户会话注入指令
- 加载技能到用户正在运行的会话

它的价值是**定期巡检+告警+轻量自动修复**，不是实时控制。
