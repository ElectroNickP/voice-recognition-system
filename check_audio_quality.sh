#!/bin/bash

# Проверка качества аудио

echo "=== ПРОВЕРКА КАЧЕСТВА АУДИО ==="
echo ""

# Проверяем, есть ли sox для анализа аудио
if command -v sox &> /dev/null; then
    echo "✅ sox найден - можно анализировать аудио"
    SOX_AVAILABLE=true
else
    echo "❌ sox не найден - установите: sudo apt install sox"
    SOX_AVAILABLE=false
fi
echo ""

# Анализируем существующие файлы
echo "1. Анализ существующих записей..."

if [ -f "improved_voice_test.wav" ]; then
    echo "Файл: improved_voice_test.wav"
    echo "Размер: $(ls -lh improved_voice_test.wav | awk '{print $5}')"
    echo "Формат: $(file improved_voice_test.wav)"
    
    if [ "$SOX_AVAILABLE" = true ]; then
        echo "Статистика аудио:"
        sox improved_voice_test.wav -n stat 2>&1 | head -10
    fi
    echo ""
fi

if [ -f "debug_test2.wav" ]; then
    echo "Файл: debug_test2.wav"
    echo "Размер: $(ls -lh debug_test2.wav | awk '{print $5}')"
    echo "Формат: $(file debug_test2.wav)"
    
    if [ "$SOX_AVAILABLE" = true ]; then
        echo "Статистика аудио:"
        sox debug_test2.wav -n stat 2>&1 | head -10
    fi
    echo ""
fi

# Сравнение с эталонным файлом
echo "2. Сравнение с эталонным файлом (jfk.wav)..."
echo "Эталонный файл:"
echo "Размер: $(ls -lh whisper.cpp/samples/jfk.wav | awk '{print $5}')"
echo "Формат: $(file whisper.cpp/samples/jfk.wav)"

if [ "$SOX_AVAILABLE" = true ]; then
    echo "Статистика эталонного файла:"
    sox whisper.cpp/samples/jfk.wav -n stat 2>&1 | head -10
fi
echo ""

# Тест записи с максимальной громкостью
echo "3. Тест записи с максимальной громкостью..."
echo "Настройка микрофона на максимум..."
amixer sset Capture 100% 2>/dev/null || echo "Не удалось настроить громкость"

echo "Скажите что-нибудь ОЧЕНЬ ГРОМКО (2 сек)..."
arecord -q -d 2 -f S16_LE -r 44100 -c 1 --buffer-size=88200 /tmp/max_volume.wav

echo "Размер: $(ls -lh /tmp/max_volume.wav | awk '{print $5}')"

if [ "$SOX_AVAILABLE" = true ]; then
    echo "Статистика максимальной громкости:"
    sox /tmp/max_volume.wav -n stat 2>&1 | head -10
fi

# Воспроизведение
echo "Воспроизведение:"
paplay /tmp/max_volume.wav

# Распознавание
echo "Распознавание:"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f /tmp/max_volume.wav -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs)
echo "Результат: '$RECOG_TEXT'"

# Сохранение
cp /tmp/max_volume.wav ./max_volume_test.wav
echo "Сохранено: max_volume_test.wav"

rm -f /tmp/max_volume.wav 