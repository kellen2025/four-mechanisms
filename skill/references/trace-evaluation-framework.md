---
title: "SkillHub TRACE评测体系"
created: 2026-06-19
category: mechanism
tags: [trace, skillhub, evaluation, quality]
status: active
---

# SkillHub TRACE评测体系

> 来源：https://skillhub.cn/tutorials#trace-evaluation
> 用途：铁壁四规通用版发布到skillhub.cn的评分标准

## 五维度（由基础到价值）

### T — Trust 可信任度
- 最小权限原则（不要求无关高权限）
- 输入验证（防止注入攻击）
- 敏感数据保护（不暴露用户隐私）
- 依赖安全（可溯源、无恶意代码）
- 国内网络环境下可直接跑通
- 完整支持中文交互

### R — Reliability 可靠性
- 同样任务每次正常执行
- 异常输入合理处理
- 失败时给出可理解反馈
- 常见/边界/复杂输入下保持一致表现

### A — Adaptability 适用性
- Skill与用户需求匹配精度高
- 能力边界清晰
- 语义匹配准确（不误触发、不漏调用）

### C — Convention 规范性
- 可读性好（快速理解能解决什么问题）
- 可维护性好（快速定位如何扩展/修复）
- 渐进式信息披露
- 可复用（从一次性能力沉淀为可复用资产）

### E — Effectiveness 有效性
- 结果正确
- 输出完整
- 符合预期格式
- 可直接使用
- 提供额外价值（信息整合、判断建议）

## 评测定位

TRACE不是"终局裁判"，更接近一套质量观察坐标：
- 帮助用户判断Skill是否值得尝试
- 帮助开发者明确从哪里继续优化
- 帮助平台判断是否适合推荐

## 铁壁四规合规清单

| 维度 | 要求 | 铁壁四规实现 |
|------|------|-------------|
| T Trust | 国内可用 | 不依赖海外API，Hindsight可选 |
| T Trust | 中文支持 | 全中文文档和交互 |
| T Trust | 无恶意代码 | 开源、依赖透明 |
| R Reliability | 幂等安装 | install.sh重复执行不报错 |
| R Reliability | 零配置可用 | 默认配置完整 |
| A Adaptability | 描述清晰 | SKILL.md标准元数据 |
| A Adaptability | 边界明确 | 四规功能不越界 |
| C Convention | 语义版本号 | v4.0.0 + CHANGELOG.md |
| C Convention | 文档完整 | README/FAQ/示例齐全 |
| E Effectiveness | 一键部署 | bash install.sh |
| E Effectiveness | 立即生效 | 安装后四规自动生效 |
