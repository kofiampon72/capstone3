# Stage 1: Builder — installs all dependencies including devDependencies
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files first (layer caching — only reinstalls if package.json changes)
COPY package*.json ./
RUN npm ci --include=dev

# Copy the rest of the source
COPY . .

# Stage 2: Production — only runtime dependencies, no dev tools
FROM node:20-alpine AS production
WORKDIR /app

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package files and install ONLY production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built app from the builder stage
COPY --from=builder /app/public ./public
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/server.js ./server.js

# Create data directory and set ownership
RUN mkdir -p /app/data && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the app port
EXPOSE 3000

# Health check — Docker will ping this to know if the container is alive
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget --spider -q http://localhost:3000 || exit 1

CMD ["node", "server.js"]
