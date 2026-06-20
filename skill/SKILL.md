---
name: four-mechanisms
description: "铁壁四规：马诺防线（代码三关校验）、图书馆（v4科学管理+日期准确性）、历史书（三层记忆L1/L2/L3+L2插件化）、工蚁（多Agent协作+OPC一人公司）。所有Agent必须遵守。"
version: 3.6.1
category: devops
metadata:
  hermes:
    tags: [mechanisms, quality, memory, delegation, documentation]
    author: 米宝
---

# 铁壁四规

> 四道铁壁，缺一不可。违反任何机制的产出无效。

---

## 安装与部署

**⚠️ 双平台支持**：v4.0.0 起，安装脚本自动检测 Hermes Agent 或 OpenClaw 并选择正确路径。发布包：`four-mechanisms-v4.0.0.zip`。

### 一键安装（推荐）

```bash
unzip four-mechanisms-v4.0.0.zip -d /tmp/
cd /tmp/four-mechanisms-generic
bash install.sh    # 自动检测平台
```

**平台检测逻辑**：检测 `~/.hermes/` → Hermes；检测 `~/.openclaw/` → OpenClaw。

| 平台 | Skills路径 | 机制文档路径 | 脚本路径 | 子Profile同步 |
|------|-----------|-------------|---------|-------------|
| Hermes | `~/.hermes/skills/four-mechanisms/` | `~/.hermes/tushuguan/机制/铁壁四规/` | `~/.hermes/scripts/` | `profiles/*/skills/` |
| OpenClaw | `~/.openclaw/workspace/skills/four-mechanisms/` | `~/.openclaw/tushuguan/07-规章制度/铁壁四规/` | `~/.openclaw/workspace/scripts/` | `workspace-*/skills/` |

### 手动安装（Hermes）

```bash
# 解压后逐项复制（参见 install.sh 中的 Step 1-8）
# 关键步骤：skill → 机制文档 → 脚本 → 参考文件 → 子Profile同步 → 目录结构 → INDEX.md → SOUL.md
```

### 验证安装

```bash
# Hermes
bash ~/.hermes/scripts/mano_status.sh
ls ~/.hermes/tushuguan/机制/铁壁四规/

# OpenClaw
bash ~/.openclaw/workspace/scripts/mano_status.sh
ls ~/.openclaw/tushuguan/07-规章制度/铁壁四规/
```

---

## 铁壁一：马诺防线 (Mano Defense Line)

**四步验证流程**（三关校验 + 交付验证）：

```
代码质量关(ruff/dart analyze) → 逻辑测试关(pytest/flutter test)
→ 安全扫描关(pre-commit) → 用户验证
```

**脚本**（`~/.hermes/scripts/`）：

| 脚本 | 用途 |
|------|------|
| `mano_engine.sh validate <task_id> <agent> <files>` | 执行三关校验 |
| `mano_retry.sh` | 失败自动重试（最多3次） |
| `mano_review.sh` | 主控终审 |
| `mano_deploy.sh` | 通过后部署 |
| `mano_status.sh` | 查看运行状态 |

**适用范围**：所有代码编写（Flutter/Dart/Python）。主控调度码仔执行，主控本人严禁编码。

**v0.17.0新增能力：**
- `read_file` 现在支持提取 `.ipynb`（Jupyter笔记本）、`.docx`（Word）、`.xlsx`（Excel）为可读文本
- 马诺防线审查代码时，可直接读取项目文档，无需额外工具转换

**混合调度模式**：
```
用户需求
  ↓
① 米宝：判断任务性质
   ├─ 简单（≤3步/单Agent/无需评审）→ hermes chat --profile -Q -q
   └─ 复杂（多步骤/跨Agent/需评审）→ kanban_create 创建卡片
  ↓
② 复杂流程（Kanban自动门控）：
   产品PM → 算法Harry → 编码码仔 → 运营多宝 → 验收
  ↓
③ Gateway dispatcher 每60s调度ready任务
   Worker按任务体执行 → kanban_complete → 自动升ready
  ↓
④ 米宝验证产出 → 构建产物 → 交付用户
```

---

## 铁壁二：图书馆 (Tushuguan) — v4.0 科学管理体系

**5分类体系**：

| 类别 | 特征 | 例子 | 变化频率 |
|------|------|------|---------|
| **机制/** | 框架级操作流程，铁壁四规 | 马诺防线机制、图书馆管理机制 | 几乎不变 |
| **方案/** | 针对管理问题的设计方案 | 多Agent方案、Kanban方案 | 按需更新 |
| **项目/** | 对外产出的项目文档 | 育儿游戏分析、AI彩算 | 项目周期 |
| **会议/** | 会议纪要 | 启动会纪要 | 即写即走 |
| **备份/** | Memory压缩备份 | memory_backup_xxx | 自动生成 |

核心分界线：**机制=框架规则，方案=当前设计，项目=给用户的产出**

**目录结构**（`~/.hermes/tushuguan/`）：
```
├── INDEX.md                     # 多维索引
├── INDEX_LOG.md                 # 变更日志
├── 机制/                        # 铁壁四规
│   ├── 铁壁四规/                #   4份稳定机制文档
│   └── YYYY-MM-DD/              #   机制更新
├── 方案/                        # 管理设计方案
│   └── YYYY-MM-DD/
├── 项目/                        # 对外项目产出
│   └── <项目名>/YYYY-MM-DD/
├── 会议/                        # 会议纪要
│   └── YYYY-MM-DD/
├── 备份/                        # Memory压缩备份
├── 归档/                        # 历史完结内容
├── code-repo/                   # 代码仓库
└── script-repo/                 # 脚本仓库
```

**强制规则**：
1. root只允许 INDEX.md + INDEX_LOG.md + 分类文件夹
2. 每个.md文件必须含 YAML frontmatter（title/created/category/tags/status）
3. 写完文件立即更新 INDEX.md（层级索引格式）
4. status=archived 移入归档/
5. 项目完结时清理项目段

### v0.17.0新增：文件系统回滚保护

**已启用**：`checkpoints.enabled: true`

- 代码操作前自动创建文件系统快照
- 使用 `/rollback [N]` 可回滚到之前的状态
- 保护马诺防线审查过程中的文件安全
- 默认保留50个快照，超过自动清理

**⚠️ 文件存放铁律（2026-06-19 用户强烈纠正）**

所有项目产出必须按图书馆分类存放，**禁止放到home根目录**。

**用户原话：**"你以后能不能不要把文件放到根目录？这铁壁四规有蛋用啊"

**正确存放路径：**
```
项目产出 → ~/.hermes/tushuguan/项目/<项目名>/<日期>/
方案产出 → ~/.hermes/tushuguan/方案/<日期>/
会议纪要 → ~/.hermes/tushuguan/会议/<日期>/
备份文件 → ~/.hermes/tushuguan/备份/
```

**错误做法：**
```bash
# ❌ 放到home根目录
~/four-mechanisms-generic/
~/my-project/
```

**正确做法：**
```bash
# ✅ 按图书馆规范存放
CURRENT_DATE=$(date +%Y-%m-%d)
TARGET_DIR="$HOME/.hermes/tushuguan/项目/<项目名>/$CURRENT_DATE"
mkdir -p "$TARGET_DIR"
# 文件操作都在 $TARGET_DIR 下进行
```

**检查清单（创建任何项目文件前）：**
1. 这个文件属于哪个分类？（机制/方案/项目/会议/备份）
2. 目标路径是否在 `~/.hermes/tushuguan/` 下？
3. 是否需要更新 INDEX.md？

**🔴 日期准确性铁律（强制第一步）**：

创建任何带日期的文档前，**必须先执行 `date` 命令**确认当前系统时间。这是强制第一步，不可跳过。

```bash
# 强制第一步：获取当前日期
date  # 确认系统时间
CURRENT_DATE=$(date +%Y-%m-%d)
FILE_DATE=$(date +%Y%m%d)
```

**陷阱（高频错误，已发生多次）**：Agent容易错误预估日期（如将6月16日写成6月17日），导致：
- 文件名日期错误
- YAML frontmatter中created/updated错误
- INDEX.md中的日期错误
- 变更日志日期错误
- 需要逐一修正所有相关文件
- **用户明确指出"这已经不是第一次"**——必须根治

**正确做法**：
1. 每次创建带日期的文件前，先 `date` 确认
2. 使用 `date +%Y-%m-%d` 和 `date +%Y%m%d` 获取格式化日期
3. 创建完成后立即校对所有时间戳
4. 使用时间校对检查清单（`~/.hermes/tushuguan/机制/铁壁四规/20260616_时间校对检查清单.md`）

**错误做法**：
```bash
# ❌ 假设日期，不检查系统时间
# 直接使用"明天"的日期创建文档
```

**正确做法**：
```bash
# ✅ 先检查系统时间
date
# 输出：2026年 06月 16日 星期二 15:07:52 CST
# 然后使用2026-06-16创建文档
```

**YAML frontmatter 模板**：
```yaml
---
title: 文档标题
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: 米宝
category: 方案
tags: [标签1, 标签2]
status: active
version: 1.0
refs:
  - 关联文档.md
---
```

**文档生命周期**：draft → active → archived → obsolete

---

## 铁壁三：Memory管理 — 三层架构

### 架构总览

```
L1 热缓存：MEMORY.md / USER.md     — 每轮自动注入，零延迟
L2 温存储：可插拔工具层              — 按需recall，~200ms
L3 冷存储：session_search (FTS5)    — 全自动存储，按需检索
```

**核心原则**：按信息"热度"分层。每轮必须用的→L1，需要时能找到的→L2，原始记录→L3。

### 铁壁四规与L2工具的关系（概念澄清）

铁壁四规是**规范/制度**，L2层工具（如Hindsight）是**技术实现**。两者是"规范指定工具"的关系，不是"包含"关系：

```
铁壁四规第三规（Memory管理）定义三层架构
  → 指定 L2 层使用某个向量检索工具
  → 当前实现：Hindsight（可插拔）
```

类比：铁壁四规 = 交通法规，Hindsight = 符合标准的汽车。法规规定"什么车能上路"，但法规不"包含"汽车。

未来方向：L2层可插拔，用户可选Hindsight / Null(不使用L2) / 其他向量库。详见 `references/l2-pluggable-architecture.md`。

### L1 MEMORY.md 限值与防护

**铁壁四规覆盖限值**（通过config.yaml自定义）：

| Profile | MEMORY.md上限 | USER.md上限 |
|---------|-------------|------------|
| 米宝 (default) | 4000 字节 | 1375 字节 |
| 子Agent (PM/码仔/多宝/Harry) | 2000 字节 | 1375 字节 |

> 官方默认：MEMORY 2,200字符 / USER 1,375字符。我们覆盖为字节限值以容纳中文（每字3字节）。

**限值防护（无自动压缩）**：
- ⚠️ Hermes官方确认：Memory**不会自动压缩**，80%预警线仅是我们的策略建议，需Agent主动执行
- 硬限制（100%）：达到上限后系统拒绝写入，Agent必须自己清理后再重试
- Agent需在每次会话开始时主动检查`wc -c`，超80%时主动压缩

**LOCKED规则**：
- MEMORY.md和USER.md首行`# LOCKED — 以下条目压缩时禁止触碰`
- LOCKED之后的条目为锁定条目，压缩时禁止删除/修改
- 只能压缩 LOCKED 区域之外的条目

### 概念澄清：铁壁四规 vs L2工具

铁壁四规是**规范/制度**，L2层工具（如Hindsight）是**技术实现**。两者是"规范指定工具"的关系，不是"包含"关系。

用户问"铁壁四规包含Hindsight吗"时，正确回答：不包含。铁壁四规第三规（Memory管理）定义了三层架构，指定L2层使用某个向量检索工具。Hindsight是被引用的外部工具，不是铁壁四规的一部分。

类比：铁壁四规 = 交通法规，Hindsight = 符合标准的汽车。法规规定"什么车能上路"，但法规不"包含"汽车。

### L1 准入标准

**核心判断问题**：这条信息如果这次会话没有注入系统提示，会不会导致我犯错？

- **会犯错** → 存 MEMORY.md（L1）
- **不会犯错** → 存 Hindsight（L2）或不存

| 类别 | L1 | L2 | 不存 |
|------|----|----|------|
| 铁律规则、用户偏好、Agent团队、关键环境事实 | ✅ | | |
| 项目进展、技术经验、实体关系 | | ✅ | |
| 临时任务进度、可重新发现的信息 | | | ✅ |

### L1 压缩流程（超80%时）— v0.17.0增强

**v0.17.0新增：内存批量原子操作** — 一次调用完成释放空间+添加条目

```
# ✅ 推荐：单次原子操作（v0.17.0+）
memory(action="add", target="memory", operations=[
    {"action": "remove", "old_text": "过时条目1"},
    {"action": "remove", "old_text": "过时条目2"},
    {"action": "add", "content": "新条目"}
])
```

**传统流程（仍可用，但不如批量操作可靠）：**
1. ⛔ 跳过LOCKED条目
2. 逐条检查非LOCKED条目：能被 recall 找到的 → 标记迁移
3. 执行 `hindsight_retain()` 迁移到L2
4. 从 MEMORY.md 删除已迁移条目
5. 确保降到70%以下
6. 备份到 `~/.hermes/tushuguan/备份/memory_backup_YYYYMMDD.md`

### L2 Hindsight 三工具

| 工具 | 角色 | 触发时机 |
|------|------|----------|
| hindsight_retain | 写入L2 | Agent判断信息重要时主动调用 |
| hindsight_recall | 读取L2 | auto_recall自动 + 手动补充 |
| hindsight_reflect | 分析L2 | 需要跨记忆深度推理时 |

### 写入验证流程（预防幻觉/脏数据）

```
Agent准备写入
  ├─ ① 来源检查：用户告知 / 工具验证 / 自己推断(降级)
  ├─ ② 矛盾检查：与已有记忆矛盾 → 停止，问用户
  ├─ ③ 可发现性：一条命令能查到 → 不存
  └─ ④ 写入后校对：重新读取确认
```

### 定期审计

| 频率 | 审计内容 | 方法 |
|------|----------|------|
| 每次会话 | MEMORY.md是否超限 | wc -c |
| 每周 | 条目是否过时(30天未用) | 逐条审查 |
| 每周 | Hindsight召回质量 | recall测试关键主题 |

详细恢复SOP见：`~/.hermes/tushuguan/机制/铁壁四规/20260617_Memory审计与恢复操作手册.md`
三层架构完整方案见：`~/.hermes/tushuguan/方案/2026-06-17/20260617_Memory三层架构优化方案.md`

### Pitfall：字节计数陷阱

检查限值时必须用 `wc -c` 或 `len(string.encode('utf-8'))`，不能用 `len(string)`（后者返回字符数，中文每字3字节，会低估 ~3 倍）。

### Pitfall：术语解释陷阱

向用户解释技术方案时，必须先用通俗语言说明专业术语。参考 `references/hermes-official-memory-mechanism.md` 第十二节术语表。

### Pitfall：配置修改陷阱

修改 `~/.hermes/.env` 或 `~/.hermes/config.yaml` 前必须先展示方案，等待用户确认。用户重视系统完整性。

### Pitfall：hermes memory setup陷阱

`hermes memory setup`可能会重置provider为"built-in only"。设置后必须重新执行 `hermes config set memory.provider <provider>`。

### Pitfall：禁止声称系统功能存在但未经验证（2026-06-20发现）

Agent容易把自定义规则误认为系统内置功能。例如：铁壁四规定义了"80%预警自动压缩"，Agent误以为这是Hermes的内置行为，实际上Memory不会自动压缩（官方文档明确说 "Memory does not auto-compact"）。

**强制规则：声称任何系统功能存在前，必须先查官方文档验证。**

错误做法：
```
❌ "系统会自动处理"（未验证是否有此功能）
❌ 将自定义规则等同于系统内置行为
```

正确做法：
```
✅ 先查文档确认功能是否存在
✅ 区分"我们的策略"和"系统能力"
✅ 不确定时明确告知用户"这是我们定义的规则，不是系统内置的"
```

**根因：** Agent容易混淆"规范定义的行为"和"系统的实际行为"。规范是约束Agent的，系统是实际运行的。两者可能不一致。

### Pitfall：Hindsight dotenv路径陷阱（2026-06-17发现）

Hindsight daemon的工作目录(CWD)是 `/home/kellen`，python-dotenv 从CWD向上搜索.env。`~/.hermes/.env` 不在搜索路径上。

**正确做法**：环境变量（如HF_ENDPOINT）必须写在daemon的CWD下的.env文件中，不能只写在Hermes配置目录。

### Pitfall：HuggingFace国内下载超时（2026-06-17发现）

Hindsight需要下载bge-small-en-v1.5和ms-marco-MiniLM-L-6-v2两个HF模型。国内无法连接huggingface.co。

**解决方案**：设置 `HF_ENDPOINT=https://hf-mirror.com`（国内唯一可用镜像）。

### Pitfall：bash脚本必须显式处理--help（2026-06-20 工蚁阶段2发现）

bash脚本的参数解析中，如果case语句有`*) break` catch-all但没处理`--help|-h`，用户传入`--help`会被当作任务文本而非帮助标志。

**正确做法：**
```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --agent|-a) ... ;;
        *) break ;;
    esac
done
```

**错误做法：**
```bash
case "$1" in
    --agent|-a) ... ;;
    *) break ;;  # --help会fall through到这里
esac
```

### Pitfall：kanban任务会被dispatcher自动claim

Hermes kanban的dispatcher每60s自动claim ready任务，状态从ready变为running。创建任务后如果立刻看状态，可能已经是running而非ready。reclaim可将running任务退回ready。

### Pitfall：项目产出必须按图书馆规范存放（2026-06-19用户纠正）

项目文件、打包产物等必须放到 `~/.hermes/tushuguan/项目/<项目名>/YYYY-MM-DD/` 下，**严禁放到home根目录**。用户原话："你以后能不能不要把文件放到根目录？这铁壁四规有蛋用啊"——批评Agent自己定的规范自己不遵守。

**正确做法**：
```bash
CURRENT_DATE=$(date +%Y-%m-%d)
TARGET_DIR="$HOME/.hermes/tushuguan/项目/<项目名>/$CURRENT_DATE"
mkdir -p "$TARGET_DIR"
# 所有产出放到 TARGET_DIR 下
```

**错误做法**：
```bash
# ❌ 直接放到 ~/ 或 ~/projects/
mkdir ~/my-project
```

### Pitfall：历史查询必须先recall再回答

当用户提到"之前版本"、历史事件、或可能存在于记忆中的关键词时，**必须先hindsight_recall检索L2历史再回答**，不能凭空猜测。

用户原话："这就是记忆管理的问题...你应该通过Hindsight去检索，而不是咱俩驴头不对马嘴的对话。"

**正确做法**：触发关键词 → hindsight_recall() → 基于检索结果回答

### Cron

每天09:00自动检查（Job ID: a78f92301730）

### ⚠️ Hindsight自动触发铁律（2026-06-20 新增）

**核心问题**：Agent的"主动retain"行为不可靠，经常忘记。必须将"应该retain"编码为明确规则，而非依赖Agent判断。

**以下场景必须立即调用 `hindsight_retain()`，不需要用户提醒：**

| 触发场景 | 示例关键词 | 延迟 |
|----------|-----------|------|
| 用户纠正 | "不要"、"错了"、"应该是"、"不对" | 立即 |
| 技术决策 | "用方案A"、"选xxx"、"决定xxx"、"确定" | 立即 |
| 踩坑记录 | "坑"、"注意"、"别忘"、"教训" | 立即 |
| 配置变更 | 修改.env/config.yaml | 立即 |
| 项目里程碑 | "完成"、"交付"、"上线"、"发布" | 立即 |
| 用户偏好 | "我喜欢"、"以后都xxx"、"习惯" | 立即 |
| 架构设计 | "架构"、"方案"、"设计"、"选型" | 立即 |

**会话结束时触发：**
- 会话压缩前检查是否有未retain的重要信息
- 用户明确切换话题时
- 超过30分钟的会话

**容错机制：**
- 每天20:00三层记忆整理（Cron job）
- 每天12:00遗漏检测（增强版Cron job）
- 下次会话开始时的自动recall检查

**可发现性测试**：每条memory必须通过——Agent用一条命令能查到的信息不写。

**压缩流程**（超80%时）：
1. ⛔ 跳过LOCKED条目
2. 识别低优先级条目（可重新发现的 > 30天未用的 > 已过时的）
3. 备份到 `~/.hermes/tushuguan/备份/memory_backup_YYYYMMDD.md`
4. 合并/删除，确保降到70%以下
5. 更新INDEX.md

**Cron**：每天09:00自动检查（Job ID: a78f92301730）

---

## 铁壁四：子Agent超时应对 — 工蚁

**三级升级**：

| 级别 | 条件 | 动作 |
|------|------|------|
| L1 | 1800s内完成 | 正常接收 |
| L2 | L1超时 | 父控预读→提取关键数据→传给新子Agent |
| L3 | L2超时 | 诊断日志/API/资源→修复→重调度 |

**配置**：
```yaml
delegation:
  child_timeout_seconds: 1800
  max_iterations: 50
  max_concurrent_children: 3
  max_spawn_depth: 1
```

### v0.17.0新增：后台异步子代理

**核心改进**：`delegate_task(background=true)` 现在支持后台异步运行

```
# 传统同步模式（阻塞主对话）
delegate_task(goal="构建REST API")

# v0.17.0异步模式（不阻塞，结果自动注入）
delegate_task(goal="构建REST API", background=true)
```

**对工蚁的价值：**
- 码仔后台写代码时，米宝可同时处理其他任务
- 简单任务hermes chat，复杂任务kanban，**异步子代理填补中间地带**
- 工蚁v2.0的多Agent协作从"串行等待"升级为"并行异步"

**使用规范：**
- `background=true` 仅用于**独立任务**（不需要中途交互）
- 需要用户确认的任务仍用同步模式
- 子代理完成后自动将结果注入新对话轮次

### 工蚁v2.0-beta：任务队列 + 进度看板（阶段2，2026-06-20完成）

**脚本**（`~/.hermes/scripts/`）：

| 脚本 | 用途 |
|------|------|
| `worker-ant-queue.sh add <任务描述>` | 添加任务到队列（自动匹配Agent） |
| `worker-ant-queue.sh run` | 执行队列中下一个ready任务 |
| `worker-ant-queue.sh status` | 查看队列状态统计 |
| `worker-ant-queue.sh dashboard` | 进度看板（终端可视化） |
| `worker-ant-dashboard.sh` | 独立进度看板脚本 |

**功能：**
- 智能Agent匹配（关键词路由，复用阶段1）
- 优先级自动推断（紧急🔴/重要🟡/普通⚪）
- Kanban卡片创建（任务持久化到SQLite）
- 进度看板（进度条 + 按状态分组 + 等待时间）
- 目标循环模式（`--goal`，自动重试直到完成）

**设计文档：** `~/.hermes/tushuguan/项目/four-mechanisms/2026-06-20/core/worker-ant-v2-beta.md`

---

## 自动加载与执行保障

Hermes 没有内置的 "profile级默认预加载技能" 功能。铁壁四规采用三层软约束保障执行：

| 层级 | 机制 | 触发方式 | 可靠性 |
|------|------|---------|--------|
| L1 | SOUL.md 指令注入 | 每次会话自动加载 ~/.hermes/SOUL.md | ★★★★☆ |
| L2 | Cron 合规巡检 | 每天定时检查四规执行情况 | ★★★☆☆ |
| L3 | MEMORY 规则记忆 | Agent 从记忆中回忆需遵守四规 | ★★☆☆☆ |

**⚠️ 重要：三层都是软约束**
- SOUL.md 注入的是"请加载xxx"的指令，不是技能内容本身
- Agent 可能忽略指令（尤其在上下文压力大时）
- 真正的硬约束需要 Hermes 官方支持 profile-level auto-load skills
- 参考 `references/auto-loading-mechanisms.md` 了解详细机制

**Hermes 上下文注入点（已验证）：**

| 注入点 | 来源路径 | 触发条件 | 自动性 |
|--------|---------|---------|--------|
| SOUL.md | ~/.hermes/SOUL.md | 每次会话 | ✅ 全自动 |
| AGENTS.md | CWD 下的 AGENTS.md | 仅 cwd 匹配时 | ⚠️ 半自动 |
| -s 预加载 | CLI 参数 hermes -s xxx | 手动传入 | ❌ 手动 |
| /skill 命令 | 会话内 /skill name | 手动触发 | ❌ 手动 |

**子Agent加载：** skill 文件同步到 profiles/ 不等于自动加载。子Agent同样需要显式触发（SOUL.md 指令或 -s 参数）。

## 执行检查清单

每次Session开始时自检：
```bash
# 0. 确认铁壁四规已加载（最重要）
skill_view(name='four-mechanisms')              # 加载四规技能

# 0.5 ⚠️ 获取当前时间（创建任何文档前必须执行）
date                                              # 获取系统时间
date +%Y-%m-%d                                    # 获取格式化日期
date +%Y%m%d                                      # 获取文件名日期格式

# 1. 马诺防线
bash ~/.hermes/scripts/mano_status.sh

# 2. 机制文档
ls ~/.hermes/tushuguan/机制/铁壁四规/

# 3. 图书馆索引
cat ~/.hermes/tushuguan/INDEX.md | head -3

# 4. Memory用量
wc -c ~/.hermes/memories/MEMORY.md
```

## ⚠️ 防循环陷阱（Pitfall Guard）— 铁律

**连续失败3次必须停止，分析原因，报告问题。违反此规则是严重错误。**

### 铁律规则（零容忍）

| 规则 | 触发条件 | 强制动作 |
|------|----------|----------|
| **BLOCKED铁律** | read_file/terminal返回BLOCKED | 立即停止，换工具，**永不重试** |
| **3次铁律** | 同一命令/工具连续失败3次 | 停止，分析stderr，报告用户 |
| **语法铁律** | bash命令返回非0 | 分析错误，修正语法，**不重试相同命令** |

### 已知循环陷阱（高频错误，已发生多次）

**陷阱1：bash `*` 通配符**
```bash
# ❌ 错误：* 被展开为文件名
export API_KEY=*** ~/.config/ima/api_key)

# ✅ 正确：用 $() 读取
API_KEY=$(cat ~/.config/ima/api_key)
```

**陷阱2：read_file BLOCKED后重试**
```
# ❌ 错误：收到BLOCKED后继续调用相同参数（100+次）
read_file(path="xxx", offset=40)  # BLOCKED
read_file(path="xxx", offset=40)  # 继续调用...

# ✅ 正确：立即停止，换方法
收到BLOCKED → stop → 用search_files或terminal
```

**陷阱3：terminal语法错误循环**
```bash
# ❌ 错误：语法错误后重试相同命令（30+次）
command  # 语法错误
command  # 重试...

# ✅ 正确：分析错误，修正后再试1次
command  # 语法错误
# 分析：括号不匹配、引号问题等
corrected_command  # 修正后重试
```

### 自动跳出检查清单（每次工具调用失败后必做）
1. ✅ 检查返回结果是否包含 BLOCKED/Error/failed
2. ✅ 如果是，**立即停止重试**，分析错误原因
3. ✅ 连续失败3次 → **强制停止** → 报告用户
4. ✅ 换用不同工具或方法（不要换参数重试相同工具）

### 用户反馈（必须遵守）
用户明确指出："你在干什么？为什么在无限循环测试？"
→ **这是严重错误，必须根治。下次遇到BLOCKED/语法错误，立即停止并报告。**

### Pitfall：历史查询必须先recall

用户提到历史话题（"之前版本"、"上次怎么做"、"原来的方案"）时，**必须先调用 `hindsight_recall()` 检索相关记忆**，再基于检索结果回答。禁止凭空猜测或直接回答。

**错误做法**：
```
用户问"之前版本" → 凭理解回答 → 驴头不对马嘴
```

**正确做法**：
```
用户问"之前版本" → hindsight_recall(query="相关关键词") → 基于检索结果回答
```

**根因**：如果关键历史信息不在L2层，recall会返回空或无关结果。因此重要信息必须retain到L2。

### Pitfall：备份/会议纪要必须迁移关键信息到L2

备份文件（~/.hermes/tushuguan/备份/）和会议纪要（~/.hermes/tushuguan/会议/）中的**设计决策、技术权衡、用户纠正**等信息，如果仅存储在文件中而未retain到Hindsight，则无法通过recall检索。

**判断标准**：这条信息如果未来用户问起，我需要回答吗？
- **需要回答** → 必须hindsight_retain()到L2
- **不需要回答** → 存文件即可

**应迁移的内容**：
• 版本迭代的设计决策（为什么选A不选B）
• 用户纠正和偏好形成过程
• 技术踩坑记录和解决方案
• 项目关键里程碑和决策理由

**不应迁移的内容**：
• 已在MEMORY.md中的LOCKED条目（L1已有）
• 可通过文件名/路径重新发现的信息
• 纯粹的配置值（API密钥等）

### ⚠️ 历史查询铁律（2026-06-19 新增，用户强烈纠正）

**用户原话：**"这就是记忆管理的问题，我说的之前版本，你查一下历史记录，这么关键的信息为什么都不L2层？当你触发关键词时，你应该通过Hindsight去检索，而不是咱俩驴头不对马嘴的对话。"

**强制规则：用户提到历史话题、之前版本、过去事件、或任何可能存在于记忆中的关键词时：**
1. 必须先 `hindsight_recall()` 检索L2历史
2. 基于检索结果回答，不能凭空猜测
3. 如果L2中没有相关信息，再尝试 `session_search()` 查L3

**错误做法：**
```
用户："之前版本有什么？"
Agent：（凭记忆猜测，不查L2）→ 驴头不对马嘴
```

**正确做法：**
```
用户："之前版本有什么？"
Agent：hindsight_recall("之前版本") → 检索到历史 → 基于事实回答
```

**根因：** L2层如果缺少历史数据，recall再多也找不到。因此必须确保历史数据已迁移到L2。

### ⚠️ 历史数据迁移铁律（2026-06-19 新增）

**备份文件和会议纪要中的设计决策、用户纠正、技术权衡等"会犯错"的信息，必须retain到Hindsight L2层。**

判断标准：**这条信息如果这次会话没有注入系统提示，会不会导致我犯错？**
- 会犯错 → retain到Hindsight L2
- 不会犯错 → 可以不存

**常见遗漏类型：**
- 项目关键决策和理由（如"为什么选方案A而不是B"）
- 用户纠正和反馈（如"不要这样做"）
- 技术踩坑记录（如"bcrypt版本兼容问题"）
- Agent团队配置变更历史
- 版本迭代的设计变更理由

**错误经验：** 曾建议"不迁移历史备份到Hindsight"，理由是"备份内容与现有规则高度重叠"。结果：用户问历史问题时无法recall，导致回答完全偏离。正确做法：宁可多存，不可漏存。

### 每日20:00三层记忆整理（2026-06-19 创建）

已创建定时任务（Job ID: 1cda8dbdd7f0），每天20:00自动执行：
- 扫描当天会话记录
- 提取有价值信息（用户纠正、技术决策、项目进展、踩坑记录）
- 按三层规则分类存储到Hindsight L2

### ⚠️ 用户风格铁律：分析优先，不逼选择

**用户明确指出："两个方案的优缺点，不要一上来就让我做选择！！！"**

当存在多个方案时：
1. **先**完整分析每个方案的优缺点（列表对比）
2. **再**给出你的建议（带理由）
3. **最后**让用户决定（或等用户主动问"你建议哪个"）

错误做法：
```
❌ 方案A是xxx，方案B是xxx。你选哪个？
```

正确做法：
```
✅ 方案A优点：xxx 缺点：xxx
   方案B优点：xxx 缺点：xxx
   核心矛盾在于：xxx
   我的建议是方案X，因为xxx
```

适用范围：所有涉及方案选择、架构决策、技术选型的场景。

### 用户反馈：先分析后选择
用户明确指出："两个方案的优缺点，不要一上来就让我做选择！！！"
→ **呈现多个方案时，必须先做完整分析（每个方案的优缺点、适用场景、权衡），然后等用户自己判断，不要主动催促选择。用户需要的是信息，不是你替他做决策。**

### ⚠️ 用户反馈：项目产出必须按图书馆规范存放
用户明确指出："你以后能不能不要把文件放到根目录？这铁壁四规有蛋用啊"
→ **项目产出必须存放到 ~/.hermes/tushuguan/项目/<项目名>/YYYY-MM-DD/ 目录下，绝不允许放到home根目录。这是图书馆规范的核心要求，Agent必须遵守。**

### 用户反馈：历史问题必须先recall再回答
用户明确指出："这就是记忆管理的问题...你应该通过Hindsight去检索，而不是咱俩驴头不对马嘴的对话"
→ **当用户提到历史话题、之前版本、过去事件等关键词时，必须先 `hindsight_recall()` 检索L2历史，再回答。禁止凭空猜测。** 这是三层架构的核心用法——触发关键词→recall L2→再回答。备份文件和会议纪要中的设计决策、用户纠正、技术权衡等"会犯错"信息，必须retain到Hindsight L2层，否则无法recall。

## 附加工具参考

| 参考文件 | 用途 |
|----------|------|
| `references/use-cases.md` | 适用场景与限制详解（最佳效果/不太适合/快速决策） |

| 参考文件 | 用途 |
|----------|------|
| `references/long-image-ocr-chunking.md` | 长截图分段OCR提取工作流（PIL切割+tesseract） |
| `references/auto-loading-mechanisms.md` | Hermes技能自动加载机制分析（SOUL.md/AGENTS.md/-s注入点） |
| `references/health-check-script-pattern.md` | 定时健康检查脚本模式（cron no_agent=True + bash自动修复） |
| `references/ima-api-auth-pattern.md` | IMA OpenAPI认证模式（自定义头+cursor分页+知识库ID表） |
| `references/ima-api-rate-limiting.md` | IMA API限流机制（每日配额+短期频控+调用模板） |
| `references/loop-prevention-guard.md` | 防循环陷阱操作手册（bash通配符/BLOCKED重复/语法错误循环） |
| `references/hermes-official-memory-mechanism.md` | Hermes官方Memory机制分析（含Hindsight dotenv路径陷阱、国内HF镜像方案） |
| `references/hindsight-china-setup.md` | Hindsight国内环境配置指南（三组件架构、HF镜像、dotenv路径陷阱、daemon积压） |
| `references/hindsight-api-operations.md` | Hindsight API运维速查卡（健康检查、端点路径、retain/recall/reflect请求格式、stats字段解读） |
| `references/history-migration-checklist.md` | 历史信息迁移检查清单（备份/会议纪要→Hindsight迁移判断标准和操作流程） |
| `references/memory-three-layer-architecture.md` | Memory三层架构设计（L1热缓存/L2温存储/L3冷存储 + 准入标准 + 风险恢复） |
| `references/l2-pluggable-architecture.md` | L2层可插拔架构设计方案（插件化、收益对比、实施步骤） |
| `references/v0.17-new-capabilities.md` | v0.17.0新能力总结（后台异步子代理、内存批量操作、文件系统回滚、视频生成） |

**关联文档**：
- `~/.hermes/tushuguan/机制/铁壁四规/20260616_Memory管理机制优化方案.md`（MECH-004优化方案v1.0）
- `~/.hermes/tushuguan/机制/铁壁四规/20260616_Hindsight集成专项优化方案.md`（Hindsight + 本地LLM集成方案）
- `~/.hermes/tushuguan/机制/铁壁四规/20260616_时间校对检查清单.md`（日期准确性检查流程）
- `~/.hermes/tushuguan/机制/铁壁四规/20260616_时间错误根因分析与预防措施.md`（根因分析与预防）
- `~/.hermes/tushuguan/机制/铁壁四规/20260617_Memory审计与恢复操作手册.md`（异常分类/SOP/SQL修复/幻觉验证/备份管理）
- `~/.hermes/tushuguan/方案/2026-06-17/20260617_Memory三层架构优化方案.md`（三层架构设计/准入标准/风险恢复）

---

## 机制文档索引

完整文档路径：`~/.hermes/tushuguan/机制/铁壁四规/`

| 编号 | 机制 | 文件名 |
|------|------|--------|
| MECH-001 | 图书馆文档管理 | 20260528_图书馆文档管理机制.md |
| MECH-002 | 马诺防线 | 20260527_马诺防线机制.md |
| MECH-003 | 子Agent超时应对 | 20260528_子Agent超时应对机制.md |
| MECH-004 | Memory管理 | 20260528_Memory管理规则.md |

---

## skillhub.cn发布限制

上传zip包时，skillhub.cn**不允许**以下文件类型：
- `VERSION` 文件 → 被拒绝，需从zip中排除
- `LICENSE` 文件 → 被拒绝，需从zip中排除

打包命令：
```bash
zip -r skill-vX.Y.Z.zip . -x ".git/*" "VERSION" "LICENSE"
```

## TRACE评测体系（skillhub.cn官方标准）

| 维度 | 含义 | 设计要求 |
|------|------|----------|
| T - Trust 可信任度 | 安全、隐私、国内可用 | 无恶意代码、不收集数据、国内网络可跑通 |
| R - Reliability 可靠性 | 稳定、容错、反馈清晰 | 安装幂等、错误处理完善、失败有建议 |
| A - Adaptability 适用性 | 匹配精准、边界清晰 | 描述清晰、能力边界明确、示例丰富 |
| C - Convention 规范性 | 可读、可维护、可复用 | 语义版本号、完整变更日志、目录结构清晰 |
| E - Effectiveness 有效性 | 结果正确、有价值 | 一键安装、零配置使用、提供实际价值 |

## 变更日志

| 版本 | 日期 | 变更 |
|------|------|------|
| v2.0 | 2026-06-04 | 原版本（含完整Pitfalls、SOUL.md写入指南、参考文件） |
| v3.1.1 | 2026-06-09 | 图书馆v4体系（5分类）、Memory限值体系(4000/2000/1375)、路径更新(changchang→机制/铁壁四规/) |
| v3.1.2 | 2026-06-13 | Memory管理增加UTF-8字节计数陷阱警告；新增references/long-image-ocr-chunking.md（长图分段OCR工作流） |
| v3.2.0 | 2026-06-13 | 安装脚本增加SOUL.md自动加载设置（Step 8）；新增"自动加载与执行保障"章节（三层软约束）；执行检查清单增加skill_view步骤；新增references/auto-loading-mechanisms.md（Hermes上下文注入机制分析） |
| v3.2.1 | 2026-06-13 | 修复description限值不一致（1375→2000）；更新L2 Cron为健康检查脚本Job 08b2be27e03d；新增references/health-check-script-pattern.md（cron no_agent=True脚本模式） |
| v3.3.0 | 2026-06-14 | 安装与部署章节重写：双平台支持（Hermes + OpenClaw），install.sh 自动检测平台并选择正确路径；安装路径对照表（Hermes vs OpenClaw）；验证命令分平台 |
| v3.3.1 | 2026-06-16 | 新增 references/ima-api-auth-pattern.md：IMA API认证模式（自定义头+cursor分页+知识库ID表） |
| v3.3.2 | 2026-06-16 | ima-api-auth-pattern.md 重大修正：info_list→knowledge_list、新增folder_id参数浏览文件夹、search limit修正为20、空query返回0结果、新增速率限制章节（~1000次/天但可能提前触发）、新增media_type枚举、新增目录结构说明、新增3个错误码 |
| v3.3.3 | 2026-06-16 | 新增防循环陷阱（执行检查清单增加date命令、Pitfall Guard规则）；新增references/ima-api-rate-limiting.md（IMA限流机制）；新增references/loop-prevention-guard.md（bash通配符/BLOCKED重复/语法错误循环防护）；Memory管理章节增加Hermes官方默认限值对比（2200/1375字符）；新增references/hermes-official-memory-mechanism.md（官方Memory机制完整分析：冻结快照、安全扫描、write_approval、session_search分工、8个外部提供商）；变更日志格式修正 |
| v3.3.4 | 2026-06-17 | references/hermes-official-memory-mechanism.md 增强：新增免费/付费提供商对比表、功能对比（软件开发视角）、互斥性说明、软件开发场景推荐（决策树+场景匹配）、本地LLM集成（架构分离、llama.cpp测试结果、配置示例）；新增关联文档指针：20260617_Memory管理机制优化方案.md |
| v3.3.5 | 2026-06-17 | references/hermes-official-memory-mechanism.md 增强：明确local_embedded模式仍需HINDSIGHT_LLM_API_KEY；新增完整配置流程；新增Pitfall：配置修改需要用户批准。SKILL.md新增Pitfall：配置修改陷阱（展示命令而非直接执行） |
| v3.3.6 | 2026-06-17 | references/hermes-official-memory-mechanism.md 新增第十二节：术语表（LLM API Key、local_embedded、冻结快照、FTS5、知识图谱、HRR、信任评分、反思综合、session_search的通俗解释）；SKILL.md新增Pitfall：术语解释陷阱（向用户解释技术方案时必须先通俗化专业术语） |
| v3.3.7 | 2026-06-17 | references/hermes-official-memory-mechanism.md 新增：完整测试结果（92.5/100分）；新增Pitfall：Hindsight集成的Python环境问题（hindsight-client安装在venv但Hermes用系统Python）；新增Pitfall：hermes memory setup可能重置provider配置；SKILL.md新增Pitfall：hermes memory setup陷阱 |
| v3.3.9 | 2026-06-16 | 铁壁二（图书馆）新增Pitfall：日期准确性陷阱——创建带日期文档前必须先 `date` 确认系统时间，Agent易误估日期导致文件名/frontmatter/INDEX全部错误；关联文档指针更新：新增Hindsight集成专项优化方案、时间校对检查清单、时间错误根因分析；日期准确性陷阱加强警告（用户指出"这已经不是第一次"）；references/hermes-official-memory-mechanism.md修正frontmatter日期 |
| v3.4.0 | 2026-06-17 | references/hermes-official-memory-mechanism.md新增：Pitfall HuggingFace国内下载超时（三组件架构+镜像方案）；Pitfall dotenv路径陷阱（daemon CWD≠Hermes配置目录）；变更日志v1.4；防循环陷阱强化：新增bash语法错误循环案例（`API_KEY=***`中`*`被解释为通配符）；新增用户反馈规则："你在干什么？为什么在无限循环测试？"→必须立即停止并报告；references/hermes-official-memory-mechanism.md新增：本地llama.cpp功能测试结果（116 tokens/秒）、Hindsight集成状态检查方法 |
| v3.4.1 | 2026-06-17 | 新增用户风格铁律："分析优先，不逼选择"（先完整分析优缺点，再给建议，最后让用户决定）；新增references/memory-three-layer-architecture.md（三层架构设计速查卡）；关联文档新增Memory审计操作手册+三层架构方案；Memory管理新增三层架构设计（L1热缓存/L2温存储/L3冷存储）及准入标准；新增用户反馈：先分析后选择（呈现多方案时必须先完整分析，不要催促选择）；references/hermes-official-memory-mechanism.md新增v1.4：HuggingFace国内下载pitfall + dotenv路径陷阱 |
| v3.5.0 | 2026-06-19 | 铁壁三更名为"历史书"、铁壁四更名为"工蚁"；新增用户铁律：历史问题必须先hindsight_recall()再回答（禁止凭空猜测）；新增references/trace-evaluation-system.md（SkillHub TRACE评测体系）；新增references/universal-skill-packaging.md（通用Skill打包模式）；铁壁三架构总览改为"可插拔工具层"；新增概念澄清：铁壁四规与L2工具是"规范指定工具"关系而非"包含"关系；新增references/l2-pluggable-architecture.md（L2层可插拔架构设计方案：插件化、收益对比、实施步骤） |
| v3.5.1 | 2026-06-19 | 新增references/trace-evaluation-framework.md（SkillHub TRACE评测体系T/R/A/C/E五维度）；新增references/memory-migration-lessons.md（记忆迁移教训：备份文件必须retain到L2、历史查询必须先recall）；新增Pitfall：历史查询必须先recall；新增Pitfall：备份/会议纪要必须迁移关键信息到L2；新增references/daily-memory-consolidation.md（每日20:00三层记忆整理工作流）；新增references/hindsight-redundancy-management.md（冗余类型/评估标准/预防流程） |
| v3.5.2 | 2026-06-19 | 铁壁二（图书馆）新增文件存放铁律：所有项目产出必须按图书馆分类存放（~/.hermes/tushuguan/项目/），禁止放到home根目录；新增检查清单（分类判断→路径验证→INDEX更新） |
| v3.6.0 | 2026-06-20 | v0.17.0能力整合+工蚁阶段2+Memory修正
| v3.6.1 | 2026-06-20 | 新增Pitfall：bash--help处理+kanban自动claim；新增references/worker-ant-v2-beta-implementation.md：铁壁四（工蚁）新增后台异步子代理规范；铁壁三（历史书）新增内存批量原子操作；铁壁一（马诺防线）新增read_file提取.ipynb/.docx/.xlsx能力；铁壁二（图书馆）新增文件系统回滚保护；新增references/v0.17-new-capabilities.md；启用video_gen工具（Agnes Video V2.0）；铁壁四（工蚁）新增阶段2任务队列+进度看板（worker-ant-queue.sh/worker-ant-dashboard.sh）；新增Pitfall：禁止声称系统功能存在但未经验证（Memory无自动压缩）；铁壁三（历史书）修正"两层防护"为"限值防护（无自动压缩）" |
