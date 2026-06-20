---
title: Hermes官方Memory机制分析
created: 2026-06-16
category: 机制
tags: [memory, hermes-official, security, session-search]
status: active
author: 米宝
source: https://hermes-agent.nousresearch.com/docs/user-guide/features/memory
---

# Hermes官方Memory机制分析

> 基于Hermes官方文档的Memory系统完整分析，用于指导铁壁四规MECH-004优化。

---

## 一、核心架构

### 双文件系统

| 文件 | 用途 | 官方字符限制 | 典型条目数 |
|------|------|-------------|------------|
| MEMORY.md | Agent个人笔记：环境事实、惯例、经验 | 2,200字符（~800 tokens） | 8-15条 |
| USER.md | 用户档案：偏好、沟通风格、期望 | 1,375字符（~500 tokens） | 5-10条 |

存储路径：`~/.hermes/memories/`

### 注入方式：冻结快照（Frozen Snapshot）

```
会话开始 → 从磁盘加载 → 注入系统提示 → 会话内永不改变
```

- 设计意图：保持LLM前缀缓存的性能
- 实时性：内存变更立即持久化到磁盘，但**下个会话才生效**
- 工具响应始终显示实时状态

### 系统提示中的显示格式

```
══════════════════════════════════════════════
MEMORY (your personal notes) [67% — 1,474/2,200 chars]
══════════════════════════════════════════════
条目内容
§
条目内容
```

- 头部显示使用百分比和字符数
- 条目用 `§`（section sign）分隔
- 条目可以是多行

---

## 二、管理工具

### memory工具动作

| 动作 | 用途 | 说明 |
|------|------|------|
| add | 添加新条目 | 自动拒绝完全重复的条目 |
| replace | 替换现有条目 | 使用子串匹配（old_text），需唯一匹配 |
| remove | 删除条目 | 使用子串匹配（old_text），需唯一匹配 |

**无read动作** — 内容自动注入系统提示。

### 子串匹配机制

replace和remove使用短唯一子串匹配，不需要完整文本：

```python
# old_text只需是能唯一标识一个条目的子串
memory(action="replace", target="memory",
       old_text="dark mode",
       content="User prefers light mode in VS Code")
```

如果子串匹配多个条目，返回错误要求更精确匹配。

---

## 三、容量管理

### 严格限制，不自动压缩

- **写入超限**：返回错误，不会静默丢弃
- **Agent责任**：需要自行整合/删除条目后再重试
- **替换限制**：replace也受限制，新内容必须更短

### 超限时的错误响应

```json
{
  "success": false,
  "error": "Memory at 2,100/2,200 chars. Adding this entry (250 chars) would exceed the limit.",
  "current_entries": ["..."],
  "usage": "2,100/2,200"
}
```

### 最佳实践

- 80%容量时主动整合条目
- 合并相关条目（如3条"project uses X"合并为1条项目描述）
- 紧凑、信息密集的条目最佳

---

## 四、安全特性

### 自动安全扫描

Memory条目在写入前会被扫描，检测以下威胁模式：

1. **提示注入**：试图修改Agent行为的指令
2. **凭证泄露**：API密钥、令牌、密码等
3. **SSH后门**：未经授权的远程访问配置
4. **隐形Unicode字符**：不可见字符注入

匹配威胁模式的内容会被阻止写入。

### 重复检测

自动拒绝完全相同的条目，返回success + "no duplicate added"消息。

---

## 五、写入审批机制（write_approval）

### 配置选项

```yaml
memory:
  write_approval: false   # false=自由写入（默认） | true=需要审批
```

### 行为差异

| write_approval | 行为 |
|----------------|------|
| false（默认） | 自由写入，包括后台自改进审查 |
| true | 所有写入需要审批 |

### 审批模式详情

- **CLI交互式**：内联提示审批
- **消息平台/脚本/后台**：暂存到 `/memory pending`
- **后台自改进审查**：也受审批门控

### 审批命令

```
/memory pending             # 列出暂存的写入
/memory approve <id>        # 批准一个（或'all'）
/memory reject <id>         # 拒绝一个（或'all'）
/memory approval on         # 开启审批门控
```

---

## 六、Memory vs Session Search

### 分工原则

| 特性 | 持久记忆 | 会话搜索 |
|------|----------|----------|
| 容量 | ~1,300 tokens总计 | 无限（所有会话） |
| 速度 | 即时（系统提示中） | ~20ms FTS5查询 |
| 成本 | 每个会话都有token成本 | 免费——无LLM调用 |
| 用途 | 关键事实始终可用 | 查找特定过去对话 |
| 管理 | Agent手动维护 | 自动存储所有会话 |
| Token成本 | 固定每会话（~1,300 tokens） | 按需（搜索时才消耗） |

### 官方设计哲学

> **"小记忆+大搜索"**
> - 关键事实放Memory（始终在上下文中）
> - 历史对话用session_search（按需查询）
> - 不要把Memory当数据库用

### 会话搜索能力

- 所有CLI和消息平台会话存储在SQLite（`~/.hermes/state.db`）+ FTS5全文搜索
- 搜索查询返回实际消息——无LLM摘要，无截断
- 可以找到几周前讨论的内容，即使不在活跃记忆中
- 支持在任何会话中向前/向后滚动

---

## 七、外部记忆提供商

Hermes支持8个外部记忆插件（与内置记忆并存，不替代）。**一次只能激活一个外部提供商**。

### 免费 vs 付费对比

| 提供商 | 存储位置 | 费用 | API Key需求 | 依赖 |
|--------|----------|------|-------------|------|
| **Holographic** | 本地SQLite | **免费** | 不需要 | 无（SQLite总是可用） |
| **OpenViking** | 自托管 | **免费** | 不需要 | openviking + 运行服务器 |
| **ByteRover** | 本地（默认） | **免费** | 不需要 | ByteRover CLI |
| **Hindsight** | 本地PostgreSQL | **免费** | 需要LLM API key | hindsight-client + LLM |
| Honcho | 云端 | 付费（自托管免费） | 需要（云端） | honcho-ai |
| Mem0 | 云端 | 付费 | 需要 | mem0ai |
| RetainDB | 云端 | $20/月 | 需要 | requests |
| Supermemory | 云端 | 付费 | 需要 | supermemory |

### 功能对比（软件开发视角）

| 提供商 | 知识图谱 | 代数查询 | 信任评分 | 反思综合 | 自动保留 | 最佳场景 |
|--------|----------|----------|----------|----------|----------|----------|
| Holographic | ❌ | ✅ HRR | ✅ | ❌ | ❌ | 个人开发、小型项目 |
| Hindsight | ✅ | ❌ | ❌ | ✅ | ✅ | 团队协作、复杂架构 |
| OpenViking | ✅ 文件系统 | ❌ | ❌ | ❌ | ✅ | 结构化知识管理 |
| ByteRover | ❌ | ❌ | ❌ | ❌ | ✅ | CLI友好、便携记忆 |

### 互斥性

```
"Only one external provider can be active at a time — 
the built-in memory is always active alongside it."
```

- ❌ 不能同时激活两个外部提供商
- ✅ 可以同时使用任一外部提供商 + 内置记忆
- ✅ 可以在不同会话中使用不同提供商

### 配置命令

```bash
hermes memory setup      # 选择提供商并配置
hermes memory status     # 检查当前状态
hermes memory off        # 禁用外部提供商
```

---

## 八、配置参考

```yaml
# ~/.hermes/config.yaml
memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200      # 官方默认
  user_char_limit: 1375        # 官方默认
  provider: ''                 # 外部提供商
  write_approval: false        # 审批门控
  nudge_interval: 10           # 提醒间隔
  flush_min_turns: 6           # 最小刷新轮次
```

---

## 九、与铁壁四规的差异

| 维度 | Hermes官方 | 铁壁四规MECH-004 | 建议 |
|------|------------|------------------|------|
| 容量 | 2200/1375字符 | 4000/2000字节 | 可保留覆盖，但需明确记录 |
| 压缩 | 不自动压缩 | 80%预警+Cron自动化 | 保留自动化，增加多维度评分 |
| 安全 | 内置威胁检测 | 依赖官方 | 验证启用状态，增加审计日志 |
| 审批 | 可选write_approval | 未实现 | 分阶段引入 |
| 外部集成 | 8个提供商 | 未使用 | 评估Honcho/Mem0 |
| 搜索整合 | session_search互补 | 未整合 | 明确分工，迁移历史信息 |

---

## 十、软件开发场景推荐

### 决策树

```
需要知识图谱和实体关系？
├─ 是 → Hindsight（需LLM API key）
│       ├─ 有免费LLM？ → 使用本地模式（Groq免费tier或本地llama.cpp）
│       └─ 无LLM？ → 考虑Holographic
└─ 否 → 需要代数查询和信任评分？
        ├─ 是 → Holographic（零成本）
        └─ 否 → 都可以，选择更简单的Holographic
```

### 场景匹配

| 场景 | 推荐 | 理由 |
|------|------|------|
| 个人游戏开发（<10k行） | Holographic | 零成本，代码事实管理足够 |
| 中型软件项目（3-5人） | Hindsight本地 | 知识图谱管理模块依赖 |
| 大型游戏引擎（>100k行） | Hindsight云端 | 复杂架构需要深度分析 |

---

## 十一、本地LLM集成（Hindsight）

### 架构分离

```
Hindsight本地模式 = 本地数据存储 + 外部LLM推理
                  ↓
        数据：嵌入式PostgreSQL（完全本地）
        AI：需要LLM服务（云端或本地）
```

### llama.cpp集成测试

已验证本地llama.cpp服务可满足Hindsight需求：

| 测试项 | 结果 | 详情 |
|--------|------|------|
| 实体提取 | ✅ 成功 | 从中文文本提取5个实体 |
| 反思综合 | ✅ 成功 | 280 tokens，2.5秒，112 tokens/s |
| OpenAI兼容 | ✅ 支持 | /v1/chat/completions端点 |
| 中文支持 | ✅ 良好 | 20B参数模型，中文处理正常 |

### 配置示例

```json
// $HERMES_HOME/hindsight/config.json
{
  "mode": "local_embedded",
  "llm_provider": "openai_compatible",
  "llm_base_url": "http://localhost:8080",
  "llm_model": "your-model.gguf",
  "bank_id": "hermes"
}
```

### ⚠️ 关键发现：local_embedded模式仍需API Key

**实测发现**：即使使用本地llama.cpp，`hermes memory status`仍显示需要`HINDSIGHT_LLM_API_KEY`。

```
Status:    not available ✗
Missing:
  ✗ HINDSIGHT_LLM_API_KEY
```

**原因分析**：Hindsight的配置接口统一要求`HINDSIGHT_LLM_API_KEY`环境变量，即使是本地LLM也不例外。这是接口设计的一致性要求，而非功能性依赖。

**解决方案**：
```bash
# 方案1：设置虚拟API Key（推荐）
echo "HINDSIGHT_LLM_API_KEY=local" >> ~/.hermes/.env

# 方案2：使用Hermes设置向导
hermes memory setup  # 选择"hindsight" → "local embedded"
```

**配置完整流程**：
```bash
# 1. 创建配置文件
mkdir -p ~/.hermes/hindsight
cat > ~/.hermes/hindsight/config.json << 'EOF'
{
  "mode": "local_embedded",
  "llm_provider": "openai_compatible",
  "llm_base_url": "http://localhost:8080",
  "llm_model": "GPT-OSS-20B-Uncensored-HauhauCS-MXFP4-Balanced.gguf",
  "bank_id": "hermes",
  "auto_retain": true,
  "auto_recall": true,
  "recall_types": "observation,world,experience"
}
EOF

# 2. 设置环境变量
echo "HINDSIGHT_MODE=local_embedded" >> ~/.hermes/.env
echo "HINDSIGHT_LLM_API_KEY=local" >> ~/.hermes/.env

# 3. 设置提供商
hermes config set memory.provider hindsight

# 4. 验证状态
hermes memory status
```

### Pitfall：配置修改需要用户批准

**问题**：直接修改`~/.hermes/.env`或`~/.hermes/config.yaml`的命令可能被用户拒绝。

**原因**：用户重视系统完整性，不希望Agent自动修改关键配置文件。

**正确做法**：
1. 先展示配置方案，等待用户确认
2. 提供手动执行的命令，让用户决定是否执行
3. 或使用`hermes memory setup`交互式向导

**错误做法**：
```bash
# ❌ 直接追加到.env（可能被拒绝）
echo "HINDSIGHT_MODE=local_embedded" >> ~/.hermes/.env

# ❌ 批量修改配置（可能被拒绝）
cat > ~/.hermes/.env << 'EOF'
...
EOF
```

**正确做法**：
```bash
# ✅ 展示命令，让用户手动执行
echo "请手动执行以下命令："
echo "echo 'HINDSIGHT_MODE=local_embedded' >> ~/.hermes/.env"
echo "echo 'HINDSIGHT_LLM_API_KEY=local' >> ~/.hermes/.env"

# ✅ 或使用交互式向导
hermes memory setup
```

### 免费LLM选择

| 方案 | 成本 | 质量 | 适合场景 |
|------|------|------|----------|
| Groq免费tier | $0 | 高（Llama3-70B） | 有网络连接 |
| 本地llama.cpp | $0（需GPU） | 中等（20B） | 隐私优先 |
| Ollama | $0（需GPU） | 中等 | 简单易用 |

### 完整测试结果（2026-06-16）

本地llama.cpp + Hindsight功能测试完成，详细报告：`~/.hermes/tushuguan/项目/本地llama.cpp测试/20260616_本地llama.cpp测试报告.md`

| 测试项 | 评分 | 详情 |
|--------|------|------|
| 实体提取 | 95/100 | 成功提取5个实体，分类准确 |
| 关系构建 | 90/100 | 成功识别4种关系 |
| 反思综合 | 95/100 | 多维度分析深入，逻辑清晰 |
| 冲突检测 | 95/100 | 准确识别冲突，原因分析全面 |
| 响应时间 | 90/100 | 平均1.945秒 |
| 生成速度 | 95/100 | 平均115.33 tokens/秒 |
| **总体评分** | **92.5/100** | **优秀** |

### Pitfall：Hindsight集成的Python环境问题

**问题**：即使正确设置所有环境变量、安装hindsight-client，`hermes memory status`仍显示"not available"。

**根本原因**：hindsight-client安装在虚拟环境中（`~/.hermes/hindsight-venv/`），但Hermes使用系统Python，找不到该包。

**验证方法**：
```bash
pip3 list | grep hindsight  # 系统Python中无此包
source ~/.hermes/hindsight-venv/bin/activate && pip list | grep hindsight  # 虚拟环境中有
```

**解决方案**：
1. 使用`hermes memory setup`向导（可能自动处理依赖）
2. 在Hermes使用的Python环境中安装hindsight-client
3. 或改用Holographic（无外部依赖）

**注意**：`hermes memory setup`可能会重置provider为"built-in only"，需要重新设置`hermes config set memory.provider hindsight`。

### Pitfall：hermes memory setup重置provider

**问题**：执行`hermes memory setup`后，provider被重置为"built-in only"，之前配置的外部提供商丢失。

**原因**：设置向导的默认行为是选择"built-in only"。

**解决方案**：设置向导完成后，必须重新执行：
```bash
hermes config set memory.provider hindsight
```

**验证方法**：
```bash
hermes memory status  # 检查Provider字段是否显示hindsight
```

### Pitfall：HuggingFace模型国内下载超时（2026-06-17验证）

**问题**：Hindsight daemon启动时需要下载两个HuggingFace模型（bge-small-en-v1.5 ~130MB + ms-marco-MiniLM-L-6-v2 ~80MB），国内网络无法连接huggingface.co导致超时，daemon启动失败。

**表现**：
- `hindsight_recall`/`hindsight_retain`/`hindsight_reflect`全部返回"Failed to start daemon"
- daemon日志：`'timed out' thrown while requesting HEAD https://huggingface.co/...`

**Hindsight三组件架构**（为什么需要这两个小模型）：

| 组件 | 类型 | 大小 | 功能 |
|------|------|------|------|
| GPT-OSS-20B | 大语言模型 | ~12GB | 实体提取、反思综合、冲突检测 |
| bge-small-en-v1.5 | 嵌入模型 | ~130MB | 文本→向量（相似度检索，不走大模型） |
| ms-marco-MiniLM-L-6-v2 | 重排序模型 | ~80MB | 搜索结果相关性打分（不走大模型） |

bge和MiniLM加载在daemon进程内存中（共~210MB），不在独立服务器运行。高频轻量操作（向量检索、排序）不占用大模型资源。

**解决方案**：设置HuggingFace国内镜像
```bash
# 1. Hermes主进程读取
echo 'HF_ENDPOINT=https://hf-mirror.com' >> ~/.hermes/.env

# 2. daemon子进程读取（详见下方dotenv陷阱）
echo 'HF_ENDPOINT=https://hf-mirror.com' > ~/.env
```

### Pitfall：dotenv路径陷阱——daemon读不到~/.hermes/.env（2026-06-17验证）

**问题**：即使在`~/.hermes/.env`中设置了`HF_ENDPOINT`，daemon仍然请求huggingface.co而非hf-mirror.com。

**根本原因**：Hindsight daemon代码中：
```python
# hindsight_api/config.py
from dotenv import find_dotenv, load_dotenv
load_dotenv(find_dotenv(usecwd=True), override=True)
```
`find_dotenv(usecwd=True)`从进程**当前工作目录（CWD）**向上搜索。daemon CWD是`/home/kellen`：
```
/home/kellen/.env          ← 会搜索（daemon CWD）
/home/kellen/.hermes/.env  ← 不会！.hermes是子目录不是父目录
```

**验证方法**：
```bash
ls -l /proc/<daemon_pid>/cwd  # 确认daemon CWD
python3 -c "from dotenv import find_dotenv; print(find_dotenv(usecwd=True))"
```

**解决方案**：在daemon CWD创建.env
```bash
echo 'HF_ENDPOINT=https://hf-mirror.com' > ~/.env  # /home/kellen/.env
```

**关键区别**：`~/.hermes/.env`供Hermes主进程，`~/.env`（daemon CWD）供daemon子进程。两者作用域不同，需分别设置。

**参考文档**：
- 时间校对检查清单：`~/.hermes/tushuguan/机制/铁壁四规/20260616_时间校对检查清单.md`
- 时间错误根因分析：`~/.hermes/tushuguan/机制/铁壁四规/20260616_时间错误根因分析与预防措施.md`
- Hindsight集成专项优化方案：`~/.hermes/tushuguan/机制/铁壁四规/20260616_Hindsight集成专项优化方案.md`
- 本地llama.cpp测试报告：`~/.hermes/tushuguan/项目/本地llama.cpp测试/20260616_本地llama.cpp测试报告.md`

---

## 十二、术语表（向用户解释时使用）

> ⚠️ 用户曾问"LLM API key是什么？"——说明我们使用了未解释的术语。向用户解释技术概念时，必须先用通俗语言说明。

| 术语 | 通俗解释 | 技术含义 |
|------|----------|----------|
| **LLM API Key** | 调用AI大模型服务的"钥匙"，类似网站登录密码 | 认证密钥，用于访问OpenAI/Groq等大语言模型API |
| **local_embedded** | 数据存在自己电脑上，但AI推理可能需要外部服务 | Hindsight模式：PostgreSQL本地运行，LLM可选本地/云端 |
| **冻结快照** | 会话开始时把记忆"拍照"放进系统提示，会话中途不会更新 | Memory在session start时注入，之后不变（为保持缓存性能） |
| **FTS5** | 数据库的全文搜索功能，类似在文档中按关键词搜索 | SQLite的Full-Text Search 5扩展 |
| **知识图谱** | 把信息组织成"节点+关系"的网络图，而非平铺列表 | 实体（人物/模块）+ 关系（调用/依赖）的图结构 |
| **HRR** | 一种数学方法，可以用代数运算查询组合实体 | Holographic Reduced Representations，向量代数查询 |
| **信任评分** | 给每条记忆打分，常用的信息分数高，过时的分数低 | 0.0-1.0的可信度权重，影响召回优先级 |
| **反思综合** | 让AI跨多条记忆进行深度推理，找出关联和结论 | Hindsight的hindsight_reflect工具，LLM驱动的跨记忆合成 |
| **session_search** | 搜索过去的对话记录，类似在聊天记录中搜索 | 基于SQLite FTS5的会话历史搜索，无需LLM调用 |

---

## 十三、优化建议优先级

1. **立即**：验证安全扫描启用状态
2. **1周内**：评估write_approval分阶段启用
3. **1月内**：评估1-2个外部记忆提供商
4. **3月内**：整合session_search，迁移历史信息
5. **6月内**：决定是否采用外部提供商

---

## 变更记录

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-06-17 | v1.0 | 初版：基于Hermes官方文档的完整分析 |
| 2026-06-17 | v1.1 | 新增：免费/付费提供商对比表、功能对比（软件开发视角）、互斥性说明；新增第十节：软件开发场景推荐（决策树+场景匹配）；新增第十一节：本地LLM集成（架构分离、llama.cpp测试结果、配置示例、免费LLM选择） |
| 2026-06-17 | v1.2 | 第十一节增强：明确local_embedded模式仍需HINDSIGHT_LLM_API_KEY；新增完整配置流程（4步骤）；新增Pitfall：配置修改需要用户批准（展示命令而非直接执行）；修正配置示例mode为local_embedded |
| 2026-06-16 | v1.3 | 修正frontmatter日期（2026-06-17→2026-06-16）；新增参考文档指针：Hindsight集成专项优化方案、本地llama.cpp测试报告 |
| 2026-06-17 | v1.4 | 新增Pitfall：HuggingFace模型国内下载超时（三组件架构说明+HF镜像解决方案）；新增Pitfall：dotenv路径陷阱（daemon CWD与~/.hermes/.env不一致导致环境变量不生效） |