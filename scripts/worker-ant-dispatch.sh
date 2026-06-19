#!/bin/bash
# 工蚁v2.0-alpha：智能任务路由器
# 自动分析任务类型，分配给合适的Agent

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Agent能力表
declare -A AGENT_PROFILES=(
    ["pm"]="mibao-kills-pm"
    ["coder"]="mibao-kellen-coder"
    ["ops"]="mibao-duobao-om"
    ["algorithm"]="harry"
)

declare -A AGENT_NAMES=(
    ["pm"]="毙杀(产品经理)"
    ["coder"]="码仔(编码工程师)"
    ["ops"]="多宝(运营负责人)"
    ["algorithm"]="Harry(算法专家)"
)

# 关键词映射到Agent类型
match_agent() {
    local input="$1"
    local input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    
    # 产品类关键词
    if echo "$input_lower" | grep -qE "设计|ui|界面|页面|原型|交互|需求|prd|功能|竞品|分析|调研|市场"; then
        echo "pm"
        return
    fi
    
    # 开发类关键词
    if echo "$input_lower" | grep -qE "编码|开发|写代码|实现|功能|bug|修复|问题|错误|异常|审查|review|代码质量|优化|api|接口|后端|服务端|数据库"; then
        echo "coder"
        return
    fi
    
    # 运营类关键词
    if echo "$input_lower" | grep -qE "运营|内容|文案|推广|活动|增长|获客|留存|转化|数据|报表|指标"; then
        echo "ops"
        return
    fi
    
    # 算法类关键词
    if echo "$input_lower" | grep -qE "算法|模型|训练|预测|ai|游戏|机制|玩法|数值"; then
        echo "algorithm"
        return
    fi
    
    # 默认：PM
    echo "pm"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "用法: worker-ant-dispatch <任务描述>"
        echo ""
        echo "示例:"
        echo "  worker-ant-dispatch '帮我设计一个登录页面'"
        echo "  worker-ant-dispatch '修复登录Bug'"
        echo "  worker-ant-dispatch '写一个API接口'"
        echo "  worker-ant-dispatch '分析用户数据'"
        exit 1
    fi
    
    local task="$*"
    
    echo -e "${BLUE}🐜 工蚁智能调度${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "任务: ${YELLOW}$task${NC}"
    echo ""
    
    # 匹配Agent
    local agent_type=$(match_agent "$task")
    local agent_profile="${AGENT_PROFILES[$agent_type]}"
    local agent_name="${AGENT_NAMES[$agent_type]}"
    
    echo -e "匹配结果:"
    echo -e "  Agent: ${GREEN}$agent_name${NC}"
    echo -e "  Profile: $agent_profile"
    echo ""
    
    # 调用Agent
    echo -e "${BLUE}正在调用 $agent_name...${NC}"
    echo ""
    
    hermes chat --profile "$agent_profile" -Q "$task"
}

main "$@"
