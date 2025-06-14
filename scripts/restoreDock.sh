#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restore Dock
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 🔄
# @raycast.description Восстанавливает dock к стандартному состоянию

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "Восстанавливаю dock..."

# Сбрасываем настройку static-only
defaults delete com.apple.dock static-only 2>/dev/null

# Перезапускаем dock
killall Dock

echo "✅ Dock восстановлен!"