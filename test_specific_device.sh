#!/bin/bash

# Тест конкретного устройства микрофона
# ИЗМЕНИТЕ ПАРАМЕТРЫ НИЖЕ ПОД ВАШЕ УСТРОЙСТВО

# Настройки устройства (ИЗМЕНИТЕ ЭТИ СТРОКИ!)
CARD=0          # Номер карты (например, 0, 1, 2...)
DEVICE=0        # Номер устройства (например, 0, 1, 2...)
ALSA_DEV="plughw:$CARD,$DEVICE"

# Настройки записи
REC_FILE="/tmp/test_device.wav"
REC_SECONDS=3

echo "=== ТЕСТ УСТРОЙСТВА МИКРОФОНА ==="
echo "Устройство: $ALSA_DEV"
echo "Карта: $CARD, Устройство: $DEVICE"
echo ""

# Настройка громкости (понижаем чувствительность)
echo "Настройка громкости записи на 30%..."
amixer sset Capture 30% 2>/dev/null || echo "Не удалось настроить громкость"
echo ""

echo "Скажите 'ПРИВЕТ МИР' четко (3 секунды)..."
echo "Используется устройство: $ALSA_DEV"

# Запись с указанным устройством
arecord -D "$ALSA_DEV" -q -d $REC_SECONDS -f S16_LE -r 16000 -c 1 "$REC_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Запись успешна!"
    echo "Размер файла: $(ls -lh $REC_FILE | awk '{print $5}')"
    echo ""
    
    echo "Воспроизведение записи:"
    paplay "$REC_FILE"
    echo ""
    
    echo "Распознавание через Whisper:"
    WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
    WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
    
    RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs)
    echo "Результат: '$RECOG_TEXT'"
    
    if [[ "$RECOG_TEXT" == *"привет"* ]] || [[ "$RECOG_TEXT" == *"мир"* ]]; then
        echo "🎉 УСПЕХ: Голос распознан!"
    elif [[ -n "$RECOG_TEXT" ]]; then
        echo "⚠️ Распознан текст, но не 'привет мир': '$RECOG_TEXT'"
    else
        echo "❌ Не распознано ничего"
    fi
    
    # Сохранение для анализа
    cp "$REC_FILE" "./device_test_card${CARD}_dev${DEVICE}.wav"
    echo "Файл сохранен: device_test_card${CARD}_dev${DEVICE}.wav"
    
else
    echo "❌ Ошибка записи с устройством $ALSA_DEV"
    echo "Попробуйте другие значения CARD и DEVICE"
fi

# Очистка
rm -f "$REC_FILE"

echo ""
echo "=== ИНСТРУКЦИЯ ==="
echo "Если устройство не работает, измените значения CARD и DEVICE в скрипте"
echo "Например: CARD=1 DEVICE=0 для plughw:1,0"
echo "Или попробуйте: CARD=0 DEVICE=1 для plughw:0,1" 