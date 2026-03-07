#!/bin/bash
cd "$(dirname "$(realpath "$0")")" 

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

############################################
# КОНФИГ
############################################

set_work_directory() {
	BASE="$1/photographer"
	mkdir -p "$BASE"
	BASE="$(realpath "$BASE")"
	SEG="$BASE/segments"
	CLIPS="$BASE/clips"
}

SCRIPT="$0"
CONFIG_DIR="$HOME/.config/photographer"
CLIPS_DATA_DIR="data"
MADE_CLIPS_DIR="made_clips"
STREAMERS_FILE="$CONFIG_DIR/streamers"
CONFIG_FILE="$CONFIG_DIR/config"
CONFIG_FILES="$CONFIG_DIR/streamers_configs"
TWITCH_LINK="https://twitch.tv/"

NONE_STREAMER="--None--"
WOFI="WOFI"
ROFI="ROFI"
FZF="FZF"
TRUE="1"
FALSE="0"
POINTER_UP="⬆️"
POINTER_DOWN="⬇️"
NONE_STRING="--None--"
LINE_STRING="--------------------------"
ONLINE_INDICATOR="🟢"
OFFLINE_INDICATOR="🔴"
STREAM_EMOJ="🎥"
PLUS_EMOJI="➕"
SETTINGS_EMOJI="⚙️"
POINTER_BACK_EMOJI="⬅️"
COMMENT_EMOJI="💬"

DEFAULT_DURATION_FORWARD=12
DEFAULT_DURATION_BACK=12
DEFAULT_SEGMENT_TIME=10
DEFAULT_WORK_DIRECTORY="$HOME"
DEFAULT_MERGE_ADJACENT_CLIPS=0
POINTER_EMOJI="$POINTER_UP"
INVERT_POINTER_EMOJI="$POINTER_DOWN"
DEFAULT_USING_UI=""
DEFAULT_BUFFER_SIZE=60
ENABLE_ONLINE_CHECK="$FALSE"
INVERT_COMMENTS="$FALSE"
START_BUFFER="$FALSE"

DURATION_FORWARD=5
DURATION_BACK=5
SEG_TIME=10
BUFFER_SIZE=$DEFAULT_BUFFER_SIZE
TITLE=""



mkdir -p "$CONFIG_DIR" "$CONFIG_FILES"
touch "$STREAMERS_FILE"

load_local_config() {
    while IFS='=' read -r key value; do
        if [[ -n "$value" && ! -z "$value" && ! "$value" == "''" ]]; then
            export "$key=$value"
        fi
    done < <(
        grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$1"
    )
}

load_all_config_for_streamer() {
	source "$CONFIG_FILE"
	load_local_config "$CONFIG_FILES/$1.conf"
}


sync_variable_with_config() {
	NICK="$CURRENT_STREAMER"
	FORWARD="$DURATION_FORWARD"
	BACK="$DURATION_BACK"
	SEG_TIME="$SEGMENT_TIME"
	BUFFER_SIZE="$BUFFER_SIZE"
	set_work_directory "$WORK_DIRECTORY"
	MERGE_ADJACENT_CLIPS="$MERGE_ADJACENT_CLIPS"
	STREAM_LINK="$TWITCH_LINK$NICK"
}

load_all_config_for_streamer "$CURRENT_STREAMER"
sync_variable_with_config

flip_pointers() {
    if [[ "$POINTER_EMOJI" == "$POINTER_UP" ]]; then
        POINTER_EMOJI="$POINTER_DOWN"
        INVERT_POINTER_EMOJI="$POINTER_UP"
    else
        POINTER_EMOJI="$POINTER_UP"
        INVERT_POINTER_EMOJI="$POINTER_DOWN"
    fi
}

invert_comments() {
    if [[ "$INVERT_COMMENTS" == "$FALSE" ]]; then
        INVERT_COMMENTS="$TRUE"
    else
        INVERT_COMMENTS="$FALSE"
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --ui-config)
                UI_CONFIG="$2"
                shift 2
                ;;
            --use-wofi)
                USING_UI="$WOFI"
                shift
                ;;
            --use-rofi)
                USING_UI="$ROFI"
                shift
                ;;
            --use-fzf)
                USING_UI="$FZF"
                SILENCE_LOG="$TRUE"
                invert_comments
                flip_pointers
                shift
                ;;
			--start-buffer)
				START_BUFFER="$TRUE"
				shift
				;;
			--streamer)
				NICK="$1"
				shift
				;;
            --silence-log)
                SILENCE_LOG="$TRUE"
                shift
                ;;
            --flip-pointers)
                flip_pointers
                shift
                ;;
            --eneble-online-check)
                ENABLE_ONLINE_CHECK="$TRUE"
                shift
                ;;
            --invert-comments)
                invert_comments
                shift
                ;;
            --)
                shift
                parse_gui_args "$@"
                break
                ;;
            --clip)
                MODE="--clip"
                shift
                ;;
            --full-clip)
                MODE="--full-clip"
                shift
                ;;
            --duration-back)
                BACK="$2"
                shift 2
                ;;
            --duration-forward)
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
            --directory)
				set_work_directory "$2"
                shift 2
                ;;
            --merge-adjacent-clips)
                MERGE_ADJACENT_CLIPS=1
                shift
                ;;
            --buffer-size)
                BUFFER_SIZE="$2"
                shift 2
                ;;
            --title)
                TITLE="$2"
                shift 2
                ;;
            --use-configs)
                USE_CONFIGS="$TRUE"
                exit 0
                ;;
            " ")
                shift
                ;;
            "")
                shift
                ;;
            *)
                echo "unknown flag: $1" >&2
                shift
                ;;
        esac
    done
}

mkdir -p "$SEG/$NICK" "$CLIPS/$NICK" "$CLIPS/$NICK/$CLIPS_DATA_DIR" "$CLIPS/$NICK/$MADE_CLIPS_DIR"


parse_gui_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --)
                shift
                parse_args "$@"
                break
                ;;
            *)
                GUI_ARGS="$GUI_ARGS $1"
                shift
                ;;
        esac
    done
}

parse_args "$@"

############################################
# РЕЖИМ ЗАПИСИ БУФЕРА
############################################
start_buffer() {
	echo "$SEG" >&2
    rm -f "$SEG/$NICK"/*.ts
    echo "Starting buffer..."
    streamlink "$STREAM_LINK" best -O | \
    ffmpeg -loglevel warning \
        -i - \
        -c copy \
        -f segment \
        -segment_time $SEG_TIME \
        -segment_wrap $BUFFER_SIZE \
        -reset_timestamps 1 \
        "$SEG/$NICK/seg_%03d.ts"
    exit 0
}
    
if [[ "$START_BUFFER" == "$TRUE" ]]; then
	echo "$SEG" >&2
	start_buffer
fi


detect_ui() {
    local session="${XDG_SESSION_TYPE:-}"

    if [[ "$session" == "wayland" ]]; then
        if command -v wofi >/dev/null 2>&1; then
            echo "$WOFI"
            return
        fi
    fi

    if command -v rofi >/dev/null 2>&1; then
        echo "$ROFI"
        return
    fi

    # if command -v wofi >/dev/null 2>&1; then
        # echo "$WOFI"
        # return
    # fi

    if command -v fzf >/dev/null 2>&1; then
        echo "$FZF"
        return
    fi
}


if [[ -z "$USING_UI" ]]; then
    USING_UI="$(detect_ui)"
fi



rofi_menu() {
    local ui_conf
    if [[ ! -z "$UI_CONFIG" ]]; then
        ui_conf="-theme $UI_CONFIG"
    fi
    echo -e "$1" | rofi -dmenu -p "$2" "$ui_conf" $GUI_ARGS
}

wofi_menu() {
    local ui_conf
    if [[ ! -z "$UI_CONFIG" ]]; then
        ui_conf="--conf $UI_CONFIG"
    fi
    echo -e "$1" | wofi "$ui_conf: " --cache-file=/dev/null --matching=none --dmenu --prompt "$2" $GUI_ARGS
}

fzf_menu() {
    input="$(echo -e "$1" | fzf --prompt "$2: " --print-query $GUI_ARGS)"
    if [[ "$input" == *$'\n'* ]]; then
        printf '%s' "${input#*$'\n'}"
    else
        printf '%s' "$input"
    fi
}

grap_menu() {
    case "$USING_UI" in
        "$WOFI")
            wofi_menu "$1" "$2"
            ;;
        "$ROFI")
            rofi_menu "$1" "$2"
            ;;
        "$FZF")
            fzf_menu "$1" "$2"
            ;;
    esac
}


inpu_name_menu() {
	back="back"
	first_string="$POINTER_EMOJI$(insert_zwsp_between_chars " Enter the name of the clip ")$POINTER_EMOJI"
	other_strings="$POINTER_BACK_EMOJI $(insert_zwsp_between_chars "$back")
$(build_comment "Entering the name does not slow down the script
(you can think about the name for as long as you like,
the clip was created when the script was activated)")"

	comment="$first_string
$other_strings"
	menu="$(echo -e "$comment")"
	name="$(grap_menu "$menu" "Enter the name of the clip")"
	echo "$menu" > tets.test
	echo "$name" > tets2.test
	grep -q "$name" <<EOF
$first_string
EOF
	fs=$?
	grep -q "$name" <<EOF
$other_strings
EOF
	os=$?
	if [[ $fs -eq 0 && $os -eq 0 ]]; then
		return 1
	elif [[ $fs -eq 0 ]]; then
		return 0
	elif [[ $os -eq 1 ]]; then
		echo "$name"       
		return 0
	else
		return 1
	fi
}



############################################
# УТИЛИТЫ
############################################


init_global_config() {
    mv "$CONFIG_FILE" "$CONFIG_FILE.bak"
    echo "$(cat << EOF
DURATION_FORWARD=$DEFAULT_DURATION_FORWARD
DURATION_BACK=$DEFAULT_DURATION_BACK
BUFFER_SIZE=$DEFAULT_BUFFER_SIZE
SEGMENT_TIME=$DEFAULT_SEGMENT_TIME
CURRENT_STREAMER=$NONE_STREAMER
WORK_DIRECTORY=$DEFAULT_WORK_DIRECTORY
MERGE_ADJACENT_CLIPS=$DEFAULT_MERGE_ADJACENT_CLIPS
EOF
)" > "$CONFIG_FILE"
}

init_local_config() {
    echo "init_local_config $1" >&2
    echo "$(cat << EOF
DURATION_FORWARD=
DURATION_BACK=
BUFFER_SIZE=
SEGMENT_TIME=
WORK_DIRECTORY=
MERGE_ADJACENT_CLIPS=
EOF
)" > "$CONFIG_FILES/$1.conf"
}

if [[ ! -f "$CONFIG_FILE" ]]; then
    init_global_config
fi

check_global_config() {
    source "$1"
    if [[ ! -f "$1" || -z "$BUFFER_SIZE" || -z "$DURATION_BACK" || -z "$DURATION_FORWARD" || -z "$SEGMENT_TIME" || -z "$CURRENT_STREAMER" || -z "$WORK_DIRECTORY" || -z "$MERGE_ADJACENT_CLIPS" ]]; then
        init_global_config
        echo "the global configuration file is not valid. this file will be reset to the default settings." >&2
    fi
    if ! [[ "$MERGE_ADJACENT_CLIPS" == "1" || "$MERGE_ADJACENT_CLIPS" == "0" ]]; then
        init_global_config;
        echo "the global configuration file is not valid. this file will be reset to the default settings. the MERGE_ADJACENT_CLIPS variable can only be 1 or 0." >&2;
    fi
}

check_global_config "$CONFIG_FILE"

get_current() {
    source "$CONFIG_FILE" 2>/dev/null
    echo "$CURRENT_STREAMER"
}

get_all_running_streamers() {
    local dir="$CONFIG_FILES"
    local file

    [[ -d "$dir" ]] || return

    for file in "$dir"/*.conf; do
        [[ -e "$file" ]] || continue
        local streamer="$(basename "$file" .conf)"
        $(is_running "$streamer") && echo "$streamer"
    done
}

is_running() {
    local streamer="$1"

    if systemctl --user is-active --quiet "photographer-$streamer.scope"; then
        return 0
    fi
    return 1
}

is_streaming() {
    streamlink -Q "https://twitch.tv/$1" >/dev/null 2>&1
    return $?
}

get_streaming_indicator() {
    if is_streaming "$1"; then
        local online_indicator="$ONLINE_INDICATOR"
    else
        local online_indicator="$OFFLINE_INDICATOR"
    fi
    echo "$STREAM_EMOJ$online_indicator"
}

toggle_buffer() {
    local streamer="$1"

    if is_running "$streamer"; then
        kill_streamer_buffer "$streamer"
    else
        {
            systemd-run --user \
                --scope \
                --unit="photographer-$streamer" \
				"$SCRIPT" --start-buffer &
        } 2> >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat >&2 )
    fi

    [[ "$USING_UI" == "$WOFI" ]] && sleep 0.01
    [[ "$USING_UI" == "$ROFI" ]] && sleep 0.01
    [[ "$USING_UI" == "$FZF" ]] && sleep 0.01
}

insert_zwsp_between_chars() {
    local input="$1"
    local zwsp=$'\u200B'
    local output=""
    local i

    for (( i=0; i<${#input}; i++ )); do
        output+="${input:i:1}"
        if (( i < ${#input}-1 )); then
            output+="$zwsp"
        fi
    done

    printf '%s\n' "$output"
}
build_comment() {
    local comment="$1"
    local invert="$INVERT_COMMENTS"
    

    local lines
    lines=$(echo -e "$comment")
    
    lines="$(insert_zwsp_between_chars "$lines")"    

    print() {
        echo "$1" | sed "s/^/$COMMENT_EMOJI /"
    }

    if [[ "$invert" == "$TRUE" ]]; then
        print "$lines" |tac
    else
        print "$lines"
    fi
}

kill_streamer_buffer() {
    local streamer="$1"
    if ! is_running "$streamer"; then return; fi
    systemctl --user stop "photographer-$streamer.scope"
}

add_streamer() {
    echo "$1" >&2
    if [[ -n "$1" ]] && ! grep -q "$1" "$STREAMERS_FILE"; then
        if [[ -z "$(cat $STREAMERS_FILE)" ]]; then
            echo "$1" > "$STREAMERS_FILE"
        else
            echo "$1" >> "$STREAMERS_FILE"
        fi
    fi
}
add_streamer_ui() {
    local enter_string="$POINTER_EMOJI A.d.d s.t.r.e.a.m.e.r $POINTER_EMOJI" 
    NEW="$(grap_menu "$enter_string" "Add streamer")"
    if [[ ! "$NEW" == "$enter_string" && ! "$NEW" == "" ]]; then
        add_streamer "$NEW"
    fi
}

streamer_list() {
    local menu=$(
        local pids=()
        while read l_streamer; do
            (
                if [[ -z "$l_streamer" ]]; then continue; fi
                if $(is_running "$l_streamer"); then
                    local indicator="$ONLINE_INDICATOR"
                else
                    local indicator="$OFFLINE_INDICATOR"
                fi
                if [[ "$ENABLE_ONLINE_CHECK" == "$TRUE" ]]; then
                    local online_emoji_indicator=$(get_streaming_indicator "$l_streamer")
                fi
                if ! [[ -z "$menu" ]]; then 
                    local n="\n"
                fi
                #menu="$menu$n$indicator $l_streamer $STREAM_EMOJ$online_indicator"
                echo "$indicator $l_streamer $online_emoji_indicator"
            ) &
            pids+=($!)
            sleep 0.01
        done < <( cat "$STREAMERS_FILE" )
        for pid in "${pids[@]}"; do
            wait "$pid"
        done
    )
    local full_menu="$(cat <<EOF
$PLUS_EMOJI Add streamer $PLUS_EMOJI
$menu
EOF
)"
    local sel="$(grap_menu "$full_menu" "Set active streamer")"
    sel=$(echo "$sel" | sed 's/^[^ ]* //')
    sel="${sel% *}"
    echo "$sel" >&2
    streamer_list_selector "$sel"
}

streamer_list_selector() {
    case "$1" in 
        "Add streamer")
            add_streamer_ui
            streamer_list
            ;;
        *)
            echo "$1"
            ;;
    esac
}


set_local_variable() {
    local file="$1"
    local var="$2"
    local value="$3"

    echo "set $var=$value in $file"
    
    local escaped
    printf -v escaped '%q' "$value"

    if grep -q "^${var}=" "$file" 2>/dev/null; then
        sed -i "s|^${var}=.*|${var}=${escaped}|" "$file"
    else
        printf '%s=%s\n' "$var" "$escaped" >> "$file"
    fi 
}

change_variable_menu() {
	load_all_config_for_streamer "$CURRENT_STREAMER"
    variable="$1"
    menu="$(cat <<EOF
$POINTER_EMOJI enter a new value for the variable $variable $POINTER_EMOJI
$3
$POINTER_BACK_EMOJI back
EOF
)"
    if [[ "$4" == "_" ]]; then
        menu="_\n$menu"
    fi
    local var="$(grap_menu "$menu" "Change variable")"
    $(grep -q "$var" <<EOF
$menu
EOF
) && [[ ! "$var" == "_" ]] && return 1
    [[ "$var" == "_" ]] && var=""

    set_local_variable "$2" "$variable" "$var"
	load_all_config_for_streamer "$CURRENT_STREAMER"
	sync_variable_with_config
}

change_loacal_variable_menu() {
    change_variable_menu "$1" "$2" "$3" "_"
    return "$?"
}

restart_buffer() {
    if is_running "$1"; then
        kill_streamer_buffer "$1"
        toggle_buffer "$1"
    fi
}

restart_all_buffers() {
    echo "restart_all_buffers $(get_all_running_streamers)" >&2

    while IFS= read -r l_streamer; do
    #for streamer in $get_all_running_streamers; do
        echo "streamer = $l_streamer" >&2 
        restart_buffer "$l_streamer"
    done < <( get_all_running_streamers )
}

delete_data_for_streamer() {
    local streamer="$1"
	load_all_config_for_streamer
    echo "removing cache folder for $(realpath "$CLIPS/$streamer/$CLIPS_DATA_DIR")" >&2

    rm -rf "$(realpath "$CLIPS/$streamer/$CLIPS_DATA_DIR")"
}

delete_all_clip_data() {
	while read line; do
		delete_data_for_streamer "$line"
	done < <(cat "$STREAMERS_FILE")
}

clip() {
	TMP_NAME_FILE=$(mktemp)
	echo "Creating a clip..."
	if [[ -z "$TITLE" ]]; then
		(
			( inpu_name_menu; echo " $?" ) > "$TMP_NAME_FILE"
		) &
		ZENITY_PID=$!
	fi

	LATEST_FILE=$(ls -t "$SEG/$NICK"/seg_*.ts 2>/dev/null | tac | tail -n1)
	echo "The last segment: $LATEST_FILE"

	if [[ -z "$LATEST_FILE" && ! "$MODE" == "--full-clip" ]]; then
		echo "The segments have not been created yet"
		exit 1
	fi
	if ! [[ -z "$LATEST_FILE" ]]; then
		LATEST_NUM=$(basename "$LATEST_FILE" | grep -o '[0-9]\+')
		LATEST_NUM=$((10#$LATEST_NUM))

		#CLIP_DIR="$CLIPS/$NICK/$CLIPS_DATA_DIR/clip_$(date +%H_%M_%S)"
		clip_dir="clip_$(date +%d_%m_%y__%H_%M_%S)"
		clip_data_dir="$CLIPS/$NICK/$CLIPS_DATA_DIR/$clip_dir"
		mkdir -p "$clip_data_dir"

		############################################
		# КОПИРУЕМ НАЗАД
		############################################
		if [[ "$MODE" == "--clip" ]]; then
			DURATION_BACK=$((BACK+FORWARD))
		else
			DURATION_BACK=$BACK
		fi

		for ((i=DURATION_BACK; i>-1; i--)); do
			IDX=$(( (LATEST_NUM - i + BUFFER_SIZE) % BUFFER_SIZE))
			printf -v PAD "%03d" "$IDX"
			FILE="$SEG/$NICK/seg_$PAD.ts"

			[[ -f "$FILE" ]] && cp "$FILE" "$clip_data_dir/"
		done
	fi
		
	if [[ "$MODE" == "--full-clip" ]]; then

		echo "$clipdir">&2
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
			IDX=$(( (LATEST_NUM + i) % BUFFER_SIZE ))
			printf -v PAD "%03d" "$IDX"
			FILE="$SEG/$NICK/seg_$PAD.ts"

			[[ -f "$FILE" ]] && cp "$FILE" "$clip_data_dir/"
		done

		echo "Сегменты сохранены в $clip_data_dir"
	fi

	############################################
	# СКЛЕИВАЕМ В MP4
	############################################

	if ! [[ -z "$ZENITY_PID" ]]; then
		wait "$ZENITY_PID"
		TITLE="$(cat "$TMP_NAME_FILE")"
		rm -f "$TMP_NAME_FILE"
		if [[ "${TITLE#* }" == "1" ]]; then
			echo "remove $clip_data_dir"
			rm -rf "$clip_data_dir"
			exit 0
		fi
	fi

	TITLE="${TITLE% *}"
	TITLE="${TITLE%$'\n'}"
	if ! [[ -z "$TITLE" ]]; then
		underlining="_"
	fi

	OUTFILE="$CLIPS/$NICK/$MADE_CLIPS_DIR/${TITLE}${underlining}$clip_dir.mp4"
	mkdir -p "$CLIPS/$NICK/$MADE_CLIPS_DIR"
	CONCAT_LIST="$clip_data_dir/concat.txt"

	> "$CONCAT_LIST"


	for f in $(ls -t "$clip_data_dir"/seg_*.ts | tac); do
		printf "file '%s'\n" "$f" >> "$CONCAT_LIST"
	done

	ffmpeg -loglevel warning \
		-f concat \
		-safe 0 \
		-i "$CONCAT_LIST" \
		-c copy \
		-movflags +faststart \
		"$OUTFILE"
	
	if [[ -z "$MERGE_ADJACENT_CLIPS" ]]; then
		rm -rf "$clip_data_dir"
	fi

	echo "Готовый клип: $OUTFILE"
	exit 0
}

if [[ "$MODE" == "--clip" || "$MODE" == "--full-clip" ]]; then
	clip
fi

settings_menu() {
    local streamer="$1"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        init_global_config
    fi
    source "$CONFIG_FILE"
    local glogal_settings_submenu_title="$SETTINGS_EMOJI Global settings"
    local duration_forward="Duty forward = $DURATION_FORWARD segments ($(($DURATION_FORWARD*$SEGMENT_TIME)) sec)"
    local duration_back="Duty back = $DURATION_BACK segments ($(($DURATION_BACK*$SEGMENT_TIME)) sec)"
    local buffer_size="Buffer size = $BUFFER_SIZE"
    local segment_time="Segment time = $SEGMENT_TIME"
    local work_directory="Work dirrectory = $WORK_DIRECTORY"
    local merge_adjacent_clips="Merge adjacent clips = $MERGE_ADJACENT_CLIPS"
    local delete_data_clips="Delete ALL clip data"
    
    local back="$POINTER_BACK_EMOJI Back"
    global_settings_comment="$(build_comment "Local variables have a higher priority and will be.\nused instead of global ones if they are not empty.")"


    local global_seg_time
    printf -v global_seg_time "$SEGMENT_TIME"

    if [[ ! "$streamer" == "$NONE_STREAMER" ]]; then
        if [[ ! -f "$CONFIG_FILES/$streamer.conf" && ! "$streamer" == "$NONE_STREAMER" ]]; then
            init_local_config "$streamer"
        fi
        source "$CONFIG_FILES/$streamer.conf"
        local l_streamer_settings_submenu_title="$SETTINGS_EMOJI Streamer ($streamer) settings"
        local full_duration
        if [[ ! -z "$DURATION_BACK" ]]; then
            if [[ -z "$SEGMENT_TIME" ]]; then
                full_duration=$(("$DURATION_BACK"*"$global_seg_time"))
            else
                full_duration=$(("$DURATION_BACK"*"$SEGMENT_TIME"))
            fi
        fi
        local l_duration_back="local Duty = $DURATION_BACK segments ($full_duration sec)"
        local full_duration
        if [[ ! -z "$DURATION_FORWARD" ]]; then
            if [[ -z "$SEGMENT_TIME" ]]; then
                full_duration=$(("$DURATION_FORWARD"*"$global_seg_time"))
            else
                full_duration=$(("$DURATION_FORWARD"*"$SEGMENT_TIME"))
            fi
        fi
        local l_duration_forward="local Duty = $DURATION_FORWARD segments ($full_duration sec)"
        
        local l_buffer_size="local Buffer size = $BUFFER_SIZE"
        local l_segment_time="local Segment time = $SEGMENT_TIME"
        local l_work_directory="local Work dirrectory = $WORK_DIRECTORY"
        local l_merge_adjacent_clips="local Merge adjacent clips = $MERGE_ADJACENT_CLIPS"
        local l_delete_data_clips="Delete all clip data for $streamer"
    fi

    local menu
    menu=$(cat <<EOF
$back
$glogal_settings_submenu_title
$duration_forward
$duration_back
$buffer_size
$segment_time
$work_directory
$merge_adjacent_clips
$delete_data_clips
EOF
)
    if ! [[ "$streamer" == "$NONE_STREAMER" ]]; then
        menu=$(cat <<EOF
$menu
$LINE_STRING
$l_streamer_settings_submenu_title
$l_duration_forward
$l_duration_back
$l_buffer_size
$l_segment_time
$l_work_directory
$l_merge_adjacent_clips
$l_delete_data_clips
EOF
)
    fi
    menu=$(cat <<EOF
$menu
$LINE_STRING
$back
$global_settings_comment
EOF
)
    
    local sel="$(grap_menu "$menu" "Settings")"

    local duration_forward_comment="When using full-clip, the script waits for the specified number of new segments.\nWhen using clip, this value is added to the value of the duration_back and saves the specified number of segments that have already been created.\nThe value must be an integer."
    local duration_back_comment="Specifies how many segments back in time will be taken to create the clip.\nThe value must be an integer."
    local buffer_size_comment="The size of the buffer in segments.\nThe value must be an integer."
    local segment_time_comment="Segment time in seconds.\n!WHEN YOU CHANGE THIS VARIABLE, THE ALL STREAM BUFFERS WILL BE RESTARTED!\nThe value must be an integer."
    local work_directory_comment="The directory where the stream fragments and the resulting clips will be placed.\nThe value must be an integer."
    local merge_adjacent_clips_comment="Zero -- temporary files (which make up the clip segments) will be deleted.\nOne -- temporary files will not be deleted.\nThe value must be an intager."

    case "$sel" in
        "$duration_forward")
            change_variable_menu "DURATION_FORWARD" "$CONFIG_FILE" "$(build_comment "$duration_forward_comment")"
            ;;
        "$duration_back")
            change_variable_menu "DURATION_BACK" "$CONFIG_FILE" "$(build_comment "$duration_back_comment")"
            ;;
        "$buffer_size")
            change_variable_menu "BUFFER_SIZE" "$CONFIG_FILE" "$(build_comment "$buffer_size_comment")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$segment_time")
            change_variable_menu "SEGMENT_TIME" "$CONFIG_FILE" "$(build_comment "$segment_time_comment")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$work_directory")
            change_variable_menu "WORK_DIRECTORY" "$CONFIG_FILE" "$(build_comment "$work_directory_comment")"
            [[ ! "$?" == "1" ]] && restart_all_buffers
            ;;
        "$merge_adjacent_clips")
            change_variable_menu "MERGE_ADJACENT_CLIPS" "$CONFIG_FILE" "$(build_comment "$merge_adjacent_clips_comment")"
            ;;
        "$delete_data_clips")
            delete_all_clip_data
            ;;
        *)
            ret="$TRUE"
            ;;
    esac
    if ! [[ "$streamer" == "$NONE_STREAMER" ]]; then
        case "$sel" in
            "$l_duration_forward")
                change_loacal_variable_menu "DURATION_FORWARD" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$duration_forward_comment")"
                ;;
            "$l_duration_back")
                change_loacal_variable_menu "DURATION_BACK" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$duration_back_comment")"
                ;;
            "$l_buffer_size")
                change_loacal_variable_menu "BUFFER_SIZE" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$buffer_size_comment")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_segment_time")
                change_loacal_variable_menu "SEGMENT_TIME" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$segment_time_comment")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_work_directory")
                change_loacal_variable_menu "WORK_DIRECTORY" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$work_directory_comment")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_merge_adjacent_clips")
                change_loacal_variable_menu "MERGE_ADJACENT_CLIPS" "$CONFIG_FILES/$streamer.conf" "$(build_comment "$merge_adjacent_clips_comment")"
                ;;
            "$l_delete_data_clips")
                echo "test" >&2
                delete_data_for_streamer "$streamer"
                ;;
            *)
                ret="$TRUE"
                ;;
        esac
    fi
    if [[ "$ret" == "$TRUE" ]]; then
        return
    fi
    settings_menu "$streamer"
}

############################################
# МЕНЮ СТРИМЕРА
############################################

streamer_menu() {
    CURRENT_STREAMER_NICK=$(get_current)
    [[ "$CURRENT_STREAMER_NICK" == "" || "$CURRENT_STREAMER_NICK" == "$NONE_STREAMER" ]] && CURRENT_STREAMER_NICK="$NONE_STREAMER"

    if is_running "$CURRENT_STREAMER_NICK"; then
        TOGGLE="⏹ $ONLINE_INDICATOR Stop buffer"
    else
        TOGGLE="▶ $OFFLINE_INDICATOR Start buffer"
    fi

    ACTIVE_STREAMER_EMOJI="📋"
    CLIP="✂️ Clip"
    FULL_CLIP="✂️ Full Clip"
    REMOVE_STREAMER="➖ Remove streamer"
    SETTINGS="$SETTINGS_EMOJI Settings"
    RELOAD="🔄 Reload"
    EXIT="🚪 Exit"
    
    if [[ "$ENABLE_ONLINE_CHECK" == "$TRUE" ]]; then
        local online_emoji_indicator=" $(get_streaming_indicator "$CURRENT_STREAMER_NICK")"
    fi
    if [[ "$CURRENT_STREAMER_NICK" == "$NONE_STREAMER" ]]; then
        ACTIVE_STREAMER_STRING="$ACTIVE_STREAMER_EMOJI Select active streamer$online_emoji_indicator"
        MENU=$(cat <<EOF
$ACTIVE_STREAMER_STRING
$SETTINGS
$RELOAD
$EXIT
EOF
    )
    else
        ACTIVE_STREAMER_STRING="$ACTIVE_STREAMER_EMOJI Active streamer => [$CURRENT_STREAMER_NICK]$online_emoji_indicator"
        MENU=$(cat <<EOF
$ACTIVE_STREAMER_STRING
$TOGGLE
$CLIP
$FULL_CLIP
$REMOVE_STREAMER
$SETTINGS
$RELOAD
$EXIT
EOF
    )
    fi

    if [[ ! "$CURRENT_STREAMER_NICK" == "$NONE_STREAMER" && ! -f "$CONFIG_FILES/$CURRENT_STREAMER_NICK.conf" ]]; then
        init_local_config "$CURRENT_STREAMER_NICK"
    fi

    CHOICE="$(grap_menu "$MENU" "Photographer")"

    case "$CHOICE" in
        "$ACTIVE_STREAMER_STRING")
            SEL=$(streamer_list)
            [[ -z "$SEL" ]] && SEL="$CURRENT_STREAMER_NICK"
            set_local_variable "$CONFIG_FILE" "CURRENT_STREAMER" "$SEL"
            ;;
        "$TOGGLE")
            toggle_buffer "$CURRENT_STREAMER_NICK"
            ;;
        "$CLIP")
            {
				MODE="--clip"
				sleep 0.1 && clip &
                # "$SCRIPT" --clip &
            } 2> >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat >&2 ) > >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat)
            ;;
        "$FULL_CLIP")
            {
				MODE="--full-clip"
				sleep 0.1 && clip &
                # "$SCRIPT" --full-clip &
            } 2> >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat >&2 ) > >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat)
            ;;
        "$REMOVE_STREAMER")
            kill_streamer_buffer "$CURRENT_STREAMER_NICK"
            sed -i "/^$CURRENT_STREAMER_NICK$/d" "$STREAMERS_FILE"
            set_local_variable "$CONFIG_FILE" "CURRENT_STREAMER" "$NONE_STREAMER"
            ;;
        "$SETTINGS")
            settings_menu "$CURRENT_STREAMER_NICK"
            ;;
        "$EXIT")
            exit 0
            ;;
        "$RELOAD")
            ;;
        *)
            exit 0
            ;;
    esac
    streamer_menu
}


streamer_menu
