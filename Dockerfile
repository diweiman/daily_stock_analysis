#  ===================== 前端自动构建 =====================
FROM node:18-alpine AS frontend
WORKDIR /app
COPY . .

# 进入你的前端目录并构建（精准匹配你的项目）
WORKDIR /app/apps/dsa-web
RUN npm install
RUN npm run build

#  ===================== 后端服务 =====================
FROM python:3.11-slim
WORKDIR /app

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends gcc
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 把前端构建好的页面复制到后端
COPY --from=frontend /app/apps/dsa-web/dist /app/static/

# 启动服务（你的真实启动路径）
EXPOSE 8000
CMD ["python", "scripts/server.py"]
