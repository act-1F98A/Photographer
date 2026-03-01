#!/bin/bash

############################################
# ПРОВЕРКА ЗАВИСИМОСТЕЙ
############################################
check_dependencies() {
    local missing=0

    for cmd in ffmpeg streamlink; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Ошибка: '$cmd' не установлен."
            missing=1
        fi
    done

    if [[ $missing -eq 1 ]]; then
        echo ""
        echo "Установи зависимости:"
        echo "  sudo pacman -S ffmpeg streamlink"
        echo "Или:"
        echo "  sudo apt install ffmpeg streamlink"
        echo "Или ещё както, я хз"
        exit 1
    fi
}
check_dependencies

BASE="$HOME/twitch-buffer"
SEG="$BASE/segments"
CLIPS="$BASE/clips"

SEG_TIME=10
WRAP=60

BACK=5      # 2.5 мин назад (15 * 10с)
FORWARD=5   # 2.5 мин вперёд


############################################
# HELP
############################################
print_help() {
    case "$LANG" in 
        en_US.UTF-8)
            cat << EOF
Using:

$0 <nickname on twitch> [flag]

Without a flag:
    starts the ring buffer of the stream

--clip:
    creates a clip only BACKWARDS in time ($(($BACK*$SEG_TIME+$FORWARD*$SEG_TIME)) seconds by default)

--full-clip:
    creates a clip backward + forward in time ($(($BACK*$SEG_TIME+$FORWARD*$SEG_TIME)) seconds, the button in the center)

--duty <number>:
    the duration in segments that last $SEG_TIME seconds by default. The clip will be longer by 2 times.
    
--segment-time <number>:
    the duration in seconds of one segment must be specified and when starting the buffer and when creating the clip. The default is $SEG_TIME seconds

--dirrectory <path>:
    specifies the working directory in which the buffer will be created

--not-rm-data-dir:
    not delete the directory with data. By default, it is deleted

--help, -h:
    show this help
EOF
        ;;
        ru_RU.UTF-8)
            cat << EOF
Использование:

$0 <ник на твиче> [флаг]

Без флага:
    запускает кольцевой буфер стрима

--clip:
    создаёт клип только НАЗАД по времени ($(($BACK*$SEG_TIME+$FORWARD*$SEG_TIME)) секунд по умолчанию)

--full-clip:
    создаёт клип назад + вперёд по времени ($(($BACK*$SEG_TIME+$FORWARD*$SEG_TIME)) секунд, кнопка в центре)

--duty <число>:
    длительность в сегментах, которые длятся $SEG_TIME секунд по умолчанию. Клип будет длиться в 2 раза дольше.
    
--segment-time <число>:
    длительность в секундах одного сегмента необходимо указать и при запуске буфера и при создании клипа одинаково. По умолчанию $SEG_TIME секунд
    
--dirrectory <путь>:
    указывает рабочую директорию, в которой будет создан буфер
    
--not-rm-data-dir:
    не удалять директорию с данными. По умолчанию она удаляется

--help, -h:
    показать эту справку
EOF
        ;;
    esac
exit 0
}

if [[ -z "$1" || "$1" == --* ]]; then
    case "$LANG" in 
        ru_RU.UTF-8)
            echo "Укажите ник стримера"
        ;;
        en_US.UTF-8*)
            echo "Specify streamer's nickname"
        ;;
    esac
    exit 1
else
    echo "Ник: $1"
    NICK="$1"
    shift
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clip)
            MODE="--clip"
            shift
            ;;
        --full-clip)
            MODE="--full-clip"
            shift
            ;;
        --duty)
            BACK="$2"
            FORWARD="$2"
            shift 2
            ;;
        --segment-time)
            SEG_TIME="$2"
            shift 2
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        --dirrectory)
            BASE=$(realpath "$2/twitch-buffer")
            SEG="$BASE/segments"
            CLIPS="$BASE/clips"
            shift 2
            ;;
        --not-rm-data-dir)
            NOT_RM_DATA_DIR=1
            shift
            ;;
        *)
            echo "Неизвестный флаг: $1"
            exit 1
            ;;
    esac
done




STREAM="https://twitch.tv/$NICK"

mkdir -p "$SEG/$NICK" "$CLIPS/$NICK"


############################################
# РЕЖИМ ЗАПИСИ БУФЕРА
############################################
if [[ -z "$MODE" ]]; then
    rm -f "$SEG/$NICK"/*.ts
    echo "Запуск буфера..."

    streamlink "$STREAM" best -O | \
    ffmpeg -loglevel warning \
        -i - \
        -c copy \
        -f segment \
        -segment_time $SEG_TIME \
        -segment_wrap $WRAP \
        -reset_timestamps 1 \
        "$SEG/$NICK/seg_%03d.ts"

    exit 0
fi

############################################
# РЕЖИМ СОЗДАНИЯ КЛИПА
############################################

if [[ "$MODE" == "--clip" || "$MODE" == "--full-clip" ]]; then
    echo "Создание клипа..."

    # Получаем последний сегмент
    LATEST_FILE=$(ls -t "$SEG/$NICK"/seg_*.ts 2>/dev/null | tac | tail -n1)
    echo "Последний сегмент: $LATEST_FILE"

    if [[ -z "$LATEST_FILE" ]]; then
        echo "Сегменты ещё не созданы"
        exit 1
    fi

    LATEST_NUM=$(basename "$LATEST_FILE" | grep -o '[0-9]\+')
    LATEST_NUM=$((10#$LATEST_NUM))  # убираем возможный leading zero

    CLIP_DIR="$CLIPS/$NICK/clip_$(date +%H_%M_%S)"
    mkdir -p "$CLIP_DIR"

    ############################################
    # КОПИРУЕМ НАЗАД
    ############################################
    if [[ "$MODE" == "--clip" ]]; then
        DUTY=$((BACK+FORWARD))
    else
        DUTY=$BACK
    fi

    for ((i=DUTY; i>-1; i--)); do
        IDX=$(( (LATEST_NUM - i + WRAP) % WRAP ))
        printf -v PAD "%03d" "$IDX"
        FILE="$SEG/$NICK/seg_$PAD.ts"
        echo "IDX: $FILE"

        [[ -f "$FILE" ]] && cp "$FILE" "$CLIP_DIR/"
    done

    if [[ "$MODE" == "--full-clip" ]]; then

        ############################################
        # ЖДЁМ СЕГМЕНТЫ ВПЕРЁД
        ############################################

        echo "Ждём $((FORWARD * SEG_TIME)) секунд вперёд..."
        sleep $((FORWARD * SEG_TIME))

        ############################################
        # КОПИРУЕМ ВПЕРЁД
        ############################################

        NEW_LATEST=$(ls "$SEG/$NICK"/seg_*.ts | tac | tail -n1)
        NEW_NUM=$(basename "$NEW_LATEST" | grep -o '[0-9]\+')
        NEW_NUM=$((10#$NEW_NUM))

        for ((i=0; i<=FORWARD; i++)); do
            IDX=$(( (LATEST_NUM + i) % WRAP ))
            printf -v PAD "%03d" "$IDX"
            FILE="$SEG/$NICK/seg_$PAD.ts"

            [[ -f "$FILE" ]] && cp "$FILE" "$CLIP_DIR/"
        done

        echo "Сегменты сохранены в $CLIP_DIR"
    fi

    ############################################
    # СКЛЕИВАЕМ В MP4
    ############################################

    OUTFILE="$CLIP_DIR.mp4"
    CONCAT_LIST="$CLIP_DIR/concat.txt"

    > "$CONCAT_LIST"

    # ВАЖНО: сортируем по времени изменения, а не по имени
    for f in $(ls -t "$CLIP_DIR"/seg_*.ts | tac); do
        printf "file '%s'\n" "$f" >> "$CONCAT_LIST"
    done

    ffmpeg -loglevel warning \
        -f concat \
        -safe 0 \
        -i "$CONCAT_LIST" \
        -c copy \
        -movflags +faststart \
        "$OUTFILE"
    
    if [[ -z "$NOT_RM_DATA_DIR" ]]; then
        rm -rf "$CLIP_DIR"
    fi

    echo "Готовый клип: $OUTFILE"
fi