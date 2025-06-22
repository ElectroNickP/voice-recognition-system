# 📚 Примеры использования

## Базовые примеры

### 1. Простой синтез речи

```bash
# Синтез одной фразы
./speak.sh "Привет, это тест синтеза речи"

# Синтез с сохранением в файл
echo "Привет мир" | ./piper/piper --model piper/ru_RU-irina-medium.onnx --output_file hello.wav
```

### 2. Простое распознавание речи

```bash
# Запись и распознавание
./listen.sh

# Распознавание существующего файла
./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f audio.wav -l ru
```

### 3. Полный цикл самораспознавания

```bash
# Демонстрация системы
./demo_recognition.sh

# Базовый тест
./restore_working_test.sh
```

## Продвинутые примеры

### 1. Многократное тестирование

```bash
# Тест с разными фразами
./multi_test_voice.sh

# Результаты сохраняются в файлы:
# - multi_test_synth_1.wav до multi_test_synth_5.wav
# - multi_test_rec_1.wav до multi_test_rec_5.wav
# - voice_test_results.txt
```

### 2. Анализ качества аудио

```bash
# Тестирование устройств записи
./test_devices.sh

# Анализ записей
./analyze_recordings.sh

# Проверка качества аудио
./check_audio_quality.sh
```

### 3. Настройка синхронизации

```bash
# Тест синхронизации
./sync_voice_test.sh

# Эксперименты с синхронизацией
./sync_recording_experiment.sh
```

## Интеграция в другие проекты

### 1. Использование в Python

```python
import subprocess
import os

def synthesize_speech(text, output_file="output.wav"):
    """Синтез речи с помощью Piper"""
    cmd = f'echo "{text}" | ./piper/piper --model piper/ru_RU-irina-medium.onnx --output_file {output_file}'
    subprocess.run(cmd, shell=True, check=True)
    return output_file

def recognize_speech(audio_file):
    """Распознавание речи с помощью Whisper"""
    cmd = f'./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f {audio_file} -l ru -otxt -nt --no-timestamps'
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

# Пример использования
synthesize_speech("Привет, это тест")
text = recognize_speech("output.wav")
print(f"Распознано: {text}")
```

### 2. Использование в Node.js

```javascript
const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

async function synthesizeSpeech(text, outputFile = 'output.wav') {
    const cmd = `echo "${text}" | ./piper/piper --model piper/ru_RU-irina-medium.onnx --output_file ${outputFile}`;
    await execAsync(cmd);
    return outputFile;
}

async function recognizeSpeech(audioFile) {
    const cmd = `./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f ${audioFile} -l ru -otxt -nt --no-timestamps`;
    const { stdout } = await execAsync(cmd);
    return stdout.trim();
}

// Пример использования
async function main() {
    await synthesizeSpeech('Привет, это тест');
    const text = await recognizeSpeech('output.wav');
    console.log(`Распознано: ${text}`);
}

main().catch(console.error);
```

### 3. Использование в веб-приложении

```html
<!DOCTYPE html>
<html>
<head>
    <title>Voice Recognition Demo</title>
</head>
<body>
    <h1>Демонстрация распознавания речи</h1>
    
    <button onclick="synthesize()">Синтезировать речь</button>
    <button onclick="record()">Записать речь</button>
    <button onclick="recognize()">Распознать речь</button>
    
    <div id="output"></div>

    <script>
        async function synthesize() {
            const response = await fetch('/api/synthesize', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ text: 'Привет, это тест' })
            });
            const audio = await response.blob();
            const url = URL.createObjectURL(audio);
            new Audio(url).play();
        }

        async function record() {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            const mediaRecorder = new MediaRecorder(stream);
            const chunks = [];
            
            mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
            mediaRecorder.onstop = () => {
                const blob = new Blob(chunks, { type: 'audio/wav' });
                localStorage.setItem('recordedAudio', URL.createObjectURL(blob));
            };
            
            mediaRecorder.start();
            setTimeout(() => mediaRecorder.stop(), 5000);
        }

        async function recognize() {
            const audioUrl = localStorage.getItem('recordedAudio');
            if (!audioUrl) return;
            
            const response = await fetch('/api/recognize', {
                method: 'POST',
                body: JSON.stringify({ audio: audioUrl })
            });
            const result = await response.json();
            document.getElementById('output').textContent = result.text;
        }
    </script>
</body>
</html>
```

## Автоматизация

### 1. Скрипт для автоматического тестирования

```bash
#!/bin/bash
# auto_test.sh

echo "=== АВТОМАТИЧЕСКОЕ ТЕСТИРОВАНИЕ ==="

# Массив тестовых фраз
phrases=(
    "Привет"
    "Как дела"
    "Тест системы"
    "Распознавание речи"
    "Синтез голоса"
)

# Счетчики
total=0
success=0
partial=0
failed=0

for phrase in "${phrases[@]}"; do
    echo "Тестирую: '$phrase'"
    
    # Синтез
    echo "$phrase" | ./piper/piper --model piper/ru_RU-irina-medium.onnx --output_file test_synth.wav
    
    # Запись
    sox -d -r 16000 -c 1 -b 16 test_rec.wav trim 0 3 &
    paplay test_synth.wav &
    wait
    
    # Распознавание
    result=$(./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f test_rec.wav -l ru -otxt -nt --no-timestamps 2>/dev/null)
    
    echo "Результат: '$result'"
    
    # Анализ результата
    if [[ "$result" == *"$phrase"* ]]; then
        echo "✅ ПОЛНЫЙ УСПЕХ"
        ((success++))
    elif [[ "$result" == *"привет"* ]] || [[ "$result" == *"тест"* ]] || [[ "$result" == *"систем"* ]]; then
        echo "⚠️ ЧАСТИЧНЫЙ УСПЕХ"
        ((partial++))
    else
        echo "❌ НЕУДАЧА"
        ((failed++))
    fi
    
    ((total++))
    echo "---"
done

echo "=== РЕЗУЛЬТАТЫ ==="
echo "Всего тестов: $total"
echo "Полных успехов: $success"
echo "Частичных успехов: $partial"
echo "Неудач: $failed"
echo "Процент успешности: $((success * 100 / total))%"
```

### 2. Мониторинг системы

```bash
#!/bin/bash
# monitor.sh

echo "=== МОНИТОРИНГ СИСТЕМЫ ==="

# Проверка процессов
echo "Проверка процессов:"
ps aux | grep -E "(sox|whisper|piper)" | grep -v grep

# Проверка файлов
echo "Проверка моделей:"
ls -la whisper.cpp/models/ 2>/dev/null || echo "Модели Whisper не найдены"
ls -la piper/ 2>/dev/null || echo "Модели Piper не найдены"

# Проверка аудиоустройств
echo "Проверка аудиоустройств:"
arecord --list-devices | grep -A 1 "card" | head -10

# Проверка места на диске
echo "Проверка места на диске:"
df -h . | tail -1

# Проверка памяти
echo "Проверка памяти:"
free -h | head -2
```

### 3. Резервное копирование

```bash
#!/bin/bash
# backup.sh

echo "=== РЕЗЕРВНОЕ КОПИРОВАНИЕ ==="

# Создание архива
backup_file="voice_system_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

tar -czf "$backup_file" \
    --exclude='*.wav' \
    --exclude='*.mp3' \
    --exclude='venv/' \
    --exclude='__pycache__/' \
    .

echo "Резервная копия создана: $backup_file"
echo "Размер: $(du -h "$backup_file" | cut -f1)"
```

## Оптимизация

### 1. Оптимизация для слабых систем

```bash
#!/bin/bash
# optimize_lightweight.sh

echo "=== ОПТИМИЗАЦИЯ ДЛЯ СЛАБЫХ СИСТЕМ ==="

# Использование tiny модели Whisper
if [ ! -f "whisper.cpp/models/ggml-tiny.bin" ]; then
    echo "Скачивание tiny модели..."
    wget -O whisper.cpp/models/ggml-tiny.bin \
        https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
fi

# Уменьшение частоты дискретизации
echo "Настройка параметров записи..."
# Измените параметры в скриптах:
# sox -d -r 8000 -c 1 -b 16  # вместо 16000

# Уменьшение длительности записи
echo "Уменьшение длительности записи..."
# Измените trim в скриптах:
# trim 0 3  # вместо trim 0 5
```

### 2. Оптимизация для мощных систем

```bash
#!/bin/bash
# optimize_powerful.sh

echo "=== ОПТИМИЗАЦИЯ ДЛЯ МОЩНЫХ СИСТЕМ ==="

# Использование large модели Whisper
if [ ! -f "whisper.cpp/models/ggml-large.bin" ]; then
    echo "Скачивание large модели..."
    wget -O whisper.cpp/models/ggml-large.bin \
        https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin
fi

# Увеличение буферов
echo "Увеличение буферов..."
# Измените параметры в скриптах:
# sox -d -r 16000 -c 1 -b 16 --buffer 16384

# Параллельная обработка
echo "Настройка параллельной обработки..."
# Используйте & для параллельного выполнения
```

## Интеграция с CI/CD

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Voice Recognition Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Install dependencies
      run: |
        sudo apt update
        sudo apt install -y sox alsa-utils pulseaudio bc wget make
    
    - name: Build Whisper.cpp
      run: |
        cd whisper.cpp
        make
        cd ..
    
    - name: Download models
      run: |
        mkdir -p whisper.cpp/models
        wget -O whisper.cpp/models/ggml-base.bin \
          https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
    
    - name: Run tests
      run: |
        chmod +x *.sh
        ./demo_recognition.sh
    
    - name: Upload results
      uses: actions/upload-artifact@v2
      with:
        name: test-results
        path: demo_*.wav
```

Эти примеры помогут вам интегрировать систему распознавания речи в ваши проекты и автоматизировать процессы тестирования и развертывания. 