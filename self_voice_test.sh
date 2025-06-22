#!/bin/bash

# Самотест голосовой системы: озвучить -> записать -> распознать -> сравнить

TEST_PHRASE="Проверка самотестирования голосовой системы"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/self_voice_test.wav"
REC_SECONDS=3

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Проверка микрофона (короткая запись)
echo -e "${YELLOW}1. Проверка микрофона...${NC}"
echo "Говорите что-нибудь (2 сек)..."
arecord -q -d 2 -f S16_LE -r 16000 -c 1 /tmp/mic_test.wav
paplay /tmp/mic_test.wav
rm -f /tmp/mic_test.wav

# 2. Озвучить тестовую фразу и одновременно записать с микрофона
echo -e "${YELLOW}2. Самотест: озвучить и записать...${NC}"
echo "Озвучиваю: '$TEST_PHRASE'"

# Запуск озвучки и записи параллельно (Piper -> динамики, arecord -> микрофон)
$PIPER_BIN --model $VOICE_MODEL --output_file - <<< "$TEST_PHRASE" | paplay --raw --rate=22050 --format=s16le --channels=1 &
PIPER_PID=$!
arecord -q -d $REC_SECONDS -f S16_LE -r 16000 -c 1 "$REC_FILE"
wait $PIPER_PID

# 3. Распознать записанное
echo -e "${YELLOW}3. Распознаю записанное...${NC}"
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt | sed 's/\[.*\]//g' | xargs)
echo "Распознанный текст: '$RECOG_TEXT'"

# 4. Сравнить с оригиналом
echo -e "${YELLOW}4. Сравнение...${NC}"
if [[ "$RECOG_TEXT" == *"${TEST_PHRASE}"* ]]; then
    echo -e "${GREEN}УСПЕХ: Микрофон слышит динамики, распознавание совпадает!${NC}"
else
    echo -e "${RED}ОШИБКА: Распознанный текст не совпадает!${NC}"
    echo "Ожидалось: '$TEST_PHRASE'"
    echo "Получено:  '$RECOG_TEXT'"
fi

# 5. Очистка
rm -f "$REC_FILE" 