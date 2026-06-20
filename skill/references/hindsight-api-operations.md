# Hindsight API 运维速查卡

> 2026-06-19 实测验证，API版本基于hindsight-api。

## 健康检查三步法

```bash
# 1. 端口监听
ss -tlnp | grep 9177

# 2. 进程存活
ps aux | grep hindsight-api | grep -v grep

# 3. HTTP健康检查
curl -s http://localhost:9177/health
# 预期：{"status":"healthy","database":"connected"}
```

## API端点路径

所有端点格式：`/v1/default/banks/{bank_id}/...`

| 功能 | 方法 | 路径 | 说明 |
|------|------|------|------|
| retain | POST | `/v1/default/banks/hermes/memories` | 写入记忆 |
| recall | POST | `/v1/default/banks/hermes/memories/recall` | 检索记忆 |
| reflect | POST | `/v1/default/banks/hermes/reflect` | 反思分析 |
| list | GET | `/v1/default/banks/hermes/memories/list` | 列出记忆 |
| stats | GET | `/v1/default/banks/hermes/stats` | 统计信息 |
| operations | GET | `/v1/default/banks/hermes/operations` | 查看操作记录 |
| health | GET | `/health` | 健康状态 |
| swagger | GET | `/docs` | API文档 |
| openapi | GET | `/openapi.json` | 完整端点列表 |

## Retain 请求格式

```bash
curl -X POST http://localhost:9177/v1/default/banks/hermes/memories \
  -H "Content-Type: application/json" \
  -d '{"items": [{"content": "记忆内容", "context": "上下文", "tags": ["tag1"]}]}' 
```

**关键**：body必须是 `{"items": [...]}` 数组格式，不是直接放content字段。

## Recall 请求格式

```bash
curl -X POST http://localhost:9177/v1/default/banks/hermes/memories/recall \
  -H "Content-Type: application/json" \
  -d '{"query": "搜索关键词", "limit": 5}'
```

## Reflect 请求格式

```bash
curl -X POST http://localhost:9177/v1/default/banks/hermes/reflect \
  -H "Content-Type: application/json" \
  -d '{"query": "要分析的问题"}'
```

## Stats 字段解读

```json
{
  "total_nodes": 46,           // 总记忆条目
  "total_links": 335,          // 条目间关联数
  "total_documents": 4,        // 导入的文档数
  "failed_operations": 24,     // ⚠️ 失败操作数（需关注）
  "pending_consolidation": 2   // 待合并数
}
```

- `failed_operations` 非零：可能有积压任务，检查operations详情
- `total_links / total_nodes > 5`：记忆关联密度健康

## 完整端点列表

通过 `/openapi.json` 可获取当前版本所有可用端点：

```bash
curl -s http://localhost:9177/openapi.json | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(json.dumps(list(d['paths'].keys()), indent=2))"
```

## Pitfall

- retain的body格式是 `{"items": [...]}`，不是 `{"content": "...", "context": "..."}` 直接放顶层
- bank_id固定为 `hermes`（对应Hermes的MEMORY.md）
- 端口9177是默认端口，如被占用需检查config
