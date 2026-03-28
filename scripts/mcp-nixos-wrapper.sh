#!/bin/sh
# MCP Server NixOS 包装脚本
# 用于解决 FastMCP banner 干扰 JSON-RPC 通信的问题

# 重定向 uvx 的标准错误输出到 /dev/null
# 这样可以抑制 FastMCP 的欢迎信息和日志
exec uvx mcp-nixos 2>/dev/null
