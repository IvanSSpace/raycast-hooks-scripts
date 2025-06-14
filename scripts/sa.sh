#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title use FLOW space
# @raycast.mode fullOutput
# @raycast.needsConfirmation true

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 🚀
# @raycast.description Включает режим глубокого фокуса: "Не беспокоить", музыка, таймер Pomodoro, заметка для идей и мотивирующая цитата
# @raycast.confirmationText Готовы войти в режим FLOW?

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "🚀 Запускаю FLOW space..."
echo ""

# 1. Включаем режим "Не беспокоить"
echo "🔕 Включаю режим 'Не беспокоить'..."
defaults -currentHost write com.apple.notificationcenterui doNotDisturb -bool true
killall NotificationCenter

# 2. Запускаем фоновую музыку
echo "🎶 Запускаю музыку для фокуса..."
open "https://music.yandex.ru/playlist/deep-focus" 2>/dev/null || echo "⚠️ Не удалось открыть Яндекс Музыку"

# 3. Создаем заметку для идей
echo "📝 Создаю заметку для идей..."
NOTE_TITLE="FLOW Session $(date +%Y-%m-%d_%H%M%S)"
osascript <<EOD
tell application "Notes"
    activate
    set newNote to make new note at folder "Notes" with properties {name:"$NOTE_TITLE", body:"$NOTE_CONTENT"}
    show newNote
end tell
EOD

# 4. Устанавливаем таймер Pomodoro (25 минут)
echo "⏲️ Запускаю таймер Pomodoro (25 минут)..."
(sleep 1500 && osascript -e 'display notification "Pomodoro завершён! Время для 5-минутного перерыва." with title "FLOW space"') &

# 5. Показываем мотивирующую цитату
echo "📜 Мотивирующая цитата..."
QUOTES=(
    "«Погрузись в процесс, и результат придёт сам.»"
    "«Фокус — это суперсила в мире отвлечений.»"
    "«Каждый шаг вперёд начинается с одного действия.»"
    "«Твой разум — это сад, выращивай в нём идеи.»"
)
RANDOM_QUOTE=${QUOTES[$RANDOM % ${#QUOTES[@]}]}
osascript -e "display notification \"$RANDOM_QUOTE\" with title \"FLOW space\""

# 6. Логируем сессию
LOG_DIR="$HOME/FLOW_Logs"
LOG_FILE="$LOG_DIR/flow_$(date +%Y%m%d).log"
mkdir -p "$LOG_DIR"
echo "[$(date +%H:%M:%S)] FLOW session started: Music, Note ('$NOTE_TITLE'), Pomodoro" >> "$LOG_FILE"
echo "📋 Сессия записана в лог: $LOG_FILE"

echo ""
echo "✅ FLOW space активирован! Погружайтесь в работу!"