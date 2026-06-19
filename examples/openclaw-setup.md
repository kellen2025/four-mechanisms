# OpenClaw 配置示例

> 在OpenClaw中使用铁壁四规

---

## 安装路径

```
~/.openclaw/workspace/skills/four-mechanisms/
```

---

## 配置文件位置

```
~/.openclaw/config.yaml
```

在config.yaml中添加：

```yaml
# 铁壁四规配置
four_mechanisms:
  enabled: true
  version: 4.0.0
```

---

## SOUL.md 集成

在 `~/.openclaw/SOUL.md` 中添加：

```markdown
# 加载铁壁四规
skill_view(name='four-mechanisms')
```

这样每次会话开始时会自动加载铁壁四规。

---

## 脚本位置

安装后，脚本位于：

```
~/.openclaw/workspace/scripts/
├── mano_engine.sh
├── mano_retry.sh
├── mano_review.sh
├── mano_deploy.sh
└── mano_status.sh
```

---

## 文档位置

```
~/.openclaw/tushuguan/
├── INDEX.md
├── 07-规章制度/
│   └── 铁壁四规/
├── 方案/
├── 项目/
├── 会议/
└── 备份/
```
