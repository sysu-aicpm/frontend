FROM vosarat/flutter AS build

COPY . /app
WORKDIR /app
RUN flutter clean
RUN flutter build web

FROM nginx:latest
ARG MCP_BIN_URL="https://github.com/sysu-aicpm/mcp-server/releases/download/v0.0.1/mcp_server"
ARG INSTALL_DIR="/usr/local/bin"
COPY --from=build /app/build/web /usr/share/nginx/html
RUN apt-get update && \
    apt-get dist-upgrade -y --auto-remove --purge --no-install-recommends \
        ca-certificates wget &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    wget -O "${INSTALL_DIR}/mcp_server" "${MCP_BIN_URL}" && \
    chmod +111 "${INSTALL_DIR}/mcp_server"