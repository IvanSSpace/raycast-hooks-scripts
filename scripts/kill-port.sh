#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Kill Process by Port
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 💀
# @raycast.argument1 { "type": "text", "placeholder": "Port", "optional": false }

# Documentation:
# @raycast.description Find and kill process by port
# @raycast.author chatgpt
# @raycast.authorURL https://chat.openai.com/

PORT=$1

PID=$(lsof -ti tcp:$PORT)

if [ -z "$PID" ]; then
  echo "❌ No process found on port $PORT"
  exit 1
fi

kill -9 $PID
echo "✅ Killed process $PID on port $PORT"