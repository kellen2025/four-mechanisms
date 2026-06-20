# L2层可插拔架构设计方案

> 状态：提案（2026-06-19）
> 目标：让铁壁四规成为通用型skill，L2层工具可选或不选

## 一、当前问题

SKILL.md中硬编码了Hindsight（16处引用），导致：
- 用户必须安装Hindsight才能使用铁壁四规
- 国内用户因HF网络问题安装困难
- 无法扩展到其他L2工具（Chroma、Weaviate等）

## 二、方案设计

### 插件化架构

```
four-mechanisms/
├── SKILL.md                    # 核心规范（不含具体工具引用）
├── config.yaml.example         # 配置模板
├── plugins/                    # L2实现插件目录
│   ├── hindsight/              # Hindsight插件
│   │   ├── PLUGIN.md
│   │   ├── setup.sh
│   │   └── references/
│   └── null/                   # 空实现（不使用L2）
│       └── PLUGIN.md
└── references/                 # 通用文档
```

### L2插件接口规范

插件需实现三个核心操作：

| 操作 | 输入 | 输出 | 说明 |
|------|------|------|------|
| retain | content, context, tags | success/failure | 写入记忆 |
| recall | query, limit | memory_list | 检索记忆 |
| reflect | query | analysis_text | 反思分析 |

### 配置模板

```yaml
# config.yaml
memory:
  l2_provider: null  # 可选值：hindsight / null / 自定义插件名
  l2_bank_id: hermes
```

## 三、收益对比

| 维度 | 当前版本(v3.4.1) | 插件化方案 |
|------|-----------------|-----------|
| L2层绑定 | 硬绑定Hindsight | 可插拔，用户自选 |
| 通用性 | 仅限Hindsight用户 | 所有Hermes用户 |
| 打包体积 | ~50KB | ~15KB（核心+null） |
| 安装复杂度 | 需先装Hindsight | 核心独立运行 |
| 扩展性 | 每增加L2选项需改SKILL | 只需增加插件目录 |
| 覆盖用户群 | ~30%* | ~100% |
| 安装成功率 | ~60% | ~95% |

*假设仅30%用户有Hindsight运行环境

## 四、实施步骤

1. 定义L2插件接口规范
2. 重构SKILL.md，移除Hindsight硬编码
3. 创建Hindsight插件（从现有内容抽取）
4. 创建Null插件（默认不使用L2）
5. 编写配置模板和安装脚本
6. 测试打包

预计工作量：12-14小时

## 五、相关决策

2026-06-19：用户询问Hindsight历史失败操作处理方案，采纳"保留现状"（方案A）。24条APIConnectionError为6月16日配置问题的历史残留，不影响当前系统运行。

## 六、v4.0 通用化改造方向（2026-06-19 用户确认）

### 用户确认的设计原则
1. **通用型**：不含个人定制内容，所有Hermes/OpenClaw用户可用
2. **双平台**：同时支持Hermes和OpenClaw
3. **插件化**：L2层可选可扩展，但不允许修改skill核心内容
4. **易用性**：一键部署，零配置即可使用（首次用户友好）
5. **版本化**：语义版本号，变更日志完整，版本管理科学严谨

### 命名变更
- 铁壁三 "Memory管理" → **"历史书"**（三层记忆就像历史书：目录/索引/正文）
- 铁壁四 "子Agent超时" → **"工蚁"**（多Agent协作就像蚁群分工）

### 工蚁迭代方向
- v1.0：子Agent超时应对（当前）
- v2.0：多Agent协作调度（Hermes）
- v3.0：跨平台协作（Hermes+OpenClaw）

### 待确认
- skillhub.cn 5.0评分标准（搜索未找到，需用户提供）
- GitHub发布方式（用户有GitHub账号但不熟悉发布流程）
