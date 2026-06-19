# Hindsight 插件

> 功能完整的L2层实现，支持向量检索和知识图谱

---

## 简介

Hindsight是铁壁四规推荐的L2层实现，提供：
- 向量检索（retain/recall/reflect）
- 知识图谱（实体关系）
- 本地部署（数据安全）

---

## 安装要求

- Python 3.10+
- 4GB+ 可用内存
- 可选：GPU（加速嵌入计算）

---

## 安装

```bash
bash plugins/hindsight/install.sh
```

安装脚本会：
1. 安装Hindsight依赖
2. 下载模型文件（首次运行）
3. 启动daemon服务
4. 验证安装结果

---

## 配置

在 `config.yaml` 中配置：

```yaml
history_book:
  l2:
    plugin: hindsight
    hindsight:
      bank_id: hermes
      port: 9177
      llm_api_key: "your-api-key"  # 可选
```

---

## 使用

安装后自动生效，无需额外操作。Agent会自动：
- 调用 `retain()` 写入重要记忆
- 调用 `recall()` 检索历史知识
- 调用 `reflect()` 进行深度分析

---

## 故障排除

### daemon启动失败

```bash
# 检查端口是否被占用
lsof -i :9177

# 手动启动
hindsight-api --daemon --port 9177
```

### 模型下载失败（国内网络）

设置HF镜像：
```bash
export HF_ENDPOINT=https://hf-mirror.com
```
