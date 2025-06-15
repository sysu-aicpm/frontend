# smart_home_app

开发时，通过如下方式指定后端 API：

```shell
flutter run --dart-define=API_URL=http://172.18.198.206/api/v1
```

## MCP server

使用该功能，需要将 [mcp_server.py](https://github.com/sysu-aicpm/mcp-server/blob/main/mcp_server.py) 放置在可执行文件的同一目录下。

目前不支持移动端平台使用该功能，因为移动端不方便运行 MCP 服务。

目前仅支持 Gemini，并且 Gemini 不允许中国大陆 ip 访问，所以目前需要 “透明代理”、“增强模式” 等代理环境下启动程序。
