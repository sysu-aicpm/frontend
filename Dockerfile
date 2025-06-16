FROM ubuntu/nginx:latest
COPY ./build/web /usr/share/nginx/html
COPY --chown=1000:1000 ./mcp_server /usr/local/bin/mcp_server
RUN chmod +111 /usr/local/bin/mcp_server
