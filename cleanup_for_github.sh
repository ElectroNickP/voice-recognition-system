#!/bin/bash

# Очистка проекта для публикации на GitHub

echo "=== ОЧИСТКА ПРОЕКТА ДЛЯ GITHUB ==="
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Удаление аудиофайлов...${NC}"

# Удаление всех аудиофайлов
find . -name "*.wav" -type f -delete
find . -name "*.mp3" -type f -delete
find . -name "*.ogg" -type f -delete
find . -name "*.flac" -type f -delete

echo -e "${GREEN}✅ Аудиофайлы удалены${NC}"

echo -e "${BLUE}Удаление изображений...${NC}"

# Удаление изображений
find . -name "*.png" -type f -delete
find . -name "*.jpg" -type f -delete
find . -name "*.jpeg" -type f -delete
find . -name "*.gif" -type f -delete

echo -e "${GREEN}✅ Изображения удалены${NC}"

echo -e "${BLUE}Удаление результатов тестов...${NC}"

# Удаление файлов результатов
find . -name "*_results.txt" -type f -delete
find . -name "*_feedback.txt" -type f -delete
find . -name "*.log" -type f -delete

echo -e "${GREEN}✅ Файлы результатов удалены${NC}"

echo -e "${BLUE}Удаление временных файлов...${NC}"

# Удаление временных файлов
find . -name "*.tmp" -type f -delete
find . -name "*.temp" -type f -delete
find . -name "*~" -type f -delete

echo -e "${GREEN}✅ Временные файлы удалены${NC}"

echo -e "${BLUE}Создание README для моделей...${NC}"

# Создание README для директории моделей Whisper
mkdir -p whisper.cpp/models
cat > whisper.cpp/models/README.md << 'EOF'
# Whisper Models

Эта директория предназначена для моделей Whisper.

## Скачивание моделей

```bash
# Базовая модель (рекомендуется)
wget -O ggml-base.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin

# Tiny модель (быстрая, но менее точная)
wget -O ggml-tiny.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin

# Medium модель (более точная, но медленнее)
wget -O ggml-medium.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin

# Large модель (самая точная, но очень медленная)
wget -O ggml-large.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin
```

## Размеры моделей

- ggml-tiny.bin: ~39 MB
- ggml-base.bin: ~142 MB  
- ggml-medium.bin: ~769 MB
- ggml-large.bin: ~1550 MB

## Использование

После скачивания модели измените путь в скриптах:

```bash
# В скриптах замените:
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

# На нужную модель, например:
WHISPER_MODEL="./whisper.cpp/models/ggml-medium.bin"
```
EOF

echo -e "${GREEN}✅ README для моделей Whisper создан${NC}"

# Создание README для директории Piper
cat > piper/README.md << 'EOF'
# Piper Models

Эта директория предназначена для моделей Piper TTS.

## Скачивание моделей

Скачайте русскую модель с официального сайта Piper:

```bash
# Модель и конфигурация
wget -O ru_RU-irina-medium.onnx [URL_TO_MODEL]
wget -O ru_RU-irina-medium.onnx.json [URL_TO_CONFIG]
```

## Альтернатива - espeak-ng

Если у вас нет модели Piper, используйте espeak-ng:

```bash
# Синтез с espeak-ng
./espeak-ng -v ru -w output.wav "Привет, это тест"
```

## Использование

После скачивания модели измените путь в скриптах:

```bash
# В скриптах замените:
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"

# На нужную модель
```

## Доступные модели

- ru_RU-irina-medium.onnx - Русская модель (среднее качество)
- ru_RU-irina-high.onnx - Русская модель (высокое качество)
EOF

echo -e "${GREEN}✅ README для моделей Piper создан${NC}"

echo -e "${BLUE}Проверка структуры проекта...${NC}"

# Показ структуры проекта
echo "Структура проекта:"
tree -I 'venv|__pycache__|*.pyc|*.pyo|*.pyd|.git' -a

echo ""
echo -e "${BLUE}Проверка размера проекта...${NC}"

# Показ размера проекта
echo "Размер проекта:"
du -sh . 2>/dev/null || echo "Не удалось определить размер"

echo ""
echo -e "${BLUE}Проверка .gitignore...${NC}"

# Проверка .gitignore
if [ -f ".gitignore" ]; then
    echo -e "${GREEN}✅ .gitignore найден${NC}"
    echo "Содержимое .gitignore:"
    head -20 .gitignore
else
    echo -e "${RED}❌ .gitignore не найден${NC}"
fi

echo ""
echo -e "${BLUE}Проверка основных файлов...${NC}"

# Проверка основных файлов
required_files=("README.md" "LICENSE" "requirements.txt" ".gitignore")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file найден${NC}"
    else
        echo -e "${RED}❌ $file не найден${NC}"
    fi
done

echo ""
echo -e "${BLUE}Проверка основных скриптов...${NC}"

# Проверка основных скриптов
required_scripts=("demo_recognition.sh" "restore_working_test.sh" "speak.sh" "listen.sh")
for script in "${required_scripts[@]}"; do
    if [ -f "$script" ]; then
        echo -e "${GREEN}✅ $script найден${NC}"
    else
        echo -e "${RED}❌ $script не найден${NC}"
    fi
done

echo ""
echo -e "${BLUE}Проверка документации...${NC}"

# Проверка документации
if [ -d "docs" ]; then
    echo -e "${GREEN}✅ Папка docs найдена${NC}"
    echo "Файлы документации:"
    ls -la docs/
else
    echo -e "${RED}❌ Папка docs не найдена${NC}"
fi

echo ""
echo -e "${GREEN}=== ОЧИСТКА ЗАВЕРШЕНА ===${NC}"
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Проверьте, что все нужные файлы на месте"
echo "2. Скачайте модели Whisper и Piper"
echo "3. Протестируйте систему"
echo "4. Создайте репозиторий на GitHub"
echo "5. Выполните git add, commit и push"
echo ""
echo -e "${BLUE}Команды для GitHub:${NC}"
echo "git init"
echo "git add ."
echo "git commit -m 'Initial commit: Voice Recognition System'"
echo "git branch -M main"
echo "git remote add origin https://github.com/yourusername/voice-recognition-system.git"
echo "git push -u origin main" 