#!/bin/bash

# Анализ записей для определения источника звука

echo "=== АНАЛИЗ ЗАПИСЕЙ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Анализируем каждый файл
for file in test_device_*.wav; do
    if [ -f "$file" ]; then
        echo -e "${BLUE}Анализируем: $file${NC}"
        
        # Получаем информацию о файле
        echo "Информация о файле:"
        soxi "$file" 2>/dev/null | head -5
        
        # Анализируем уровни звука
        echo "Анализ уровней звука:"
        sox "$file" -n stat 2>&1 | grep -E "(RMS|Peak|Mean|Std|Max|Min)" | head -10
        
        # Проверяем, есть ли речь (амплитуда выше порога)
        RMS=$(sox "$file" -n stat 2>&1 | grep "RMS" | awk '{print $3}')
        if (( $(echo "$RMS > 0.01" | bc -l) )); then
            echo -e "${YELLOW}⚠️  Обнаружен звук (RMS: $RMS)${NC}"
        else
            echo -e "${GREEN}✅ Тишина (RMS: $RMS)${NC}"
        fi
        
        echo ""
        echo "---"
        echo ""
    fi
done

echo -e "${BLUE}=== РЕКОМЕНДАЦИИ ===${NC}"
echo "1. Если все файлы показывают тишину - микрофон не работает"
echo "2. Если есть звук - это может быть фоновый шум или эхо"
echo "3. Проверьте настройки микрофона в системе"
echo "4. Убедитесь, что нет фоновой музыки/видео" 