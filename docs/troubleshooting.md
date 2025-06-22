# 🔧 Устранение неполадок

## Общие проблемы

### Система не запускается

**Симптомы**: Скрипты не выполняются или выдают ошибки

**Решение**:
```bash
# Проверка прав доступа
ls -la *.sh
chmod +x *.sh

# Проверка зависимостей
which sox
which arecord
which aplay

# Установка недостающих пакетов
sudo apt install -y sox alsa-utils pulseaudio bc
```

### Ошибка "Permission denied"

**Симптомы**: `zsh: permission denied: ./script.sh`

**Решение**:
```bash
chmod +x script.sh
```

### Ошибка "Command not found"

**Симптомы**: `command not found: sox`

**Решение**:
```bash
sudo apt update
sudo apt install -y sox
```

## Проблемы с аудио

### Микрофон не работает

**Симптомы**: Запись пустая или слишком тихая

**Диагностика**:
```bash
# Проверка устройств
arecord --list-devices

# Тест записи
arecord -d 3 test.wav
paplay test.wav

# Проверка уровня звука
sox test.wav -n stat
```

**Решения**:

1. **Проверка устройства**:
```bash
# Тест разных устройств
arecord -D hw:0,0 -d 3 test1.wav
arecord -D hw:1,0 -d 3 test2.wav
arecord -D default -d 3 test3.wav
```

2. **Настройка чувствительности**:
```bash
# Увеличение чувствительности
amixer sset Capture 50%

# Проверка настроек
amixer sget Capture
```

3. **Проверка прав доступа**:
```bash
# Добавление пользователя в группу audio
sudo usermod -a -G audio $USER

# Перезагрузка или перелогин
```

### Динамики не работают

**Симптомы**: Нет звука при воспроизведении

**Диагностика**:
```bash
# Проверка устройств воспроизведения
aplay --list-devices

# Тест воспроизведения
paplay /usr/share/sounds/alsa/Front_Left.wav

# Проверка громкости
amixer sget Master
```

**Решения**:

1. **Настройка громкости**:
```bash
amixer sset Master 80%
amixer sset PCM 80%
```

2. **Проверка PulseAudio**:
```bash
pulseaudio --start
pactl list sinks
```

### Проблемы с синхронизацией

**Симптомы**: Запись и воспроизведение не синхронизированы

**Диагностика**:
```bash
# Тест синхронизации
./sync_voice_test.sh

# Анализ временных меток
sox sync_recorded.wav -n stat
```

**Решения**:

1. **Увеличение задержки**:
```bash
# Измените sleep в скриптах
sleep 0.5  # вместо sleep 0.1
```

2. **Оптимизация буферов**:
```bash
# Увеличение размера буфера
sox -d -r 16000 -c 1 -b 16 --buffer 8192 output.wav
```

## Проблемы с Whisper

### Модель не найдена

**Симптомы**: `Error: failed to load model`

**Решение**:
```bash
# Проверка наличия модели
ls -la whisper.cpp/models/

# Скачивание модели
wget -O whisper.cpp/models/ggml-base.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

### Ошибка распознавания

**Симптомы**: Пустой результат или ошибки

**Диагностика**:
```bash
# Проверка аудиофайла
sox input.wav -n stat

# Тест Whisper напрямую
./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f input.wav -l ru
```

**Решения**:

1. **Проверка формата аудио**:
```bash
# Конвертация к правильному формату
sox input.wav -r 16000 -c 1 -b 16 output.wav
```

2. **Проверка языка**:
```bash
# Указание правильного языка
./whisper.cpp/main -m whisper.cpp/models/ggml-base.bin -f input.wav -l ru
```

### Медленная работа

**Симптомы**: Распознавание занимает много времени

**Решения**:

1. **Использование более легкой модели**:
```bash
# Скачивание tiny модели
wget -O whisper.cpp/models/ggml-tiny.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
```

2. **Оптимизация параметров**:
```bash
# Уменьшение длительности записи
# Измените trim в скриптах
```

## Проблемы с Piper

### Модель не найдена

**Симптомы**: `Error: failed to load model`

**Решение**:
```bash
# Проверка наличия модели
ls -la piper/

# Скачивание модели (замените URL)
# wget -O piper/ru_RU-irina-medium.onnx [URL]
```

### Ошибка синтеза

**Симптомы**: Синтез не работает или выдает ошибки

**Диагностика**:
```bash
# Тест Piper напрямую
echo "Привет" | ./piper/piper --model piper/ru_RU-irina-medium.onnx --output_file test.wav

# Проверка файла
sox test.wav -n stat
```

**Решения**:

1. **Использование espeak-ng**:
```bash
# Альтернативный синтез
./piper/espeak-ng -v ru -w output.wav "Привет"
```

2. **Проверка прав доступа**:
```bash
chmod +x piper/piper
```

## Проблемы с производительностью

### Высокое потребление CPU

**Симптомы**: Система тормозит при работе

**Решения**:

1. **Использование более легких моделей**:
```bash
# Whisper tiny вместо base
# Piper fast вместо medium
```

2. **Оптимизация параметров записи**:
```bash
# Уменьшение частоты дискретизации
sox -d -r 8000 -c 1 -b 16 output.wav
```

### Нехватка памяти

**Симптомы**: Ошибки "out of memory"

**Решения**:

1. **Закрытие других приложений**
2. **Использование swap**:
```bash
sudo swapon --show
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Логи и отладка

### Включение подробного вывода

```bash
# Добавьте -v в команды для подробного вывода
sox -v -d output.wav
./whisper.cpp/main -v -m model.bin -f input.wav
```

### Создание логов

```bash
# Перенаправление вывода в файл
./script.sh > log.txt 2>&1

# Просмотр логов в реальном времени
./script.sh | tee log.txt
```

### Анализ ошибок

```bash
# Проверка последних ошибок
tail -f /var/log/syslog | grep -i audio

# Проверка процессов
ps aux | grep -E "(sox|whisper|piper)"
```

## Получение помощи

Если проблема не решается:

1. **Создайте Issue в GitHub** с подробным описанием
2. **Приложите логи** и результаты диагностики
3. **Укажите версии** используемого ПО
4. **Опишите шаги** для воспроизведения проблемы 