# SkillHub.cn 发布指南

> 基于2026-06-19实际发布经验整理

---

## TRACE评测体系（skillhub.cn官方标准）

来源：https://skillhub.cn/tutorials#trace-evaluation

五个维度，从基础到价值：

| 维度 | 全称 | 核心要求 |
|------|------|----------|
| T | Trust 可信任度 | 无恶意代码、不收集数据、国内网络可用、支持中文 |
| R | Reliability 可靠性 | 安装幂等、错误处理完善、失败反馈清晰 |
| A | Adaptability 适用性 | 描述清晰、能力边界明确、场景匹配精准 |
| C | Convention 规范性 | 语义版本号、完整变更日志、可维护可复用 |
| E | Effectiveness 有效性 | 一键安装、零配置使用、结果正确有价值 |

---

## 上传限制（已踩坑）

skillhub.cn 对上传的zip包有文件类型限制，以下文件**不允许**：

| 文件 | 状态 | 说明 |
|------|------|------|
| VERSION | ❌ 不允许 | 打包时必须排除 |
| LICENSE | ❌ 不允许 | 打包时必须排除 |
| .git/* | ❌ 不允许 | 打包时必须排除 |
| SKILL.md | ✅ 必须有 | 核心规范文件 |
| README.md | ✅ 推荐 | 用户指南 |
| CHANGELOG.md | ✅ 推荐 | 变更日志 |

### 打包命令

```bash
zip -r skill-v1.0.0.zip . -x ".git/*" "VERSION" "LICENSE"
```

---

## 发布流程

1. 创建GitHub仓库（公开）
2. 推送代码
3. 创建Release（tag: v1.0.0）
4. 登录 skillhub.cn → 发布Skill
5. 填写仓库地址、描述、标签
6. 上传zip包
7. 等待审核

---

## 描述模板

```
一句话介绍 + 核心功能列表 + 适用场景 + 平台支持
```

示例：
```
铁壁四规 —— AI Agent的四道铁壁：马诺防线（代码质量）、图书馆（文档管理）、历史书（三层记忆）、工蚁（多Agent协作），通过TRACE五维评测，支持Hermes/OpenClaw双平台，一键部署即用。
```
