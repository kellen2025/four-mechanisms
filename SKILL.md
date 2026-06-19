---
name: four-mechanisms
version: 4.0.0
description: "铁壁四规：历史书(三层记忆)、工蚁(多Agent协作)、马诺防线(代码质量)、图书馆(文档管理)。所有Agent必须遵守。"
category: devops
author: community
license: MIT
platforms: [hermes, openclaw]
tags: [quality, memory, collaboration, documentation]
---

# 铁壁四规 v4.0.0

> 四道铁壁，缺一不可。违反任何机制的产出无效。

---

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                    铁壁四规                          │
├─────────────┬─────────────┬─────────────┬───────────┤
│  马诺防线   │   图书馆    │   历史书    │   工蚁    │
│  代码质量   │  文档管理   │  三层记忆   │ 多Agent   │
│  四步验证   │  5分类体系  │  L1/L2/L3   │  协作调度  │
└─────────────┴─────────────┴─────────────┴───────────┘
```

---

## 铁壁一：马诺防线 (Mano Defense Line)

**四步验证流程**：代码质量关 → 逻辑测试关 → 安全扫描关 → 用户验证

详见 `core/mano-defense.md`

---

## 铁壁二：图书馆 (Tushuguan)

**5分类体系**：机制 / 方案 / 项目 / 会议 / 备份

详见 `core/tushuguan.md`

---

## 铁壁三：历史书 (History Book)

**三层记忆架构**：
- L1 热缓存：MEMORY.md（每轮自动注入）
- L2 温存储：可插拔工具层（按需检索）
- L3 冷存储：session_search（全自动存储）

详见 `core/history-book.md`

**L2插件选择**：
- Hindsight：推荐，功能完整
- Null：不使用L2层
- 自定义：参考 `plugins/l2-interface.md`

---

## 铁壁四：工蚁 (Worker Ant)

**多Agent协作调度**：
- 任务分配与负载均衡
- 进度追踪与状态同步
- 超时应对三级升级

详见 `core/worker-ant.md`

---

## 安装

```bash
bash scripts/install.sh
```

## 文档

- 用户指南：`README.md`
- 插件开发：`plugins/README.md`
- 常见问题：`references/faq.md`
- 变更日志：`CHANGELOG.md`
