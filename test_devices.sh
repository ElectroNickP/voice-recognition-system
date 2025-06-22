#!/bin/bash

# Тест разных устройств записи

echo "=== ТЕСТ РАЗНЫХ УСТРОЙСТВ ЗАПИСИ ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Тестируем разные устройства
DEVICES=(
    "default"
    "hw:0,0"
    "hw:1,0"
    "plughw:0,0"
    "plughw:1,0"
    "sysdefault:CARD=0"
    "sysdefault:CARD=1"
)

for device in "${DEVICES[@]}"; do
    echo -e "${BLUE}Тестируем устройство: $device${NC}"
    
    # Пробуем записать 2 секунды
    REC_FILE="/tmp/test_device_${device//[^a-zA-Z0-9]/_}.wav"
    
    if sox -t alsa "$device" -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 2 2>/dev/null; then
        echo -e "${GREEN}✅ Устройство $device работает${NC}"
        
        # Проверяем размер файла
        SIZE=$(ls -lh "$REC_FILE" | awk '{print $5}')
        echo "Размер записи: $SIZE"
        
        # Пробуем воспроизвести
        echo "Воспроизведение записи:"
        if paplay "$REC_FILE" 2>/dev/null; then
            echo -e "${GREEN}✅ Воспроизведение работает${NC}"
        else
            echo -e "${RED}❌ Воспроизведение не работает${NC}"
        fi
        
        # Сохраняем файл для анализа
        cp "$REC_FILE" "./test_device_${device//[^a-zA-Z0-9]/_}.wav"
        echo "Файл сохранен: test_device_${device//[^a-zA-Z0-9]/_}.wav"
        
    else
        echo -e "${RED}❌ Устройство $device не работает${NC}"
    fi
    
    echo ""
    echo "---"
    echo ""
    
    # Очистка
    rm -f "$REC_FILE"
    
    # Пауза между тестами
    sleep 1
done

echo -e "${BLUE}=== РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ УСТРОЙСТВ ===${NC}"
echo "Все тестовые файлы сохранены в текущей директории"
echo "Проверьте, какие файлы создались и прослушайте их"
echo "Это поможет определить правильное устройство микрофона" 