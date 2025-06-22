#!/bin/bash

# Скрипт "Голос 2.0" для озвучивания текста из буфера обмена с помощью Piper

# Определяем пути
PIPER_DIR="/home/nick/Projects/Cursor/piper"
MODEL_NAME="ru_RU-irina-medium.onnx"
MODEL_PATH="$PIPER_DIR/$MODEL_NAME"

# Проверяем, существует ли модель
if [ ! -f "$MODEL_PATH" ]; then
    echo "Модель голоса не найдена по пути $MODEL_PATH"
    # Попытка озвучить ошибку старым методом для обратной совместимости
    espeak-ng -v ru "Ошибка, модель голоса Пайпер не найдена"
    exit 1
fi

# Получаем содержимое основного буфера обмена (Ctrl+C / Ctrl+V)
CLIPBOARD_CONTENT=$(xclip -o -selection clipboard)

# Проверяем, есть ли что-нибудь в буфере обмена
if [ -n "$CLIPBOARD_CONTENT" ]; then
    # Если есть, генерируем речь и сразу проигрываем через paplay
    # --raw указывает, что это "сырые" аудиоданные
    # --rate, --format, --channels задают параметры аудиопотока
    echo "$CLIPBOARD_CONTENT" | "$PIPER_DIR/piper" --model "$MODEL_PATH" --output_file - | paplay --raw --rate=22050 --format=s16le --channels=1
else
    # Если буфер пуст, сообщаем об этом
    echo "Буфер обмена пуст" | "$PIPER_DIR/piper" --model "$MODEL_PATH" --output_file - | paplay --raw --rate=22050 --format=s16le --channels=1
fi 