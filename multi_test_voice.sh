#!/bin/bash

# Многократный тест с разными фразами разной сложности

VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

# Массив фраз разной сложности
PHRASES=(
    "Привет"                    # Простая (1 слово)
    "Привет мир"                # Средняя (2 слова)
    "Привет мир тест"           # Средняя (3 слова)
    "Привет мир это тест"       # Сложная (4 слова)
    "Привет мир это тест синхронизации"  # Очень сложная (5 слов)
)

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== МНОГОКРАТНЫЙ ТЕСТ САМОРАСПОЗНАВАНИЯ ==="
echo "5 попыток с фразами разной сложности"
echo ""

# Настройка аудио
echo -e "${BLUE}Настройка аудио...${NC}"
amixer sset Capture 20% 2>/dev/null
amixer sset Master 80% 2>/dev/null
echo ""

# Статистика
TOTAL_TESTS=0
SUCCESSFUL_TESTS=0
PARTIAL_TESTS=0
FAILED_TESTS=0

# Файл для результатов
RESULTS_FILE="voice_test_results.txt"
echo "=== РЕЗУЛЬТАТЫ ТЕСТА САМОРАСПОЗНАВАНИЯ ===" > "$RESULTS_FILE"
echo "Дата: $(date)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

for i in {0..4}; do
    TEST_NUM=$((i + 1))
    TEST_PHRASE="${PHRASES[$i]}"
    
    echo -e "${BLUE}=== ТЕСТ ${TEST_NUM}/5 ===${NC}"
    echo -e "${BLUE}Фраза: '$TEST_PHRASE'${NC}"
    echo -e "${BLUE}Сложность: $((i + 1))/5${NC}"
    echo ""
    
    # Создание синтезированного аудио
    SYNTH_FILE="/tmp/multi_test_synth_${TEST_NUM}.wav"
    $PIPER_BIN --model $VOICE_MODEL --output_file "$SYNTH_FILE" <<< "$TEST_PHRASE"
    
    # Нормализация
    if command -v sox &> /dev/null; then
        sox "$SYNTH_FILE" "/tmp/multi_test_synth_norm_${TEST_NUM}.wav" norm -3
        mv "/tmp/multi_test_synth_norm_${TEST_NUM}.wav" "$SYNTH_FILE"
    fi
    
    # Определение длительности записи
    DUR=$(sox "$SYNTH_FILE" -n stat 2>&1 | grep "Length" | awk '{print $3}')
    DUR_INT=$(printf "%.0f" "$DUR")
    REC_SEC=$((DUR_INT + 1))
    
    echo "Длительность: ${DUR} сек, запись: ${REC_SEC} сек"
    
    # Идеальная синхронизация
    REC_FILE="/tmp/multi_test_rec_${TEST_NUM}.wav"
    
    echo "Записываю и воспроизвожу одновременно..."
    (sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC gain -6 norm -3) &
    REC_PID=$!
    
    paplay "$SYNTH_FILE" &
    PLAY_PID=$!
    
    wait $REC_PID
    wait $PLAY_PID
    
    echo "Запись завершена"
    
    # Воспроизведение результата
    echo "Воспроизведение записи:"
    paplay "$REC_FILE"
    echo ""
    
    # Распознавание
    RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)
    echo "Распознано: '$RECOG_TEXT'"
    
    # Анализ результата
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "${RECOG_TEXT,,}" == *"${TEST_PHRASE,,}"* ]]; then
        echo -e "${GREEN}✅ ПОЛНЫЙ УСПЕХ${NC}"
        SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
        RESULT="ПОЛНЫЙ УСПЕХ"
    elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]] || [[ "${RECOG_TEXT,,}" == *"тест"* ]]; then
        echo -e "${YELLOW}⚠️ ЧАСТИЧНЫЙ УСПЕХ${NC}"
        PARTIAL_TESTS=$((PARTIAL_TESTS + 1))
        RESULT="ЧАСТИЧНЫЙ УСПЕХ"
    elif [[ -n "$RECOG_TEXT" ]]; then
        echo -e "${YELLOW}⚠️ РАСПОЗНАН ДРУГОЙ ТЕКСТ${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        RESULT="ДРУГОЙ ТЕКСТ"
    else
        echo -e "${RED}❌ НЕ РАСПОЗНАНО${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        RESULT="НЕ РАСПОЗНАНО"
    fi
    
    # Сохранение в файл результатов
    echo "Тест $TEST_NUM: '$TEST_PHRASE' -> '$RECOG_TEXT' ($RESULT)" >> "$RESULTS_FILE"
    
    # Сохранение файлов
    cp "$SYNTH_FILE" "./multi_test_synth_${TEST_NUM}.wav"
    cp "$REC_FILE" "./multi_test_rec_${TEST_NUM}.wav"
    
    echo "Файлы сохранены: multi_test_synth_${TEST_NUM}.wav, multi_test_rec_${TEST_NUM}.wav"
    echo ""
    echo "---"
    echo ""
    
    # Очистка временных файлов
    rm -f "$SYNTH_FILE" "$REC_FILE"
    
    # Пауза между тестами
    if [[ $i -lt 4 ]]; then
        echo "Пауза 2 секунды перед следующим тестом..."
        sleep 2
        echo ""
    fi
done

# Итоговая статистика
echo -e "${BLUE}=== ИТОГОВАЯ СТАТИСТИКА ===${NC}"
echo "Всего тестов: $TOTAL_TESTS"
echo -e "${GREEN}Полных успехов: $SUCCESSFUL_TESTS${NC}"
echo -e "${YELLOW}Частичных успехов: $PARTIAL_TESTS${NC}"
echo -e "${RED}Неудач: $FAILED_TESTS${NC}"

SUCCESS_RATE=$((SUCCESSFUL_TESTS * 100 / TOTAL_TESTS))
PARTIAL_RATE=$((PARTIAL_TESTS * 100 / TOTAL_TESTS))
FAILED_RATE=$((FAILED_TESTS * 100 / TOTAL_TESTS))

echo ""
echo "Процент успешности:"
echo -e "${GREEN}Полный успех: ${SUCCESS_RATE}%${NC}"
echo -e "${YELLOW}Частичный успех: ${PARTIAL_RATE}%${NC}"
echo -e "${RED}Неудачи: ${FAILED_RATE}%${NC}"

# Сохранение статистики в файл
echo "" >> "$RESULTS_FILE"
echo "=== СТАТИСТИКА ===" >> "$RESULTS_FILE"
echo "Всего тестов: $TOTAL_TESTS" >> "$RESULTS_FILE"
echo "Полных успехов: $SUCCESSFUL_TESTS" >> "$RESULTS_FILE"
echo "Частичных успехов: $PARTIAL_TESTS" >> "$RESULTS_FILE"
echo "Неудач: $FAILED_TESTS" >> "$RESULTS_FILE"
echo "Процент полного успеха: ${SUCCESS_RATE}%" >> "$RESULTS_FILE"
echo "Процент частичного успеха: ${PARTIAL_RATE}%" >> "$RESULTS_FILE"
echo "Процент неудач: ${FAILED_RATE}%" >> "$RESULTS_FILE"

echo ""
echo -e "${BLUE}=== ЗАКЛЮЧЕНИЕ ===${NC}"
if [[ $SUCCESS_RATE -ge 80 ]]; then
    echo -e "${GREEN}🎉 ОТЛИЧНО! Система работает стабильно!${NC}"
elif [[ $SUCCESS_RATE -ge 60 ]]; then
    echo -e "${YELLOW}⚠️ ХОРОШО! Система работает, но есть проблемы${NC}"
elif [[ $SUCCESS_RATE -ge 40 ]]; then
    echo -e "${YELLOW}⚠️ УДОВЛЕТВОРИТЕЛЬНО! Нужна доработка${NC}"
else
    echo -e "${RED}❌ ПЛОХО! Система не работает стабильно${NC}"
fi

echo ""
echo "Подробные результаты сохранены в: $RESULTS_FILE"
echo "Все аудиофайлы сохранены в текущей директории" 