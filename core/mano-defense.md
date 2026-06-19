# 铁壁一：马诺防线 (Mano Defense Line)

> 代码质量管理规范，确保每一行代码都经过严格校验

---

## 四步验证流程

```
代码质量关(ruff/dart analyze) → 逻辑测试关(pytest/flutter test)
→ 安全扫描关(pre-commit) → 用户验证
```

---

## 工具链

| 工具 | 用途 | 配置 |
|------|------|------|
| ruff | Python代码检查 | pyproject.toml |
| mypy | Python类型检查 | mypy.ini |
| pytest | Python测试 | pytest.ini |
| pre-commit | Git钩子 | .pre-commit-config.yaml |
| dart analyze | Dart代码检查 | analysis_options.yaml |
| flutter test | Flutter测试 | test/ |

---

## 适用范围

- 所有代码编写（Flutter/Dart/Python）
- 主控调度执行，主控本人严禁编码

---

## 验证命令

```bash
# Python代码检查
ruff check .
mypy .

# Python测试
pytest

# Dart代码检查
dart analyze

# Flutter测试
flutter test
```
