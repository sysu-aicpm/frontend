FROM nginx:latest
COPY ./build/web /usr/share/nginx/html
COPY --chown=1000:1000 --chmod=+111 ./mcp_server "/usr/local/bin/mcp_server"
