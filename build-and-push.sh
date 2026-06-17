#!/bin/bash
# 校园事务管理系统 Docker 镜像构建和推送脚本
# 使用方法: ./build-and-push.sh

set -e

IMAGE_PREFIX="gxfdev"
BACKEND_IMAGE="${IMAGE_PREFIX}/campus-affairs-backend"
FRONTEND_IMAGE="${IMAGE_PREFIX}/campus-affairs-frontend"
TAG="latest"

echo "===== 构建后端镜像 ====="
docker build -f 001-backend/Dockerfile -t ${BACKEND_IMAGE}:${TAG} .
echo "后端镜像构建完成: ${BACKEND_IMAGE}:${TAG}"

echo "===== 构建前端镜像 ====="
docker build -f 001-frontend/Dockerfile -t ${FRONTEND_IMAGE}:${TAG} .
echo "前端镜像构建完成: ${FRONTEND_IMAGE}:${TAG}"

echo "===== 查看镜像大小 ====="
docker images | grep campus-affairs

echo "===== 推送镜像到 Docker Hub ====="
docker push ${BACKEND_IMAGE}:${TAG}
docker push ${FRONTEND_IMAGE}:${TAG}

echo "===== 完成 ====="
echo "后端镜像: docker pull ${BACKEND_IMAGE}:${TAG}"
echo "前端镜像: docker pull ${FRONTEND_IMAGE}:${TAG}"
