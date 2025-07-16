# Multi-stage build for optimized image size
FROM node:22-alpine AS builder

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies with clean install
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# Copy source code
COPY . .

# Build if needed (though this project uses experimental strip types)
# RUN npm run build

# Runtime stage
FROM node:22-alpine

# Add non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Install wget for healthcheck
RUN apk add --no-cache wget

WORKDIR /usr/src/app

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

# Create config directory for potential future use
RUN mkdir -p /usr/src/app/config && \
    chown -R nodejs:nodejs /usr/src/app

# Switch to non-root user
USER nodejs

# Environment variables
ENV NODE_ENV=production \
    MCP_HTTP_MODE=true \
    MCP_PORT=3000

# Expose port
EXPOSE ${MCP_PORT}

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${MCP_PORT}/health || exit 1

# Start the application
CMD ["node", "--experimental-strip-types", "index.ts", "--http"]
