import pyaudio
import numpy as np
import openwakeword
from openwakeword.model import Model
import subprocess
import os

# --- Настройки ---
WAKEWORD_KEY = "hey_jarvis_v0.1"  # Ключевое слово, на которое реагирует модель
PROJECT_DIR = "/home/nick/Projects/Cursor"
PIPER_EXE = os.path.join(PROJECT_DIR, "piper/piper")
PIPER_MODEL = os.path.join(PROJECT_DIR, "piper/ru_RU-irina-medium.onnx")
RECORD_SCRIPT = os.path.join(PROJECT_DIR, "record_command.sh")

# --- Инициализация ---
# Инициализируем модель.
# Предполагается, что вызов без аргументов загрузит все доступные модели,
# включая предварительно скачанную 'hey_jarvis'.
print("Инициализация модели ключевого слова...")
owwModel = Model()
print("Модель инициализирована.")

# Настройки PyAudio
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 16000
CHUNK = 1280  # 80 ms

audio = pyaudio.PyAudio()
stream = audio.open(format=FORMAT,
                    channels=CHANNELS,
                    rate=RATE,
                    input=True,
                    frames_per_buffer=CHUNK)

def say(text):
    """Озвучивает текст с помощью Piper."""
    command = f'echo "{text}" | {PIPER_EXE} --model {PIPER_MODEL} --output_file - | paplay --raw --rate=22050 --format=s16le --channels=1'
    subprocess.run(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# --- Основной цикл ---
print("Демон 'Ухо' запущен. Ожидаю ключевое слово 'Hey Jarvis'...")
say("Система слуха активирована")

try:
    while True:
        # Получаем аудиоданные
        audio_data = np.frombuffer(stream.read(CHUNK), dtype=np.int16)

        # Подаем в модель
        prediction = owwModel.predict(audio_data)
        
        # Отладочный вывод: посмотрим, что возвращает модель
        if prediction:
            print(prediction)

        # Если ключевое слово найдено (используем .get для безопасности)
        if prediction.get(WAKEWORD_KEY, 0) > 0.5: # 0.5 - порог уверенности
            print(f"Ключевое слово 'Hey Jarvis' обнаружено!")
            say("Слушаю")
            
            # Запускаем скрипт записи и распознавания
            subprocess.run([RECORD_SCRIPT])
            
            print("Запись и распознавание завершены.")
            say("Сообщение записано")

except KeyboardInterrupt:
    print("\nДемон 'Ухо' остановлен.")
    say("Система слуха деактивирована")

finally:
    # --- Очистка ---
    stream.stop_stream()
    stream.close()
    audio.terminate() 