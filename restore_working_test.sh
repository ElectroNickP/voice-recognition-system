#!/bin/bash

# Восстановленный тест с рабочей конфигурацией

echo "=== ВОССТАНОВЛЕННЫЙ ТЕСТ С РАБОЧЕЙ КОНФИГУРАЦИЕЙ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Настройки (как в рабочем скрипте)
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

# Тестовая фраза (простая, как в успешных тестах)
TEST_PHRASE="Привет мир тест"

echo -e "${BLUE}Настройки:${NC}"
echo "Фраза: '$TEST_PHRASE'"
echo "Устройство записи: default (-d)"
echo "Whisper: $WHISPER_BIN"
echo ""

# Настройка аудио (как в рабочем скрипте)
echo -e "${BLUE}Настройка аудио...${NC}"
amixer sset Capture 20% 2>/dev/null
amixer sset Master 80% 2>/dev/null
echo ""

# Шаг 1: Синтез речи
echo -e "${BLUE}Шаг 1: Синтез речи...${NC}"
SYNTH_FILE="/tmp/restore_synth.wav"

if $PIPER_BIN --model $VOICE_MODEL --output_file "$SYNTH_FILE" <<< "$TEST_PHRASE"; then
    echo -e "${GREEN}✅ Синтез речи выполнен${NC}"
    
    # Нормализация (как в рабочем скрипте)
    if command -v sox &> /dev/null; then
        sox "$SYNTH_FILE" "/tmp/restore_synth_norm.wav" norm -3
        mv "/tmp/restore_synth_norm.wav" "$SYNTH_FILE"
        echo "Аудио нормализовано"
    fi
else
    echo -e "${RED}❌ Ошибка синтеза речи${NC}"
    exit 1
fi

# Шаг 2: Определение длительности
echo -e "${BLUE}Шаг 2: Определение длительности...${NC}"
DUR=$(sox "$SYNTH_FILE" -n stat 2>&1 | grep "Length" | awk '{print $3}')
DUR_INT=$(printf "%.0f" "$DUR")
REC_SEC=$((DUR_INT + 1))
echo "Длительность синтеза: ${DUR} сек"
echo "Длительность записи: ${REC_SEC} сек"

# Шаг 3: Запись с устройством default (как в рабочем скрипте)
echo -e "${BLUE}Шаг 3: Запись с устройством default...${NC}"
REC_FILE="/tmp/restore_rec.wav"

echo "Записываю и воспроизвожу одновременно..."
echo "Используется устройство: default (-d)"

# Идеальная синхронизация (как в рабочем скрипте)
(sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC gain -6 norm -3) &
REC_PID=$!

paplay "$SYNTH_FILE" &
PLAY_PID=$!

wait $REC_PID
wait $PLAY_PID

echo -e "${GREEN}✅ Запись завершена${NC}"

# Шаг 4: Анализ записи
echo -e "${BLUE}Шаг 4: Анализ записи...${NC}"
RMS=$(sox "$REC_FILE" -n stat 2>&1 | awk '/RMS.*amplitude/ {print $3}')
echo "Уровень звука (RMS): $RMS"

if (( $(echo "$RMS > 0.01" | bc -l) )); then
    echo -e "${GREEN}✅ Звук обнаружен${NC}"
else
    echo -e "${YELLOW}⚠️  Звук слишком тихий${NC}"
fi

# Шаг 5: Воспроизведение для проверки
echo -e "${BLUE}Шаг 5: Воспроизведение записи...${NC}"
echo "Сейчас прозвучит ваша запись:"
paplay "$REC_FILE"
echo ""

# Шаг 6: Распознавание речи (как в рабочем скрипте)
echo -e "${BLUE}Шаг 6: Распознавание речи...${NC}"

if [ -f "$WHISPER_BIN" ]; then
    RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)
    echo -e "${GREEN}Результат распознавания: '$RECOG_TEXT'${NC}"
    
    # Анализ результата (как в рабочем скрипте)
    if [[ "${RECOG_TEXT,,}" == *"${TEST_PHRASE,,}"* ]]; then
        echo -e "${GREEN}✅ ПОЛНЫЙ УСПЕХ${NC}"
        RESULT="ПОЛНЫЙ УСПЕХ"
    elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]] || [[ "${RECOG_TEXT,,}" == *"тест"* ]]; then
        echo -e "${YELLOW}⚠️ ЧАСТИЧНЫЙ УСПЕХ${NC}"
        RESULT="ЧАСТИЧНЫЙ УСПЕХ"
    elif [[ -n "$RECOG_TEXT" ]]; then
        echo -e "${YELLOW}⚠️ РАСПОЗНАН ДРУГОЙ ТЕКСТ${NC}"
        RESULT="ДРУГОЙ ТЕКСТ"
    else
        echo -e "${RED}❌ НЕ РАСПОЗНАНО${NC}"
        RESULT="НЕ РАСПОЗНАНО"
    fi
else
    echo -e "${RED}❌ Whisper не найден${NC}"
    RESULT="ОШИБКА"
fi

# Сохранение файлов
cp "$SYNTH_FILE" "./restore_synth.wav"
cp "$REC_FILE" "./restore_rec.wav"

echo ""
echo -e "${BLUE}=== РЕЗУЛЬТАТЫ ВОССТАНОВЛЕННОГО ТЕСТА ===${NC}"
echo "Фраза: '$TEST_PHRASE'"
echo "Результат: $RESULT"
echo "Распознано: '$RECOG_TEXT'"
echo ""
echo "Файлы:"
echo "- Синтез: restore_synth.wav"
echo "- Запись: restore_rec.wav"

# Очистка
rm -f "$SYNTH_FILE" "$REC_FILE" 