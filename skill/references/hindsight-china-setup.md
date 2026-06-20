# Hindsight 国内环境配置指南

> 2026-06-17 实测验证，适用于中国大陆网络环境。

## 三组件架构

Hindsight不是单独运行一个大模型，而是三个组件协作：

| 组件 | 类型 | 大小 | 功能 | 运行方式 |
|------|------|------|------|----------|
| GPT-OSS-20B | 大语言模型 | ~12GB | 实体提取、反思综合、冲突检测 | llama.cpp服务器(端口8080) |
| bge-small-en-v1.5 | 嵌入模型 | ~130MB | 文本→向量(相似度检索) | Hindsight daemon进程内 |
| ms-marco-MiniLM-L-6-v2 | 重排序模型 | ~80MB | 搜索结果相关性打分 | Hindsight daemon进程内 |

后两个是小型专用模型，不是独立服务器，加载到daemon进程内存中。

## 国内网络问题

bge和MiniLM需要从HuggingFace下载。国内无法连接huggingface.co。

## 解决方案

### 方案A：国内镜像（推荐）

```bash
# 1. 添加到Hermes配置（Hermes自身使用）
echo 'HF_ENDPOINT=https://hf-mirror.com' >> ~/.hermes/.env

# 2. 添加到daemon工作目录（关键！daemon从这里读取）
echo 'HF_ENDPOINT=https://hf-mirror.com' > /home/kellen/.env
```

### 方案B：手动下载模型

从 https://hf-mirror.com 手动下载后放到 `~/.cache/huggingface/hub/` 对应目录。

## dotenv路径陷阱

Hindsight daemon的CWD是 `/home/kellen`（用户home目录）。python-dotenv从CWD向上搜索.env文件。

`~/.hermes/.env` 不在搜索路径上！必须在 `/home/kellen/.env` 放一份。

验证方法：
```python
from dotenv import find_dotenv
print(find_dotenv(usecwd=True))  # 应输出 /home/kellen/.env
```

## 模型下载路径

```
~/.cache/huggingface/hub/models--BAAI--bge-small-en-v1.5/
~/.cache/huggingface/hub/models--cross-encoder--ms-marco-MiniLM-L-6-v2/
```

## daemon积压问题

如果retain调用过多，daemon任务队列会积压。llama.cpp同时处理多个retain+consolidation请求会超时。

解决方案：`pkill -f "hindsight-api"` 清理后重启，daemon会从数据库重新加载未完成任务。
