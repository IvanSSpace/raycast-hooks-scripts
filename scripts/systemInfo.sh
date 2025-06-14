#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title show SYSTEM info
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.packageName System
# @raycast.icon 📊
# @raycast.description Показывает подробную информацию о системе: CPU, память, диск, батарея

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

echo "📊 СИСТЕМНАЯ ИНФОРМАЦИЯ"
echo "═══════════════════════"
echo ""

# Получаем информацию о системе
SYSTEM_INFO=$(system_profiler SPSoftwareDataType | grep "System Version" | awk -F': ' '{print $2}')
UPTIME=$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}')

echo "🖥️  СИСТЕМА:"
echo "   macOS: $SYSTEM_INFO"
echo "   Время работы: $UPTIME"
echo ""

# Информация о CPU
echo "⚡ ПРОЦЕССОР:"
CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.1f", s}')
CPU_COUNT=$(sysctl -n hw.ncpu)
CPU_TEMP=$(sudo powermetrics --sample-count 1 --sample-interval 1000 -n 0 2>/dev/null | grep "CPU die temperature" | awk '{print $4}' | head -n 1)
echo "   Загрузка: ${CPU_USAGE}%"
echo "   Ядер: $CPU_COUNT"
if [ ! -z "$CPU_TEMP" ]; then
    echo "   Температура: ${CPU_TEMP}°C"
fi
echo ""

# Информация о памяти
echo "🧠 ПАМЯТЬ:"
MEMORY_INFO=$(vm_stat)
PAGES_FREE=$(echo "$MEMORY_INFO" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
PAGES_ACTIVE=$(echo "$MEMORY_INFO" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
PAGES_INACTIVE=$(echo "$MEMORY_INFO" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
PAGES_WIRED=$(echo "$MEMORY_INFO" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')

# Размер страницы в байтах (обычно 4096)
PAGE_SIZE=$(vm_stat | grep "page size" | awk '{print $8}')

# Вычисляем использование памяти в ГБ
TOTAL_PAGES=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))
USED_PAGES=$((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED))

TOTAL_GB=$(echo "scale=1; $TOTAL_PAGES * $PAGE_SIZE / 1024 / 1024 / 1024" | bc)
USED_GB=$(echo "scale=1; $USED_PAGES * $PAGE_SIZE / 1024 / 1024 / 1024" | bc)
FREE_GB=$(echo "scale=1; $PAGES_FREE * $PAGE_SIZE / 1024 / 1024 / 1024" | bc)
USAGE_PERCENT=$(echo "scale=0; $USED_GB * 100 / $TOTAL_GB" | bc)

echo "   Всего: ${TOTAL_GB} ГБ"
echo "   Используется: ${USED_GB} ГБ (${USAGE_PERCENT}%)"
echo "   Свободно: ${FREE_GB} ГБ"
echo ""

# Информация о дисках
echo "💾 ДИСКИ:"
df -h | grep -E "^/dev/" | while read filesystem size used available capacity mount; do
    echo "   $mount: $used из $size (используется $capacity)"
done
echo ""

# Информация о батарее (только для ноутбуков)
BATTERY_INFO=$(pmset -g batt 2>/dev/null)
if echo "$BATTERY_INFO" | grep -q "Battery"; then
    echo "🔋 БАТАРЕЯ:"
    BATTERY_PERCENT=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | head -1)
    BATTERY_STATUS=$(echo "$BATTERY_INFO" | grep -o 'discharging\|charging\|charged' | head -1)

    case $BATTERY_STATUS in
        "charging") STATUS_ICON="⚡" ;;
        "discharging") STATUS_ICON="🔋" ;;
        "charged") STATUS_ICON="✅" ;;
        *) STATUS_ICON="🔋" ;;
    esac

    echo "   Заряд: $BATTERY_PERCENT $STATUS_ICON"

    # Время до разрядки/зарядки
    TIME_REMAINING=$(echo "$BATTERY_INFO" | grep -o '[0-9]*:[0-9]* remaining\|no estimate' | head -1)
    if [ ! -z "$TIME_REMAINING" ] && [ "$TIME_REMAINING" != "no estimate" ]; then
        echo "   Время: $TIME_REMAINING"
    fi
    echo ""
fi

# Топ 5 процессов по использованию CPU
echo "🔥 ТОП ПРОЦЕССЫ (CPU):"
ps -eo pid,pcpu,comm --sort=-pcpu | head -6 | tail -5 | while read pid cpu comm; do
    printf "   %-20s %s%%\n" "$(basename "$comm")" "$cpu"
done
echo ""

# Информация о сети
echo "🌐 СЕТЬ:"
NETWORK_INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
if [ ! -z "$NETWORK_INTERFACE" ]; then
    IP_ADDRESS=$(ifconfig "$NETWORK_INTERFACE" | grep "inet " | awk '{print $2}')
    echo "   Интерфейс: $NETWORK_INTERFACE"
    echo "   IP адрес: $IP_ADDRESS"

    # Проверяем подключение к интернету
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "   Интернет: ✅ Подключен"
    else
        echo "   Интернет: ❌ Нет подключения"
    fi
fi
echo ""

echo "═══════════════════════"
echo "Обновлено: $(date '+%H:%M:%S')"