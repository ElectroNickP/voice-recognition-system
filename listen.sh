#!/bin/bash

# Запись и распознавание речи с идеальной синхронизацией

REC_FILE="/tmp/voice_recording.wav"
REC_SECONDS=5

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🎤 Запись речи (${REC_SECONDS} сек)...${NC}"
echo "Говорите четко и громко..."

# Настройка аудио
amixer sset Capture 20% 2>/dev/null

# Запись с идеальными настройками
sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SECONDS gain -6 norm -3

echo "Запись завершена"
echo ""

echo -e "${BLUE}🔍 Распознавание...${NC}"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)

if [[ -n "$RECOG_TEXT" ]]; then
    echo -e "${GREEN}✅ Распознано: '$RECOG_TEXT'${NC}"
    
    # Копируем в буфер обмена
    echo "$RECOG_TEXT" | xclip -selection clipboard
    echo -e "${GREEN}📋 Скопировано в буфер обмена${NC}"
else
    echo -e "${RED}❌ Не удалось распознать речь${NC}"
fi

# Очистка
rm -f "$REC_FILE" 