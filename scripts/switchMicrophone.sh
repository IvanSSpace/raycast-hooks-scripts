#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title useSwitchMicrophone
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName Audio
# @raycast.icon 🎤
# @raycast.description Переключает активный микрофон между доступными устройствами

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

# Проверяем, установлена ли утилита SwitchAudioSource
if ! command -v SwitchAudioSource &> /dev/null; then
    echo "❌ SwitchAudioSource не найден. Установите через: brew install switchaudio-osx"
    exit 1
fi

# Получаем список доступных микрофонов (каждый на новой строке)
available_mics=()
while IFS= read -r line; do
    available_mics+=("$line")
done < <(SwitchAudioSource -t input -a)

if [ ${#available_mics[@]} -eq 0 ]; then
    echo "❌ Не найдено доступных микрофонов"
    exit 1
fi

# Получаем текущий активный микрофон
current_mic=$(SwitchAudioSource -t input -c)

echo "🎤 Текущий микрофон: $current_mic"
echo ""

# Находим индекс текущего микрофона в списке
current_index=-1
for i in "${!available_mics[@]}"; do
    if [[ "${available_mics[$i]}" == "$current_mic" ]]; then
        current_index=$i
        break
    fi
done

# Определяем следующий микрофон (циклически)
if [ $current_index -eq -1 ]; then
    # Если текущий микрофон не найден в списке, берем первый
    next_index=0
else
    # Переходим к следующему микрофону (с возвратом к началу)
    next_index=$(((current_index + 1) % ${#available_mics[@]}))
fi

next_mic="${available_mics[$next_index]}"

# Переключаем микрофон
echo "🔄 Переключаю на: $next_mic"
result=$(SwitchAudioSource -t input -s "$next_mic" 2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Микрофон успешно переключен на: $next_mic"
else
    echo "❌ Ошибка при переключении: $result"
    exit 1
fi
# Показываем список всех доступных микрофонов
echo ""
echo "📋 Доступные микрофоны:"
for i in "${!available_mics[@]}"; do
    mic="${available_mics[$i]}"
    if [[ "$mic" == "$next_mic" ]]; then
        echo "  → $mic (активный)"
    else
        echo "    $mic"
    fi
done
