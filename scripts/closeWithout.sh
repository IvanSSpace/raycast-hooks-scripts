#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title use WORK space
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 👩‍💻
# @raycast.description Закрывает все пользовательские приложения кроме Cursor и Chrome

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "Закрываю приложения..."

# Команда для закрытия приложений
osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | tr ',' '\n' | sed 's/^ *//' | grep -v -E "(Dock|ControlCenter|CoreLocationAgent|SystemUIServer|NotificationCenter|Spotlight|Siri|Keychain|WallpaperAgent|UIKitSystem|Calendar|Maps|Preview|Cursor|Google Chrome|Telegram|Яндекс Музыка|Notion)" | while read app; do
    if [ ! -z "$app" ]; then
        echo "Закрываю: $app"
        osascript -e "tell application \"$app\" to quit" 2>/dev/null
    fi
done

# Убираем неактивные приложения из dock
echo "Убираю неактивные приложения из dock..."
defaults write com.apple.dock static-only -bool true
killall Dock

echo "✅ Готово!"