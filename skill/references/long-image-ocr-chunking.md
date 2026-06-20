# 长图分段 OCR 提取工作流

> 适用场景：截图高度超过 4000px（如长文档、聊天记录、网页全页截图），直接 OCR 效果差或超时

---

## 工作流

### 1. 检查图片尺寸
```python
from PIL import Image
img = Image.open("path.png")
print(f"{img.size[0]}x{img.size[1]}")  # 宽x高
```

### 2. 分段切割（每段 4000px）
```python
chunk = 4000
h = img.size[1]
for i in range((h // chunk) + 1):
    y1, y2 = i * chunk, min((i+1) * chunk, h)
    if y1 >= h: break
    img.crop((0, y1, 1200, y2)).save(f"chunks/{i}.png")
```

### 3. 逐段 OCR
```bash
# 需要 tesseract + 中文语言包
# apt install tesseract-ocr tesseract-ocr-chi-sim
for f in chunks/*.png; do
  tesseract "$f" stdout -l chi_sim+eng --psm 6 2>/dev/null
done > output.txt
```

### 4. 拼接校验
合并各段文本，检查段落衔接处是否有重复或断裂。

---

## 替代方案：视觉模型直接分析

当 OCR 精度不够时（如复杂排版、表格、代码块），可改用 `vision_analyze`：
- 将长图裁剪为 3-4 段（top/mid/bot）
- 逐段调用 vision_analyze
- 优点：能理解表格、代码块等结构化内容
- 缺点：逐字精度不如 OCR，适合"理解"而非"提取"

---

## Pitfalls

- **PIL 裁剪坐标**：`crop((left, top, right, bottom))`，不是 `(x, y, w, h)`
- **tesseract 中文**：必须指定 `-l chi_sim+eng`，否则中文识别率为零
- **文件路径**：Python f-string 中的变量在 terminal heredoc 中不展开，需用独立脚本文件
- **分段边界**：段落可能被切断，导致 OCR 丢失跨段内容。4000px 是经验值，可根据内容密度调整
