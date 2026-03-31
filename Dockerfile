# --------------- 前端构建阶段 ---------------
FROM node:18-alpine AS builder
WORKDIR /app

# 复制整个项目（确保能找到前端目录）
COPY . .

# 进入前端目录安装依赖并构建
WORKDIR /app/apps/dsa-web
RUN npm install && npm run build

# --------------- 后端运行阶段 ---------------
FROM python:3.11-slim
WORKDIR /app

# 安装系统依赖（解决 Python 包编译问题）
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制后端全部代码
COPY . .

# 核心：把前端构建产物复制到后端 static 目录
COPY --from=builder /app/apps/dsa-web/dist ./static

# 暴露端口
EXPOSE 8000

# 启动服务（根据你的入口调整，默认是 server.py）
CMD ["python", "scripts/server.py"]
