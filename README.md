# 🎤 Voice Recognition System

**Профессиональная модульная система распознавания и синтеза речи на базе Whisper.cpp и Piper.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Language: Bash/Python](https://img.shields.io/badge/Language-Bash%20/%20Python-blue.svg)](https://www.python.org/)

## 📋 Описание

Это профессиональная система распознавания и синтеза речи, разработанная для Linux с упором на модульность и расширяемость. Система построена на базе state-of-the-art технологий **Whisper.cpp** для распознавания и **Piper** для синтеза.

Проект развивается по модульному принципу, где каждая ключевая функция (например, "голос" или "слух") инкапсулирована в свой собственный, независимый модуль.

## ✨ Ключевые возможности

- **🗣️ Синтез речи**: Высококачественный синтез на русском языке с помощью модуля **"Голос"**.
- **🎧 Распознавание речи**: Точное распознавание речи с помощью **Whisper.cpp**.
- **⚙️ Модульная архитектура**: Легко расширяемая и поддерживаемая структура.
- **🐍 Python API**: Удобный программный интерфейс для интеграции синтеза речи.
- **🧪 Тестирование**: Набор скриптов для комплексного тестирования системы.
- **📄 Документация**: Подробная документация для каждого модуля и для проекта в целом.

## 🚀 Быстрый старт

### 1. Установка зависимостей
```bash
# Обновите пакеты и установите зависимости
sudo apt update
sudo apt install -y sox alsa-utils pulseaudio bc git python3
```

### 2. Клонирование и установка
```bash
# Клонируйте репозиторий
git clone https://github.com/ElectroNickP/voice-recognition-system.git
cd voice-recognition-system

# Инициализируйте и обновите подмодули (Whisper.cpp)
git submodule update --init --recursive

# Соберите Whisper.cpp
cd whisper.cpp && make && cd ..

# Скачайте модели (пример для базовой модели)
./whisper.cpp/models/download-ggml-model.sh base
# Модель для Piper уже в комплекте
```

### 3. Использование модуля "Голос"

#### Через командную строку:
```bash
# Справка по использованию
./modules/voice/голос.sh --help

# Озвучить и воспроизвести текст
./modules/voice/голос.sh 'Модульная система работает!' --play
```

#### Через Python:
```python
# Создайте файл test.py
# from modules.voice import speak
# speak("Привет из Python!", play=True)

# Запустите
# python3 test.py
```

## 🤖 Модули

Система построена на модулях, каждый из которых отвечает за свою функциональность.

### Модуль "Голос" (`modules/voice`)

Отвечает за синтез речи (Text-to-Speech).
- **API**: `from modules.voice import speak`
- **CLI**: `modules/voice/голос.sh`
- **Документация**: `modules/voice/docs/`

*В будущем здесь появятся модули "Слух", "Зрение" и другие.*

## 📁 Структура проекта

```
voice-recognition-system/
├── modules/
│   └── voice/                # Модуль синтеза речи (Piper)
│       ├── __init__.py
│       ├── голос.sh
│       ├── voice_api.py
│       └── docs/
├── whisper.cpp/              # Git submodule для распознавания речи
├── piper/                    # Бинарные файлы и модели Piper
├── оперативка/               # Рабочая директория для временных файлов
├── docs/                     # Общая документация проекта
├── .gitignore
├── LICENSE
├── README.md
└── ... (тестовые скрипты)
```

## 🧪 Тестирование

Для проверки работоспособности системы используйте тестовые скрипты:

```bash
# Базовый тест системы
./restore_working_test.sh

# Комплексный тест с несколькими фразами
./multi_test_voice.sh
```

## 🤝 Вклад в проект

Мы приветствуем любой вклад!
1. Сделайте форк репозитория.
2. Создайте новую ветку (`git checkout -b feature/AmazingFeature`).
3. Внесите свои изменения.
4. Сделайте коммит (`git commit -m 'Add some AmazingFeature'`).
5. Запушьте в ветку (`git push origin feature/AmazingFeature`).
6. Откройте Pull Request.

## 📝 Лицензия

Этот проект распространяется под лицензией MIT. Подробности см. в файле [LICENSE](LICENSE).

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

vlc ./оперативка/описание_проекта.wav 