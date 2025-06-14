#!/bin/bash

# Script для закрытия приложений и удаления их из dock
# Требует установленный dockutil: brew install dockutil

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title use TARGETw close
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 🧹
# @raycast.description Закрывает приложения и убирает их из dock

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "Закрываю приложения и убираю из dock..."

# Проверяем наличие dockutil
if ! command -v dockutil &> /dev/null; then
    echo "⚠️  dockutil не установлен. Устанавливаю..."
    brew install dockutil
fi

# Исключаемые приложения (которые НЕ закрываем и НЕ убираем из dock)
EXCLUDED_APPS="Dock|ControlCenter|CoreLocationAgent|SystemUIServer|NotificationCenter|Spotlight|Siri|Keychain|WallpaperAgent|UIKitSystem|Calendar|Maps|Preview|Cursor|Google Chrome|Telegram|Яндекс Музыка|Notion"

# Получаем список активных приложений
ACTIVE_APPS=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | tr ',' '\n' | sed 's/^ *//' | grep -v -E "$EXCLUDED_APPS")

# Закрываем приложения и убираем из dock
echo "$ACTIVE_APPS" | while read app; do
    if [ ! -z "$app" ]; then
        echo "Закрываю: $app"
        osascript -e "tell application \"$app\" to quit" 2>/dev/null

        # Ждем немного для корректного закрытия
        sleep 1

        # Убираем из dock, если приложение там есть
        dockutil --remove "$app" --no-restart 2>/dev/null && echo "  ↳ Убрал из dock: $app"
    fi
done

# Перезапускаем dock для применения изменений
killall Dock

echo "✅ Готово!"