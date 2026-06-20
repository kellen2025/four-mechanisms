# 通用Skill打包模式

> 将特定skill改造为通用版本的设计模式

## 设计原则

1. **通用型**：不含个人定制内容，所有用户可用
2. **双平台**：同时支持Hermes和OpenClaw
3. **插件化**：可选功能通过插件实现，核心不可修改
4. **易用性**：一键部署，零配置即可使用
5. **版本化**：语义版本号，变更日志完整

## 目录结构模板

```
skill-name-generic/
├── SKILL.md                    # 核心规范（通用版）
├── README.md                   # 用户说明文档（详细易懂）
├── CHANGELOG.md                # 变更日志（完整）
├── VERSION                     # 版本号文件
├── LICENSE                     # 开源协议
├── config.example.yaml         # 配置模板
├── .gitignore
│
├── core/                       # 核心模块（不可修改）
│   └── *.md
│
├── plugins/                    # 插件目录（可选可扩展）
│   ├── README.md               # 插件开发指南
│   ├── l2-interface.md         # 插件接口规范
│   ├── plugin-a/               # 插件A
│   ├── plugin-b/               # 插件B
│   └── _template/              # 自定义插件模板
│
├── scripts/                    # 通用脚本
│   ├── install.sh              # 一键安装脚本
│   ├── uninstall.sh            # 卸载脚本
│   └── health-check.sh         # 健康检查
│
├── references/                 # 参考文档
│   ├── architecture.md         # 架构设计
│   ├── faq.md                  # 常见问题
│   └── trace-compliance.md     # TRACE合规清单
│
└── examples/                   # 使用示例
    ├── quick-start.md
    ├── hermes-setup.md
    └── openclaw-setup.md
```

## 安装脚本模式

```bash
#!/bin/bash
# 1. 检测平台（Hermes/OpenClaw）
# 2. 创建目标目录
# 3. 复制核心文件
# 4. 让用户选择插件
# 5. 验证安装
```

## GitHub发布流程

1. 创建仓库（公开）
2. 首次提交（feat: vX.Y.Z）
3. 创建Release（tag: vX.Y.Z）
4. 同步到skillhub.cn

## 命名规范

- 通用版后缀：`-generic` 或无后缀
- 插件目录：`plugins/`
- 脚本目录：`scripts/`
- 参考文档：`references/`
