# FastAPI 后端开发工作流

> 标准化的后端API开发流程，确保代码质量和一致性。

## 开发顺序（严格按序）

```
1. Schema (Pydantic) → 2. Service (业务逻辑) → 3. Endpoint (API路由) → 4. Tests → 5. Router注册
```

### Step 1: Schema (`app/schemas/xxx.py`)
- 定义请求/响应的Pydantic模型
- 使用`Field`添加字段描述（自动生成API文档）
- 响应模型统一用`code`/`message`/`data`包装

### Step 2: Service (`app/services/xxx_service.py`)
- 纯业务逻辑，不依赖FastAPI
- 接收`AsyncSession`作为参数
- 使用SQLAlchemy `select`查询，返回dict或Schema对象
- 辅助函数用`_`前缀（如`_draw_to_dict`）

### Step 3: Endpoint (`app/api/v1/endpoints/xxx.py`)
- 薄层：只做参数解析和响应包装
- 调用Service层获取数据
- 统一返回格式：`{"code": 0, "message": "success", "data": ...}`
- 错误返回：`{"code": 404, "message": "未找到...", "data": null}`

### Step 4: Tests (`tests/test_xxx.py`)
- 集成测试：直接调用真实API（`httpx.AsyncClient`）
- 测试有数据场景（种子数据已存在）
- 测试不存在的彩种（用`xxxxx`作为code）
- 测试参数校验（如periods<10应返回422）

### Step 5: Router注册 (`app/api/v1/router.py`)
- `api_router.include_router(xxx.router, prefix="/xxx", tags=["标签"])`
- 同时在`endpoints/__init__.py`中导出

## 马诺防线校验

```bash
# 第一关：代码质量
cd backend && ruff check .

# 第二关：逻辑测试
sg docker -c "docker exec caisuan-api python -m pytest tests/ -v"

# 第三关：安全合规
grep -r "password\|secret\|api_key" --include="*.py" . | grep -v __pycache__
```

## API验证模板

```python
# test_apis.py — 临时验证脚本，验证后删除
import httpx

with httpx.Client(timeout=10) as client:
    for name, path in apis:
        r = client.get(f"http://localhost:8000/api/v1{path}")
        d = r.json()
        print(f"{'OK' if d.get('code') == 0 else 'FAIL'} | {name}")
```

## 常见坑

- **模型属性不存在**：检查实际模型定义，不要凭印象写属性名
- **测试假设空DB**：种子数据已存在，测试应适配有数据场景
- **Docker tests未同步**：docker-compose.yml需挂载`./tests:/code/tests`
- **重启方式**：修改docker-compose.yml后用`docker compose up -d`（recreate），不是`docker restart`
- **async session依赖**：`_get_db()`必须是`async def`，内部用`async for session in get_db(): yield session`
- **bcrypt+passlib不兼容**：bcrypt>=4.1与passlib 1.7冲突，直接用bcrypt模块
- **SQLAlchemy ForeignKey缺失**：relationship报错时检查Column是否有ForeignKey
- **conftest.py mock污染类型**：不要mock sys.modules，会破坏FastAPI的类型解析

> 深度技术细节详见独立skill：`fastapi-docker-backend`（async模式、ORM陷阱、JWT认证、后台任务等）
