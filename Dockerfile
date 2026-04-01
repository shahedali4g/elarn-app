# -------- Stage 1: Build Stage --------
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build


# -------- Stage 2: Production Stage --------
FROM nginx:alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy build files
COPY --from=build /app/build /usr/share/nginx/html

# Set permissions so appuser can read files
RUN chown -R appuser:appgroup /usr/share/nginx/html \
    && chmod -R 755 /usr/share/nginx/html

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]