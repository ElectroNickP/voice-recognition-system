# 🤖 AI Integration Guide

**Техническое руководство по интеграции Voice Recognition System с нейросетями и ИИ-системами**

> **Для ИИ-разработчиков**: Это руководство содержит всю необходимую информацию для интеграции системы синтеза и распознавания речи в ваши нейросети и ИИ-приложения.

## 📋 Обзор системы

Voice Recognition System - это **модульная система распознавания и синтеза речи** для Linux, специально разработанная для интеграции с ИИ-системами. Построена на базе:

- **Whisper.cpp** (распознавание речи) - state-of-the-art модель от OpenAI
- **Piper TTS** (синтез речи) - высококачественный нейросетевой синтезатор
- **Модульная архитектура** - легкая интеграция и расширяемость

### 🎯 Ключевые преимущества для ИИ

- **Низкая задержка**: Оптимизированные C++ библиотеки
- **Высокая точность**: Современные нейросетевые модели
- **Простая интеграция**: Python API и CLI интерфейсы
- **Модульность**: Независимые компоненты для разных задач
- **Кроссплатформенность**: Работает на Linux (Ubuntu/Debian)

## 🏗️ Архитектура системы

```
Voice Recognition System
├── modules/
│   └── voice/                    # Модуль синтеза речи
│       ├── __init__.py          # Python API (основной интерфейс)
│       ├── голос.sh             # CLI интерфейс
│       ├── voice_api.py         # Внутренний API
│       └── docs/                # Документация модуля
├── whisper.cpp/                 # Распознавание речи (Git submodule)
│   ├── models/                  # Модели Whisper
│   └── main                     # Исполняемый файл
├── piper/                       # Синтез речи
│   ├── piper                    # Исполняемый файл
│   ├── espeak-ng               # Фонетический движок
│   └── ru_RU-irina-medium.onnx # Русская модель
└── оперативка/                  # Временные файлы и логи
```

## 🔌 API для интеграции

### Python API (рекомендуется для ИИ)

```python
# Основной импорт
from modules.voice import speak

# Базовое использование
speak("Текст для озвучивания")

# С воспроизведением
speak("Текст с воспроизведением", play=True)

# Сохранение в файл
speak("Текст для сохранения", save="output.wav")

# Полный контроль параметров
speak(
    text="Полный контроль параметров",
    play=True,
    save="output.wav",
    voice_model="ru_RU-irina-medium.onnx"
)
```

### CLI API (для скриптов и автоматизации)

```bash
# Базовое использование
./modules/voice/голос.sh "Текст для озвучивания"

# С воспроизведением
./modules/voice/голос.sh "Текст" --play

# Сохранение в файл
./modules/voice/голос.sh "Текст" --save output.wav

# Полная справка
./modules/voice/голос.sh --help
```

## 🚀 Быстрая интеграция

### 1. Установка зависимостей

```bash
# Системные зависимости
sudo apt update
sudo apt install -y sox alsa-utils pulseaudio bc git python3

# Клонирование проекта
git clone https://github.com/ElectroNickP/voice-recognition-system.git
cd voice-recognition-system

# Инициализация подмодулей
git submodule update --init --recursive

# Сборка Whisper.cpp
cd whisper.cpp && make && cd ..

# Скачивание моделей
./whisper.cpp/models/download-ggml-model.sh base
```

### 2. Минимальный пример интеграции

```python
#!/usr/bin/env python3
"""
Минимальный пример интеграции с ИИ-системой
"""

import sys
import os

# Добавляем путь к модулям
sys.path.append(os.path.join(os.path.dirname(__file__), 'modules'))

try:
    from voice import speak
    
    def ai_response(text):
        """Функция для озвучивания ответов ИИ"""
        print(f"ИИ говорит: {text}")
        speak(text, play=True)
    
    # Пример использования
    ai_response("Привет! Я готов к работе.")
    
except ImportError as e:
    print(f"Ошибка импорта: {e}")
    print("Убедитесь, что проект установлен корректно")
```

## 🔧 Конфигурация для ИИ

### Переменные окружения

```bash
# Пути к моделям
export WHISPER_MODEL_PATH="./whisper.cpp/models/ggml-base.bin"
export PIPER_MODEL_PATH="./piper/ru_RU-irina-medium.onnx"

# Настройки аудио
export AUDIO_SAMPLE_RATE=16000
export AUDIO_CHANNELS=1

# Настройки производительности
export WHISPER_THREADS=4
export PIPER_THREADS=2
```

### Конфигурационный файл

```python
# config.py
VOICE_CONFIG = {
    'default_voice': 'ru_RU-irina-medium.onnx',
    'sample_rate': 16000,
    'channels': 1,
    'play_audio': True,
    'save_audio': False,
    'output_dir': './output/',
    'whisper_threads': 4,
    'piper_threads': 2,
    'cache_enabled': True,
    'cache_dir': './cache/'
}
```

## 📊 Технические характеристики

### Синтез речи (Piper)
- **Формат**: WAV, 16-bit PCM
- **Частота дискретизации**: 22050 Hz (по умолчанию)
- **Каналы**: 1 (моно)
- **Модель**: ru_RU-irina-medium.onnx
- **Размер модели**: ~50 MB
- **Задержка**: ~100-500ms (зависит от длины текста)
- **Качество**: 8/10 (субъективная оценка)

### Распознавание речи (Whisper.cpp)
- **Формат входа**: WAV, 16-bit PCM
- **Частота дискретизации**: 16000 Hz
- **Каналы**: 1 (моно)
- **Модель**: ggml-base.bin
- **Размер модели**: ~142 MB
- **Задержка**: ~1-3 секунды (зависит от длины аудио)
- **Точность**: 85-95% (зависит от качества аудио)

## 🔄 Примеры интеграции

### 1. Чат-бот с голосовым интерфейсом

```python
from modules.voice import speak
import speech_recognition as sr

class VoiceChatBot:
    def __init__(self):
        self.recognizer = sr.Recognizer()
    
    def listen(self):
        """Слушает пользователя"""
        with sr.Microphone() as source:
            audio = self.recognizer.listen(source)
            try:
                text = self.recognizer.recognize_google(audio, language='ru-RU')
                return text
            except:
                return None
    
    def respond(self, text):
        """Отвечает голосом"""
        # Здесь логика ИИ
        response = f"Вы сказали: {text}"
        speak(response, play=True)
        return response

# Использование
bot = VoiceChatBot()
user_input = bot.listen()
if user_input:
    bot.respond(user_input)
```

### 2. ИИ-ассистент с синтезом речи

```python
from modules.voice import speak
import json

class AIAssistant:
    def __init__(self):
        self.context = []
    
    def process_query(self, query):
        """Обрабатывает запрос пользователя"""
        # Здесь логика ИИ
        response = {
            'text': f'Обрабатываю запрос: {query}',
            'confidence': 0.95,
            'action': 'respond'
        }
        return response
    
    def speak_response(self, response):
        """Озвучивает ответ"""
        speak(response['text'], play=True)
    
    def run(self):
        """Основной цикл работы"""
        while True:
            query = input("Введите запрос: ")
            if query.lower() == 'выход':
                break
            
            response = self.process_query(query)
            self.speak_response(response)

# Использование
assistant = AIAssistant()
assistant.run()
```

### 3. Интеграция с TensorFlow/PyTorch

```python
import tensorflow as tf
from modules.voice import speak

class VoiceAIModel:
    def __init__(self):
        self.model = self.load_model()
    
    def load_model(self):
        """Загружает вашу ИИ-модель"""
        # Здесь загрузка вашей модели
        return tf.keras.models.load_model('your_model.h5')
    
    def predict_and_speak(self, input_data):
        """Делает предсказание и озвучивает результат"""
        prediction = self.model.predict(input_data)
        result_text = self.format_prediction(prediction)
        speak(result_text, play=True)
        return result_text
    
    def format_prediction(self, prediction):
        """Форматирует предсказание для озвучивания"""
        return f"Результат анализа: {prediction}"

# Использование
ai_model = VoiceAIModel()
ai_model.predict_and_speak(your_data)
```

### 4. Интеграция с OpenAI API

```python
import openai
from modules.voice import speak

class OpenAIVoiceAssistant:
    def __init__(self, api_key):
        openai.api_key = api_key
    
    def chat_and_speak(self, user_message):
        """Отправляет сообщение в OpenAI и озвучивает ответ"""
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "user", "content": user_message}
            ]
        )
        
        ai_response = response.choices[0].message.content
        speak(ai_response, play=True)
        return ai_response

# Использование
assistant = OpenAIVoiceAssistant("your-api-key")
assistant.chat_and_speak("Расскажи анекдот")
```

## 🧪 Тестирование интеграции

### Тест базовой функциональности

```python
def test_voice_integration():
    """Тест интеграции с модулем голоса"""
    try:
        from modules.voice import speak
        
        # Тест 1: Базовый синтез
        speak("Тест интеграции прошел успешно", play=True)
        
        # Тест 2: Сохранение файла
        speak("Тестовый файл", save="test_output.wav")
        
        print("✅ Интеграция работает корректно")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка интеграции: {e}")
        return False

# Запуск теста
if __name__ == "__main__":
    test_voice_integration()
```

### Тест производительности

```python
import time
from modules.voice import speak

def benchmark_voice_synthesis():
    """Тест производительности синтеза речи"""
    test_texts = [
        "Короткий текст",
        "Средний текст для тестирования производительности",
        "Длинный текст для проверки работы системы синтеза речи с различными параметрами и настройками"
    ]
    
    for text in test_texts:
        start_time = time.time()
        speak(text, save="benchmark.wav")
        end_time = time.time()
        
        duration = end_time - start_time
        print(f"Текст ({len(text)} символов): {duration:.2f} секунд")

# Запуск бенчмарка
benchmark_voice_synthesis()
```

## 🚨 Обработка ошибок

### Типичные ошибки и решения

```python
import logging

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def safe_speak(text, **kwargs):
    """Безопасный вызов синтеза речи"""
    try:
        from modules.voice import speak
        speak(text, **kwargs)
        return True
    except ImportError:
        logger.error("Модуль voice не найден")
        return False
    except FileNotFoundError:
        logger.error("Модели Piper не найдены")
        return False
    except Exception as e:
        logger.error(f"Ошибка синтеза речи: {e}")
        return False

# Использование в ИИ-системе
def ai_speak_with_fallback(text):
    """ИИ говорит с резервным вариантом"""
    if not safe_speak(text, play=True):
        # Резервный вариант - вывод в консоль
        print(f"ИИ: {text}")
```

## 📈 Производительность и оптимизация

### Рекомендации для высоконагруженных систем

1. **Кэширование**: Сохраняйте часто используемые фразы
2. **Асинхронность**: Используйте threading для неблокирующего синтеза
3. **Пул процессов**: Для высоконагруженных систем

```python
import threading
from queue import Queue

class AsyncVoiceSynthesizer:
    def __init__(self):
        self.queue = Queue()
        self.worker_thread = threading.Thread(target=self._worker)
        self.worker_thread.start()
    
    def _worker(self):
        """Рабочий поток для синтеза"""
        while True:
            text = self.queue.get()
            if text is None:
                break
            speak(text, play=True)
            self.queue.task_done()
    
    def speak_async(self, text):
        """Асинхронный синтез"""
        self.queue.put(text)
    
    def stop(self):
        """Остановка синтезатора"""
        self.queue.put(None)
        self.worker_thread.join()

# Использование в ИИ-системе
synthesizer = AsyncVoiceSynthesizer()
synthesizer.speak_async("Асинхронный ответ ИИ")
```

### Оптимизация для реального времени

```python
import asyncio
from modules.voice import speak

class RealtimeVoiceAI:
    def __init__(self):
        self.cache = {}
    
    async def speak_realtime(self, text):
        """Асинхронный синтез для реального времени"""
        if text in self.cache:
            # Используем кэшированный результат
            return self.cache[text]
        
        # Синтезируем новый текст
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, speak, text, True)
        
        # Кэшируем результат
        self.cache[text] = True
        return True

# Использование
ai = RealtimeVoiceAI()
asyncio.run(ai.speak_realtime("Быстрый ответ"))
```

## 🔗 Интеграция с популярными ИИ-фреймворками

### TensorFlow/Keras

```python
import tensorflow as tf
from modules.voice import speak

class VoiceTensorFlowModel:
    def __init__(self):
        self.model = tf.keras.models.load_model('model.h5')
    
    def predict_and_speak(self, input_data):
        prediction = self.model.predict(input_data)
        result = f"Предсказание: {prediction[0]}"
        speak(result, play=True)
        return result
```

### PyTorch

```python
import torch
from modules.voice import speak

class VoicePyTorchModel:
    def __init__(self):
        self.model = torch.load('model.pth')
        self.model.eval()
    
    def predict_and_speak(self, input_tensor):
        with torch.no_grad():
            prediction = self.model(input_tensor)
        result = f"Результат: {prediction.item():.2f}"
        speak(result, play=True)
        return result
```

### Hugging Face Transformers

```python
from transformers import pipeline
from modules.voice import speak

class VoiceTransformerModel:
    def __init__(self):
        self.classifier = pipeline("text-classification")
    
    def classify_and_speak(self, text):
        result = self.classifier(text)
        response = f"Классификация: {result[0]['label']} ({result[0]['score']:.2f})"
        speak(response, play=True)
        return response
```

## 🔗 Ссылки и ресурсы

- **Репозиторий**: https://github.com/ElectroNickP/voice-recognition-system
- **Whisper.cpp**: https://github.com/ggerganov/whisper.cpp
- **Piper TTS**: https://github.com/rhasspy/piper
- **Документация**: `docs/` папка проекта
- **Issues**: https://github.com/ElectroNickP/voice-recognition-system/issues

## 📞 Поддержка

Для технических вопросов по интеграции:
1. Создайте Issue в GitHub с тегом `[AI-Integration]`
2. Проверьте логи в `оперативка/`
3. Запустите тесты: `./restore_working_test.sh`
4. Обратитесь к документации модуля: `modules/voice/docs/`

---

**Версия**: 2.0  
**Дата**: 2024  
**Совместимость**: Python 3.7+, Linux (Ubuntu/Debian)  
**Лицензия**: MIT