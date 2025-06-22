#!/bin/bash

# Детальная отладка микрофона

echo "=== ОТЛАДКА МИКРОФОНА ==="
echo ""

# Проверка устройств
echo "1. Доступные устройства записи:"
arecord --list-devices
echo ""

# Проверка настроек ALSA
echo "2. Настройки ALSA:"
amixer sget Master 2>/dev/null || echo "amixer не доступен"
echo ""

# Тест записи с разными настройками
echo "3. Тест записи с разными настройками..."

# Тест 1: Стандартные настройки
echo "Тест 1: Стандартные настройки (16kHz, S16LE)"
echo "Скажите что-нибудь громко (2 сек)..."
arecord -q -d 2 -f S16_LE -r 16000 -c 1 /tmp/test1.wav
echo "Размер файла: $(ls -lh /tmp/test1.wav | awk '{print $5}')"
echo ""

# Тест 2: Более высокая частота
echo "Тест 2: Высокая частота (44.1kHz, S16LE)"
echo "Скажите что-нибудь громко (2 сек)..."
arecord -q -d 2 -f S16_LE -r 44100 -c 1 /tmp/test2.wav
echo "Размер файла: $(ls -lh /tmp/test2.wav | awk '{print $5}')"
echo ""

# Тест 3: Стерео
echo "Тест 3: Стерео (16kHz, S16LE, 2 канала)"
echo "Скажите что-нибудь громко (2 сек)..."
arecord -q -d 2 -f S16_LE -r 16000 -c 2 /tmp/test3.wav
echo "Размер файла: $(ls -lh /tmp/test3.wav | awk '{print $5}')"
echo ""

# Воспроизведение для проверки
echo "4. Воспроизведение записей..."
echo "Тест 1 (16kHz, моно):"
paplay /tmp/test1.wav
echo ""

echo "Тест 2 (44.1kHz, моно):"
paplay /tmp/test2.wav
echo ""

echo "Тест 3 (16kHz, стерео):"
paplay /tmp/test3.wav
echo ""

# Сохранение файлов для анализа
cp /tmp/test1.wav ./debug_test1.wav
cp /tmp/test2.wav ./debug_test2.wav
cp /tmp/test3.wav ./debug_test3.wav

echo "5. Анализ файлов:"
echo "Тест 1: $(file /tmp/test1.wav)"
echo "Тест 2: $(file /tmp/test2.wav)"
echo "Тест 3: $(file /tmp/test3.wav)"
echo ""

echo "6. Попытка распознавания..."
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

echo "Распознавание теста 1:"
$WHISPER_BIN -m $WHISPER_MODEL -l ru -f /tmp/test1.wav -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs
echo ""

echo "Распознавание теста 2:"
$WHISPER_BIN -m $WHISPER_MODEL -l ru -f /tmp/test2.wav -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs
echo ""

echo "Распознавание теста 3:"
$WHISPER_BIN -m $WHISPER_MODEL -l ru -f /tmp/test3.wav -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs
echo ""

# Очистка
rm -f /tmp/test1.wav /tmp/test2.wav /tmp/test3.wav

echo "Файлы сохранены:"
echo "- debug_test1.wav (16kHz, моно)"
echo "- debug_test2.wav (44.1kHz, моно)"
echo "- debug_test3.wav (16kHz, стерео)" 