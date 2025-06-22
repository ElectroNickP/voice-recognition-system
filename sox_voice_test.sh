#!/bin/bash

# Тест записи через sox с лучшей синхронизацией

TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/sox_test.wav"
REC_SECONDS=4

echo "=== ТЕСТ ЗАПИСИ ЧЕРЕЗ SOX ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Проверяем наличие sox
if ! command -v sox &> /dev/null; then
    echo -e "${RED}❌ sox не найден. Установите: sudo apt install sox${NC}"
    exit 1
fi

echo -e "${BLUE}1. Настройка громкости...${NC}"
amixer sset Master 100% 2>/dev/null
amixer sset Capture 60% 2>/dev/null
echo ""

echo -e "${BLUE}2. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/sox_synthesized.wav <<< "$TEST_PHRASE"

# Увеличиваем громкость
sox /tmp/sox_synthesized.wav /tmp/sox_synthesized_boosted.wav vol 1.5
mv /tmp/sox_synthesized_boosted.wav /tmp/sox_synthesized.wav

SYNTH_DURATION=$(sox /tmp/sox_synthesized.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
echo "Длительность: ${SYNTH_DURATION} сек"
echo ""

echo -e "${BLUE}3. Запись через sox...${NC}"
echo "Записываю $REC_SECONDS секунд..."

# Запускаем воспроизведение
paplay /tmp/sox_synthesized.wav &
PIPER_PID=$!

# Задержка
sleep 0.2

# Запись через sox
sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SECONDS

# Ждем окончания воспроизведения
wait $PIPER_PID

echo "Запись завершена"
echo "Размер: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}4. Воспроизведение записанного...${NC}"
echo "Слушайте запись:"
paplay "$REC_FILE"
echo ""

echo -e "${BLUE}5. Распознавание...${NC}"
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs)
echo "Распознанный текст: '$RECOG_TEXT'"
echo ""

echo -e "${BLUE}6. Сравнение...${NC}"
echo "Оригинал: '$TEST_PHRASE'"
echo "Распознано: '$RECOG_TEXT'"

if [[ "${RECOG_TEXT,,}" == *"${TEST_PHRASE,,}"* ]]; then
    echo -e "${GREEN}🎉 УСПЕХ: Тексты совпадают!${NC}"
elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]]; then
    echo -e "${YELLOW}⚠️ Частичное совпадение: найдены ключевые слова${NC}"
elif [[ -n "$RECOG_TEXT" ]]; then
    echo -e "${YELLOW}⚠️ Распознан текст, но не совпадает: '$RECOG_TEXT'${NC}"
else
    echo -e "${RED}❌ Не распознано ничего${NC}"
fi

# Сохранение файлов
cp /tmp/sox_synthesized.wav ./sox_synthesized.wav
cp "$REC_FILE" ./sox_recorded.wav

echo ""
echo "Файлы сохранены:"
echo "- sox_synthesized.wav (что воспроизводилось)"
echo "- sox_recorded.wav (что записалось)"

# Очистка
rm -f /tmp/sox_synthesized.wav "$REC_FILE" 