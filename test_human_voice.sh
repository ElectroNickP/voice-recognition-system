#!/bin/bash

# Тест распознавания человеческой речи

echo "=== ТЕСТ РАСПОЗНАВАНИЯ ЧЕЛОВЕЧЕСКОЙ РЕЧИ ==="
echo ""

WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"
REC_FILE="/tmp/human_voice.wav"

echo "Скажите 'Привет мир' четко и громко (3 секунды)..."
arecord -q -d 3 -f S16_LE -r 16000 -c 1 "$REC_FILE"

echo "Распознаю вашу речь..."
RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt | sed 's/\[.*\]//g' | xargs)

echo "Вы сказали: '$RECOG_TEXT'"

if [[ "$RECOG_TEXT" == *"привет"* ]] || [[ "$RECOG_TEXT" == *"мир"* ]]; then
    echo "✅ Успешно распознано!"
else
    echo "❌ Не удалось распознать 'привет мир'"
fi

# Сохраняем для анализа
cp "$REC_FILE" "./human_voice_test.wav"
echo "Файл сохранен: human_voice_test.wav"

rm -f "$REC_FILE" 