FROM node:20-alpine AS builder
WORKDIR /app
COPY 001-frontend/package*.json ./
RUN npm install --registry https://registry.npmmirror.com
COPY 001-frontend/ .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY 001-frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
