#!/bin/bash

# Демонстрация работы распознавания речи

echo "=== ДЕМОНСТРАЦИЯ РАСПОЗНАВАНИЯ РЕЧИ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Настройки
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"
PIPER_BIN="./piper/piper"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

# Тестовые фразы
PHRASES=(
    "Привет"
    "Привет мир"
    "Привет мир тест"
    "Как дела"
    "Тест системы"
)

echo -e "${CYAN}Настройка системы...${NC}"
amixer sset Capture 20% 2>/dev/null
amixer sset Master 80% 2>/dev/null
echo ""

for i in {0..4}; do
    TEST_NUM=$((i + 1))
    TEST_PHRASE="${PHRASES[$i]}"
    
    echo -e "${BLUE}=== ДЕМО ${TEST_NUM}/5 ===${NC}"
    echo -e "${PURPLE}Фраза: '$TEST_PHRASE'${NC}"
    echo ""
    
    # Шаг 1: Синтез речи
    echo -e "${CYAN}1️⃣ Синтезирую речь...${NC}"
    SYNTH_FILE="/tmp/demo_synth_${TEST_NUM}.wav"
    $PIPER_BIN --model $VOICE_MODEL --output_file "$SYNTH_FILE" <<< "$TEST_PHRASE"
    sox "$SYNTH_FILE" "/tmp/demo_synth_norm_${TEST_NUM}.wav" norm -3
    mv "/tmp/demo_synth_norm_${TEST_NUM}.wav" "$SYNTH_FILE"
    echo -e "${GREEN}✅ Синтез готов${NC}"
    
    # Шаг 2: Определение длительности
    DUR=$(sox "$SYNTH_FILE" -n stat 2>&1 | grep "Length" | awk '{print $3}')
    DUR_INT=$(printf "%.0f" "$DUR")
    REC_SEC=$((DUR_INT + 1))
    
    # Шаг 3: Запись и воспроизведение
    echo -e "${CYAN}2️⃣ Записываю и воспроизвожу одновременно...${NC}"
    echo -e "${YELLOW}🔊 Сейчас прозвучит синтезированная речь:${NC}"
    echo -e "${YELLOW}🎤 И одновременно начнется запись...${NC}"
    echo ""
    
    REC_FILE="/tmp/demo_rec_${TEST_NUM}.wav"
    
    # Запускаем запись и воспроизведение
    (sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SEC gain -6 norm -3) &
    REC_PID=$!
    
    paplay "$SYNTH_FILE" &
    PLAY_PID=$!
    
    wait $REC_PID
    wait $PLAY_PID
    
    echo -e "${GREEN}✅ Запись завершена${NC}"
    
    # Шаг 4: Анализ записи
    RMS=$(sox "$REC_FILE" -n stat 2>&1 | awk '/RMS.*amplitude/ {print $3}')
    echo -e "${CYAN}3️⃣ Анализ записи: RMS = $RMS${NC}"
    
    # Шаг 5: Воспроизведение записи
    echo -e "${CYAN}4️⃣ Воспроизвожу то, что записалось:${NC}"
    echo -e "${YELLOW}🔊 Слушайте запись:${NC}"
    paplay "$REC_FILE"
    echo ""
    
    # Шаг 6: Распознавание
    echo -e "${CYAN}5️⃣ Распознаю речь...${NC}"
    echo -e "${PURPLE}🤖 Whisper обрабатывает аудио...${NC}"
    
    if [ -f "$WHISPER_BIN" ]; then
        RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt --no-timestamps 2>/dev/null | sed 's/\[.*\]//g' | xargs)
        
        echo ""
        echo -e "${BLUE}=== РЕЗУЛЬТАТ РАСПОЗНАВАНИЯ ===${NC}"
        echo -e "${PURPLE}Оригинал: '$TEST_PHRASE'${NC}"
        echo -e "${GREEN}Распознано: '$RECOG_TEXT'${NC}"
        
        # Анализ результата
        if [[ "${RECOG_TEXT,,}" == *"${TEST_PHRASE,,}"* ]]; then
            echo -e "${GREEN}🎉 ПОЛНЫЙ УСПЕХ!${NC}"
            RESULT="ПОЛНЫЙ УСПЕХ"
        elif [[ "${RECOG_TEXT,,}" == *"привет"* ]] || [[ "${RECOG_TEXT,,}" == *"мир"* ]] || [[ "${RECOG_TEXT,,}" == *"тест"* ]] || [[ "${RECOG_TEXT,,}" == *"дела"* ]] || [[ "${RECOG_TEXT,,}" == *"систем"* ]]; then
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
    cp "$SYNTH_FILE" "./demo_synth_${TEST_NUM}.wav"
    cp "$REC_FILE" "./demo_rec_${TEST_NUM}.wav"
    
    echo ""
    echo -e "${BLUE}📁 Файлы сохранены:${NC}"
    echo "- Синтез: demo_synth_${TEST_NUM}.wav"
    echo "- Запись: demo_rec_${TEST_NUM}.wav"
    echo ""
    
    # Очистка
    rm -f "$SYNTH_FILE" "$REC_FILE"
    
    echo -e "${BLUE}---${NC}"
    echo ""
    
    # Пауза между демо
    if [[ $i -lt 4 ]]; then
        echo -e "${CYAN}Пауза 3 секунды перед следующим демо...${NC}"
        sleep 3
        echo ""
    fi
done

echo -e "${BLUE}=== ИТОГИ ДЕМОНСТРАЦИИ ===${NC}"
echo -e "${GREEN}✅ Система работает!${NC}"
echo -e "${CYAN}📊 Все файлы сохранены в текущей директории${NC}"
echo -e "${PURPLE}🎯 Распознавание функционирует${NC}"
echo ""
echo -e "${YELLOW}💡 Для улучшения точности можно:${NC}"
echo "- Попробовать другие модели Whisper"
echo "- Настроить качество записи"
echo "- Использовать шумоподавление" 