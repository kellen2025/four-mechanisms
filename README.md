# 铁壁四规 v4.0.0

> 四道铁壁，缺一不可。违反任何机制的产出无效。

## 概述

铁壁四规是一套AI Agent管理系统，包含四大核心机制：

1. **马诺防线** — 代码质量四步验证
2. **图书馆** — 科学文档管理（5分类体系）
3. **历史书** — 三层Memory架构（L1热缓存/L2温存储/L3冷存储）
4. **工蚁** — 多Agent协作调度

## 安装

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/kellen2025/four-mechanisms/main/install.sh | bash
```

### 手动安装

```bash
git clone https://github.com/kellen2025/four-mechanisms.git
cd four-mechanisms
bash install.sh
```

## 平台支持

| 平台 | 状态 |
|------|------|
| Hermes Agent | ✅ 支持 |
| OpenClaw | ✅ 支持 |

## 文档

- [SKILL.md](skill/SKILL.md) — 完整技能文档
- [references/](skill/references/) — 参考文档目录

## 版本管理

- **本地版本** (v3.6.0) — 个人定制版，含18个版本pitfalls积累
- **通用版** (v4.0.0) — 面向所有用户，结构更规范+插件化架构

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request。

---

**作者**: Kellan.Li  
**仓库**: [kellen2025/four-mechanisms](https://github.com/kellen2025/four-mechanisms)
