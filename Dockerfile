# 前端构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY apps/dsa-web ./apps/dsa-web
WORKDIR /app/apps/dsa-web
RUN npm install && npm run build

# Python 运行阶段
FROM python:3.11-slim
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制所有代码
COPY . .

# 复制构建好的前端
COPY --from=builder /app/apps/dsa-web/build ./apps/dsa-web/build

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["python", "server.py"]
