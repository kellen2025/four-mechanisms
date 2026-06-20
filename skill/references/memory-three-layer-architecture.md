# Memory三层架构设计

> 设计日期：2026-06-17 | 状态：生效中
> 完整方案：`~/.hermes/tushuguan/方案/2026-06-17/20260617_Memory三层架构优化方案.md`
> 操作手册：`~/.hermes/tushuguan/机制/铁壁四规/20260617_Memory审计与恢复操作手册.md`

---

## 架构总览

```
L1 热缓存：MEMORY.md/USER.md  → 零延迟，冻结快照，4000字节上限
L2 温存储：Hindsight 知识图谱  → ~200ms，语义检索+反思综合，无限容量
L3 冷存储：session_search      → ~20ms，FTS5全文搜索，自动存储，无限容量
```

## 准入标准（写入决策）

```
每轮都要用？（铁律/偏好/团队/环境） → MEMORY.md
未来可能用但不需每轮看？           → Hindsight
只是临时进度？                     → 不存（session_search自动）
一条命令能查到？                   → 不存（可发现性测试）
```

## MEMORY.md 热数据标准

判断问题：这条信息如果这次会话没注入，会不会导致我犯错？
- 会 → 存 MEMORY.md
- 不会 → 存 Hindsight 或不存

## Hindsight 温数据标准

判断问题：这条信息未来可能用到，但不需要每轮都看到？
- 是 → 存 Hindsight
- 否 → 不存

## 压缩迁移规则

当 MEMORY.md 超80%（3200字节）：
1. 跳过LOCKED条目
2. 逐条检查：移到Hindsight后recall能找到吗？→ 能则迁移
3. 执行 hindsight_retain() → 从MEMORY.md删除
4. 确保降到70%以下

## 风险与恢复

| 风险 | 恢复方式 |
|------|----------|
| MEMORY.md错误 | memory(action='replace') 即时修复 |
| Hindsight脏数据 | SQL删除 或 全量重建 |
| 幻觉写入 | session_search验证原始对话 → 修正记忆 |
| Agent不遵守规则 | 用户纠正 → 更新铁律(LOCKED区域) |

## 审计频率

| 频率 | 内容 |
|------|------|
| 每次会话 | wc -c检查MEMORY.md占用率 |
| 每周 | 条目过时审查 + Hindsight recall质量测试 |
| 每月 | 全量交叉验证(MEMORY + Hindsight + session_search) |

## 降级策略

- daemon挂了 → L1+L3照常，关键信息不丢
- llama.cpp挂了 → L2检索仍可用（嵌入模型独立）
- PostgreSQL挂了 → 同上

---

## 变更记录
| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-06-17 | v1.0 | 初版：三层架构设计、准入标准、压缩规则、风险恢复 |
