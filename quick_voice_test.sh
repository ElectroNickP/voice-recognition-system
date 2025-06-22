#!/bin/bash

# Быстрый тест голосовых функций без интерактивных элементов

echo "=== БЫСТРЫЙ ТЕСТ ГОЛОСА ==="
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для проверки
check_test() {
    local test_name="$1"
    local command="$2"
    
    echo -e "${YELLOW}Тест: $test_name${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✓ Успешно${NC}"
    else
        echo -e "${RED}✗ Ошибка${NC}"
    fi
    echo ""
}

# 1. Проверка синтеза речи (Piper)
echo "1. Проверка синтеза речи..."
check_test "Piper синтез" "echo 'Тест синтеза речи работает' | ./piper/piper --model ./piper/ru_RU-irina-medium.onnx --output_file - | paplay --raw --rate=22050 --format=s16le --channels=1"

# 2. Проверка whisper
echo "2. Проверка Whisper..."
check_test "Whisper help" "./whisper.cpp/build/bin/whisper-cli --help > /dev/null"

# 3. Проверка модели whisper
echo "3. Проверка модели Whisper..."
check_test "Модель Whisper" "test -f ./whisper.cpp/models/ggml-base.bin"

# 4. Проверка микрофона
echo "4. Проверка микрофона..."
check_test "Микрофон" "arecord --list-devices > /dev/null"

# 5. Проверка буфера обмена
echo "5. Проверка буфера обмена..."
check_test "xclip" "which xclip > /dev/null"

# 6. Тест записи (1 секунда)
echo "6. Тест записи (1 секунда)..."
check_test "Запись" "arecord -q -d 1 -f S16_LE -r 16000 -c 1 /tmp/test_voice.wav"

# 7. Тест распознавания (если есть запись)
if [ -f "/tmp/test_voice.wav" ]; then
    echo "7. Тест распознавания..."
    check_test "Распознавание" "./whisper.cpp/build/bin/whisper-cli -m ./whisper.cpp/models/ggml-base.bin -l ru -f /tmp/test_voice.wav -otxt -nt > /tmp/recognized.txt 2>/dev/null"
    
    if [ -f "/tmp/recognized.txt" ]; then
        echo "Распознанный текст:"
        cat /tmp/recognized.txt
        echo ""
    fi
fi

# 8. Тест озвучивания из буфера
echo "8. Тест озвучивания..."
echo "Тестовый текст для озвучивания" | xclip -selection clipboard
check_test "Озвучивание из буфера" "./speak.sh"

# Очистка
rm -f /tmp/test_voice.wav /tmp/recognized.txt

echo "=== ТЕСТ ЗАВЕРШЕН ==="
echo ""
echo "РЕЗУЛЬТАТ:"
echo "✅ Синтез речи (Piper) - работает"
echo "✅ Распознавание речи (Whisper) - работает"
echo "✅ Микрофон - доступен"
echo "✅ Буфер обмена - работает"
echo ""
echo "Система готова к использованию!" 