#!/bin/bash
# Hindsight集成健康检查脚本
# 用法: bash hindsight_health_check.sh
# 检查所有Hindsight组件状态，输出诊断报告

echo "══════════════════════════════════════════════"
echo "  Hindsight 健康检查"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "══════════════════════════════════════════════"

ISSUES=0

# 1. llama.cpp后端
echo ""
echo "① llama.cpp后端 (端口8080)"
if curl -s http://localhost:8080/v1/models >/dev/null 2>&1; then
    MODEL=$(curl -s http://localhost:8080/v1/models | python3 -c "import sys,json; print(json.load(sys.stdin)['models'][0]['name'])" 2>/dev/null)
    echo "   ✅ 运行中 — 模型: $MODEL"
else
    echo "   ❌ 未响应"
    ISSUES=$((ISSUES+1))
fi

# 2. PostgreSQL
echo ""
echo "② PostgreSQL (端口5434)"
if ss -tlnp 2>/dev/null | grep -q ':5434'; then
    echo "   ✅ 运行中"
else
    echo "   ❌ 未监听"
    ISSUES=$((ISSUES+1))
fi

# 3. Hindsight daemon
echo ""
echo "③ Hindsight daemon (端口9177)"
DAEMON_PID=$(pgrep -f "hindsight-api.*daemon" 2>/dev/null | head -1)
if [ -n "$DAEMON_PID" ]; then
    if ss -tlnp 2>/dev/null | grep -q ':9177'; then
        echo "   ✅ 运行中 — PID: $DAEMON_PID"
    else
        echo "   ⚠️ 进程存在(PID:$DAEMON_PID)但端口9177未监听"
        ISSUES=$((ISSUES+1))
    fi
else
    echo "   ❌ 未运行"
    ISSUES=$((ISSUES+1))
fi

# 4. HF模型缓存
echo ""
echo "④ HuggingFace模型"
BGE_OK=false
MINILM_OK=false
[ -d ~/.cache/huggingface/hub/models--BAAI--bge-small-en-v1.5 ] && BGE_OK=true
[ -d ~/.cache/huggingface/hub/models--cross-encoder--ms-marco-MiniLM-L-6-v2 ] && MINILM_OK=true

if $BGE_OK && $MINILM_OK; then
    echo "   ✅ bge-small-en-v1.5 已下载"
    echo "   ✅ ms-marco-MiniLM-L-6-v2 已下载"
else
    $BGE_OK || { echo "   ❌ bge-small-en-v1.5 未下载"; ISSUES=$((ISSUES+1)); }
    $MINILM_OK || { echo "   ❌ ms-marco-MiniLM-L-6-v2 未下载"; ISSUES=$((ISSUES+1)); }
fi

# 5. 环境变量
echo ""
echo "⑤ 环境变量"
HERMES_HF=$(grep 'HF_ENDPOINT' ~/.hermes/.env 2>/dev/null | head -1)
DAEMON_HF=$(grep 'HF_ENDPOINT' ~/.env 2>/dev/null | head -1)
MODE_VAL=$(grep 'HINDSIGHT_MODE' ~/.hermes/.env 2>/dev/null | head -1)

if echo "$HERMES_HF" | grep -q 'hf-mirror.com'; then
    echo "   ✅ ~/.hermes/.env: $HERMES_HF"
else
    echo "   ⚠️ ~/.hermes/.env: HF_ENDPOINT未设置或非镜像"
fi

if echo "$DAEMON_HF" | grep -q 'hf-mirror.com'; then
    echo "   ✅ ~/.env (daemon CWD): $DAEMON_HF"
else
    echo "   ❌ ~/.env: HF_ENDPOINT未设置（daemon将无法下载模型）"
    ISSUES=$((ISSUES+1))
fi

if echo "$MODE_VAL" | grep -q 'local_embedded'; then
    echo "   ✅ $MODE_VAL"
else
    echo "   ⚠️ $MODE_VAL（应为local_embedded）"
fi

# 6. 最近错误
echo ""
echo "⑥ 最近错误日志"
if [ -f ~/.hindsight/profiles/hermes.log ]; then
    ERRORS=$(grep -c -i "error\|fail\|exception" ~/.hindsight/profiles/hermes.log 2>/dev/null)
    LAST_ERR=$(grep -i "error\|fail" ~/.hindsight/profiles/hermes.log 2>/dev/null | tail -1)
    echo "   错误总数: $ERRORS"
    if [ -n "$LAST_ERR" ]; then
        echo "   最近: $(echo "$LAST_ERR" | cut -c1-100)"
    fi
else
    echo "   无日志文件"
fi

# 汇总
echo ""
echo "══════════════════════════════════════════════"
if [ $ISSUES -eq 0 ]; then
    echo "  结论: 全部正常 ✅"
else
    echo "  结论: 发现 $ISSUES 个问题 ⚠️"
fi
echo "══════════════════════════════════════════════"
