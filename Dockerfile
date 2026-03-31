FROM python:3.11-slim

WORKDIR /app

# 安装 Node.js + npm 用于构建前端
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# 复制项目代码
COPY . .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 构建前端
WORKDIR /app/apps/dsa-web
RUN npm install
RUN npm run build

# 回到根目录启动服务
WORKDIR /app
CMD ["python", "main.py", "--webui-only"]
