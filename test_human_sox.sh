#!/bin/bash

# Простой тест записи человеческого голоса через sox

echo "=== ТЕСТ ЗАПИСИ ЧЕЛОВЕЧЕСКОГО ГОЛОСА ==="
echo ""

REC_FILE="/tmp/human_sox.wav"
REC_SECONDS=3

echo "Скажите 'ПРИВЕТ МИР' четко и громко (3 секунды)..."
echo "Записываю через sox..."

# Запись через sox
sox -d -r 16000 -c 1 -b 16 "$REC_FILE" trim 0 $REC_SECONDS

echo "Запись завершена"
echo "Размер: $(ls -lh $REC_FILE | awk '{print $5}')"
echo ""

echo "Воспроизведение записи:"
paplay "$REC_FILE"
echo ""

echo "Распознавание через Whisper:"
WHISPER_BIN="./whisper.cpp/build/bin/whisper-cli"
WHISPER_MODEL="./whisper.cpp/models/ggml-base.bin"

RECOG_TEXT=$($WHISPER_BIN -m $WHISPER_MODEL -l ru -f "$REC_FILE" -otxt -nt 2>/dev/null | sed 's/\[.*\]//g' | xargs)
echo "Результат: '$RECOG_TEXT'"

if [[ "$RECOG_TEXT" == *"привет"* ]] || [[ "$RECOG_TEXT" == *"мир"* ]]; then
    echo "✅ УСПЕХ: Распознано ключевое слово!"
elif [[ -n "$RECOG_TEXT" ]]; then
    echo "⚠️ Распознан текст, но не 'привет мир': '$RECOG_TEXT'"
else
    echo "❌ Не распознано ничего"
fi

# Сохранение
cp "$REC_FILE" "./human_sox_test.wav"
echo "Файл сохранен: human_sox_test.wav"

rm -f "$REC_FILE" 