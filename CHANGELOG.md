# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/).

## [4.0.0] - 2026-06-19

### 🎉 首次发布

这是铁壁四规通用版的首次正式发布。

### ✨ 新增

#### 核心功能
- **马诺防线**：代码质量管理规范，四步验证流程
- **图书馆**：文档管理规范，5分类体系
- **历史书**：三层记忆架构（L1/L2/L3）
- **工蚁**：多Agent协作调度规范

#### 插件系统
- L2层插件化架构，支持可选可扩展
- Hindsight插件（推荐）
- Null插件（不使用L2）
- 自定义插件模板

#### 平台支持
- Hermes Agent 支持
- OpenClaw 支持
- 自动检测平台并适配

#### 安装体验
- 一键安装脚本 (`install.sh`)
- 零配置即可使用
- 安装验证脚本

#### 文档
- 完整的README用户指南
- 详细的插件开发指南
- FAQ常见问题
- TRACE合规清单

### 📋 TRACE合规

基于SkillHub TRACE评测体系设计：
- **T - Trust 可信任度**：无恶意代码、不收集数据、国内可用
- **R - Reliability 可靠性**：安装幂等、错误处理完善
- **A - Adaptability 适用性**：描述清晰、能力边界明确
- **C - Convention 规范性**：语义版本、完整变更日志
- **E - Effectiveness 有效性**：一键安装、零配置使用

---

## [未发布]

### 计划功能

#### v4.1.0
- 更多L2插件支持（Chroma、Weaviate等）
- 插件市场

#### v4.2.0
- 工蚁v2.0：Hermes多Agent协作增强

#### v5.0.0
- 工蚁v3.0：跨平台协作（Hermes+OpenClaw）

---

## 版本说明

- **主版本号 (Major)**：不兼容的API变更
- **次版本号 (Minor)**：新增功能（向下兼容）
- **修订号 (Patch)**：问题修复（向下兼容）
