#!/bin/bash

# Детальная отладка голосовой системы

echo "=== ОТЛАДКА ГОЛОСОВОЙ СИСТЕМЫ ==="
echo ""

# Настройки
TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/debug_voice.wav"
SYNTH_FILE="/tmp/synthesized.wav"
REC_SECONDS=4

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Проверка устройств аудио...${NC}"
arecord --list-devices
echo ""

echo -e "${BLUE}2. Синтез речи в файл...${NC}"
echo "Фраза: '$TEST_PHRASE'"
$PIPER_BIN --model $VOICE_MODEL --output_file "$SYNTH_FILE" <<< "$TEST_PHRASE"
echo "Синтезированный файл: $SYNTH_FILE"
echo "Размер файла: $(ls -lh $SYNTH_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}3. Воспроизведение синтезированного файла...${NC}"
echo "Слушайте внимательно, затем нажмите Enter для продолжения..."
paplay "$SYNTH_FILE"
read -p "Нажмите Enter после прослушивания..."

echo -e "${BLUE}4. Запись с микрофона во время воспроизведения...${NC}"
echo "Записываю $REC_SECONDS секунд..."
paplay "$SYNTH_FILE" &
PIPER_PID=$!
sleep 0.5  # Небольшая задержка для синхронизации
arecord -q -d $REC_SECONDS -f S16_LE -r 16000 -c 1 "$REC_FILE"
wait $PIPER_PID
echo "Записанный файл: $REC_FILE"
echo "Размер файла: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}5. Воспроизведение записанного файла...${NC}"
echo "Слушайте, что записалось с микрофона..."
paplay "$REC_FILE"
echo ""

echo -e "${BLUE}6. Распознавание записанного файла...${NC}"
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt | sed 's/\[.*\]//g' | xargs)
echo "Распознанный текст: '$RECOG_TEXT'"
echo ""

echo -e "${BLUE}7. Сравнение...${NC}"
echo "Оригинал: '$TEST_PHRASE'"
echo "Распознано: '$RECOG_TEXT'"

if [[ "$RECOG_TEXT" == *"${TEST_PHRASE}"* ]]; then
    echo -e "${GREEN}✅ УСПЕХ: Тексты совпадают!${NC}"
else
    echo -e "${RED}❌ ОШИБКА: Тексты не совпадают${NC}"
    
    # Проверим, есть ли хотя бы частичное совпадение
    if [[ "$RECOG_TEXT" == *"привет"* ]] || [[ "$RECOG_TEXT" == *"мир"* ]]; then
        echo -e "${YELLOW}⚠️ Частичное совпадение найдено${NC}"
    fi
fi

echo ""
echo -e "${BLUE}8. Анализ файлов...${NC}"
echo "Синтезированный файл ($SYNTH_FILE):"
file "$SYNTH_FILE"
echo ""

echo "Записанный файл ($REC_FILE):"
file "$REC_FILE"
echo ""

echo -e "${BLUE}9. Сохранение файлов для анализа...${NC}"
cp "$SYNTH_FILE" "./debug_synthesized.wav"
cp "$REC_FILE" "./debug_recorded.wav"
echo "Файлы сохранены:"
echo "- debug_synthesized.wav (синтезированный)"
echo "- debug_recorded.wav (записанный с микрофона)"
echo ""

echo -e "${YELLOW}Для дальнейшей отладки:${NC}"
echo "1. Прослушайте файлы: paplay debug_synthesized.wav"
echo "2. Прослушайте файлы: paplay debug_recorded.wav"
echo "3. Попробуйте распознать вручную: $WHISPER_BIN -m $WHISPER_MODEL -l ru -f debug_recorded.wav -otxt -nt"
echo ""

# Очистка временных файлов
rm -f "$SYNTH_FILE" "$REC_FILE" 