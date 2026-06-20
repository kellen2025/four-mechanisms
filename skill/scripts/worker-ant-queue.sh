#!/bin/bash
# 工蚁v2.0-beta：智能任务队列
# 基于Hermes Kanban的任务队列系统
# 阶段2：任务队列 + 进度看板

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================
# Agent能力表（复用阶段1）
# ============================================================
declare -A AGENT_PROFILES=(
    [pm]="mibao-kills-pm"
    [coder]="mibao-kellen-coder"
    [ops]="mibao-duobao-om"
    [algorithm]="harry"
    [default]="mibao"
)

declare -A AGENT_NAMES=(
    [pm]="毙杀(产品经理)"
    [coder]="码仔(编码工程师)"
    [ops]="多宝(运营负责人)"
    [algorithm]="Harry(算法专家)"
    [default]="米宝(主控)"
)

# ============================================================
# 任务类型关键词映射
# ============================================================
match_agent() {
    local input="$1"
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    # 产品类
    if echo "$input_lower" | grep -qE "设计|ui|界面|页面|原型|交互|需求|prd|功能|竞品|分析|调研|市场"; then
        echo "pm"
        return
    fi

    # 开发类
    if echo "$input_lower" | grep -qE "编码|开发|写代码|实现|bug|修复|问题|错误|异常|审查|review|代码质量|优化|api|接口|后端|服务端|数据库"; then
        echo "coder"
        return
    fi

    # 运营类
    if echo "$input_lower" | grep -qE "运营|内容|文案|推广|活动|增长|获客|留存|转化|数据|报表|指标"; then
        echo "ops"
        return
    fi

    # 算法类
    if echo "$input_lower" | grep -qE "算法|模型|训练|预测|ai|游戏|机制|玩法|数值"; then
        echo "algorithm"
        return
    fi

    # 默认
    echo "default"
}

# 优先级推断
infer_priority() {
    local input="$1"
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    if echo "$input_lower" | grep -qE "紧急|urgent|p0|立刻|马上|立即|crash|崩溃|线上"; then
        echo "1"
    elif echo "$input_lower" | grep -qE "重要|high|p1|尽快"; then
        echo "2"
    else
        echo "3"
    fi
}

# ============================================================
# 主函数
# ============================================================
usage() {
    echo -e "${BOLD}🐜 工蚁任务队列 v2.0-beta${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "用法:"
    echo "  worker-ant-queue add <任务描述>     添加任务到队列"
    echo "  worker-ant-queue add --agent pm <任务描述>  指定Agent"
    echo "  worker-ant-queue add --priority 1 <任务描述> 指定优先级"
    echo "  worker-ant-queue add --goal <任务描述>  目标循环模式"
    echo "  worker-ant-queue run               执行队列中的下一个任务"
    echo "  worker-ant-queue status            查看队列状态"
    echo "  worker-ant-queue dashboard         进度看板"
    echo ""
    echo "优先级: 1=紧急 2=重要 3=普通"
    echo ""
    echo "示例:"
    echo "  worker-ant-queue add '设计登录页面'"
    echo "  worker-ant-queue add --agent coder '修复登录Bug'"
    echo "  worker-ant-queue add --priority 1 '线上崩溃紧急修复'"
    echo "  worker-ant-queue add --goal '完成用户系统重构'"
}

cmd_add() {
    local agent_override=""
    local priority_override=""
    local goal_mode=false
    local body=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                usage
                exit 0
                ;;
            --agent|-a)
                agent_override="$2"
                shift 2
                ;;
            --priority|-p)
                priority_override="$2"
                shift 2
                ;;
            --goal|-g)
                goal_mode=true
                shift
                ;;
            --body|-b)
                body="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ $# -eq 0 ]]; then
        echo -e "${RED}错误: 请提供任务描述${NC}"
        usage
        exit 1
    fi

    local task="$*"

    # 智能匹配Agent
    local agent_type
    if [[ -n "$agent_override" ]]; then
        # 支持简写
        case "$agent_override" in
            pm|product|产品) agent_type="pm" ;;
            coder|code|开发|engineer) agent_type="coder" ;;
            ops|运营) agent_type="ops" ;;
            algorithm|algo|算法) agent_type="algorithm" ;;
            *) agent_type="$agent_override" ;;
        esac
    else
        agent_type=$(match_agent "$task")
    fi

    local agent_profile="${AGENT_PROFILES[$agent_type]}"
    local agent_name="${AGENT_NAMES[$agent_type]}"

    # 推断优先级
    local priority
    if [[ -n "$priority_override" ]]; then
        priority="$priority_override"
    else
        priority=$(infer_priority "$task")
    fi

    # 构建kanban命令
    local cmd="hermes kanban create"
    cmd="$cmd --assignee '$agent_profile'"
    cmd="$cmd --priority $priority"
    cmd="$cmd --created-by worker-ant"

    if [[ "$goal_mode" == true ]]; then
        cmd="$cmd --goal --goal-max-turns 20"
    fi

    if [[ -n "$body" ]]; then
        cmd="$cmd --body '$body'"
    fi

    cmd="$cmd '$task'"

    # 显示任务信息
    echo -e "${BLUE}🐜 工蚁任务队列${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "任务: ${YELLOW}$task${NC}"
    echo -e "Agent: ${GREEN}$agent_name${NC} ($agent_profile)"
    echo -e "优先级: $priority"
    [[ "$goal_mode" == true ]] && echo -e "模式: ${CYAN}目标循环${NC}"
    echo ""

    # 执行创建
    echo -e "${BLUE}正在创建任务卡片...${NC}"
    local result
    result=$(eval "$cmd" 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}❌ 创建失败${NC}"
        echo -e "错误信息: $result"
        echo ""
        echo -e "可能原因:"
        echo -e "  1. Kanban未初始化 → 执行 ${CYAN}hermes kanban init${NC}"
        echo -e "  2. Agent profile不存在 → 检查 ${CYAN}hermes profile list${NC}"
        echo -e "  3. 权限不足 → 检查文件权限"
        return 1
    fi

    echo "$result"
    echo ""

    # 从结果中提取任务ID
    local task_id
    task_id=$(echo "$result" | grep -oP 't_[a-f0-9]+' | head -1)

    echo -e "${GREEN}✅ 任务已加入队列${NC}"
    [[ -n "$task_id" ]] && echo -e "任务ID: ${CYAN}$task_id${NC}"
    echo -e "查看状态: worker-ant-queue status"
    echo -e "查看看板: worker-ant-queue dashboard"
}

cmd_run() {
    echo -e "${BLUE}🐜 工蚁执行队列${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 获取ready状态的任务
    local tasks=$(hermes kanban list --json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = [t for t in data if t.get('status') == 'ready']
    if not tasks:
        print('NO_TASKS')
    else:
        # 按优先级排序
        tasks.sort(key=lambda x: x.get('priority', 99))
        t = tasks[0]
        print(json.dumps({'id': t['id'], 'title': t['title'], 'assignee': t.get('assignee', 'unknown'), 'priority': t.get('priority', 99)}))
except:
    print('ERROR')
" 2>/dev/null)

    if [[ "$tasks" == "NO_TASKS" ]]; then
        echo -e "${YELLOW}队列中没有ready状态的任务${NC}"
        echo ""
        echo "查看队列: worker-ant-queue status"
        return 0
    fi

    if [[ "$tasks" == "ERROR" ]]; then
        echo -e "${RED}❌ 解析任务列表失败${NC}"
        echo ""
        echo -e "可能原因:"
        echo -e "  1. Kanban未初始化 → 执行 ${CYAN}hermes kanban init${NC}"
        echo -e "  2. 数据库损坏 → 执行 ${CYAN}hermes kanban diagnostics${NC}"
        return 1
    fi

    # 解析任务
    local task_id=$(echo "$tasks" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
    local task_title=$(echo "$tasks" | python3 -c "import sys,json; print(json.load(sys.stdin)['title'])")
    local task_assignee=$(echo "$tasks" | python3 -c "import sys,json; print(json.load(sys.stdin)['assignee'])")

    echo -e "即将执行:"
    echo -e "  ID: ${CYAN}$task_id${NC}"
    echo -e "  任务: ${YELLOW}$task_title${NC}"
    echo -e "  Agent: ${GREEN}$task_assignee${NC}"
    echo ""

    # 原子claim + 执行
    echo -e "${BLUE}正在claim任务...${NC}"
    local claim_result=$(hermes kanban claim "$task_id" 2>&1)
    local claim_exit=$?

    if [[ $claim_exit -ne 0 ]]; then
        echo -e "${RED}❌ Claim失败${NC}"
        echo -e "错误信息: $claim_result"
        echo ""
        echo -e "可能原因:"
        echo -e "  1. 任务已被其他Agent认领 → 等待或选择其他任务"
        echo -e "  2. 任务状态不是ready → 执行 ${CYAN}worker-ant-queue status${NC} 查看"
        echo -e "  3. Dispatcher正在处理 → 稍后重试"
        return 1
    fi

    echo "$claim_result"
    echo ""

    # 通过delegate_task执行（后台异步）
    echo -e "${BLUE}正在派发给Agent执行...${NC}"
    echo -e "使用 hermes chat --profile $task_assignee 执行"
    echo ""

    hermes chat --profile "$task_assignee" -Q "$task_title"
}

cmd_status() {
    echo -e "${BOLD}🐜 工蚁队列状态${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    hermes kanban stats 2>/dev/null
    echo ""
    hermes kanban list 2>/dev/null
}

cmd_dashboard() {
    echo -e "${BOLD}🐜 工蚁进度看板${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 获取JSON数据
    hermes kanban list --json 2>/dev/null | python3 -c "
import sys, json

try:
    tasks = json.load(sys.stdin)
except:
    print('  (无任务数据)')
    sys.exit(0)

if not tasks:
    print('  队列为空，没有任务')
    sys.exit(0)

# 按状态分组
status_groups = {}
for t in tasks:
    s = t.get('status', 'unknown')
    if s not in status_groups:
        status_groups[s] = []
    status_groups[s].append(t)

# 状态图标
status_icons = {
    'ready': '📋',
    'running': '🔄',
    'completed': '✅',
    'blocked': '🚫',
    'scheduled': '⏰',
    'triage': '🔍',
    'archived': '📦'
}

status_names = {
    'ready': '待执行',
    'running': '执行中',
    'completed': '已完成',
    'blocked': '已阻塞',
    'scheduled': '已计划',
    'triage': '待分类',
    'archived': '已归档'
}

# 统计
total = len(tasks)
completed = len(status_groups.get('completed', []))
running = len(status_groups.get('running', []))
ready = len(status_groups.get('ready', []))
blocked = len(status_groups.get('blocked', []))

if total > 0:
    progress = int(completed / total * 100)
    bar_len = 20
    filled = int(bar_len * completed / total) if total > 0 else 0
    bar = '█' * filled + '░' * (bar_len - filled)
    print(f'  进度: [{bar}] {progress}% ({completed}/{total})')
    print()

# 按状态输出
for status in ['running', 'ready', 'blocked', 'scheduled', 'triage', 'completed']:
    group = status_groups.get(status, [])
    if not group:
        continue

    icon = status_icons.get(status, '❓')
    name = status_names.get(status, status)
    print(f'  {icon} {name} ({len(group)})')
    print(f'  ─────────────────────────')

    for t in group:
        tid = t.get('id', '?')[:8]
        title = t.get('title', '无标题')
        assignee = t.get('assignee', '未分配')
        priority = t.get('priority', 99)

        # 优先级图标
        if priority == 1:
            pri = '🔴'
        elif priority == 2:
            pri = '🟡'
        else:
            pri = '⚪'

        print(f'  {pri} [{tid}] {title}')
        print(f'     └─ {assignee}')
    print()
" 2>/dev/null
}

# ============================================================
# 入口
# ============================================================
case "${1:-}" in
    add|a)
        shift
        cmd_add "$@"
        ;;
    run|r)
        cmd_run
        ;;
    status|s)
        cmd_status
        ;;
    dashboard|dash|d)
        cmd_dashboard
        ;;
    help|--help|-h|"")
        usage
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        usage
        exit 1
        ;;
esac
