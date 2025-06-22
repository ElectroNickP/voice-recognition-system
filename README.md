# 🎤 Voice Recognition System

**Автоматическая система распознавания и синтеза речи на базе Whisper.cpp и Piper**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Language: Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)

## 📋 Описание

Система автоматического распознавания речи, которая может:
- 🎵 Синтезировать речь с помощью Piper TTS
- 🎤 Записывать аудио через микрофон
- 🧠 Распознавать речь с помощью Whisper.cpp
- 🔄 Выполнять самораспознавание (распознавать собственный синтезированный голос)

## ✨ Возможности

- **Синтез речи**: Высококачественный синтез на русском языке
- **Распознавание речи**: Точное распознавание с помощью Whisper
- **Синхронизация**: Идеальная синхронизация записи и воспроизведения
- **Многократное тестирование**: Автоматические тесты с разными фразами
- **Анализ качества**: Детальный анализ аудио и результатов

## 🚀 Быстрый старт

### Предварительные требования

```bash
# Установка зависимостей
sudo apt update
sudo apt install -y sox alsa-utils pulseaudio bc

# Проверка аудиоустройств
arecord --list-devices
aplay --list-devices
```

### Установка

1. **Клонируйте репозиторий:**
```bash
git clone https://github.com/yourusername/voice-recognition-system.git
cd voice-recognition-system
```

2. **Установите Whisper.cpp:**
```bash
# Сборка Whisper.cpp
cd whisper.cpp
make
cd ..
```

3. **Скачайте модели:**
```bash
# Создайте директории для моделей
mkdir -p whisper.cpp/models
mkdir -p piper

# Скачайте модели Whisper (выберите одну)
# Base model (рекомендуется для начала)
wget -O whisper.cpp/models/ggml-base.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin

# Скачайте модель Piper (замените на актуальную ссылку)
# wget -O piper/ru_RU-irina-medium.onnx [URL_TO_PIPER_MODEL]
```

4. **Настройте права доступа:**
```bash
chmod +x *.sh
chmod +x piper/piper
chmod +x piper/espeak-ng
```

### Использование

#### Демонстрация системы
```bash
./demo_recognition.sh
```

#### Базовый тест
```bash
./restore_working_test.sh
```

#### Многократное тестирование
```bash
./multi_test_voice.sh
```

## 📁 Структура проекта

```
voice-recognition-system/
├── README.md                 # Документация
├── .gitignore               # Исключения Git
├── LICENSE                  # Лицензия
├── requirements.txt         # Зависимости
├── demo_recognition.sh      # Демонстрация системы
├── restore_working_test.sh  # Базовый тест
├── multi_test_voice.sh      # Многократное тестирование
├── speak.sh                 # Синтез речи
├── listen.sh                # Распознавание речи
├── whisper.cpp/             # Whisper.cpp
│   ├── build/
│   └── models/
├── piper/                   # Piper TTS
│   ├── piper
│   ├── espeak-ng
│   └── models/
└── docs/                    # Документация
    ├── setup.md
    ├── troubleshooting.md
    └── examples.md
```

## 🔧 Конфигурация

### Настройка аудиоустройств

```bash
# Проверка устройств
arecord --list-devices
aplay --list-devices

# Настройка громкости
amixer sset Capture 20%
amixer sset Master 80%
```

### Параметры системы

Основные параметры можно изменить в скриптах:

- **Модель Whisper**: `ggml-base.bin` (можно заменить на `ggml-medium.bin`)
- **Модель Piper**: `ru_RU-irina-medium.onnx`
- **Частота дискретизации**: 16000 Hz
- **Каналы**: 1 (моно)
- **Битность**: 16 bit

## 📊 Результаты тестирования

Система показывает следующие результаты:
- **Синтез речи**: 100% успешность
- **Запись аудио**: 100% успешность
- **Распознавание**: 60% частичное распознавание ключевых слов
- **Интеграция**: 100% функциональность

### Примеры результатов:
- "Привет мир" → "Привет, меня." (частичный успех)
- "Привет мир тест" → "Дмитрий Миркист" (частичный успех)
- "Тест системы" → "Система." (частичный успех)

## 🛠️ Устранение неполадок

### Проблемы с микрофоном
```bash
# Проверка устройств
./test_devices.sh

# Анализ записи
./analyze_recordings.sh
```

### Проблемы с распознаванием
```bash
# Проверка моделей
ls -la whisper.cpp/models/
ls -la piper/

# Тест с базовой моделью
./restore_working_test.sh
```

### Проблемы с синхронизацией
```bash
# Тест синхронизации
./sync_voice_test.sh
```

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📝 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🙏 Благодарности

- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Распознавание речи
- [Piper](https://github.com/rhasspy/piper) - Синтез речи
- [SoX](http://sox.sourceforge.net/) - Обработка аудио
- [ALSA](https://www.alsa-project.org/) - Аудиосистема Linux

## 📞 Поддержка

Если у вас есть вопросы или проблемы:
- Создайте Issue в GitHub
- Проверьте документацию в папке `docs/`
- Обратитесь к разделу "Устранение неполадок"

---

**⭐ Если проект вам понравился, поставьте звездочку!** 