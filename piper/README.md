# Piper Models

Эта директория предназначена для моделей Piper TTS.

## Скачивание моделей

Скачайте русскую модель с официального сайта Piper:

```bash
# Модель и конфигурация
wget -O ru_RU-irina-medium.onnx [URL_TO_MODEL]
wget -O ru_RU-irina-medium.onnx.json [URL_TO_CONFIG]
```

## Альтернатива - espeak-ng

Если у вас нет модели Piper, используйте espeak-ng:

```bash
# Синтез с espeak-ng
./espeak-ng -v ru -w output.wav "Привет, это тест"
```

## Использование

После скачивания модели измените путь в скриптах:

```bash
# В скриптах замените:
VOICE_MODEL="./piper/ru_RU-irina-medium.onnx"

# На нужную модель
```

## Доступные модели

- ru_RU-irina-medium.onnx - Русская модель (среднее качество)
- ru_RU-irina-high.onnx - Русская модель (высокое качество)
