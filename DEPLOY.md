# Socket MCP Docker Deployment Guide

This guide covers deploying Socket MCP as part of your MCP infrastructure.

## Prerequisites

1. Docker and Docker Compose installed
2. Socket.dev API key ([Get one here](https://docs.socket.dev/reference/creating-and-managing-api-tokens))
3. Access to the MCP network (or create it)

## Quick Start

1. **Clone and configure:**
   ```bash
   git clone https://github.com/SamuraiBuddha/socket-mcp.git
   cd socket-mcp
   cp .env.example .env
   # Edit .env and add your SOCKET_API_KEY
   ```

2. **Create MCP network (if not exists):**
   ```bash
   docker network create mcp-network
   ```

3. **Deploy:**
   ```bash
   docker-compose up -d
   ```

4. **Verify health:**
   ```bash
   curl http://localhost:3000/health
   ```

## Integration Options

### Standalone HTTP Mode
The default configuration runs Socket MCP in HTTP mode on port 3000:
```json
{
  "mcpServers": {
    "socket-mcp": {
      "type": "http",
      "url": "http://localhost:3000"
    }
  }
}
```

### Integration with Docker MCP Toolkit
Add to your main MCP toolkit docker-compose.yml:
```yaml
  socket-mcp:
    image: socket-mcp:latest
    build: ./socket-mcp
    container_name: socket-mcp
    environment:
      - SOCKET_API_KEY=${SOCKET_API_KEY}
    networks:
      - mcp-network
    ports:
      - "3009:3000"  # Different port to avoid conflicts
```

### MAGI Fleet Integration
For deployment on your MAGI infrastructure:
1. Build and tag the image: `docker build -t magi-registry/socket-mcp:latest .`
2. Push to your local registry
3. Deploy via your orchestration system

## Advanced Configuration

### Custom Build Args
```bash
docker build \
  --build-arg NODE_VERSION=22 \
  --build-arg API_BASE_URL=https://custom.socket.dev \
  -t socket-mcp:custom .
```

### Volume Mounts (optional)
```yaml
volumes:
  - ./custom-config.json:/usr/src/app/config/config.json:ro
  - ./logs:/usr/src/app/logs
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 256M
    reservations:
      cpus: '0.25'
      memory: 128M
```

## Monitoring

### Health Check
```bash
# Basic health check
curl http://localhost:3000/health

# Watch health status
watch -n 5 'curl -s http://localhost:3000/health | jq'
```

### Logs
```bash
# View logs
docker-compose logs -f socket-mcp

# View last 100 lines
docker-compose logs --tail=100 socket-mcp
```

## Troubleshooting

### Container won't start
- Check API key: `docker-compose config | grep SOCKET_API_KEY`
- Verify Node.js 22 support in base image
- Check port conflicts: `netstat -tulpn | grep 3000`

### API errors
- Verify API key permissions (needs `packages:list`)
- Check network connectivity to api.socket.dev
- Review logs for detailed errors

### Performance issues
- Adjust resource limits based on usage
- Consider caching strategies for repeated queries
- Monitor with: `docker stats socket-mcp`

## Security Considerations

1. **API Key Protection:**
   - Never commit .env files
   - Use secrets management in production
   - Rotate keys regularly

2. **Network Isolation:**
   - Use internal networks for MCP communication
   - Expose only necessary ports

3. **Container Security:**
   - Runs as non-root user (nodejs:1001)
   - Minimal Alpine base image
   - No unnecessary packages

## Integration with Your Tools

### LM Studio Sidekick
Offload batch dependency checking:
```javascript
// In your sidekick workflow
const deps = ['express@4.18.2', 'lodash@4.17.21', 'react@18.2.0'];
const scores = await batchCheckDependencies(deps);
```

### N8N Workflows
Create automated security scanning workflows:
1. Trigger on git push
2. Extract package.json dependencies
3. Call Socket MCP for scoring
4. Alert on low scores

### Sequential Thinking Integration
Add to your tool chain for systematic security checks during development planning.

## Maintenance

### Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose build --no-cache
docker-compose up -d
```

### Backup
No persistent data to backup - stateless service.

### Cleanup
```bash
docker-compose down
docker image prune -f
```

## Support

- Socket MCP Issues: https://github.com/SocketDev/socket-mcp/issues
- Socket.dev Docs: https://docs.socket.dev/
- Your Fork: https://github.com/SamuraiBuddha/socket-mcp
