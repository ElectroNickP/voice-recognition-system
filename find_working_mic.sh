#!/bin/bash

# Поиск рабочего микрофона: перебор всех устройств и тестовая запись

echo "=== ПОИСК РАБОЧЕГО МИКРОФОНА ==="
echo ""

# Получаем список устройств
DEVICES=$(arecord -l | grep '^card' | awk '{print $2 $3}' | sed 's/://g')

if [ -z "$DEVICES" ]; then
    echo "Микрофоны не найдены!"
    exit 1
fi

for dev in $DEVICES; do
    CARD=$(echo $dev | cut -d',' -f1 | sed 's/card//')
    DEVICE=$(echo $dev | cut -d',' -f2 | sed 's/device//')
    ALSA_DEV="plughw:$CARD,$DEVICE"
    OUTFILE="mic_test_card${CARD}_dev${DEVICE}.wav"
    echo "\nТестируем устройство: $ALSA_DEV"
    echo "Говорите в микрофон (2 сек)..."
    arecord -D $ALSA_DEV -q -d 2 -f S16_LE -r 16000 -c 1 "$OUTFILE"
    echo "Воспроизведение:"
    paplay "$OUTFILE"
    echo "Файл сохранён: $OUTFILE"
    echo "---"
done

echo "\nПроверьте, в каком файле слышен ваш голос — это и есть нужное устройство!"
echo "Для использования: arecord -D plughw:<card>,<device> ..." 