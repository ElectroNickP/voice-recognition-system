#!/bin/bash

# Улучшенный тест с пониженной чувствительностью и без клиппинга

TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/improved_test.wav"
REC_SECONDS=4

echo "=== УЛУЧШЕННЫЙ ТЕСТ БЕЗ КЛИППИНГА ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Настройка аудио...${NC}"
# Уменьшаем чувствительность микрофона
amixer sset Capture 20% 2>/dev/null || echo "Не удалось настроить Capture"
# Устанавливаем громкость воспроизведения
amixer sset Master 80% 2>/dev/null || echo "Не удалось настроить Master"
echo "Чувствительность микрофона: 20%"
echo "Громкость воспроизведения: 80%"
echo ""

echo -e "${BLUE}2. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/improved_synthesized.wav <<< "$TEST_PHRASE"

# Нормализуем громкость без клиппинга
if command -v sox &> /dev/null; then
    sox /tmp/improved_synthesized.wav /tmp/improved_synthesized_norm.wav norm -3
    mv /tmp/improved_synthesized_norm.wav /tmp/improved_synthesized.wav
    echo "Аудио нормализовано (без клиппинга)"
fi

SYNTH_DURATION=$(sox /tmp/improved_synthesized.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
echo "Длительность: ${SYNTH_DURATION} сек"
echo ""

echo -e "${BLUE}3. Запись с пониженной чувствительностью...${NC}"
echo "Записываю $REC_SECONDS секунд..."

# Запускаем воспроизведение
paplay /tmp/improved_synthesized.wav &
PIPER_PID=$!

# Задержка
sleep 0.3

# Запись с пониженной чувствительностью и нормализацией
sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SECONDS gain -6 norm -3

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
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)
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

# Анализ качества записи
echo ""
echo -e "${BLUE}7. Анализ качества...${NC}"
if command -v sox &> /dev/null; then
    echo "Статистика записанного файла:"
    sox "$REC_FILE" -n stat 2>&1 | grep -E "(Length|Mean|RMS|Max|Min)"
fi

# Сохранение файлов
cp /tmp/improved_synthesized.wav ./improved_synthesized.wav
cp "$REC_FILE" ./improved_recorded.wav

echo ""
echo "Файлы сохранены:"
echo "- improved_synthesized.wav (что воспроизводилось)"
echo "- improved_recorded.wav (что записалось)"

# Очистка
rm -f /tmp/improved_synthesized.wav "$REC_FILE" 