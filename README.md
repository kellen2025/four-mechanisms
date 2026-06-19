# 铁壁四规 - 通用版

> AI Agent的四道铁壁，适用于所有Hermes/OpenClaw用户

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Hermes](https://img.shields.io/badge/Platform-Hermes-blue.svg)](https://hermes-agent.nousresearch.com)
[![Platform: OpenClaw](https://img.shields.io/badge/Platform-OpenClaw-green.svg)](https://openclaw.ai)
[![Version: 4.0.0](https://img.shields.io/badge/Version-4.0.0-brightgreen.svg)](https://github.com/kellen2025/four-mechanisms)

---

## 🎯 这个Skill适合谁？

### 最佳效果场景

| 场景 | 为什么适合 |
|------|-----------|
| **独立开发者/一人公司(OPC)** | 一个人+AI团队，四规自动保障质量/文档/记忆/协作 |
| **多Agent协作项目** | 2-5个Agent协同工作，工蚁规范自动调度 |
| **长期迭代产品** | 持续开发的SaaS/App，历史书记住所有决策 |
| **代码密集型项目** | 大量代码编写，马诺防线保证质量 |

### 不太适合的场景

- 一次性脚本/临时任务（不需要文档和记忆）
- 纯运维部署（不涉及代码编写）
- 1-2天能完成的项目（四规可能过重）
- 不用Agent的纯手动开发

### 快速决策

```
你在用AI Agent吗？
├─ 否 → 不需要
└─ 是 → 项目需要迭代吗？
         ├─ 否 → 可能不需要
         └─ 是 → 推荐使用
```

---

## 🚀 快速开始

### 一键安装

```bash
# 方式1：从GitHub直接安装
bash <(curl -s https://raw.githubusercontent.com/kellen2025/four-mechanisms/main/scripts/install.sh)

# 方式2：下载后安装
git clone https://github.com/kellen2025/four-mechanisms.git
cd four-mechanisms
bash scripts/install.sh
```

### 安装流程

安装脚本会自动：
1. ✅ 检测平台（Hermes/OpenClaw）
2. ✅ 复制核心文件
3. ✅ 让你选择L2层插件
4. ✅ 验证安装结果

---

## 📦 四规介绍

### 铁壁一：马诺防线 🔐
**代码质量管理规范**

四步验证流程确保代码质量：
```
代码质量关(ruff/dart analyze) → 逻辑测试关(pytest/flutter test)
→ 安全扫描关(pre-commit) → 用户验证
```

**适用场景**：所有代码编写（Flutter/Dart/Python）

### 铁壁二：图书馆 📚
**文档管理规范**

5分类体系让文档井然有序：
| 类别 | 特征 | 例子 |
|------|------|------|
| 机制/ | 框架级操作流程 | 马诺防线机制 |
| 方案/ | 管理设计方案 | 多Agent方案 |
| 项目/ | 对外产出 | 育儿游戏分析 |
| 会议/ | 会议纪要 | 启动会纪要 |
| 备份/ | 历史备份 | memory_backup |

### 铁壁三：历史书 📖
**三层记忆架构**

按信息"热度"分层存储：
- **L1 热缓存**：MEMORY.md — 每轮自动注入，零延迟
- **L2 温存储**：可插拔工具层 — 按需检索，~200ms
- **L3 冷存储**：session_search — 全自动存储，按需检索

**L2插件选择**：
| 插件 | 说明 | 适用场景 |
|------|------|----------|
| Hindsight | 功能完整 | 推荐使用 |
| Null | 不使用L2 | 轻量级需求 |
| 自定义 | 按需扩展 | 特殊需求 |

### 铁壁四：工蚁 🐜
**多Agent协作规范**

任务分配、进度追踪、超时应对：
- 任务分配与负载均衡
- 进度追踪与状态同步
- 超时三级升级机制

---

## ⚠️ 使用限制

### 环境要求

| 系统 | 支持状态 | 说明 |
|------|----------|------|
| Linux | ✅ 完全支持 | 推荐 |
| macOS | ✅ 完全支持 | 推荐 |
| Windows | ⚠️ 需额外步骤 | 见下方说明 |

### Windows使用方式

| 方式 | 复杂度 | 说明 |
|------|--------|------|
| **WSL2** | 简单 | 安装WSL2后与Linux完全一致 |
| **Git Bash** | 简单 | Windows自带，支持bash脚本 |
| **手动安装** | 中等 | 不走脚本，直接复制文件 |

### 已知限制

| 限制 | 说明 | 解决方案 |
|------|------|----------|
| 国内安装Hindsight | 需要下载模型 | 设置 `HF_ENDPOINT=https://hf-mirror.com` |
| 首次加载慢 | Hindsight需加载模型 | 约10-30秒，后续正常 |

---

## 🔧 配置

### 选择L2插件

安装时会让你选择L2层实现：

```bash
# 1. Hindsight（推荐）
# 功能完整的向量检索工具
bash plugins/hindsight/install.sh

# 2. Null（不使用L2）
# 只使用L1和L3
cp -r plugins/null/ plugins/l2/

# 3. 自定义插件
# 参考 plugins/_template/ 创建
```

### 配置文件

复制并编辑配置文件：

```bash
cp config.example.yaml config.yaml
# 编辑 config.yaml 按需配置
```

---

## 📖 文档

| 文档 | 说明 |
|------|------|
| [README.md](README.md) | 本文档 |
| [SKILL.md](SKILL.md) | 核心规范 |
| [CHANGELOG.md](CHANGELOG.md) | 变更日志 |
| [references/use-cases.md](references/use-cases.md) | 适用场景详解 |
| [core/](core/) | 四规核心文档 |
| [plugins/](plugins/) | L2插件目录 |
| [examples/](examples/) | 使用示例 |

---

## 🤝 贡献

欢迎贡献！请参考：
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/xxx`)
3. 提交更改 (`git commit -m 'Add xxx'`)
4. 推送到分支 (`git push origin feature/xxx`)
5. 创建 Pull Request

---

## 📄 许可证

MIT License

---

## 🔗 相关链接

- [Hermes Agent](https://hermes-agent.nousresearch.com)
- [OpenClaw](https://openclaw.ai)
- [SkillHub](https://skillhub.cn)
