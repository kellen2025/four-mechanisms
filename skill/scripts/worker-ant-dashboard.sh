#!/bin/bash
# 工蚁v2.0-beta：进度看板（独立脚本）
# 实时查看任务队列状态

set -e

BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}"
echo "╔══════════════════════════════════════╗"
echo "║     🐜 工蚁进度看板 v2.0-beta       ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

hermes kanban list --json 2>/dev/null | python3 -c "
import sys, json
from datetime import datetime

try:
    tasks = json.load(sys.stdin)
except:
    print('  ⚠️  无法读取任务数据')
    sys.exit(0)

if not tasks:
    print('  📭 队列为空')
    print()
    print('  添加任务: worker-ant-queue add <任务描述>')
    sys.exit(0)

# 按状态分组
groups = {}
for t in tasks:
    s = t.get('status', 'unknown')
    groups.setdefault(s, []).append(t)

# 状态配置
order = ['running', 'ready', 'blocked', 'scheduled', 'triage', 'completed', 'archived']
icons = {
    'running': '🔄', 'ready': '📋', 'blocked': '🚫',
    'scheduled': '⏰', 'triage': '🔍', 'completed': '✅', 'archived': '📦'
}
names = {
    'running': '执行中', 'ready': '待执行', 'blocked': '已阻塞',
    'scheduled': '已计划', 'triage': '待分类', 'completed': '已完成', 'archived': '已归档'
}

# 统计
total = len(tasks)
done = len(groups.get('completed', []))
run = len(groups.get('running', []))
wait = len(groups.get('ready', []))
block = len(groups.get('blocked', []))

# 进度条
pct = int(done / total * 100) if total else 0
bar_w = 30
filled = int(bar_w * done / total) if total else 0
bar = '█' * filled + '░' * (bar_w - filled)

print(f'  总计: {total} 个任务')
print(f'  进度: [{bar}] {pct}%')
print(f'  🔄 执行中: {run}  📋 待执行: {wait}  🚫 阻塞: {block}  ✅ 完成: {done}')
print()

# 按状态输出
for status in order:
    group = groups.get(status, [])
    if not group:
        continue

    icon = icons.get(status, '❓')
    name = names.get(status, status)
    print(f'  {icon} {name} ({len(group)})')
    print(f'  ─────────────────────────────────')

    for t in group:
        tid = t.get('id', '?')[:8]
        title = t.get('title', '无标题')
        assignee = t.get('assignee', '未分配')
        priority = t.get('priority', 99)
        created = t.get('created_at', 0)

        pri_icon = '🔴' if priority == 1 else ('🟡' if priority == 2 else '⚪')

        # 计算等待时间
        age_str = ''
        if created and status in ('ready', 'running', 'blocked'):
            age_s = int(datetime.now().timestamp()) - created
            if age_s < 60:
                age_str = f' ({age_s}s前)'
            elif age_s > 3600:
                age_str = f' ({age_s // 3600}h{(age_s % 3600) // 60}m前)'
            elif age_s > 60:
                age_str = f' ({age_s // 60}m前)'
            else:
                age_str = f' ({age_s}s前)'

        # 提取profile简名
        profile_short = assignee.split('-')[-1] if '-' in assignee else assignee

        print(f'  {pri_icon} [{tid}] {title}{age_str}')
        print(f'     └─ 👤 {profile_short}')
    print()
" 2>/dev/null
