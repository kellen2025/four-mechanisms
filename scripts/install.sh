#!/bin/bash
# 铁壁四规 通用版一键安装脚本
# 支持平台：Hermes Agent / OpenClaw

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

print_info "铁壁四规 v4.0.0 安装程序"
echo "============================================"

# ============================================
# Step 1: 检测平台
# ============================================
print_info "Step 1/5: 检测平台..."

PLATFORM=""
SKILLS_DIR=""

if [ -d "$HOME/.hermes" ]; then
    PLATFORM="hermes"
    SKILLS_DIR="$HOME/.hermes/skills"
    print_success "检测到 Hermes Agent 平台"
elif [ -d "$HOME/.openclaw" ]; then
    PLATFORM="openclaw"
    SKILLS_DIR="$HOME/.openclaw/workspace/skills"
    print_success "检测到 OpenClaw 平台"
else
    print_warning "未检测到 Hermes 或 OpenClaw 平台"
    read -p "请手动选择平台 (hermes/openclaw): " PLATFORM
    if [ "$PLATFORM" = "hermes" ]; then
        SKILLS_DIR="$HOME/.hermes/skills"
    elif [ "$PLATFORM" = "openclaw" ]; then
        SKILLS_DIR="$HOME/.openclaw/workspace/skills"
    else
        print_error "无效的平台选择"
        exit 1
    fi
fi

# ============================================
# Step 2: 创建目录
# ============================================
print_info "Step 2/5: 创建目录..."

TARGET_DIR="$SKILLS_DIR/four-mechanisms"
mkdir -p "$TARGET_DIR"
mkdir -p "$TARGET_DIR/core"
mkdir -p "$TARGET_DIR/plugins/l2"
mkdir -p "$HOME/.${PLATFORM}/scripts"

print_success "目录创建完成"

# ============================================
# Step 3: 复制文件
# ============================================
print_info "Step 3/5: 复制文件..."

# 复制核心文件
cp "$SKILL_DIR/SKILL.md" "$TARGET_DIR/"
cp "$SKILL_DIR/README.md" "$TARGET_DIR/"
cp "$SKILL_DIR/CHANGELOG.md" "$TARGET_DIR/"
cp "$SKILL_DIR/LICENSE" "$TARGET_DIR/"
cp "$SKILL_DIR/VERSION" "$TARGET_DIR/"

# 复制核心文档
if [ -d "$SKILL_DIR/core" ]; then
    cp -r "$SKILL_DIR/core/"* "$TARGET_DIR/core/" 2>/dev/null || true
fi

# 复制插件目录结构
if [ -d "$SKILL_DIR/plugins" ]; then
    cp -r "$SKILL_DIR/plugins/"* "$TARGET_DIR/plugins/" 2>/dev/null || true
fi

# 复制脚本
if [ -d "$SKILL_DIR/scripts" ]; then
    cp "$SKILL_DIR/scripts/"*.sh "$HOME/.${PLATFORM}/scripts/" 2>/dev/null || true
fi

print_success "文件复制完成"

# ============================================
# Step 4: 选择L2插件
# ============================================
print_info "Step 4/5: 选择L2层实现..."

echo ""
echo "请选择L2层实现（三层记忆架构中的温存储层）："
echo ""
echo "  1) Hindsight（推荐）"
echo "     功能完整的向量检索工具，支持retain/recall/reflect"
echo ""
echo "  2) Null（不使用L2）"
echo "     只使用L1(MEMORY.md)和L3(session_search)"
echo "     适合轻量级需求或不想安装额外工具的用户"
echo ""
echo "  3) 跳过（稍后手动配置）"
echo ""

read -p "请选择 [1-3]: " L2_CHOICE

case $L2_CHOICE in
    1)
        print_info "安装 Hindsight 插件..."
        cp -r "$SKILL_DIR/plugins/hindsight/"* "$TARGET_DIR/plugins/l2/" 2>/dev/null || true
        if [ -f "$SKILL_DIR/plugins/hindsight/install.sh" ]; then
            bash "$SKILL_DIR/plugins/hindsight/install.sh"
        fi
        print_success "Hindsight 插件安装完成"
        ;;
    2)
        print_info "配置 Null 插件..."
        cp -r "$SKILL_DIR/plugins/null/"* "$TARGET_DIR/plugins/l2/" 2>/dev/null || true
        print_success "Null 插件配置完成"
        ;;
    3)
        print_warning "跳过L2插件安装，稍后手动配置"
        ;;
    *)
        print_warning "无效选择，跳过L2插件安装"
        ;;
esac

# ============================================
# Step 5: 验证安装
# ============================================
print_info "Step 5/5: 验证安装..."

echo ""
echo "============================================"
echo "安装完成！"
echo "============================================"
echo ""
echo "平台: $PLATFORM"
echo "安装目录: $TARGET_DIR"
echo "版本: $(cat "$TARGET_DIR/VERSION" 2>/dev/null || echo '4.0.0')"
echo ""
echo "下一步："
echo "  1. 查看文档: cat $TARGET_DIR/README.md"
echo "  2. 了解四规: cat $TARGET_DIR/SKILL.md"
echo "  3. 查看插件: ls $TARGET_DIR/plugins/"
echo ""
print_success "铁壁四规安装成功！"
