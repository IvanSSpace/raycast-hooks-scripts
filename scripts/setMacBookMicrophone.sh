#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title useSetMacBookMicrophone
# @raycast.mode compact

# Optional parameters:
# @raycast.packageName Audio
# @raycast.icon 💻
# @raycast.description Переключает на встроенный микрофон MacBook Pro

# Documentation:
# @raycast.author Shar
# @raycast.authorURL https://raycast.com

# Проверяем, установлена ли утилита SwitchAudioSource
if ! command -v SwitchAudioSource &> /dev/null; then
    echo "❌ SwitchAudioSource не найден. Установите через: brew install switchaudio-osx"
    exit 1
fi

# Название встроенного микрофона MacBook Pro
MACBOOK_MIC="Микрофон MacBook Pro"

# Получаем текущий активный микрофон
current_mic=$(SwitchAudioSource -t input -c)

echo "🎤 Текущий микрофон: $current_mic"

# Проверяем, уже ли активен микрофон MacBook
if [[ "$current_mic" == "$MACBOOK_MIC" ]]; then
    echo "✅ Микрофон MacBook Pro уже активен"
    exit 0
fi

# Проверяем, доступен ли микрофон MacBook в списке устройств
available_mics=()
while IFS= read -r line; do
    available_mics+=("$line")
done < <(SwitchAudioSource -t input -a)

macbook_mic_found=false
for mic in "${available_mics[@]}"; do
    if [[ "$mic" == "$MACBOOK_MIC" ]]; then
        macbook_mic_found=true
        break
    fi
done

if [ "$macbook_mic_found" = false ]; then
    echo "❌ Микрофон MacBook Pro не найден в списке доступных устройств"
    echo "📋 Доступные микрофоны:"
    for mic in "${available_mics[@]}"; do
        echo "    $mic"
    done
    exit 1
fi

# Переключаем на микрофон MacBook Pro
echo "🔄 Переключаю на: $MACBOOK_MIC"
result=$(SwitchAudioSource -t input -s "$MACBOOK_MIC" 2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Микрофон успешно переключен на: $MACBOOK_MIC"
else
    echo "❌ Ошибка при переключении: $result"
    exit 1
fi