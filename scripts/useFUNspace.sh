#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title use FAN space (RPM)
# @raycast.mode fullOutput
# @raycast.needsConfirmation true

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 🌀
# @raycast.description Позволяет задавать точную скорость вентиляторов (RPM) через Macs Fan Control
# @raycast.argument1 { "type": "text", "placeholder": "RPM (1000-7000)", "optional": false }
# @raycast.confirmationText Установит вентиляторы на указанную скорость (RPM)

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "🌀 Настраиваю вентиляторы..."
echo ""

# Путь к Macs Fan Control CLI
MFC_CLI="/Applications/Macs Fan Control.app/Contents/MacOS/control"

if [ ! -f "$MFC_CLI" ]; then
    echo "❌ Macs Fan Control CLI не найдено! Установите: https://crystalidea.com/macs-fan-control"
    exit 1
fi

# Логирование
LOG_DIR="$HOME/FAN_Logs"
LOG_FILE="$LOG_DIR/fan_$(date +%Y%m%d).log"
mkdir -p "$LOG_DIR"

# Получаем RPM из аргумента
FAN_RPM="$1"

# Проверяем валидность ввода
if ! [[ "$FAN_RPM" =~ ^[0-9]+$ ]] || [ "$FAN_RPM" -lt 1000 ] || [ "$FAN_RPM" -gt 7000 ]; then
    echo "❌ Неверная скорость! Введите число от 1000 до 7000 RPM."
    osascript -e "display notification \"Неверная скорость! Используйте 1000-7000 RPM.\" with title \"FAN space\""
    exit 1
fi

# Устанавливаем скорость для вентилятора 0
echo "🌀 Устанавливаю вентиляторы на $FAN_RPM RPM..."
$MFC_CLI setrpm 0 $FAN_RPM
if [ $? -ne 0 ]; then
    echo "❌ Ошибка установки скорости!"
    $MFC_CLI setauto 0
    osascript -e "display notification \"Ошибка установки скорости. Вентиляторы возвращены в авто-режим.\" with title \"FAN space\""
    exit 1
fi

# Показываем уведомление
osascript -e "display notification \"Вентиляторы установлены на $FAN_RPM RPM\" with title \"FAN space\""

# Логируем действие
echo "[$(date +%H:%M:%S)] FAN speed set to $FAN_RPM RPM" >> "$LOG_FILE"
echo "📋 Действие записано в лог: $LOG_FILE"

echo ""
echo "✅ FAN space активирован: $FAN_RPM RPM!"