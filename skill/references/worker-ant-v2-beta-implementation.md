# 工蚁v2.0-beta 阶段2 实现记录

> 2026-06-20 实现，基于Hermes Kanban的任务队列系统

## 架构

```
用户输入 → 关键词匹配Agent → 推断优先级 → 创建Kanban卡片 → 队列管理 → 进度看板
```

复用Hermes Kanban的SQLite存储和dispatcher，不重复造轮子。

## 脚本

| 脚本 | 路径 | 用途 |
|------|------|------|
| worker-ant-queue.sh | ~/.hermes/scripts/ | 任务队列（添加/执行/状态/看板） |
| worker-ant-dashboard.sh | ~/.hermes/scripts/ | 独立进度看板 |

## Agent路由规则

| 关键词 | Agent | Profile |
|--------|-------|---------|
| 设计/UI/界面/需求/竞品/调研 | pm | mibao-kills-pm |
| 开发/Bug/修复/API/后端/数据库 | coder | mibao-kellen-coder |
| 运营/内容/文案/增长/留存/转化 | ops | mibao-duobao-om |
| 算法/模型/训练/预测/游戏/数值 | algorithm | harry |
| 其他 | default | mibao |

## 优先级推断

| 关键词 | 级别 | 说明 |
|--------|------|------|
| 紧急/urgent/p0/崩溃/线上 | 1 | 立即执行 |
| 重要/high/p1/尽快 | 2 | 优先执行 |
| 其他 | 3 | 正常队列 |

## 验证结果（2026-06-20）

10项测试全部通过：
1. help显示用法 ✅
2. add --help不再创建任务 ✅
3. 空输入正确报错 ✅
4. 自动匹配PM ✅
5. 指定Agent ✅
6. 紧急优先级推断 ✅
7. 运营类路由 ✅
8. 算法类路由 ✅
9. 状态统计 ✅
10. 看板显示等待时间 ✅

## 发现并修复的BUG

### BUG1: --help 被当作任务标题

**现象**: `worker-ant-queue add --help` 创建了标题为"--help"的任务
**原因**: case语句未处理--help参数， falls through到*) break，然后$*包含--help
**修复**: 在cmd_add的参数解析中增加 `--help|-h) usage; exit 0`
**教训**: bash脚本的flag解析必须显式处理--help，不能依赖*) catch-all

### BUG2: 看板不显示任务等待时间

**现象**: 任务已创建但看板不显示age
**原因**: 只对ready状态计算age，且<60s不显示；任务被dispatcher claim后变成running
**修复**: 扩展到running/blocked状态，增加秒级显示(0-60s)
**教训**: kanban任务会被dispatcher自动claim，状态会从ready变为running

## 已知行为

- dispatcher每60s自动claim ready任务 → 任务状态会从ready变为running
- reclaim可将running任务退回ready状态
- kanban create的--goal参数启用目标循环模式（自动重试直到完成）
