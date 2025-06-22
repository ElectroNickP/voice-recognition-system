#!/bin/bash

# Отладочный тест с проверкой синхронизации

TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/debug_sync.wav"
REC_SECONDS=6

echo "=== ОТЛАДОЧНЫЙ ТЕСТ СИНХРОНИЗАЦИИ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Настройка аудио...${NC}"
amixer sset Capture 15% 2>/dev/null
amixer sset Master 70% 2>/dev/null
echo "Чувствительность микрофона: 15%"
echo "Громкость воспроизведения: 70%"
echo ""

echo -e "${BLUE}2. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/debug_synthesized.wav <<< "$TEST_PHRASE"

# Нормализуем громкость
if command -v sox &> /dev/null; then
    sox /tmp/debug_synthesized.wav /tmp/debug_synthesized_norm.wav norm -3
    mv /tmp/debug_synthesized_norm.wav /tmp/debug_synthesized.wav
    echo "Аудио нормализовано"
fi

SYNTH_DURATION=$(sox /tmp/debug_synthesized.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
echo "Длительность синтезированного: ${SYNTH_DURATION} сек"
echo ""

echo -e "${BLUE}3. Проверка синтезированного аудио...${NC}"
echo "Воспроизводим синтезированный файл для проверки:"
paplay /tmp/debug_synthesized.wav
echo ""

echo -e "${BLUE}4. Синхронизированная запись...${NC}"
echo "Записываю $REC_SECONDS секунд..."
echo "Сейчас начнется воспроизведение синтезированного голоса..."

# Запускаем воспроизведение в фоне
paplay /tmp/debug_synthesized.wav &
PIPER_PID=$!

echo "Воспроизведение запущено (PID: $PIPER_PID)"

# Длинная задержка для стабилизации
echo "Ждем 1 секунду для стабилизации..."
sleep 1

echo "Начинаем запись..."
# Запись с пониженной чувствительностью
sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SECONDS gain -8 norm -3

# Ждем окончания воспроизведения
echo "Ждем окончания воспроизведения..."
wait $PIPER_PID
echo "Воспроизведение завершено"

echo "Запись завершена"
echo "Размер: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}5. Воспроизведение записанного...${NC}"
echo "Слушайте, что записалось:"
paplay "$REC_FILE"
echo ""

echo -e "${BLUE}6. Распознавание...${NC}"
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)
echo "Распознанный текст: '$RECOG_TEXT'"
echo ""

echo -e "${BLUE}7. Сравнение...${NC}"
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

# Анализ качества
echo ""
echo -e "${BLUE}8. Анализ качества...${NC}"
if command -v sox &> /dev/null; then
    echo "Статистика записанного файла:"
    sox "$REC_FILE" -n stat 2>&1 | grep -E "(Length|Mean|RMS|Max|Min)"
fi

# Сохранение файлов
cp /tmp/debug_synthesized.wav ./debug_synthesized.wav
cp "$REC_FILE" ./debug_recorded.wav

echo ""
echo "Файлы сохранены:"
echo "- debug_synthesized.wav (что воспроизводилось)"
echo "- debug_recorded.wav (что записалось)"

# Очистка
rm -f /tmp/debug_synthesized.wav "$REC_FILE" 