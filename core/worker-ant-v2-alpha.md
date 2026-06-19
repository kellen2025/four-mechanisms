# 工蚁v2.0-alpha 阶段1：智能调度

> 实现一句话指令 → 自动分配给合适的Agent

---

## 设计目标

```
用户输入："帮我设计一个登录页面"
      ↓
任务路由器分析
  • 任务类型：UI设计
  • 需要能力：产品设计、UI/UX
      ↓
匹配最优Agent：PM（毙杀）
  • 专业领域：产品设计
  • 能力评级：A
  • 当前负载：20%
      ↓
自动调用：hermes chat --profile pm -Q -q "设计登录页面"
      ↓
结果返回给用户
```

---

## Agent能力表

### 数据结构

```yaml
agents:
  pm:
    name: 毙杀
    profile: mibao-kills-pm
    role: 产品经理
    capabilities:
      - 产品设计
      - 需求分析
      - UI/UX设计
      - 竞品分析
      - PRD撰写
    model: agnes
    proficiency: A  # A优秀 B良好 C一般
    max_load: 100
    current_load: 0
    status: idle   # idle / busy / offline
    
  coder:
    name: 码仔
    profile: mibao-kellen-coder
    role: 编码工程师
    capabilities:
      - 编码开发
      - 代码审查
      - Bug修复
      - 技术方案
      - API开发
      - 数据库设计
    model: mimo-v2.5-pro
    proficiency: A
    max_load: 100
    current_load: 0
    status: idle
    
  ops:
    name: 多宝
    profile: mibao-duobao-om
    role: 运营负责人
    capabilities:
      - 运营策划
      - 内容运营
      - 用户增长
      - 数据分析
      - 活动策划
      - 文案撰写
    model: agnes
    proficiency: B
    max_load: 100
    current_load: 0
    status: idle
    
  algorithm:
    name: Harry
    profile: harry
    role: 算法专家
    capabilities:
      - 算法设计
      - 模型训练
      - 数据分析
      - 机器学习
      - 游戏算法
    model: deepseek-v4-pro
    proficiency: A
    max_load: 100
    current_load: 0
    status: idle
```

---

## 任务路由器

### 任务类型映射

```yaml
task_types:
  # 产品类
  ui_design:
    keywords: [设计, UI, 界面, 页面, 原型, 交互]
    agent: pm
    priority: high
    
  requirement:
    keywords: [需求, PRD, 功能, 规格, 说明]
    agent: pm
    priority: high
    
  competitive_analysis:
    keywords: [竞品, 分析, 调研, 市场]
    agent: pm
    priority: medium
    
  # 开发类
  coding:
    keywords: [编码, 开发, 写代码, 实现, 功能]
    agent: coder
    priority: high
    
  bug_fix:
    keywords: [Bug, 修复, 问题, 错误, 异常]
    agent: coder
    priority: high
    
  code_review:
    keywords: [审查, Review, 代码质量, 优化]
    agent: coder
    priority: medium
    
  api_development:
    keywords: [API, 接口, 后端, 服务端]
    agent: coder
    priority: high
    
  # 运营类
  content_operation:
    keywords: [运营, 内容, 文案, 推广, 活动]
    agent: ops
    priority: high
    
  user_growth:
    keywords: [增长, 获客, 留存, 转化]
    agent: ops
    priority: medium
    
  data_analysis:
    keywords: [数据, 分析, 报表, 指标]
    agent: ops  # 或 algorithm，根据具体需求
    priority: medium
    
  # 算法类
  algorithm_design:
    keywords: [算法, 模型, 训练, 预测, AI]
    agent: algorithm
    priority: high
    
  game_mechanics:
    keywords: [游戏, 机制, 玩法, 数值]
    agent: algorithm
    priority: medium
```

### 路由逻辑

```python
def route_task(user_input):
    """
    任务路由器：分析用户输入，分配给合适的Agent
    """
    # 1. 关键词匹配
    matched_type = match_keywords(user_input)
    
    # 2. 获取对应Agent
    agent = get_agent_by_type(matched_type)
    
    # 3. 检查Agent状态
    if agent.status == 'busy':
        # 选择备选Agent或排队
        agent = get_alternative_agent(matched_type)
    
    # 4. 调用Agent
    result = call_agent(agent, user_input)
    
    # 5. 返回结果
    return result
```

---

## 调用方式

### 自动模式

```bash
# 用户直接输入任务
hermes chat -Q "帮我设计一个登录页面"

# 系统自动分析并分配给PM
# 等同于：
hermes chat --profile mibao-kills-pm -Q "设计登录页面"
```

### 手动模式（保留）

```bash
# 用户指定Agent
hermes chat --profile mibao-kellen-coder -Q "编写登录API"
```

---

## 配置文件

```yaml
# worker-ant-v2.yaml

# 智能调度开关
dispatch:
  auto_mode: true      # 自动模式
  fallback_agent: pm   # 默认Agent
  
# Agent能力表
agents: ...  # 见上方

# 任务类型映射
task_types: ...  # 见上方

# 超时配置
timeout:
  default: 1800       # 默认30分钟
  max: 3600           # 最大1小时
```
