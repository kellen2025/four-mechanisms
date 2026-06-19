# 插件开发指南

> 如何为铁壁四规开发L2层插件

---

## 概述

铁壁四规的L2层（历史书的温存储层）采用插件化架构，允许用户：
- 选择现有的L2实现（如Hindsight）
- 不使用L2层（Null插件）
- 开发自定义L2实现

---

## 可用插件

| 插件 | 说明 | 推荐度 |
|------|------|--------|
| [hindsight/](hindsight/) | 功能完整的向量检索工具 | ⭐⭐⭐⭐⭐ |
| [null/](null/) | 不使用L2层 | ⭐⭐ |
| [_template/](_template/) | 自定义插件模板 | - |

---

## 快速开始

### 使用现有插件

```bash
# 安装Hindsight插件
bash plugins/hindsight/install.sh

# 或使用Null插件
cp -r plugins/null/ plugins/l2/
```

### 开发自定义插件

1. 复制模板
```bash
cp -r plugins/_template/ plugins/my-plugin/
```

2. 实现接口
参考 `l2-interface.md` 实现以下函数：
- `retain(content, context, tags)`
- `recall(query, limit)`
- `reflect(query)`

3. 测试插件
```bash
python -m pytest plugins/my-plugin/test_plugin.py
```

4. 注册插件
在 `config.yaml` 中设置：
```yaml
history_book:
  l2:
    plugin: my-plugin
```

---

## 插件接口规范

详见 [l2-interface.md](l2-interface.md)

---

## 插件目录结构

```
plugins/
├── README.md               # 本文档
├── l2-interface.md         # 接口规范
├── hindsight/              # Hindsight插件
│   ├── PLUGIN.md
│   ├── install.sh
│   └── config.yaml
├── null/                   # Null插件
│   └── PLUGIN.md
└── _template/              # 自定义模板
    ├── PLUGIN.md.template
    └── plugin.py.template
```

---

## 贡献插件

欢迎贡献高质量的L2插件！

### 贡献流程

1. Fork 本仓库
2. 在 `plugins/` 下创建你的插件目录
3. 实现接口规范
4. 编写文档和测试
5. 提交 Pull Request

### 插件质量要求

- 遵循TRACE评测体系
- 完整的README文档
- 单元测试覆盖率 > 80%
- 无恶意代码
