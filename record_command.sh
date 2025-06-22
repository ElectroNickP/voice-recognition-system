#!/bin/bash

# Скрипт для записи команды пользователя после активации
# и сохранения результата в файл.

# Настройки
WHISPER_DIR="/home/nick/Projects/Cursor/whisper.cpp"
MODEL_PATH="$WHISPER_DIR/models/ggml-base.bin"
OUTPUT_WAV="/tmp/command_audio.wav"
OUTPUT_TXT="/home/nick/Projects/Cursor/обращение.txt"

# Запись с микрофона с автоматическим определением тишины
# rec - записывает
# -c 1 - моно
# -r 16000 - частота 16кГц
# silence 1 0.1 3% 1 3.0 3% - магия sox:
#   - Начать запись при появлении звука (1 0.1 3%)
#   - Остановить запись после 3 секунд тишины (1 3.0 3%)
rec -q "$OUTPUT_WAV" -c 1 -r 16000 silence 1 0.1 3% 1 3.0 3%

# Распознавание речи
RECOGNIZED_TEXT=$("$WHISPER_DIR/build/bin/whisper-cli" -m "$MODEL_PATH" -l ru -f "$OUTPUT_WAV" -otxt -nt | sed 's/\[.*\]//g' | xargs)

# Сохранение в файл
if [ -n "$RECOGNIZED_TEXT" ]; then
    echo "$RECOGNIZED_TEXT" > "$OUTPUT_TXT"
else
    echo "Не удалось распознать речь." > "$OUTPUT_TXT"
fi

# Очистка
rm "$OUTPUT_WAV" 