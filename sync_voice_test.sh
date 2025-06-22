#!/bin/bash

# Синхронизированный тест: озвучить и одновременно записать

TEST_PHRASE="Привет мир тест"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/sync_test.wav"
REC_SECONDS=4

echo "=== СИНХРОНИЗИРОВАННЫЙ ТЕСТ ГОЛОСА ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

# Создаем синтезированный файл
$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/synthesized_sync.wav <<< "$TEST_PHRASE"
SYNTH_DURATION=$(sox /tmp/synthesized_sync.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
echo "Длительность синтезированного аудио: ${SYNTH_DURATION} сек"
echo ""

echo -e "${BLUE}2. Синхронизированная запись и воспроизведение...${NC}"
echo "Записываю $REC_SECONDS секунд одновременно с воспроизведением..."

# Запускаем воспроизведение в фоне
paplay /tmp/synthesized_sync.wav &
PIPER_PID=$!

# Небольшая задержка для стабилизации
sleep 0.2

# Записываем с микрофона
arecord -q -d $REC_SECONDS -f S16_LE -r 16000 -c 1 "$REC_FILE"

# Ждем окончания воспроизведения
wait $PIPER_PID

echo "Запись завершена"
echo "Размер записанного файла: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}3. Воспроизведение записанного...${NC}"
echo "Слушайте, что записалось с микрофона:"
paplay "$REC_FILE"
echo ""

echo -e "${BLUE}4. Распознавание записанного...${NC}"
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs)
echo "Распознанный текст: '$RECOG_TEXT'"
echo ""

echo -e "${BLUE}5. Сравнение...${NC}"
echo "Оригинал: '$TEST_PHRASE'"
echo "Распознано: '$RECOG_TEXT'"

# Проверяем совпадение (игнорируем регистр)
if [[ "${RECOG_TEXT,,}" == *"${TEST_PHRASE,,}"* ]]; then
    echo -e "${GREEN}🎉 УСПЕХ: Тексты совпадают!${NC}"
elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]]; then
    echo -e "${YELLOW}⚠️ Частичное совпадение: найдены ключевые слова${NC}"
else
    echo -e "${RED}❌ ОШИБКА: Тексты не совпадают${NC}"
fi

# Сохранение файлов для анализа
cp /tmp/synthesized_sync.wav ./sync_synthesized.wav
cp "$REC_FILE" ./sync_recorded.wav

echo ""
echo -e "${BLUE}6. Анализ файлов...${NC}"
echo "Синтезированный: $(file /tmp/synthesized_sync.wav)"
echo "Записанный: $(file $REC_FILE)"
echo ""
echo "Файлы сохранены:"
echo "- sync_synthesized.wav (что воспроизводилось)"
echo "- sync_recorded.wav (что записалось с микрофона)"

# Очистка
rm -f /tmp/synthesized_sync.wav "$REC_FILE" 