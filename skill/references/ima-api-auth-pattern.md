# IMA API 认证与调用模式

> IMA OpenAPI 使用自定义认证头，不是标准 `Authorization: Bearer`。

## 认证头（必须使用）

```
ima-openapi-clientid: <client_id>
ima-openapi-apikey: <api_key>
ima-openapi-ctx: skill_version=1.0
```

**错误用法**（会返回 `clientID or apiKey is empty`）：
```
Authorization: Bearer <api_key>     ← 错误！
X-Api-Key: <api_key>               ← 错误！
```

## 凭证来源

优先级：
1. 环境变量 `IMA_OPENAPI_CLIENTID` / `IMA_OPENAPI_APIKEY`
2. 文件 `~/.config/ima/client_id` / `~/.config/ima/api_key`

## 常用 API 端点

| 端点 | 用途 | 关键参数 |
|------|------|---------|
| `openapi/wiki/v1/get_knowledge_list` | 浏览知识库/文件夹内容 | `knowledge_base_id`, `cursor`, `limit`(1~50), **`folder_id`**(可选) |
| `openapi/wiki/v1/get_knowledge_base` | 获取知识库详情 | `ids`（1-20个） |
| `openapi/wiki/v1/search_knowledge_base` | 搜索知识库 | `query`(必填，空=0结果), `cursor`, `limit`(1~**20**) |
| `openapi/wiki/v1/add_knowledge` | 添加内容到知识库 | `media_type`, `knowledge_base_id` |
| `openapi/wiki/v1/create_media` | 创建媒体（上传前） | `file_name`, `file_size`, `content_type` |
| `openapi/wiki/v1/check_repeated_names` | 检查文件名重复 | `params[].name`, `knowledge_base_id` |
| `openapi/wiki/v1/import_urls` | 添加网页链接 | `urls`(1-10), `knowledge_base_id` |
| `openapi/wiki/v1/get_addable_knowledge_base_list` | 获取可添加的知识库 | `cursor`, `limit` |

## 分页与目录结构

知识库是树形结构：知识库 → 文件夹(media_type=99) → 子文件夹 → 内容条目。
`get_knowledge_list` 默认返回根级条目；传入 `folder_id` 可浏览指定文件夹。

**media_type 枚举**：99=文件夹, 11=笔记(note), 6=微信文章(wechatarticle), 2=其他

cursor-based 分页：
```json
// 第一页（根级）
{"knowledge_base_id": "xxx", "cursor": "", "limit": 50}

// 浏览文件夹内容
{"knowledge_base_id": "xxx", "folder_id": "folder_xxx", "cursor": "", "limit": 50}

// 下一页（使用返回的 next_cursor）
{"knowledge_base_id": "xxx", "cursor": "<next_cursor>", "limit": 50}

// 结束标志：is_end = true
```

⚠️ **search_knowledge_base** 限制：limit 最大 20（不是50）；空 query 返回 0 结果，必须传有意义的关键词。

## 速率限制

⚠️ IMA OpenAPI 日配额约 1000 次/天，但实际 `get_knowledge_list` 在连续翻页多个库时可能提前触发限额。错误信息："资料获取次数已达上限，请明天再尝试"。建议：每扫描完一个库暂停 1-2 秒；遇到限额立即停止并记录 cursor 进度，次日继续。

## Python 调用模板

```python
import json, requests

with open('/home/kellen/.config/ima/client_id') as f:
    client_id = f.read().strip()
with open('/home/kellen/.config/ima/api_key') as f:
    api_key = f.read().strip()

url = "https://ima.qq.com/openapi/wiki/v1/<endpoint>"
headers = {
    "Content-Type": "application/json",
    "ima-openapi-clientid": client_id,
    "ima-openapi-apikey": api_key,
    "ima-openapi-ctx": "skill_version=1.0"
}

# 列出知识库根级内容
data = {"knowledge_base_id": "<kb_id>", "cursor": "", "limit": 50}
# 浏览文件夹内容（加 folder_id）
data = {"knowledge_base_id": "<kb_id>", "folder_id": "<folder_id>", "cursor": "", "limit": 50}

response = requests.post(url, headers=headers, json=data)
result = response.json()
# result["code"] == 0 表示成功
# result["data"]["knowledge_list"] 是内容列表（不是 info_list）
# result["data"]["is_end"] 表示是否最后一页
# result["data"]["next_cursor"] 用于下一页
```

## 常见错误

| 错误码 | 含义 | 原因 |
|--------|------|------|
| 200002 | clientID or apiKey is empty | 认证头名称错误或值为空 |
| 400 | Param Incorrect | 参数格式错误 |
| 400 | invalid knowledge_base_id | folder_id 不能作为 knowledge_base_id 使用（需用知识库ID） |
| 51 | limit out of range | search_knowledge_base 的 limit 必须 ≤20 |
| success+空列表 | 资料获取次数已达上限 | 日配额耗尽，明天再试 |

## 已知知识库 ID（育儿游戏项目）

| 知识库 | ID |
|--------|-----|
| 游戏技术美术 | `xn6QdcLt5s_sHX3bttvkPD3yZmE6oFk0fRzoi9YRJ2w=` |
| 游戏设计知识共享 | `mzMz4zRl9yD_LRosYSta9GGowDNZSPVnQpSnEpDLxEk=` |
| 游戏运营/策划自留地 | `kRlzCTIFQirfxqsAzY0mkEtJwuX_LoLzXCFKxL43RK4=` |
| 游戏数值实验室 | `8DotroweGeWTAZqRX1_UC359_8bj86s773F56jQZ2ak=` |
| 游戏设计与研究（书籍） | `UYegXegaiIiJFwSW7eNe_oqgDglOKvPGRkAY8zA_iXI=` |
| 游戏|设计|理论|实践|行业 | `UM71D83_Qak306ehWxph7uKQj-sdz8TzzlcI7Fmqirw=` |
| unity性能优化 | `UiSvegsjl9_Op9LRonE5fcF3xl7Wiw6O4Xz0BaCKMwI=` |
| 游戏开发大杂烩 | `mJlG3GHGf5-M-V07PGZf-mOCJMD_rGsEFxCH2GFwN9E=` |
| Unity开发知识库 | `9dBXDuov_Ca6HcAherUKnwPhjO-ILNuxuU33jsjF6KE=` |
| 育儿育心·亲子教育馆 | `smYQOW1CTG3dKNbrTN34Ib2H7VvGvza4ACZrjre9-DE=` |
| 犟爸教育知识库 | `YiDAtUFvJxYuzNu-xh9QHD3BrH4zs3KPfsUJWe9ZlaM=` |
| 健说育儿-育儿助手 | `OUiIT53zbIM1AXDGyfuLohqLC7U4pBKPy7B_Ki2IMQQ=` |
| 亲子教育 | `xThiHelUsd7uWEC_JngOIs1DoAEyLcHc4u6p0-9Rdyg=` |
| MBTI性格测试最全知识库 | `3RbzBQhnfoTZZ3vzisbZDmaPM0q_dl2GB6_1eS8bxz0=` |
