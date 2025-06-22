#!/bin/bash

# Финальный тест с идеальной синхронизацией

TEST_PHRASE="Привет мир"
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/perfect_test.wav"

echo "=== ФИНАЛЬНЫЙ ТЕСТ С ИДЕАЛЬНОЙ СИНХРОНИЗАЦИЕЙ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. Настройка аудио...${NC}"
amixer sset Capture 20% 2>/dev/null
amixer sset Master 80% 2>/dev/null
echo "Чувствительность микрофона: 20%"
echo "Громкость воспроизведения: 80%"
echo ""

echo -e "${BLUE}2. Создание синтезированного аудио...${NC}"
echo "Фраза: '$TEST_PHRASE'"

$PIPER_BIN --model $VOICE_MODEL --output_file /tmp/perfect_synthesized.wav <<< "$TEST_PHRASE"

# Нормализуем громкость
if command -v sox &> /dev/null; then
    sox /tmp/perfect_synthesized.wav /tmp/perfect_synthesized_norm.wav norm -3
    mv /tmp/perfect_synthesized_norm.wav /tmp/perfect_synthesized.wav
    echo "Аудио нормализовано"
fi

# Узнаём длительность синтезированного файла
DUR=$(sox /tmp/perfect_synthesized.wav -n stat 2>&1 | grep "Length" | awk '{print $3}')
DUR_INT=$(printf "%.0f" "$DUR")
REC_SEC=$((DUR_INT + 1)) # запас 1 секунда

echo "Длительность синтезированного: ${DUR} сек"
echo "Длительность записи: ${REC_SEC} сек"
echo ""

echo -e "${BLUE}3. Идеальная синхронизация (одновременный старт)...${NC}"
echo "Записываю ${REC_SEC} секунд одновременно с воспроизведением..."

# ИДЕАЛЬНАЯ СИНХРОНИЗАЦИЯ: запись и воспроизведение стартуют одновременно
(sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC gain -6 norm -3) &
REC_PID=$!

paplay /tmp/perfect_synthesized.wav &
PLAY_PID=$!

# Ждем окончания записи и воспроизведения
wait $REC_PID
wait $PLAY_PID

echo "Запись завершена"
echo "Размер: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo -e "${BLUE}4. Воспроизведение записанного...${NC}"
echo "Слушайте, что записалось:"
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
    SUCCESS=true
elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]]; then
    echo -e "${YELLOW}⚠️ Частичное совпадение: найдены ключевые слова${NC}"
    SUCCESS=true
elif [[ -n "$RECOG_TEXT" ]]; then
    echo -e "${YELLOW}⚠️ Распознан текст, но не совпадает: '$RECOG_TEXT'${NC}"
    SUCCESS=false
else
    echo -e "${RED}❌ Не распознано ничего${NC}"
    SUCCESS=false
fi

# Анализ качества
echo ""
echo -e "${BLUE}7. Анализ качества...${NC}"
if command -v sox &> /dev/null; then
    echo "Статистика записанного файла:"
    sox "$REC_FILE" -n stat 2>&1 | grep -E "(Length|Mean|RMS|Max|Min)"
fi

# Сохранение файлов
cp /tmp/perfect_synthesized.wav ./perfect_synthesized.wav
cp "$REC_FILE" ./perfect_recorded.wav

echo ""
echo "Файлы сохранены:"
echo "- perfect_synthesized.wav (что воспроизводилось)"
echo "- perfect_recorded.wav (что записалось)"

# Очистка
rm -f /tmp/perfect_synthesized.wav "$REC_FILE"

echo ""
echo -e "${BLUE}=== РЕЗУЛЬТАТ ===${NC}"
if [[ "$SUCCESS" == "true" ]]; then
    echo -e "${GREEN}✅ САМОРАСПОЗНАВАНИЕ РАБОТАЕТ!${NC}"
    echo -e "${GREEN}✅ Система готова к использованию!${NC}"
    echo ""
    echo "Теперь можно использовать основные скрипты:"
    echo "- ./listen.sh - запись и распознавание"
    echo "- ./speak.sh - озвучивание из буфера"
    echo "- ./record_command.sh - запись до тишины"
else
    echo -e "${RED}❌ Самораспознавание не работает${NC}"
    echo "Нужна дополнительная отладка"
fi 