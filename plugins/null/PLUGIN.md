# Null 插件

> 不使用L2层，只使用L1和L3

---

## 简介

Null插件是L2层的空实现，适用于：
- 轻量级需求
- 不想安装额外工具
- 只需要基础记忆功能

---

## 使用方式

```bash
cp -r plugins/null/ plugins/l2/
```

或在安装时选择选项2。

---

## 功能说明

使用Null插件时：
- L1 (MEMORY.md)：正常工作
- L2 (Hindsight)：不使用
- L3 (session_search)：正常工作

Agent会自动适配，跳过L2相关操作。

---

## 何时升级到Hindsight

如果你需要：
- 语义检索历史知识
- 跨会话记忆关联
- 知识图谱分析

建议升级到Hindsight插件。
