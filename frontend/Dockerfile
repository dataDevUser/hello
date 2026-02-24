# ─── Stage 1: Build Angular app ───────────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first (better layer caching)
COPY package*.json ./

# Install ALL dependencies (including devDependencies needed for build)
RUN npm ci

# Copy source code
COPY . .

# Build Angular app for production
# API_URL is baked in at build time via environment replacement
ARG API_URL=http://localhost/api
RUN sed -i "s|http://localhost:8080/api/tutorials|${API_URL}/tutorials|g" \
      src/app/services/tutorial.service.ts && \
    npx ng build --configuration production

# ─── Stage 2: Serve with Nginx ────────────────────────────────────────────────
FROM nginx:1.25-alpine

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular files
COPY --from=builder /app/dist/angular-15-crud /usr/share/nginx/html

# Copy custom nginx config for Angular routing (HTML5 pushState)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
