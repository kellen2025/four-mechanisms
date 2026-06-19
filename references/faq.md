# 常见问题 (FAQ)

---

## 安装问题

### Q: 安装脚本报错怎么办？

A: 请检查：
1. 是否有bash环境：`bash --version`
2. 是否有写入权限：`ls -la ~/.hermes/skills/`
3. 网络是否正常（下载依赖时需要）

### Q: 如何卸载？

A: 
```bash
# 删除技能目录
rm -rf ~/.hermes/skills/four-mechanisms/

# 删除脚本
rm ~/.hermes/scripts/mano_*.sh
```

### Q: 安装后在哪里查看文档？

A: 
```bash
cat ~/.hermes/skills/four-mechanisms/README.md
```

---

## 使用问题

### Q: 四规是什么？

A: 铁壁四规是AI Agent的四道铁壁：
1. 马诺防线：代码质量管理
2. 图书馆：文档管理
3. 历史书：三层记忆架构
4. 工蚁：多Agent协作

### Q: L2层必须安装吗？

A: 不必须。可以选择：
- Hindsight（推荐）：功能完整
- Null：不使用L2，只用L1和L3

### Q: 如何更新版本？

A: 
```bash
cd ~/.hermes/skills/four-mechanisms
git pull
# 或重新运行安装脚本
```

---

## 平台问题

### Q: 支持哪些平台？

A: 
- Hermes Agent ✓
- OpenClaw ✓

### Q: 如何判断我的平台？

A: 安装脚本会自动检测。手动判断：
- `~/.hermes/` 存在 → Hermes
- `~/.openclaw/` 存在 → OpenClaw

---

## 开发问题

### Q: 如何开发自定义插件？

A: 
1. 参考 `plugins/_template/`
2. 实现 `plugins/l2-interface.md` 中的接口
3. 在 `config.yaml` 中配置插件名

### Q: 如何贡献代码？

A: 
1. Fork 仓库
2. 创建特性分支
3. 提交PR
4. 等待审核合并

---

## 其他问题

### Q: 遇到bug怎么办？

A: 
1. 查看FAQ是否有解决方案
2. 搜索GitHub Issues
3. 提交新的Issue

### Q: 如何联系作者？

A: 
- GitHub: https://github.com/kellen2025
- Issues: https://github.com/kellen2025/four-mechanisms/issues
