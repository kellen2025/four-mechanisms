# 快速开始

> 5分钟内完成铁壁四规安装

---

## 前置条件

- bash环境
- Hermes Agent 或 OpenClaw 已安装

---

## 安装步骤

### 1. 克隆仓库

```bash
git clone https://github.com/kellen2025/four-mechanisms.git
cd four-mechanisms
```

### 2. 运行安装脚本

```bash
bash scripts/install.sh
```

### 3. 选择L2插件

安装过程中会让你选择L2层实现：
- 输入 `1`：安装Hindsight（推荐）
- 输入 `2`：使用Null（不使用L2）
- 输入 `3`：跳过，稍后配置

### 4. 验证安装

```bash
# 查看安装结果
ls ~/.hermes/skills/four-mechanisms/

# 查看文档
cat ~/.hermes/skills/four-mechanisms/README.md
```

---

## 下一步

- 阅读 `SKILL.md` 了解四规详情
- 查看 `core/` 目录了解各规文档
- 配置 `config.yaml` 按需调整

---

## 遇到问题？

查看 [常见问题](../references/faq.md)
