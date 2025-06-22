#!/bin/bash

# Тест с увеличенной громкостью и улучшенной синхронизацией

TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/loud_sync_test.wav"
REC_SECONDS=5

echo "=== ТЕСТ С УВЕЛИЧЕННОЙ ГРОМКОСТЬЮ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Настройка громкости...${NC}"
# Увеличиваем громкость воспроизведения
amixer sset Master 100% 2>/dev/null || echo "Не удалось настроить громкость воспроизведения"
# Уменьшаем чувствительность микрофона
amixer sset Capture 50% 2>/dev/null || echo "Не удалось настроить чувствительность микрофона"
echo ""

echo -e "${BLUE}2. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

# Создаем синтезированный файл
$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/loud_synthesized.wav <<< "$TEST_PHRASE"

# Увеличиваем громкость синтезированного файла
if command -v sox &> /dev/null; then
    sox /tmp/loud_synthesized.wav /tmp/loud_synthesized_boosted.wav vol 2.0
    mv /tmp/loud_synthesized_boosted.wav /tmp/loud_synthesized.wav
    echo "Громкость увеличена в 2 раза"
fi

SYNTH_DURATION=$(sox /tmp/loud_synthesized.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
echo "Длительность: ${SYNTH_DURATION} сек"
echo ""

echo -e "${BLUE}3. Синхронизированная запись и воспроизведение...${NC}"
echo "Записываю $REC_SECONDS секунд..."
echo "Воспроизводится синтезированный голос..."

# Запускаем воспроизведение в фоне
paplay /tmp/loud_synthesized.wav &
PIPER_PID=$!

# Задержка для стабилизации
sleep 0.3

# Записываем с микрофона (пробуем разные настройки)
arecord -q -d $REC_SECONDS -f S16_LE -r 44100 -c 1 --buffer-size=88200 "$REC_FILE"

# Ждем окончания воспроизведения
wait $PIPER_PID

echo "Запись завершена"
echo "Размер: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}4. Воспроизведение записанного...${NC}"
echo "Слушайте запись с микрофона:"
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
cp /tmp/loud_synthesized.wav ./loud_synthesized.wav
cp "$REC_FILE" ./loud_recorded.wav

echo ""
echo "Файлы сохранены:"
echo "- loud_synthesized.wav (что воспроизводилось)"
echo "- loud_recorded.wav (что записалось)"

# Очистка
rm -f /tmp/loud_synthesized.wav "$REC_FILE" 