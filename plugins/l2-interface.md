# L2层插件接口规范 v1.0

> 定义L2温存储层的标准接口，支持插件化扩展

---

## 接口概述

L2层是三层记忆架构中的温存储层，负责按需检索历史知识。插件必须实现以下接口：

---

## 必须实现的函数

### retain(content, context, tags)

**功能**：写入记忆到L2层

**参数**：
- `content` (string, 必填)：记忆内容
- `context` (string, 可选)：上下文说明
- `tags` (list, 可选)：标签分类

**返回**：
```json
{
  "success": true,
  "id": "memory_id_123"
}
```

**示例**：
```python
retain(
    content="用户纠正：不要使用delegate_task，应该用hermes chat --profile",
    context="技术决策",
    tags=["规则", "子Agent"]
)
```

---

### recall(query, limit)

**功能**：从L2层检索记忆

**参数**：
- `query` (string, 必填)：检索关键词
- `limit` (int, 可选)：返回数量，默认10

**返回**：
```json
{
  "results": [
    {
      "id": "memory_id_123",
      "text": "记忆内容...",
      "score": 0.95,
      "tags": ["规则", "子Agent"]
    }
  ]
}
```

**示例**：
```python
results = recall(query="子Agent调度", limit=5)
for r in results:
    print(f"{r['score']:.2f}: {r['text'][:50]}...")
```

---

### reflect(query)

**功能**：基于L2层进行反思分析

**参数**：
- `query` (string, 必填)：分析问题

**返回**：
```json
{
  "answer": "基于检索到的记忆，..."
}
```

**示例**：
```python
answer = reflect(query="用户对代码质量有什么要求？")
print(answer)
```

---

## 可选实现的函数

### health_check()

**功能**：检查插件状态

**返回**：
```json
{
  "status": "healthy",
  "details": {
    "memories_count": 100,
    "last_sync": "2026-06-19T10:00:00Z"
  }
}
```

---

### stats()

**功能**：获取统计信息

**返回**：
```json
{
  "total_memories": 100,
  "total_links": 500,
  "by_type": {
    "experience": 50,
    "observation": 30,
    "world": 20
  }
}
```

---

## 插件开发模板

参考 `plugins/_template/` 目录创建自定义插件：

```
plugins/my-plugin/
├── PLUGIN.md           # 插件说明
├── plugin.py           # 插件实现
├── config.yaml         # 插件配置
└── install.sh          # 安装脚本（可选）
```

---

## 测试插件

```bash
# 运行插件测试
python -m pytest plugins/my-plugin/test_plugin.py

# 验证接口实现
python plugins/my-plugin/plugin.py --validate
```
