#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title use CLEAN space
# @raycast.mode fullOutput
# @raycast.needsConfirmation true

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 🔥
# @raycast.description Закрывает все пользовательские приложения кроме Cursor и Chrome
# @raycast.confirmationText Вы уверены, что хотите закрыть все приложения?

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "🔥 Начинаю закрытие приложений..."
echo ""

# Получаем список всех активных пользовательских приложений
apps_to_close=()
while IFS= read -r app; do
    if [ ! -z "$app" ]; then
        apps_to_close+=("$app")
    fi
done < <(osascript -e 'tell application "System Events" to get name of (processes where background only is false)' | tr ',' '\n' | sed 's/^ *//' | grep -v -E "(Dock|ControlCenter|CoreLocationAgent|SystemUIServer|NotificationCenter|Spotlight|Siri|Keychain|WallpaperAgent|UIKitSystem|Calendar|Maps|Preview)")

# Показываем сколько приложений будет закрыто
echo "📱 Найдено ${#apps_to_close[@]} приложений для закрытия"
echo ""

# Закрываем каждое приложение
for app in "${apps_to_close[@]}"; do
    echo "⏹️  Закрываю: $app"
    osascript -e "tell application \"$app\" to quit" 2>/dev/null &
done

# Ждем немного чтобы приложения успели закрыться
sleep 2

# Убираем неактивные приложения из dock
echo ""
echo "🧹 Очищаю Dock от неактивных приложений..."
defaults write com.apple.dock static-only -bool true
killall Dock

echo ""
echo "✅ Готово! Закрыто ${#apps_to_close[@]} приложений"