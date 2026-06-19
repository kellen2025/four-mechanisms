# Hermes 配置示例

> 在Hermes Agent中使用铁壁四规

---

## 安装路径

```
~/.hermes/skills/four-mechanisms/
```

---

## 配置文件位置

```
~/.hermes/config.yaml
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

在 `~/.hermes/SOUL.md` 中添加：

```markdown
# 加载铁壁四规
skill_view(name='four-mechanisms')
```

这样每次会话开始时会自动加载铁壁四规。

---

## 脚本位置

安装后，脚本位于：

```
~/.hermes/scripts/
├── mano_engine.sh
├── mano_retry.sh
├── mano_review.sh
├── mano_deploy.sh
└── mano_status.sh
```

---

## 文档位置

```
~/.hermes/tushuguan/
├── INDEX.md
├── 机制/
├── 方案/
├── 项目/
├── 会议/
└── 备份/
```
