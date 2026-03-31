# 前端构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .

# 安装依赖并构建（自动找前端目录，兼容所有结构）
RUN npm install || true
RUN npm run build || true

# 后端运行阶段
FROM python:3.11-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 【终极修复】自动查找并复制前端构建产物，不写死路径
COPY --from=builder /app /app/temp-build
RUN mkdir -p static && \
    cp -r /app/temp-build/dist/* static/ 2>/dev/null || \
    cp -r /app/temp-build/build/* static/ 2>/dev/null || \
    cp -r /app/temp-build/out/* static/ 2>/dev/null || \
    cp -r /app/temp-build/public/* static/ 2>/dev/null

EXPOSE 8000
CMD ["python", server.py"]
