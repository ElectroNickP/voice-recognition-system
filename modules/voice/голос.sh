#!/bin/bash

# 🎤 ГОЛОС v0.1 - Универсальная функция синтеза речи
# Автор: Voice Recognition System
# Версия: 0.1
# Дата: 2025-06-22

# Получаем директорию, где находится сам скрипт
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Конфигурация
PIPER_PATH="$SCRIPT_DIR/../../piper/piper"
VOICE_MODEL="$SCRIPT_DIR/../../piper/ru_RU-irina-medium.onnx"
TEMP_DIR="/tmp"
DEFAULT_OUTPUT_DIR="$SCRIPT_DIR/../../оперативка"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция помощи
show_help() {
    echo -e "${CYAN}🎤 ГОЛОС v0.1 - Универсальная функция синтеза речи${NC}"
    echo ""
    echo -e "${YELLOW}Использование:${NC}"
    echo "  ./голос.sh [текст] [опции]"
    echo ""
    echo -e "${YELLOW}Примеры:${NC}"
    echo "  ./голос.sh 'Привет мир!'"
    echo "  ./голос.sh 'Это тест системы' --save"
    echo "  ./голос.sh 'Длинный текст' --output my_audio.wav"
    echo "  ./голос.sh --file input.txt"
    echo ""
    echo -e "${YELLOW}Опции:${NC}"
    echo "  --save              Сохранить в файл (автоимя)"
    echo "  --output FILE       Сохранить в указанный файл"
    echo "  --file FILE         Озвучить текст из файла"
    echo "  --play              Воспроизвести после синтеза"
    echo "  --quiet             Тихий режим (без вывода)"
    echo "  --help              Показать эту справку"
    echo ""
    echo -e "${YELLOW}Переменные окружения:${NC}"
    echo "  VOICE_TEXT          Текст для озвучивания"
    echo "  VOICE_OUTPUT        Путь к выходному файлу"
    echo ""
}

# Функция проверки зависимостей
check_dependencies() {
    if [ ! -f "$PIPER_PATH" ]; then
        echo -e "${RED}❌ Ошибка: Piper не найден по пути $PIPER_PATH${NC}"
        return 1
    fi
    
    if [ ! -f "$VOICE_MODEL" ]; then
        echo -e "${RED}❌ Ошибка: Модель голоса не найдена по пути $VOICE_MODEL${NC}"
        return 1
    fi
    
    return 0
}

# Функция генерации имени файла
generate_filename() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local text_preview=$(echo "$1" | head -c 20 | tr ' ' '_' | tr -d '[:punct:]')
    echo "${DEFAULT_OUTPUT_DIR}/голос_${text_preview}_${timestamp}.wav"
}

# Функция синтеза речи
synthesize_speech() {
    local text="$1"
    local output_file="$2"
    local quiet="$3"
    
    if [ "$quiet" != "true" ]; then
        echo -e "${BLUE}🎤 Синтезирую речь...${NC}"
        echo -e "${CYAN}Текст:${NC} $text"
        echo -e "${CYAN}Файл:${NC} $output_file"
    fi
    
    # Создаем директорию если не существует
    mkdir -p "$(dirname "$output_file")"
    
    # Синтезируем речь
    if echo "$text" | "$PIPER_PATH" --model "$VOICE_MODEL" --output_file "$output_file"; then
        if [ "$quiet" != "true" ]; then
            echo -e "${GREEN}✅ Синтез завершен успешно!${NC}"
            
            # Показываем размер файла
            if [ -f "$output_file" ]; then
                local file_size=$(du -h "$output_file" | cut -f1)
                echo -e "${CYAN}Размер файла:${NC} $file_size"
            fi
        fi
        return 0
    else
        if [ "$quiet" != "true" ]; then
            echo -e "${RED}❌ Ошибка при синтезе речи${NC}"
        fi
        return 1
    fi
}

# Функция воспроизведения
play_audio() {
    local file="$1"
    local quiet="$2"
    
    if [ "$quiet" != "true" ]; then
        echo -e "${BLUE}🎵 Воспроизводим...${NC}"
    fi
    
    # Пробуем разные плееры, отдавая предпочтение полным путям
    if command -v /usr/bin/paplay &> /dev/null; then
        /usr/bin/paplay "$file" 2>/dev/null
    elif command -v /usr/bin/aplay &> /dev/null; then
        /usr/bin/aplay "$file" 2>/dev/null
    elif command -v paplay &> /dev/null; then
        paplay "$file" 2>/dev/null
    elif command -v aplay &> /dev/null; then
        aplay "$file" 2>/dev/null
    elif command -v ffplay &> /dev/null; then
        ffplay -nodisp -autoexit "$file" 2>/dev/null
    else
        if [ "$quiet" != "true" ]; then
            echo -e "${YELLOW}⚠️  Не найден плеер для воспроизведения${NC}"
            echo -e "${CYAN}Файл сохранен:${NC} $file"
        fi
    fi
}

# Основная функция
main() {
    local save_mode="" # 'auto' or 'file'
    local output_file=""
    local play_after=false
    local quiet=false
    local input_file=""
    
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Сначала парсим все опции
    local text_args=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --save)
                save_mode="auto"
                shift
                ;;
            --output)
                save_mode="file"
                output_file="$2"
                shift 2
                ;;
            --file)
                if [ -f "$2" ]; then
                    input_file="$2"
                else
                    echo -e "${RED}❌ Файл не найден: $2${NC}"
                    exit 1
                fi
                shift 2
                ;;
            --play)
                play_after=true
                shift
                ;;
            --quiet)
                quiet=true
                shift
                ;;
            -*)
                echo -e "${RED}❌ Неизвестная опция: $1${NC}"
                show_help
                exit 1
                ;;
            *)
                # Собираем аргументы, которые являются текстом
                text_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Объединяем текстовые аргументы в одну строку
    text="${text_args[*]}"

    # Проверяем зависимости
    if ! check_dependencies; then
        exit 1
    fi
    
    # Получаем текст из файла, если указан. Это имеет приоритет.
    if [ -n "$input_file" ]; then
        text=$(cat "$input_file")
        if [ "$quiet" != "true" ]; then
            echo -e "${BLUE}📖 Читаю текст из файла: $input_file${NC}"
        fi
    fi
    
    # Проверяем, есть ли текст
    if [ -z "$text" ]; then
        # Проверяем переменную окружения
        if [ -n "$VOICE_TEXT" ]; then
            text="$VOICE_TEXT"
            if [ "$quiet" != "true" ]; then
                echo -e "${BLUE}📝 Использую текст из переменной VOICE_TEXT${NC}"
            fi
        else
            echo -e "${RED}❌ Не указан текст для озвучивания${NC}"
            echo -e "${YELLOW}Используйте: ./голос.sh 'ваш текст'${NC}"
            show_help
            exit 1
        fi
    fi
    
    if [ -z "$text" ]; then
        echo -e "${RED}❌ Нет текста для озвучивания!${NC}"
        show_help
        exit 1
    fi

    # Определяем выходной файл
    if [ "$save_mode" = "auto" ]; then
        output_file=$(generate_filename "$text")
    elif [ "$save_mode" = "file" ]; then
        # output_file уже установлен
        if [ -z "$output_file" ]; then
             echo -e "${RED}❌ Не указано имя файла для опции --output${NC}"
             exit 1
        fi
    else
        # Если не указано сохранение, используем временный файл
        output_file=$(mktemp "${TEMP_DIR}/голос_$(date +%s)_XXXX.wav")
    fi

    # Синтезируем речь
    if ! synthesize_speech "$text" "$output_file" "$quiet"; then
        exit 1
    fi

    # Воспроизводим если нужно
    if [ "$play_after" = true ]; then
        play_audio "$output_file" "$quiet"
    fi
    
    if [ "$quiet" != "true" ] && [ "$save_mode" != "" ]; then
         echo -e "${GREEN}🎉 Готово!${NC}"
         echo -e "${CYAN}Файл:${NC} $output_file"
    fi
    
    # Если файл временный и не просили сохранить - удаляем
    if [ "$save_mode" = "" ]; then
        # Не удаляем, если нужно воспроизвести
        if [ "$play_after" = false ]; then
             rm "$output_file"
        fi
    fi
}

# Запускаем основную функцию
main "$@"
