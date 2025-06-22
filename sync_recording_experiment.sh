#!/bin/bash

# Эксперимент по синхронизации записи и воспроизведения

TEST_PHRASE="Привет, это тест синхронизации!"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
REC_DIR="/tmp"
SYNTH_FILE="$REC_DIR/sync_exp_synth.wav"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

# 1. Синтезируем голос
$PIPER_BIN --model $VOICE_MODEL --output_file "$SYNTH_FILE" <<< "$TEST_PHRASE"

# Узнаём длительность синтезированного файла
DUR=$(sox "$SYNTH_FILE" -n stat 2>&1 | grep "Length" | awk '{print $3}')
DUR_INT=$(printf "%.0f" "$DUR")
REC_SEC=$((DUR_INT + 2)) # запас 2 секунды

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Варианты синхронизации
# 1. Запись стартует за 1 сек до воспроизведения
# 2. Запись и воспроизведение стартуют одновременно
# 3. Запись стартует через 0.5 сек после старта воспроизведения

for MODE in early sync late; do
    case $MODE in
        early)
            echo -e "${BLUE}1. Запись стартует ЗАРАНЕЕ (за 1 сек до воспроизведения)...${NC}"
            REC_FILE="$REC_DIR/sync_exp_early.wav"
            (sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC) &
            REC_PID=$!
            sleep 1
            paplay "$SYNTH_FILE"
            wait $REC_PID
            ;;
        sync)
            echo -e "${BLUE}2. Запись и воспроизведение стартуют ОДНОВРЕМЕННО...${NC}"
            REC_FILE="$REC_DIR/sync_exp_sync.wav"
            (sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC) &
            REC_PID=$!
            paplay "$SYNTH_FILE" &
            PLAY_PID=$!
            wait $REC_PID
            wait $PLAY_PID
            ;;
        late)
            echo -e "${BLUE}3. Запись стартует ПОЗЖЕ (через 0.5 сек после старта воспроизведения)...${NC}"
            REC_FILE="$REC_DIR/sync_exp_late.wav"
            paplay "$SYNTH_FILE" &
            PLAY_PID=$!
            sleep 0.5
            sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC
            wait $PLAY_PID
            ;;
    esac
    echo -e "${YELLOW}Воспроизвожу результат ($REC_FILE). Скажи, слышен ли голос полностью, частично или нет:${NC}"
    paplay "$REC_FILE"
    read -p "Твой комментарий (полностью/частично/нет): " FEEDBACK
    echo "$MODE: $FEEDBACK" >> sync_exp_feedback.txt
    echo "---"
done

echo -e "${GREEN}Эксперимент завершён. Все записи сохранены в /tmp и feedback в sync_exp_feedback.txt${NC}"
echo "Файлы:"
echo "- $REC_DIR/sync_exp_early.wav"
echo "- $REC_DIR/sync_exp_sync.wav"
echo "- $REC_DIR/sync_exp_late.wav"
echo "- $SYNTH_FILE (эталон)"
echo "- sync_exp_feedback.txt (твои комментарии)" 