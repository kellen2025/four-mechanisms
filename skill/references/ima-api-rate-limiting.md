# IMA API 限流机制参考

> 基于 ima-skills v1.1.7 文档和实际测试（2026-06-16）

## 两种限制类型

### 1. 每日配额限制（Daily Quota）
- **限制**：约 1000-2000 次/天（具体数值未文档化）
- **错误信息**：`"资料获取次数已达上限，请明天再尝试"`
- **重置时间**：次日自动重置
- **实测数据**：19个知识库 × 1页 × 50条/页 ≈ 950次API调用后触发

### 2. 短期频控（Rate Limiting）
- **错误码**：`110021`
- **含义**：短时间内请求过快
- **应对策略**：请求间隔 `sleep 1`（1秒）
- **重置时间**：等待几秒后可重试
- **与日配额区别**：降低频率后可重试，不消耗日配额

## 应对策略

```bash
# 翻页之间加 sleep 1，避免触发短期频控
sleep 1

# 批量获取策略
# 1. 每次请求 limit=50（最大值），减少翻页次数
# 2. 优先级排序：先获取最重要的库
# 3. 分日执行：大量任务拆分到多天
# 4. 缓存结果：已获取的列表缓存到本地
```

## API端点速查

| 功能 | 端点 | 模块 |
|------|------|------|
| 知识库列表 | `openapi/wiki/v1/search_knowledge_base` | knowledge-base |
| 知识库内容 | `openapi/wiki/v1/get_knowledge_list` | knowledge-base |
| 笔记列表 | `openapi/note/v1/list_note` | notes |
| 笔记搜索 | `openapi/note/v1/search_note` | notes |
| 笔记内容 | `openapi/note/v1/get_doc_content` | notes |

## 调用模板

```bash
cd ~/.hermes/skills/autonomous-ai-agents/skills/ima-skills
CLIENT_ID=$(cat ~/.config/ima/client_id)
API_KEY=$(cat ~/.config/ima/api_key)
OPTS="{\"clientId\":\"$CLIENT_ID\",\"apiKey\":\"$API_KEY\"}"

# 知识库列表
node ima_api.cjs "openapi/wiki/v1/search_knowledge_base" \
  '{"query":"","limit":20}' "$OPTS"

# 笔记列表
node ima_api.cjs "openapi/note/v1/list_note" \
  '{"limit":5}' "$OPTS"
```
