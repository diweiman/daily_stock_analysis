# 前端构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY apps/dsa-web ./apps/dsa-web
WORKDIR /app/apps/dsa-web
RUN npm install && npm run build

# 后端运行阶段
FROM python:3.11-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 【核心修复】把前端构建产物放到项目根目录 static，后端自动识别
COPY --from=builder /app/apps/dsa-web/static ./static

EXPOSE 8000
CMD ["python", "server.py"]
