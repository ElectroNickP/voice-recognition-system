#!/bin/bash

# Финальный тест голосовой системы с правильным микрофоном

echo "=== ФИНАЛЬНЫЙ ТЕСТ ГОЛОСОВОЙ СИСТЕМЫ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Настройки
MIC_DEVICE="plughw:0,0"  # Правильное устройство микрофона
SPEAK_DEVICE="default"   # Устройство воспроизведения
SAMPLE_RATE=16000
CHANNELS=1
BITS=16

# Тестовая фраза
TEST_PHRASE="Привет, это тест голосовой системы"

echo -e "${BLUE}Настройки:${NC}"
echo "Микрофон: $MIC_DEVICE"
echo "Колонки: $SPEAK_DEVICE"
echo "Фраза: '$TEST_PHRASE'"
echo ""

# Шаг 1: Синтез речи
echo -e "${BLUE}Шаг 1: Синтез речи...${NC}"
SYNTH_FILE="final_synth.wav"

if ./piper/espeak-ng -v ru -w "$SYNTH_FILE" "$TEST_PHRASE" 2>/dev/null; then
    echo -e "${GREEN}✅ Синтез речи выполнен${NC}"
else
    echo -e "${RED}❌ Ошибка синтеза речи${NC}"
    exit 1
fi

# Шаг 2: Запись с правильным микрофоном
echo -e "${BLUE}Шаг 2: Запись с микрофона...${NC}"
REC_FILE="final_record.wav"

echo "Говорите: '$TEST_PHRASE'"
echo "Запись начнется через 2 секунды..."

sleep 2

# Записываем 5 секунд
if sox -t alsa "$MIC_DEVICE" -r $SAMPLE_RATE -c $CHANNELS -b $BITS "$REC_FILE" trim 0 5; then
    echo -e "${GREEN}✅ Запись завершена${NC}"
else
    echo -e "${RED}❌ Ошибка записи${NC}"
    exit 1
fi

# Шаг 3: Анализ записи
echo -e "${BLUE}Шаг 3: Анализ записи...${NC}"
RMS=$(sox "$REC_FILE" -n stat 2>&1 | awk '/RMS.*amplitude/ {print $3}')
echo "Уровень звука (RMS): $RMS"

if (( $(echo "$RMS > 0.01" | bc -l) )); then
    echo -e "${GREEN}✅ Звук обнаружен${NC}"
else
    echo -e "${YELLOW}⚠️  Звук слишком тихий${NC}"
fi

# Шаг 3.1: Преобразование записи к 16kHz, 1 канал, 16 бит
CONV_FILE="final_record_16k.wav"
sox "$REC_FILE" -r 16000 -c 1 -b 16 "$CONV_FILE"

# Шаг 4: Распознавание речи
echo -e "${BLUE}Шаг 4: Распознавание речи...${NC}"

WHISPER_BIN="./whisper.cpp/build/bin/main"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

if [ -f "$WHISPER_BIN" ]; then
    RESULT=$($WHISPER_BIN -m $WHISPER_MODEL -f "$CONV_FILE" -l ru 2>/dev/null | grep -v "whisper" | head -1)
    echo -e "${GREEN}Результат распознавания: '$RESULT'${NC}"
    # Проверяем совпадение
    if [[ "$RESULT" == *"тест"* ]] || [[ "$RESULT" == *"систем"* ]] || [[ "$RESULT" == *"голос"* ]]; then
        echo -e "${GREEN}✅ Ключевые слова распознаны!${NC}"
    else
        echo -e "${YELLOW}⚠️  Ключевые слова не найдены${NC}"
    fi
else
    echo -e "${RED}❌ Whisper не найден${NC}"
fi

# Шаг 5: Воспроизведение для проверки
echo -e "${BLUE}Шаг 5: Воспроизведение записи...${NC}"
echo "Сейчас прозвучит ваша запись:"
paplay "$REC_FILE"

echo ""
echo -e "${BLUE}=== РЕЗУЛЬТАТЫ ФИНАЛЬНОГО ТЕСТА ===${NC}"
echo "Синтез: ✅"
echo "Запись: ✅ (устройство: $MIC_DEVICE)"
echo "Распознавание: см. выше"
echo ""
echo "Файлы:"
echo "- Синтез: $SYNTH_FILE"
echo "- Запись: $REC_FILE" 