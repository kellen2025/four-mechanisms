#!/bin/bash
# 铁壁四规 v4.0.0 安装脚本
# 自动检测 Hermes 或 OpenClaw 并选择正确路径

set -e

echo "=== 铁壁四规 v4.0.0 安装脚本 ==="
echo ""

# 检测平台
if [ -d "$HOME/.hermes" ]; then
    PLATFORM="hermes"
    SKILLS_DIR="$HOME/.hermes/skills"
    TUSHUGUAN_DIR="$HOME/.hermes/tushuguan"
    SCRIPTS_DIR="$HOME/.hermes/scripts"
    echo "检测到 Hermes 平台"
elif [ -d "$HOME/.openclaw" ]; then
    PLATFORM="openclaw"
    SKILLS_DIR="$HOME/.openclaw/workspace/skills"
    TUSHUGUAN_DIR="$HOME/.openclaw/tushuguan/07-规章制度"
    SCRIPTS_DIR="$HOME/.openclaw/workspace/scripts"
    echo "检测到 OpenClaw 平台"
else
    echo "错误: 未检测到 Hermes 或 OpenClaw"
    exit 1
fi

echo "平台: $PLATFORM"
echo "Skills目录: $SKILLS_DIR"
echo "图书馆目录: $TUSHUGUAN_DIR"
echo ""

# Step 1: 创建目录
echo "Step 1: 创建目录..."
mkdir -p "$SKILLS_DIR/four-mechanisms/references"
mkdir -p "$SKILLS_DIR/four-mechanisms/scripts"
mkdir -p "$TUSHUGUAN_DIR/机制/铁壁四规"
mkdir -p "$TUSHUGUAN_DIR/方案"
mkdir -p "$TUSHUGUAN_DIR/项目"
mkdir -p "$TUSHUGUAN_DIR/会议"
mkdir -p "$TUSHUGUAN_DIR/备份"
mkdir -p "$TUSHUGUAN_DIR/归档"

# Step 2: 复制Skill文件
echo "Step 2: 复制Skill文件..."
cp skill/SKILL.md "$SKILLS_DIR/four-mechanisms/"
cp skill/references/*.md "$SKILLS_DIR/four-mechanisms/references/"
cp skill/scripts/* "$SKILLS_DIR/four-mechanisms/scripts/" 2>/dev/null || true

# Step 3: 复制机制文档
echo "Step 3: 复制机制文档..."
# 这里需要从skill中提取机制文档，或者单独提供

# Step 4: 创建INDEX.md
echo "Step 4: 创建INDEX.md..."
if [ ! -f "$TUSHUGUAN_DIR/INDEX.md" ]; then
    cat > "$TUSHUGUAN_DIR/INDEX.md" << 'EOF'
# 图书馆索引

最后同步: 2026-06-20
分类体系: 机制/ 方案/ 项目/ 会议/ 备份 + 归档/

---

## 🔧 机制/ — 铁壁四规与框架流程（稳定不常改）

### 铁壁四规/
| 文件 | 版本 | 状态 |
|------|------|------|
| 待添加 | - | active |

---

## 📐 方案/ — 管理设计方案（按日期归档）

---

## 📂 项目/ — 对外项目产出

---

## 📝 会议/ — 会议纪要

---

## 💾 备份/ — Memory压缩备份

---

## 🗄️ 归档/ — 历史完结内容
EOF
fi

# Step 5: 验证安装
echo "Step 5: 验证安装..."
echo "Skills文件:"
ls -la "$SKILLS_DIR/four-mechanisms/"
echo ""
echo "图书馆目录:"
ls -la "$TUSHUGUAN_DIR/"
echo ""

echo "=== 安装完成 ==="
echo "请执行以下命令验证:"
echo "  skill_view(name='four-mechanisms')"
