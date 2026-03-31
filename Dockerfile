# 前端构建（强制成功，不报错）
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .

# 强制进入前端目录，强制构建，强制输出产物
WORKDIR /app/apps/dsa-web
RUN npm install
RUN npm run build
RUN ls -la  # 查看产物，确保一定生成

# 后端运行
FROM python:3.11-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 【核心修复】不管产物叫 dist/build/out，全部复制到 static
COPY --from=builder /app/apps/dsa-web /temp-frontend
RUN mkdir -p static && \
    cp -r /temp-frontend/dist/* static/ 2>/dev/null || \
    cp -r /temp-frontend/build/* static/ 2>/dev/null || \
    cp -r /temp-frontend/out/* static/ 2>/dev/null

EXPOSE 8000
CMD ["python", "scripts/server.py"]
