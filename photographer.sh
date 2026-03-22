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
CONFIG_PATH="$HOME/.config/photographer"
CLIPS_DATA_DIR="data"
MADE_CLIPS_DIR="made_clips"
STREAMERS_FILE="$CONFIG_PATH/streamers"
CONFIG_FILE="$CONFIG_PATH/config"
CONFIG_FILES="$CONFIG_PATH/streamers_configs"
TWITCH_LINK="https://twitch.tv/"
STREAMER_CONFIG_EXTENSION=".conf"

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
STREAM_EMOJI="🎥"
PLUS_EMOJI="➕"
SETTINGS_EMOJI="⚙️"
POINTER_BACK_EMOJI="⬅️"
COMMENT_EMOJI="💬"
STOP_BUFFER_EMOJI="⏹"
START_BUFFER_EMOJI="▶"
CLIP_EMOJI="✂️"
REMOVE_EMOJI="➖"
RELOAD_EMOJI="🔄"
EXIT_EMOJI="🚪"
ACTIVE_STREAMER_EMOJI="📋"
LANG_EMOJI="🌐"
LOCKED_EMOJI="🔒"

################################
# Lang list 
################################

UTFCODE=".UTF-8"
	
ENGLISH="English"
RUSSIAN="Russian"
UKRAINIAN="Ukrainian"
SPANISH="Spanish"
FRENCH="French"
GERMAN="German"
CHINESE_SIMPLIFIED="Chinese (simplified)"

SELF_ENGLISH="English"
SELF_RUSSIAN="Русский"
SELF_UKRAINIAN="Українська"
SELF_SPANISH="Español"
SELF_FRENCH="Français"
SELF_GERMAN="Deutsch"
SELF_CHINESE_SIMPLIFIED="中文"
SELF_ESPERANTO="Esperanto"

ENGLISH_CODE="en_US$UTFCODE"
RUSSIAN_CODE="ru_RU$UTFCODE"
UKRAINIAN_CODE="uk_UA$UTFCODE"
SPANISH_CODE="es_ES$UTFCODE"
FRENCH_CODE="fr_FR$UTFCODE"
GERMAN_CODE="de_DE$UTFCODE"
CHINESE_SIMPLIFIED_CODE="zh_CN$UTFCODE"
ESPERANTO_CODE="eo_EO$UTFCODE"

################################
# English
################################

local_english() {
	DURATION_FORWARD_COMMENT="When using full-clip, the script waits for the specified number of new segments.\nWhen using clip, this value is added to duration_back and saves the specified number of already created segments.\nThe value must be an integer."
DURATION_BACK_COMMENT="Specifies how many segments back in time will be used to create the clip.\nThe value must be an integer."

local BUFFER_SIZE_COMMENT="Buffer size in segments.\n%s\nThe value must be an integer."
local SEGMENT_TIME_COMMENT="Segment duration in seconds.\n%s\nThe value must be an integer."
local WORK_DIRECTORY_COMMENT="Directory where program data will be stored\n(stream fragments, clip data, and final clips).\n%s\nThe value must be an integer."

local GLOBAL_BUFFER_RESTART_WARNING="!WHEN YOU CHANGE THIS VARIABLE, ALL STREAM BUFFERS WILL BE RESTARTED!"
BUFFER_SIZE_GLOBAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_GLOBAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_GLOBAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"

local LOCAL_BUFFER_RESTART_WARNING="!WHEN YOU CHANGE THIS VARIABLE, THE BUFFER FOR %s WILL BE RESTARTED!"
BUFFER_SIZE_LOCAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_LOCAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_LOCAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"

MERGE_ADJACENT_CLIPS_COMMENT="Zero (digit) -- Disabled\nOne (digit) -- Enabled\nIf enabled, clips created around the same time will be merged.\nIf enabled, clip data preservation is automatically enabled."
SAVE_CLIP_DATA_COMMENT="Zero (digit) -- Disabled\nOne (digit) -- Enabled\nIf enabled, segments used to create clips will be preserved.\nOtherwise, temporary data will be removed after the clip is created.\nIf merging adjacent clips is enabled, this option is always considered enabled."

CANCEL="Cancel"
CONFIRM_DELETE_DATA="YES, DELETE ALL DATA"
LOCAL_CONFIRM_DELETE_DATA="Yes, delete data for %s"
GLOBAL_DELETE_DATA_COMMENT="Do you confirm deletion of the original data of ALL clips?"
LOCAL_DELETE_DATA_COMMENT="Do you confirm deletion of the original data of all clips for %s?"

STOP_BUFFER_BUTTON="Stop buffer"
START_BUFFER_BUTTON="Start buffer"
CLIP_BUTTON="Clip"
FULL_CLIP_BUTTON="Full clip"
REMOVE_STREAMER_BUTTON="Remove streamer"
SETTINGS_BUTTON="Settings"
RELOAD_BUTTON="Reload"
EXIT_BUTTON="Exit"
ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Select active streamer"
ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Active streamer => [%s]"

GLOBAL_SETTINGS_SUBMENU_TITLE="%s Global settings"
GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Forward duration = %s segments (%s sec)"
GLOBAL_DURATION_BACK_SETTINGS_STRING="Backward duration = %s segments (%s sec)"
GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Buffer size = %s"
GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segment duration = %s"
GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Working directory = %s"
GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Merge adjacent clips = %s"
GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sPreserve clip segment data = %s%s"
GLOBAL_DELETE_DATA_SETTINGS_STRING="Delete ALL clip data"
GLOBAL_SETTINGS_COMMENT=""

LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="%s Streamer (%s) settings"
LOCAL_DURATION_BACK_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_BACK_SETTINGS_STRING"
LOCAL_DURATION_FORWARD_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_FORWARD_SETTINGS_STRING"
LOCAL_BUFFER_SIZE_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_BUFFER_SIZE_SETTINGS_STRING"
LOCAL_SEGMENT_TIME_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SEGMENT_TIME_SETTINGS_STRING"
LOCAL_WORK_DIRECTORY_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_WORK_DIRECTORY_SETTINGS_STRING"
LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_MERGE_CLIPS_SETTINGS_STRING"
LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING"
LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Delete all clip data for %s"
LOCAL_SETTINGS_COMMENT="Local variables have higher priority\nand will override global ones if they are not empty"

BACK_SETTINGS_STRING="%s Back"

CLIP_CREATING_CLIP="Creating clip..."
CLIP_LAST_SEGMENT_FILE="Last segment: %s"
CLIP_SEGMENTS_NOT_BEEN_CREATED="Segments have not been created yet"
CLIP_WAIT_FOR_DATA_CLIP="Waiting %s seconds to collect data for the clip"
CLIP_SEGMENT_SAVED_STRING="Segments saved at: %s"
CLIP_CENCELED="Clip creation canceled"
CLIP_REMOVE_CLIP_DATA_STRING="Removing clip data: %s"
CLIP_FINISHED_CLIP_LOCATION="Final clip is located at: %s"

RESTART_ALL_BUFFERS="All buffers have been restarted (%s)"

DELETE_DATA_FOR_STREAMER="Removing clip data for %s"

CHANGE_VARIABLE_TITLE="Change variable:"
CHANGE_VARIABLE_BACK="%s Back"
CHANGE_VARIABLE_INVITATION="%s Enter a new value for the variable here %s %s"

STREAMER_LIST_ADD_STREAMER="%s Add streamer %s"
STREAMER_LIST_TITLE="%s Select active streamer %s"

ADD_STREAMER_MENU_INVITATION="%s Enter streamer name here (case-insensitive) %s"
ADD_STREAMER_MENU_TITLE="Streamer name:"

CHECK_GLOBAL_CONFIG_ERROR="The global configuration file is invalid. It will be reset to default settings."
CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR The MERGE_ADJACENT_CLIPS variable can only be 1 or 0."
CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR The SAVE_CLIP_DATA variable can only be 1 or 0."

LANG_SETTINGS_STRING="Language"

HELP="
Usage:
  script [OPTIONS]

Interface options:
  --ui-config PATH          Path to UI configuration file
                            (wofi, rofi, fzf).
  --use-wofi                Use wofi as the user interface.
  --use-rofi                Use rofi as the user interface.
  --use-fzf                 Use fzf as the user interface.

Buffer control:
  --start-buffer            Start stream buffering process
                            (download stream into buffer).

Streamer options:
  --streamer NAME           Specify streamer nickname.

Clip creation:
  --clip                    Create a clip from buffered segments.
  --full-clip               Wait specified time and create clip.

Clip timing options:
  --duration-back N         Number of segments before trigger point.
  --duration-forward N      Number of segments after trigger point.
  --segment-time N          Duration of each segment in seconds.

Buffer options:
  --buffer-size N           Buffer size in segments.

Clip data options:
  --save-clip-data          Preserve segment files used
                            to create clips.

Working directory:
  --directory PATH          Directory for stream fragments and clips.

Title options:
  --title TEXT              Title for the final clip
                            (a suffix will be added).

Language:
  --lang CODE               Interface language
                            (available: en, ru, es, uk, fr, de, zh, eo).
                            (valid formats: en, en_US, en_US\$UTFCODE)

Behavior options:
  --silence-log             Disable log output.
  --flip-pointers           Flip decorative input field pointers.
  --invert-comments         Reverse comment order in UI.
  --eneble-online-check     Enable streamer online check.

Argument parsing:
  --                        Pass remaining arguments to GUI.
                            If used again later, arguments will be
                            processed again by the main script.

Help:
  -h, --help                Show this help message and exit.
"
}

################################
# Russian
################################

local_russian() {
	DURATION_FORWARD_COMMENT="При создании full-clip скрипт ожидает указанное количество новых сегментов.\nПри использовании clip это значение складывается со значением duration_back и сохраняет указанное количество сегментов, которые уже были созданы.\nЗначение должно быть целым числом."
	DURATION_BACK_COMMENT="Указывает, сколько сегментов назад во времени будет взято для создания клипа.\nЗначение должно быть целым числом."

	local BUFFER_SIZE_COMMENT="Размер буфера в сегментах.\n%s\nЗначение должно быть целым числом."
	local SEGMENT_TIME_COMMENT="Время сегмента в секундах.\n%s\nЗначение должно быть целым числом."
	local WORK_DIRECTORY_COMMENT="Каталог, в котором будут размещаться данные программы\n(фрагменты стрима, данные клипов и итоговые клипы).\n%s\nЗначение должно быть целым числом."

	local GLOBAL_BUFFER_RESTART_WARNING="!КОГДА ВЫ ИЗМЕНЯЕТЕ ЭТУ ПЕРЕМЕННУЮ, ВСЕ БУФЕРЫ СТРИМОВ БУДУТ ПЕРЕЗАПУЩЕНЫ!"
	BUFFER_SIZE_GLOBAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
	SEGMENT_TIME_GLOBAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
	WORK_DIRECTORY_GLOBAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"

	local LOCAL_BUFFER_RESTART_WARNING="!КОГДА ВЫ ИЗМЕНЯЕТЕ ЭТУ ПЕРЕМЕННУЮ, БУФЕР СТРИМА ОТ %s БУДУТ ПЕРЕЗАПУЩЕН!"
	BUFFER_SIZE_LOCAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
	SEGMENT_TIME_LOCAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
	WORK_DIRECTORY_LOCAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"

	MERGE_ADJACENT_CLIPS_COMMENT="Ноль(цыфрой) -- Выключено\nОдин(цыфрой) -- Включено\nЕсли включено, то сопоставимые по времени создания клипы совмещаются.\nЕсли включено, то автоматически включается функция сохранения данных клипа."
	SAVE_CLIP_DATA_COMMENT="Ноль(цыфрой) -- Выключено\nОдин(цыфрой) -- Включено\nЕсли включено, сегменты, использованные для создания клипов, будут сохранены.\nИначе временные данные будут удалены после создания клипа.\nЕсли объединение соседних клипов включено, эта опция всегда считается включённой."


	CANCEL="Отмена"
	CONFIRM_DELETE_DATA="ДА, УДАЛИТЬ ВСЕ ДАННЫЕ"
	LOCAL_CONFIRM_DELETE_DATA="Да, удалить данные для %s"
	GLOBAL_DELETE_DATA_COMMENT="Вы подтверждаете удаление исходных данных ВСЕХ клипов?"
	LOCAL_DELETE_DATA_COMMENT="Вы подтверждаете удаление исходных данных всех клипов для %s?"

	STOP_BUFFER_BUTTON="Остановить буфер"
	START_BUFFER_BUTTON="Запустить буфер"
	CLIP_BUTTON="Клип"
	FULL_CLIP_BUTTON="Полный клип"
	REMOVE_STREAMER_BUTTON="Удалить стримера"
	SETTINGS_BUTTON="Настройки"
	RELOAD_BUTTON="Обновить"
	EXIT_BUTTON="Выход"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Выбрать активного стримера"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Активный стример => [%s]"


	GLOBAL_SETTINGS_SUBMENU_TITLE="%s Глобальные настройки"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Длительность вперёд = %s сегментов (%s сек)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Длительность назад = %s сегментов (%s сек)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Размер буфера = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Длительность сегмента = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Рабочий каталог = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Объединять соседние клипы = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sСохранять данные сегментов клипа = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Удалить ВСЕ данные клипов"
	GLOBAL_SETTINGS_COMMENT=""

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="%s Настройки стримера (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_BACK_SETTINGS_STRING"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_FORWARD_SETTINGS_STRING"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_BUFFER_SIZE_SETTINGS_STRING"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SEGMENT_TIME_SETTINGS_STRING"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_WORK_DIRECTORY_SETTINGS_STRING"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_MERGE_CLIPS_SETTINGS_STRING"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Удалить все данные клипов для %s"
	LOCAL_SETTINGS_COMMENT="Локальные переменные имеют более высокий приоритет и\nбудут использоваться вместо глобальных, если они не пустые"

	BACK_SETTINGS_STRING="%s Назад"


	CLIP_CREATING_CLIP="Создание клипа..."
	CLIP_LAST_SEGMENT_FILE="Последний сегмент: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Сегменты ещё не созданы"
	CLIP_WAIT_FOR_DATA_CLIP="Ожидание %s секунд, чтобы собрать данные для клипа"
	CLIP_SEGMENT_SAVED_STRING="Сегменты сохранены по пути: %s"
	CLIP_CENCELED="Создание клипа отменено"
	CLIP_REMOVE_CLIP_DATA_STRING="Удаление данных клипа: %s"
	CLIP_FINISHED_CLIP_LOCATION="Готовый клип находится по пути: %s"

	RESTART_ALL_BUFFERS="Все буферы перезапущены все буферы (%s)"

	DELETE_DATA_FOR_STREAMER="Удаление данных клипов для %s"

	CHANGE_VARIABLE_TITLE="Измените переменную:"
	CHANGE_VARIABLE_BACK="%s Назад"
	CHANGE_VARIABLE_INVITATION="%s Введите новое значение для переменной здесь %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Добавить стримера %s"
	STREAMER_LIST_TITLE="%s Выбирите актуального стримера %s"

	ADD_STREAMER_MENU_INVITATION="%s Введите ник стримера здесь (регистр не важен) %s"
	ADD_STREAMER_MENU_TITLE="Ник стримера:"

	CHECK_GLOBAL_CONFIG_ERROR="Файл глобальной конфигурации недействителен. Этот файл будет сброшен к настройкам по умолчанию."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Переменная MERGE_ADJACENT_CLIPS может быть только 1 или 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR Переменная SAVE_CLIP_DATA может быть только 1 или 0."

	LANG_SETTINGS_STRING="Язык"

	HELP="
Использование:
  script [OPTIONS]

Параметры интерфейса:
  --ui-config PATH          Путь к файлу конфигурации интерфейса 
							(wofi, rofi, fzf).
  --use-wofi                Использовать wofi как пользовательский интерфейс.
  --use-rofi                Использовать rofi как пользовательский интерфейс.
  --use-fzf                 Использовать fzf как пользовательский интерфейс.

Управление буфером:
  --start-buffer            Запустить процесс буферизации стрима
                            (скачивание стрима в буфер).

Параметры стримера:
  --streamer NAME           Указать ник стримера для работы.

Создание клипа:
  --clip                    Создать клип из буферизированных сегментов.
  --full-clip               Подождать указанное время и создать клип
                            перед созданием клипа.

Параметры времени клипа:
  --duration-back N         Количество сегментов перед точкой триггера.
  --duration-forward N      Количество сегментов после точки триггера.
  --segment-time N          Длительность каждого сегмента в секундах.

Параметры буфера:
  --buffer-size N           Размер буфера в сегментах.

Параметры данных клипа:
  --save-clip-data          Сохранять файлы сегментов, использованные
                            для создания клипов.

Рабочий каталог:
  --directory PATH          Каталог для фрагментов стрима и итоговых клипов.

Параметры заголовка:
  --title TEXT              Название итогового клипа 
							(к нему будет добавлен посфикс).

Язык:
  --lang CODE               Язык интерфейса 
							(доступны: en, ru, es, uk, es, fr, de, zh, eo).
							(допустимые формы записи: en, en_US, en_US$UTFCODE)

Параметры поведения:
  --silence-log             Отключить вывод логов.
  --flip-pointers           Перевернуть декоративные указатели,
                            обозначающие поле ввода в UI.
  --invert-comments         Изменить порядок строк комментариев в UI.
  --eneble-online-check     Включить проверку онлайна стримера.

Разбор аргументов:
  --                        Передать оставшиеся аргументы в GUI.
                            Если использовать снова позже, аргументы будут
                            снова обработаны основным скриптом.

Справка:
  -h, --help                Показать это сообщение справки и выйти.
	"
}

################################
# French
################################

local_french() {
	DURATION_FORWARD_COMMENT="Lors de l'utilisation de full-clip, le script attend le nombre spécifié de nouveaux segments.\nLors de l'utilisation de clip, cette valeur est ajoutée à duration_back et enregistre le nombre spécifié de segments déjà créés.\nLa valeur doit être un entier."
DURATION_BACK_COMMENT="Indique combien de segments en arrière dans le temps seront utilisés pour créer le clip.\nLa valeur doit être un entier."

local BUFFER_SIZE_COMMENT="Taille du tampon en segments.\n%s\nLa valeur doit être un entier."
local SEGMENT_TIME_COMMENT="Durée d’un segment en secondes.\n%s\nLa valeur doit être un entier."
local WORK_DIRECTORY_COMMENT="Répertoire où seront stockées les données du programme\n(fragments du stream, données des clips et clips finaux).\n%s\nLa valeur doit être un entier."

local GLOBAL_BUFFER_RESTART_WARNING="!LORSQUE VOUS MODIFIEZ CETTE VARIABLE, TOUS LES TAMPONS DE STREAM SERONT REDÉMARRÉS !"
BUFFER_SIZE_GLOBAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_GLOBAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_GLOBAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"

local LOCAL_BUFFER_RESTART_WARNING="!LORSQUE VOUS MODIFIEZ CETTE VARIABLE, LE TAMPON DU STREAM DE %s SERA REDÉMARRÉ !"
BUFFER_SIZE_LOCAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_LOCAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_LOCAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"

MERGE_ADJACENT_CLIPS_COMMENT="Zéro (chiffre) -- Désactivé\nUn (chiffre) -- Activé\nSi activé, les clips créés à des moments proches seront fusionnés.\nSi activé, la conservation des données des clips est automatiquement activée."
SAVE_CLIP_DATA_COMMENT="Zéro (chiffre) -- Désactivé\nUn (chiffre) -- Activé\nSi activé, les segments utilisés pour créer les clips seront conservés.\nSinon, les données temporaires seront supprimées après la création du clip.\nSi la fusion des clips adjacents est activée, cette option est toujours considérée comme activée."

CANCEL="Annuler"
CONFIRM_DELETE_DATA="OUI, SUPPRIMER TOUTES LES DONNÉES"
LOCAL_CONFIRM_DELETE_DATA="Oui, supprimer les données pour %s"
GLOBAL_DELETE_DATA_COMMENT="Confirmez-vous la suppression des données d'origine de TOUS les clips ?"
LOCAL_DELETE_DATA_COMMENT="Confirmez-vous la suppression des données d'origine de tous les clips pour %s ?"

STOP_BUFFER_BUTTON="Arrêter le tampon"
START_BUFFER_BUTTON="Démarrer le tampon"
CLIP_BUTTON="Clip"
FULL_CLIP_BUTTON="Clip complet"
REMOVE_STREAMER_BUTTON="Supprimer le streamer"
SETTINGS_BUTTON="Paramètres"
RELOAD_BUTTON="Recharger"
EXIT_BUTTON="Quitter"
ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Sélectionner le streamer actif"
ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer actif => [%s]"

GLOBAL_SETTINGS_SUBMENU_TITLE="%s Paramètres globaux"
GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Durée avant = %s segments (%s s)"
GLOBAL_DURATION_BACK_SETTINGS_STRING="Durée arrière = %s segments (%s s)"
GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Taille du tampon = %s"
GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Durée du segment = %s"
GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Répertoire de travail = %s"
GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Fusionner les clips adjacents = %s"
GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConserver les données des segments du clip = %s%s"
GLOBAL_DELETE_DATA_SETTINGS_STRING="Supprimer TOUTES les données des clips"
GLOBAL_SETTINGS_COMMENT=""

LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="%s Paramètres du streamer (%s)"
LOCAL_DURATION_BACK_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_BACK_SETTINGS_STRING"
LOCAL_DURATION_FORWARD_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_FORWARD_SETTINGS_STRING"
LOCAL_BUFFER_SIZE_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_BUFFER_SIZE_SETTINGS_STRING"
LOCAL_SEGMENT_TIME_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SEGMENT_TIME_SETTINGS_STRING"
LOCAL_WORK_DIRECTORY_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_WORK_DIRECTORY_SETTINGS_STRING"
LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_MERGE_CLIPS_SETTINGS_STRING"
LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING"
LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Supprimer toutes les données des clips pour %s"
LOCAL_SETTINGS_COMMENT="Les variables locales ont une priorité plus élevée\net remplaceront les variables globales si elles ne sont pas vides"

BACK_SETTINGS_STRING="%s Retour"

CLIP_CREATING_CLIP="Création du clip..."
CLIP_LAST_SEGMENT_FILE="Dernier segment : %s"
CLIP_SEGMENTS_NOT_BEEN_CREATED="Les segments n'ont pas encore été créés"
CLIP_WAIT_FOR_DATA_CLIP="Attente de %s secondes pour collecter les données du clip"
CLIP_SEGMENT_SAVED_STRING="Segments enregistrés à l'emplacement : %s"
CLIP_CENCELED="Création du clip annulée"
CLIP_REMOVE_CLIP_DATA_STRING="Suppression des données du clip : %s"
CLIP_FINISHED_CLIP_LOCATION="Le clip final se trouve à : %s"

RESTART_ALL_BUFFERS="Tous les tampons ont été redémarrés (%s)"

DELETE_DATA_FOR_STREAMER="Suppression des données des clips pour %s"

CHANGE_VARIABLE_TITLE="Modifier la variable :"
CHANGE_VARIABLE_BACK="%s Retour"
CHANGE_VARIABLE_INVITATION="%s Entrez une nouvelle valeur pour la variable ici %s %s"

STREAMER_LIST_ADD_STREAMER="%s Ajouter un streamer %s"
STREAMER_LIST_TITLE="%s Sélectionner le streamer actif %s"

ADD_STREAMER_MENU_INVITATION="%s Entrez le nom du streamer ici (insensible à la casse) %s"
ADD_STREAMER_MENU_TITLE="Nom du streamer :"

CHECK_GLOBAL_CONFIG_ERROR="Le fichier de configuration global est invalide. Il sera réinitialisé aux valeurs par défaut."
CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS ne peut être que 1 ou 0."
CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR La variable SAVE_CLIP_DATA ne peut être que 1 ou 0."

LANG_SETTINGS_STRING="Langue"

HELP="
Utilisation :
  script [OPTIONS]

Options d’interface :
  --ui-config PATH          Chemin vers le fichier de configuration de l’interface
                            (wofi, rofi, fzf).
  --use-wofi                Utiliser wofi comme interface utilisateur.
  --use-rofi                Utiliser rofi comme interface utilisateur.
  --use-fzf                 Utiliser fzf comme interface utilisateur.

Gestion du tampon :
  --start-buffer            Démarrer le processus de mise en tampon du stream
                            (téléchargement du stream dans le tampon).

Options du streamer :
  --streamer NAME           Spécifier le nom du streamer.

Création de clip :
  --clip                    Créer un clip à partir des segments en mémoire.
  --full-clip               Attendre le temps spécifié puis créer le clip.

Options de durée du clip :
  --duration-back N         Nombre de segments avant le point de déclenchement.
  --duration-forward N      Nombre de segments après le point de déclenchement.
  --segment-time N          Durée de chaque segment en secondes.

Options du tampon :
  --buffer-size N           Taille du tampon en segments.

Options des données de clip :
  --save-clip-data          Conserver les segments utilisés
                            pour créer les clips.

Répertoire de travail :
  --directory PATH          Répertoire pour les fragments et les clips.

Options du titre :
  --title TEXT              Nom du clip final
                            (un suffixe sera ajouté).

Langue :
  --lang CODE               Langue de l’interface
                            (disponibles : en, ru, es, uk, fr, de, zh, eo).
                            (formats valides : en, en_US, en_US\$UTFCODE)

Options de comportement :
  --silence-log             Désactiver les logs.
  --flip-pointers           Inverser les indicateurs décoratifs du champ de saisie.
  --invert-comments         Inverser l’ordre des commentaires dans l’UI.
  --eneble-online-check     Activer la vérification en ligne du streamer.

Analyse des arguments :
  --                        Passer les arguments restants au GUI.
                            Si utilisé à nouveau plus tard, les arguments seront
                            à nouveau traités par le script principal.

Aide :
  -h, --help                Afficher cette aide et quitter.
"
}

################################
# Spanish
################################

local_spanish() {
	DURATION_FORWARD_COMMENT="Al usar full-clip, el script espera la cantidad especificada de nuevos segmentos.\nAl usar clip, este valor se suma a duration_back y guarda la cantidad especificada de segmentos ya creados.\nEl valor debe ser un número entero."
DURATION_BACK_COMMENT="Indica cuántos segmentos hacia atrás en el tiempo se usarán para crear el clip.\nEl valor debe ser un número entero."

local BUFFER_SIZE_COMMENT="Tamaño del búfer en segmentos.\n%s\nEl valor debe ser un número entero."
local SEGMENT_TIME_COMMENT="Duración del segmento en segundos.\n%s\nEl valor debe ser un número entero."
local WORK_DIRECTORY_COMMENT="Directorio donde se almacenarán los datos del programa\n(fragmentos del stream, datos de clips y clips finales).\n%s\nEl valor debe ser un número entero."

local GLOBAL_BUFFER_RESTART_WARNING="¡CUANDO CAMBIES ESTA VARIABLE, TODOS LOS BÚFERES DE STREAM SE REINICIARÁN!"
BUFFER_SIZE_GLOBAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_GLOBAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_GLOBAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"

local LOCAL_BUFFER_RESTART_WARNING="¡CUANDO CAMBIES ESTA VARIABLE, EL BÚFER DEL STREAM DE %s SE REINICIARÁ!"
BUFFER_SIZE_LOCAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_LOCAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_LOCAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"

MERGE_ADJACENT_CLIPS_COMMENT="Cero (dígito) -- Desactivado\nUno (dígito) -- Activado\nSi está activado, los clips creados en momentos cercanos se fusionarán.\nSi está activado, la conservación de datos del clip se habilita automáticamente."
SAVE_CLIP_DATA_COMMENT="Cero (dígito) -- Desactivado\nUno (dígito) -- Activado\nSi está activado, los segmentos usados para crear clips se conservarán.\nDe lo contrario, los datos temporales se eliminarán después de crear el clip.\nSi la fusión de clips adyacentes está activada, esta opción siempre se considera activada."

CANCEL="Cancelar"
CONFIRM_DELETE_DATA="SÍ, ELIMINAR TODOS LOS DATOS"
LOCAL_CONFIRM_DELETE_DATA="Sí, eliminar datos para %s"
GLOBAL_DELETE_DATA_COMMENT="¿Confirma que desea eliminar los datos originales de TODOS los clips?"
LOCAL_DELETE_DATA_COMMENT="¿Confirma que desea eliminar los datos originales de todos los clips para %s?"

STOP_BUFFER_BUTTON="Detener búfer"
START_BUFFER_BUTTON="Iniciar búfer"
CLIP_BUTTON="Clip"
FULL_CLIP_BUTTON="Clip completo"
REMOVE_STREAMER_BUTTON="Eliminar streamer"
SETTINGS_BUTTON="Configuración"
RELOAD_BUTTON="Recargar"
EXIT_BUTTON="Salir"
ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Seleccionar streamer activo"
ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer activo => [%s]"

GLOBAL_SETTINGS_SUBMENU_TITLE="%s Configuración global"
GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duración hacia adelante = %s segmentos (%s s)"
GLOBAL_DURATION_BACK_SETTINGS_STRING="Duración hacia atrás = %s segmentos (%s s)"
GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Tamaño del búfer = %s"
GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Duración del segmento = %s"
GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Directorio de trabajo = %s"
GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Fusionar clips adyacentes = %s"
GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConservar datos de segmentos del clip = %s%s"
GLOBAL_DELETE_DATA_SETTINGS_STRING="Eliminar TODOS los datos de clips"
GLOBAL_SETTINGS_COMMENT=""

LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="%s Configuración del streamer (%s)"
LOCAL_DURATION_BACK_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_BACK_SETTINGS_STRING"
LOCAL_DURATION_FORWARD_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_FORWARD_SETTINGS_STRING"
LOCAL_BUFFER_SIZE_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_BUFFER_SIZE_SETTINGS_STRING"
LOCAL_SEGMENT_TIME_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SEGMENT_TIME_SETTINGS_STRING"
LOCAL_WORK_DIRECTORY_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_WORK_DIRECTORY_SETTINGS_STRING"
LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_MERGE_CLIPS_SETTINGS_STRING"
LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING"
LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Eliminar todos los datos de clips para %s"
LOCAL_SETTINGS_COMMENT="Las variables locales tienen mayor prioridad\ny reemplazarán a las globales si no están vacías"

BACK_SETTINGS_STRING="%s Volver"

CLIP_CREATING_CLIP="Creando clip..."
CLIP_LAST_SEGMENT_FILE="Último segmento: %s"
CLIP_SEGMENTS_NOT_BEEN_CREATED="Los segmentos aún no han sido creados"
CLIP_WAIT_FOR_DATA_CLIP="Esperando %s segundos para recopilar datos del clip"
CLIP_SEGMENT_SAVED_STRING="Segmentos guardados en: %s"
CLIP_CENCELED="Creación de clip cancelada"
CLIP_REMOVE_CLIP_DATA_STRING="Eliminando datos del clip: %s"
CLIP_FINISHED_CLIP_LOCATION="El clip final se encuentra en: %s"

RESTART_ALL_BUFFERS="Todos los búferes han sido reiniciados (%s)"

DELETE_DATA_FOR_STREAMER="Eliminando datos de clips para %s"

CHANGE_VARIABLE_TITLE="Cambiar variable:"
CHANGE_VARIABLE_BACK="%s Volver"
CHANGE_VARIABLE_INVITATION="%s Introduce un nuevo valor para la variable aquí %s %s"

STREAMER_LIST_ADD_STREAMER="%s Añadir streamer %s"
STREAMER_LIST_TITLE="%s Seleccionar streamer activo %s"

ADD_STREAMER_MENU_INVITATION="%s Introduce el nombre del streamer aquí (sin distinguir mayúsculas) %s"
ADD_STREAMER_MENU_TITLE="Nombre del streamer:"

CHECK_GLOBAL_CONFIG_ERROR="El archivo de configuración global no es válido. Se restablecerá a los valores por defecto."
CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS solo puede ser 1 o 0."
CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR La variable SAVE_CLIP_DATA solo puede ser 1 o 0."

LANG_SETTINGS_STRING="Idioma"

HELP="
Uso:
  script [OPTIONS]

Opciones de interfaz:
  --ui-config PATH          Ruta al archivo de configuración de la interfaz
                            (wofi, rofi, fzf).
  --use-wofi                Usar wofi como interfaz.
  --use-rofi                Usar rofi como interfaz.
  --use-fzf                 Usar fzf como interfaz.

Control del búfer:
  --start-buffer            Iniciar el proceso de almacenamiento en búfer
                            (descargar el stream al búfer).

Opciones del streamer:
  --streamer NAME           Especificar el nombre del streamer.

Creación de clip:
  --clip                    Crear un clip desde los segmentos en búfer.
  --full-clip               Esperar el tiempo especificado y crear el clip.

Opciones de tiempo del clip:
  --duration-back N         Segmentos antes del punto de activación.
  --duration-forward N      Segmentos después del punto de activación.
  --segment-time N          Duración de cada segmento en segundos.

Opciones del búfer:
  --buffer-size N           Tamaño del búfer en segmentos.

Opciones de datos del clip:
  --save-clip-data          Conservar los segmentos usados
                            para crear clips.

Directorio de trabajo:
  --directory PATH          Directorio para fragmentos y clips.

Opciones de título:
  --title TEXT              Nombre del clip final
                            (se añadirá un sufijo).

Idioma:
  --lang CODE               Idioma de la interfaz
                            (disponibles: en, ru, es, uk, fr, de, zh, eo).
                            (formatos válidos: en, en_US, en_US\$UTFCODE)

Opciones de comportamiento:
  --silence-log             Desactivar logs.
  --flip-pointers           Invertir los indicadores decorativos del campo de entrada.
  --invert-comments         Invertir el orden de comentarios en la UI.
  --eneble-online-check     Activar comprobación de estado online del streamer.

Procesamiento de argumentos:
  --                        Pasar los argumentos restantes al GUI.
                            Si se usa de nuevo más tarde, los argumentos serán
                            procesados nuevamente por el script principal.

Ayuda:
  -h, --help                Mostrar esta ayuda y salir.
"
}

################################
# German
################################

local_german() {
	DURATION_FORWARD_COMMENT="Bei Verwendung von full-clip wartet das Skript auf die angegebene Anzahl neuer Segmente.\nBei Verwendung von clip wird dieser Wert zu duration_back addiert und speichert die angegebene Anzahl bereits erstellter Segmente.\nDer Wert muss eine ganze Zahl sein."
DURATION_BACK_COMMENT="Gibt an, wie viele Segmente rückwärts in der Zeit zur Erstellung des Clips verwendet werden.\nDer Wert muss eine ganze Zahl sein."

local BUFFER_SIZE_COMMENT="Puffergröße in Segmenten.\n%s\nDer Wert muss eine ganze Zahl sein."
local SEGMENT_TIME_COMMENT="Segmentdauer in Sekunden.\n%s\nDer Wert muss eine ganze Zahl sein."
local WORK_DIRECTORY_COMMENT="Verzeichnis, in dem Programmdaten gespeichert werden\n(Streamfragmente, Clip-Daten und fertige Clips).\n%s\nDer Wert muss eine ganze Zahl sein."

local GLOBAL_BUFFER_RESTART_WARNING="!WENN SIE DIESE VARIABLE ÄNDERN, WERDEN ALLE STREAM-PUFFER NEU GESTARTET!"
BUFFER_SIZE_GLOBAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_GLOBAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_GLOBAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$GLOBAL_BUFFER_RESTART_WARNING")"

local LOCAL_BUFFER_RESTART_WARNING="!WENN SIE DIESE VARIABLE ÄNDERN, WIRD DER PUFFER DES STREAMS VON %s NEU GESTARTET!"
BUFFER_SIZE_LOCAL_COMMENT="$(printf "$BUFFER_SIZE_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
SEGMENT_TIME_LOCAL_COMMENT="$(printf "$SEGMENT_TIME_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"
WORK_DIRECTORY_LOCAL_COMMENT="$(printf "$WORK_DIRECTORY_COMMENT" "$LOCAL_BUFFER_RESTART_WARNING")"

MERGE_ADJACENT_CLIPS_COMMENT="Null (Ziffer) -- Deaktiviert\nEins (Ziffer) -- Aktiviert\nWenn aktiviert, werden zeitlich nahe Clips zusammengeführt.\nWenn aktiviert, wird die Speicherung der Clip-Daten automatisch aktiviert."
SAVE_CLIP_DATA_COMMENT="Null (Ziffer) -- Deaktiviert\nEins (Ziffer) -- Aktiviert\nWenn aktiviert, werden die zur Clip-Erstellung verwendeten Segmente gespeichert.\nAndernfalls werden temporäre Daten nach der Erstellung des Clips gelöscht.\nWenn das Zusammenführen benachbarter Clips aktiviert ist, gilt diese Option immer als aktiviert."

CANCEL="Abbrechen"
CONFIRM_DELETE_DATA="JA, ALLE DATEN LÖSCHEN"
LOCAL_CONFIRM_DELETE_DATA="Ja, Daten für %s löschen"
GLOBAL_DELETE_DATA_COMMENT="Bestätigen Sie das Löschen der Originaldaten ALLER Clips?"
LOCAL_DELETE_DATA_COMMENT="Bestätigen Sie das Löschen der Originaldaten aller Clips für %s?"

STOP_BUFFER_BUTTON="Puffer stoppen"
START_BUFFER_BUTTON="Puffer starten"
CLIP_BUTTON="Clip"
FULL_CLIP_BUTTON="Vollständiger Clip"
REMOVE_STREAMER_BUTTON="Streamer entfernen"
SETTINGS_BUTTON="Einstellungen"
RELOAD_BUTTON="Neu laden"
EXIT_BUTTON="Beenden"
ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Aktiven Streamer auswählen"
ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Aktiver Streamer => [%s]"

GLOBAL_SETTINGS_SUBMENU_TITLE="%s Globale Einstellungen"
GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Dauer vorwärts = %s Segmente (%s s)"
GLOBAL_DURATION_BACK_SETTINGS_STRING="Dauer rückwärts = %s Segmente (%s s)"
GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Puffergröße = %s"
GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segmentdauer = %s"
GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Arbeitsverzeichnis = %s"
GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Benachbarte Clips zusammenführen = %s"
GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sClip-Segmentdaten speichern = %s%s"
GLOBAL_DELETE_DATA_SETTINGS_STRING="ALLE Clip-Daten löschen"
GLOBAL_SETTINGS_COMMENT=""

LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="%s Einstellungen für Streamer (%s)"
LOCAL_DURATION_BACK_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_BACK_SETTINGS_STRING"
LOCAL_DURATION_FORWARD_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_DURATION_FORWARD_SETTINGS_STRING"
LOCAL_BUFFER_SIZE_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_BUFFER_SIZE_SETTINGS_STRING"
LOCAL_SEGMENT_TIME_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SEGMENT_TIME_SETTINGS_STRING"
LOCAL_WORK_DIRECTORY_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_WORK_DIRECTORY_SETTINGS_STRING"
LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_MERGE_CLIPS_SETTINGS_STRING"
LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="$STREAM_EMOJI $GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING"
LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Alle Clip-Daten für %s löschen"
LOCAL_SETTINGS_COMMENT="Lokale Variablen haben eine höhere Priorität\nund überschreiben globale, wenn sie nicht leer sind"

BACK_SETTINGS_STRING="%s Zurück"

CLIP_CREATING_CLIP="Clip wird erstellt..."
CLIP_LAST_SEGMENT_FILE="Letztes Segment: %s"
CLIP_SEGMENTS_NOT_BEEN_CREATED="Segmente wurden noch nicht erstellt"
CLIP_WAIT_FOR_DATA_CLIP="Warte %s Sekunden, um Daten für den Clip zu sammeln"
CLIP_SEGMENT_SAVED_STRING="Segmente gespeichert unter: %s"
CLIP_CENCELED="Clip-Erstellung abgebrochen"
CLIP_REMOVE_CLIP_DATA_STRING="Clip-Daten werden gelöscht: %s"
CLIP_FINISHED_CLIP_LOCATION="Der fertige Clip befindet sich unter: %s"

RESTART_ALL_BUFFERS="Alle Puffer wurden neu gestartet (%s)"

DELETE_DATA_FOR_STREAMER="Clip-Daten für %s werden gelöscht"

CHANGE_VARIABLE_TITLE="Variable ändern:"
CHANGE_VARIABLE_BACK="%s Zurück"
CHANGE_VARIABLE_INVITATION="%s Neuen Wert für die Variable eingeben %s %s"

STREAMER_LIST_ADD_STREAMER="%s Streamer hinzufügen %s"
STREAMER_LIST_TITLE="%s Aktiven Streamer auswählen %s"

ADD_STREAMER_MENU_INVITATION="%s Streamer-Namen hier eingeben (Groß-/Kleinschreibung egal) %s"
ADD_STREAMER_MENU_TITLE="Streamer-Name:"

CHECK_GLOBAL_CONFIG_ERROR="Die globale Konfigurationsdatei ist ungültig. Sie wird auf die Standardeinstellungen zurückgesetzt."
CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Die Variable MERGE_ADJACENT_CLIPS kann nur 1 oder 0 sein."
CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR Die Variable SAVE_CLIP_DATA kann nur 1 oder 0 sein."

LANG_SETTINGS_STRING="Sprache"

HELP="
Verwendung:
  script [OPTIONS]

Interface-Optionen:
  --ui-config PATH          Pfad zur UI-Konfigurationsdatei
                            (wofi, rofi, fzf).
  --use-wofi                wofi als Benutzeroberfläche verwenden.
  --use-rofi                rofi als Benutzeroberfläche verwenden.
  --use-fzf                 fzf als Benutzeroberfläche verwenden.

Puffersteuerung:
  --start-buffer            Startet den Stream-Pufferprozess
                            (lädt den Stream in den Puffer).

Streamer-Optionen:
  --streamer NAME           Streamer-Namen angeben.

Clip-Erstellung:
  --clip                    Clip aus gepufferten Segmenten erstellen.
  --full-clip               Angegebene Zeit warten und Clip erstellen.

Clip-Zeitoptionen:
  --duration-back N         Segmente vor dem Auslösepunkt.
  --duration-forward N      Segmente nach dem Auslösepunkt.
  --segment-time N          Dauer jedes Segments in Sekunden.

Puffer-Optionen:
  --buffer-size N           Puffergröße in Segmenten.

Clip-Datenoptionen:
  --save-clip-data          Segmente zur Clip-Erstellung speichern.

Arbeitsverzeichnis:
  --directory PATH          Verzeichnis für Fragmente und Clips.

Titeloptionen:
  --title TEXT              Name des finalen Clips
                            (ein Suffix wird hinzugefügt).

Sprache:
  --lang CODE               Sprache der Oberfläche
                            (verfügbar: en, ru, es, uk, fr, de, zh, eo).
                            (gültige Formate: en, en_US, en_US\$UTFCODE)

Verhaltensoptionen:
  --silence-log             Log-Ausgabe deaktivieren.
  --flip-pointers           Dekorative Eingabezeiger umkehren.
  --invert-comments         Kommentarreihenfolge in der UI umkehren.
  --eneble-online-check     Online-Statusprüfung aktivieren.

Argumentverarbeitung:
  --                        Übergibt verbleibende Argumente an die GUI.
                            Bei erneuter Verwendung werden die Argumente
                            erneut vom Hauptskript verarbeitet.

Hilfe:
  -h, --help                Diese Hilfe anzeigen und beenden.
"
}

################################
# Chinese
################################

local_chinese() {
	return 0
}

################################
# Ukrainian
################################

local_ukrainian() {
	return 0
}

################################
# Esperanto
################################

local_esperanto() {
	return 0
}

################################
################################
################################

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
DEFAULT_LANG="$SELF_ENGLISH"
DEFAULT_SAVE_CLIP_DATA="$FALSE"

DURATION_FORWARD=5
DURATION_BACK=5
SEG_TIME=10
BUFFER_SIZE=$DEFAULT_BUFFER_SIZE
TITLE=""

################################
# Local
################################

# locale_self_name_to_code_converter() {
# 	local name="$1"
# 	case "$name" in 
# 		"$SELF_ENGLISH") echo "$ENGLISH_CODE" ;;
# 		"$SELF_RUSSIAN") echo "$RUSSIAN_CODE" ;;
# 		"$SELF_UKRAINIAN") echo "$UKRAINIAN_CODE" ;;
# 		"$SELF_SPANISH") echo "$SPANISH_CODE" ;;
# 		"$SELF_FRENCH") echo "$FRENCH_CODE" ;;
# 		"$SELF_GERMAN") echo "$GERMAN_CODE" ;;
# 		"$SELF_CHINESE_SIMPLIFIED") echo "$CHINESE_SIMPLIFIED_CODE" ;;
# 		*) ;;
# 	esac
# }

locale_code_to_self_name_converter() {
	local code="$1"
	case "$code" in 
		"$ENGLISH_CODE") echo "$SELF_ENGLISH" ;;
		"$RUSSIAN_CODE") echo "$SELF_RUSSIAN" ;;
		"$UKRAINIAN_CODE") echo "$SELF_UKRAINIAN" ;;
		"$SPANISH_CODE") echo "$SELF_SPANISH" ;;
		"$FRENCH_CODE") echo "$SELF_FRENCH" ;;
		"$GERMAN_CODE") echo "$SELF_GERMAN" ;;
		"$CHINESE_SIMPLIFIED_CODE") echo "$SELF_CHINESE_SIMPLIFIED" ;;
		"$ESPERANTO_CODE") echo "$SELF_ESPERANTO" ;;
		*) ;;
	esac
}

self_locale_list() {
	echo "$SELF_ENGLISH
$SELF_RUSSIAN
$SELF_UKRAINIAN
$SELF_SPANISH
$SELF_FRENCH
$SELF_GERMAN
$SELF_CHINESE_SIMPLIFIED
$SELF_ESPERANTO"
}

localize() {
	local lang="$1"
	case "$lang" in 
		"$SELF_ENGLISH") local_english ;;
		"$SELF_RUSSIAN") local_russian ;;
		"$SELF_SPANISH") local_spanish ;;
		"$SELF_FRENCH") local_french ;;
		"$SELF_GERMAN") local_german ;;
		"$SELF_CHINESE_SIMPLIFIED") local_chinese ;;
		"$SELF_UKRAINIAN") local_ukrainian ;;
		"$SELF_ESPERANTO") local_esperanto ;;
		*) ;;
	esac
}

set_locale() {
	set_variable "$CONFIG_FILE" "LOCALE_LANG" "$1"
	echo "$1"
	localize "$1"
}

################################
################################
################################

print_help() {
cat << EOF
$HELP
EOF
}


mkdir -p "$CONFIG_PATH" "$CONFIG_FILES"
touch "$STREAMERS_FILE"

init_global_config() {
	if [[ -e "$CONFIG_FILE" ]]; then
		mv "$CONFIG_FILE" "$CONFIG_FILE.bak"
	fi
    echo "$(cat << EOF
DURATION_FORWARD=$DEFAULT_DURATION_FORWARD
DURATION_BACK=$DEFAULT_DURATION_BACK
BUFFER_SIZE=$DEFAULT_BUFFER_SIZE
SEGMENT_TIME=$DEFAULT_SEGMENT_TIME
CURRENT_STREAMER=$NONE_STREAMER
WORK_DIRECTORY=$DEFAULT_WORK_DIRECTORY
MERGE_ADJACENT_CLIPS=$DEFAULT_MERGE_ADJACENT_CLIPS
SAVE_CLIP_DATA=$DEFAULT_SAVE_CLIP_DATA
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
SAVE_CLIP_DATA=
EOF
)" > "$CONFIG_FILES/$1.conf"
}

if [[ ! -f "$CONFIG_FILE" ]]; then
    init_global_config
fi

check_global_config() {
    source "$1"
    if [[ ! -f "$1" || -z "$BUFFER_SIZE" || -z "$DURATION_BACK" || -z "$DURATION_FORWARD" || -z "$SEGMENT_TIME" || -z "$CURRENT_STREAMER" || -z "$WORK_DIRECTORY" || -z "$MERGE_ADJACENT_CLIPS" || -z "$SAVE_CLIP_DATA" ]]; then
        init_global_config
        echo "$CHECK_GLOBAL_CONFIG_ERROR" >&2
	elif ! [[ "$SAVE_CLIP_DATA" == "1" || "$SAVE_CLIP_DATA" == "0" ]]; then
        init_global_config;
        echo "$CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA" >&2;
		# TODO сделать перевод этой переменной
	elif ! [[ "$MERGE_ADJACENT_CLIPS" == "1" || "$MERGE_ADJACENT_CLIPS" == "0" ]]; then
        init_global_config;
        echo "$CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS" >&2;
    fi
}

check_global_config "$CONFIG_FILE"
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
	local streamer="$1"
	if [[ -z "$streamer" ]]; then
		streamer="$CURRENT_STREAMER"
	fi
	local config="$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION"
	if [[ "$streamer" != "$NONE_STREAMER" ]]; then
		load_local_config "$config"
	fi
	sync_variable_with_config
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

set_variable() {
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
				NICK="$2"
				shift 2
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
				HELP_VAR="$TRUE"
				shift
                ;;
            --directory)
				set_work_directory "$2"
                shift 2
                ;;
            # --merge-adjacent-clips)
                # MERGE_ADJACENT_CLIPS="$TRUE"
				# shift
				# ;;
            --save-clip-data)
				SAVE_CLIP_DATA="$TRUE"
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
			--lang)
				L_LANG="$2"
				shift 2 
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

if [[ "$NICK" != "$NONE_STREAMER" ]]; then
	mkdir -p "$SEG/$NICK" "$CLIPS/$NICK" "$CLIPS/$NICK/$CLIPS_DATA_DIR" "$CLIPS/$NICK/$MADE_CLIPS_DIR"
fi


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

localize "$DEFAULT_LANG"
if [[ -z "$L_LANG" && -z "$LOCALE_LANG" ]]; then 
	lang="$(locale_code_to_self_name_converter "$LANG")"
elif ! [[ -z "$L_LANG" ]]; then
	lang="$(locale_code_to_self_name_converter "$L_LANG")"
elif ! [[ -z "$LOCALE_LANG" ]]; then
	lang="$LOCALE_LANG"
fi
localize "$lang"

if [[ "$HELP_VAR" == "$TRUE" ]]; then
	print_help
	exit 0
fi

############################################
# РЕЖИМ ЗАПИСИ БУФЕРА
############################################
start_buffer() {
	if [[ "$NICK" == "$NONE_STREAMER" || "$NICK" == " " || "$NICK" == "" ]]; then
		exit 0 
	fi
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
	local dis
	if [[ "$3" == "$TRUE" ]]; then
		dis="--disabled"
	fi
    input="$(echo -e "$1" | fzf $dis --prompt "$2: " --print-query $GUI_ARGS)"
	mapfile -t lines <<< "$input"

    local first="${lines[0]}"
    local second="${lines[1]}"
	grep -q "$first" <<EOF
$(echo -e "$1")
EOF
	if [[ $? -eq 0 ]]; then
        if [[ "$3" == "$TRUE" ]]; then
			if [[ -z "$first" ]]; then
				printf '%s\n' "$second"
			else
				printf '%s\n' "$first"
			fi
        else
            printf '%s\n' "$second"
        fi
    else
        printf '%s\n' "$first"
    fi
}

grap_menu() {
    case "$USING_UI" in
        "$WOFI")
            wofi_menu "$@"
            ;;
        "$ROFI")
            rofi_menu "$@"
            ;;
        "$FZF")
            fzf_menu "$@"
            ;;
    esac
}

input_name_menu() {
	back="back"
	first_string="$POINTER_EMOJI$(insert_zwsp_between_chars " Enter the name of the clip ")$POINTER_EMOJI"
	other_strings="$POINTER_BACK_EMOJI $(insert_zwsp_between_chars "$back")
$(build_comment "Entering the name does not slow down the script
(you can think about the name for as long as you like,
the clip was created when the script was activated)")"

	comment="$first_string
$other_strings"
	menu="$(echo -e "$comment")"
	name="$(grap_menu "$menu" "Enter the name of the clip" "$TRUE")"
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

confirmatoin() {
	local confirm="$1"
	local cancel="$2"
	local comment="$3"
	comment="$(build_comment "$comment")"
	local sel="$(grap_menu "$cancel\n$confirm\n$comment" "Confirmation")"
	if [[ "$sel" == "$confirm" ]]; then
		return 0
	else
		return 1
	fi
}


############################################
# УТИЛИТЫ
############################################




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
    streamlink -Q "$TWITCH_LINK$1" >/dev/null 2>&1
    return $?
}

get_streaming_indicator() {
    if is_streaming "$1"; then
        local online_indicator="$ONLINE_INDICATOR"
    else
        local online_indicator="$OFFLINE_INDICATOR"
    fi
    echo "$STREAM_EMOJI$online_indicator"
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
    local i c n

	perl -CS -pe 's/(.)/$1\x{200B}/g; s/%\x{200B}/%/g' <<< "$input"
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
    if [[ -n "$1" ]] && ! grep -q "$1" "$STREAMERS_FILE"; then
        if [[ -z "$(cat $STREAMERS_FILE)" ]]; then
            echo "$1" > "$STREAMERS_FILE"
        else
            echo "$1" >> "$STREAMERS_FILE"
        fi
    fi
}
add_streamer_menu() {
	local enter_string="$(printf "$(insert_zwsp_between_chars "$ADD_STREAMER_MENU_INVITATION")" "$POINTER_EMOJI" "$POINTER_EMOJI")"
	NEW="$(grap_menu "$enter_string" "$ADD_STREAMER_MENU_TITLE")"
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
$(printf "$STREAMER_LIST_ADD_STREAMER" "$PLUS_EMOJI" "$PLUS_EMOJI")
$menu
EOF
)"
	local sel="$(grap_menu "$full_menu" "$(printf "$STREAMER_LIST_TITLE" "$INVERT_POINTER_EMOJI" "$INVERT_POINTER_EMOJI")")"
    sel="$(echo "$sel" | sed 's/^[^ ]* //')"
    sel="${sel% *}"
    streamer_list_selector "$sel"
}

streamer_list_selector() {
	local add_stremer_string="$(echo "$STREAMER_LIST_ADD_STREAMER" | sed 's/^[^ ]* //')"
	add_stremer_string="${add_stremer_string% *}"
	echo "$add_stremer_string" >&2
    case "$1" in 
        "$add_stremer_string")
            add_streamer_menu
            streamer_list
            ;;
        *)
            echo "$1"
            ;;
    esac
}




set_locale_menu() {
	local self_lang="$(grap_menu "$(self_locale_list)" "$LOCLALE_MENU_SELECT_LOCALE_TITLE")"
	if [[ -z "$self_lang" ]]; then
		return
	fi
	set_locale "$self_lang"
}

change_variable_menu() {
	# load_all_config_for_streamer "$CURRENT_STREAMER"
    variable="$1"
    menu="$(cat <<EOF
$(printf "$CHANGE_VARIABLE_INVITATION" "$POINTER_EMOJI" "$variable" "$POINTER_EMOJI") 
$(printf "$CHANGE_VARIABLE_BACK" "$POINTER_BACK_EMOJI")
$3
EOF
)"
    if [[ "$4" == "_" ]]; then
        menu="_\n$menu"
    fi
    local var="$(grap_menu "$menu" "$CHANGE_VARIABLE_TITLE" "$TRUE")"
    $(grep -q "$var" <<EOF
$menu
EOF
) && [[ ! "$var" == "_" ]] && return 1
    [[ "$var" == "_" ]] && var=""

    set_variable "$2" "$variable" "$var"
	load_all_config_for_streamer "$CURRENT_STREAMER"
	sync_variable_with_config
}

change_local_variable_menu() {
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
    printf "$RESTART_ALL_BUFFERS" "$(get_all_running_streamers)" >&2

    while IFS= read -r l_streamer; do
        restart_buffer "$l_streamer"
    done < <( get_all_running_streamers )
}

delete_data_for_streamer() {
    local streamer="$1"
	load_all_config_for_streamer
	local path="$(realpath "$CLIPS/$streamer/$CLIPS_DATA_DIR")"
    printf "$DELETE_DATA_FOR_STREAMER" "$path" >&2

    rm -rf "$path"
}

delete_all_clip_data() {
	while read line; do
		delete_data_for_streamer "$line"
	done < <(cat "$STREAMERS_FILE")
}

# TODO доделать эту функцию, оня щас тотальная параша
merge_clip() {
    local new_start="$1"
    local new_end="$2"
    local new_segments_dir="$3"

    local meta="$CLIP_DIR/meta"

    if [[ -f "$meta" ]]; then
        source "$meta"

        if (( new_start <= end_segment )); then
            reuse_dir=1
        fi
    fi

    if [[ "$reuse_dir" != 1 ]]; then
        CLIP_DIR="clips/clip_$(date +%s)"
        mkdir -p "$CLIP_DIR/segments"
        start_segment="$new_start"
    fi

    # удалить старые сегменты, которые будут перекрыты
    for f in "$CLIP_DIR/segments/"*; do
        seg="${f##*_}"
        seg="${seg%.ts}"
        if (( seg >= new_start )); then
            rm "$f"
        fi
    done

    # добавить новые сегменты
    cp "$new_segments_dir"/*.ts "$CLIP_DIR/segments/"

    end_segment="$new_end"

    echo "start_segment=$start_segment" > "$meta"
    echo "end_segment=$end_segment" >> "$meta"

    rebuild_clip "$CLIP_DIR"
}

clip() {
	if [[ "$NICK" == "$NONE_STREAMER" || "$NICK" == " " || "$NICK" == "" ]]; then
		exit 0 
	fi
	TMP_NAME_FILE=$(mktemp)
	echo "$CLIP_CREATING_CLIP"
	if [[ -z "$TITLE" ]]; then
		(
			( input_name_menu; echo " $?" ) > "$TMP_NAME_FILE"
		) &
		NAME_ENTRY_MENU_PID=$!
	fi

	LATEST_FILE="$(ls -t "$SEG/$NICK"/seg_*.ts 2>/dev/null | tac | tail -n1)"
	printf "$CLIP_LAST_SEGMENT_FILE\n" "$LATEST_FILE"

	if [[ -z "$LATEST_FILE" && ! "$MODE" == "--full-clip" ]]; then
		echo "$CLIP_SEGMENTS_NOT_BEEN_CREATED"
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
			IDX="$(( (LATEST_NUM - i + BUFFER_SIZE) % BUFFER_SIZE))"
			printf -v PAD "%03d" "$IDX"
			FILE="$SEG/$NICK/seg_$PAD.ts"

			[[ -f "$FILE" ]] && cp "$FILE" "$clip_data_dir/"
		done
	fi
		
	if [[ "$MODE" == "--full-clip" ]]; then

		echo "$clipdir">&2

		printf "$CLIP_WAIT_FOR_DATA_CLIP\n" "$((FORWARD * SEG_TIME))"
		sleep $((FORWARD * SEG_TIME))


		NEW_LATEST=$(ls "$SEG/$NICK"/seg_*.ts | tac | tail -n1)
		NEW_NUM=$(basename "$NEW_LATEST" | grep -o '[0-9]\+')
		NEW_NUM=$((10#$NEW_NUM))

		for ((i=0; i<=FORWARD; i++)); do
			IDX=$(( (LATEST_NUM + i) % BUFFER_SIZE ))
			printf -v PAD "%03d" "$IDX"
			FILE="$SEG/$NICK/seg_$PAD.ts"

			[[ -f "$FILE" ]] && cp "$FILE" "$clip_data_dir/"
		done

		printf "$CLIP_SEGMENT_SAVED_STRING\n" "$clip_data_dir"
	fi


	if ! [[ -z "$NAME_ENTRY_MENU_PID" ]]; then
		wait "$NAME_ENTRY_MENU_PID"
		TITLE="$(cat "$TMP_NAME_FILE")"
		rm -f "$TMP_NAME_FILE"
		if [[ "${TITLE#* }" == "1" ]]; then
			printf "$CLIP_CENCELED\n"
			printf "$CLIP_REMOVE_CLIP_DATA_STRING\n" "$(reatpath "$clip_data_dir")"
			rm -rf "$clip_data_dir"
			exit 0
		fi
	fi

	TITLE="${TITLE% *}"
	TITLE="${TITLE%$'\n'}"
	local underlining
	if ! [[ -z "$TITLE" ]]; then
		underlining="_"
	fi

	OUTFILE="$CLIPS/$NICK/$MADE_CLIPS_DIR/$TITLE$underlining$clip_dir.mp4"
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
	
	if ! [[ "$MERGE_ADJACENT_CLIPS" == "$TRUE" || "$SAVE_CLIP_DATA" == "$TRUE" ]]; then
		printf "$CLIP_REMOVE_CLIP_DATA_STRING\n" "$(reatpath "$clip_data_dir")"
		rm -rf "$clip_data_dir"
	fi

	printf "$CLIP_FINISHED_CLIP_LOCATION\n" "$(reatpath "$OUTFILE")"
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
	local glogal_settings_submenu_title="$(printf "$GLOBAL_SETTINGS_SUBMENU_TITLE" "$SETTINGS_EMOJI")"
	local duration_forward="$(printf "$GLOBAL_DURATION_FORWARD_SETTINGS_STRING" "$DURATION_FORWARD" "$(($DURATION_FORWARD*$SEGMENT_TIME))")"
	local duration_back="$(printf "$GLOBAL_DURATION_BACK_SETTINGS_STRING" "$DURATION_BACK" "$(($DURATION_BACK*$SEGMENT_TIME))")"
	local buffer_size="$(printf "$GLOBAL_BUFFER_SIZE_SETTINGS_STRING" "$BUFFER_SIZE")"
	local segment_time="$(printf "$GLOBAL_SEGMENT_TIME_SETTINGS_STRING" "$SEGMENT_TIME")"
	local work_directory="$(printf "$GLOBAL_WORK_DIRECTORY_SETTINGS_STRING" "$WORK_DIRECTORY")"
	local merge_adjacent_clips="$(printf "$GLOBAL_MERGE_CLIPS_SETTINGS_STRING" "$MERGE_ADJACENT_CLIPS")"
	local g_save_clip_data_locked="$FALSE"
	if [[ "$MERGE_ADJACENT_CLIPS" == "$TRUE" ]]; then
		lock_emoji="$LOCKED_EMOJI" 
		g_save_clip_data_locked="$TRUE"
		SAVE_CLIP_DATA="$TRUE"
	fi
	local save_clip_data="$(printf "$GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING" "$lock_emoji" "$SAVE_CLIP_DATA" "$lock_emoji")"
    local delete_data_clips="$GLOBAL_DELETE_DATA_SETTINGS_STRING"
    
	local back="$(printf "$BACK_SETTINGS_STRING" "$POINTER_BACK_EMOJI")"
    local local_settings_comment="$(build_comment "$LOCAL_SETTINGS_COMMENT")"
	local global_lang="$LANG_EMOJI $LANG_SETTINGS_STRING"


    local global_seg_time
    printf -v global_seg_time "$SEGMENT_TIME"

    if [[ ! "$streamer" == "$NONE_STREAMER" ]]; then
        if [[ ! -f "$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION" && ! "$streamer" == "$NONE_STREAMER" ]]; then
            init_local_config "$streamer"
        fi
        source "$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION"
		local l_streamer_settings_submenu_title="$(printf "$LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING" $SETTINGS_EMOJI "$streamer")"
        local full_duration
        if [[ ! -z "$DURATION_BACK" ]]; then
            if [[ -z "$SEGMENT_TIME" ]]; then
                full_duration=$(("$DURATION_BACK"*"$global_seg_time"))
            else
                full_duration=$(("$DURATION_BACK"*"$SEGMENT_TIME"))
            fi
        fi
		local l_duration_back="$(printf "$LOCAL_DURATION_BACK_SETTINGS_STRING" "$DURATION_BACK" "$full_duration")"
        local full_duration
        if [[ ! -z "$DURATION_FORWARD" ]]; then
            if [[ -z "$SEGMENT_TIME" ]]; then
                full_duration=$(("$DURATION_FORWARD"*"$global_seg_time"))
            else
                full_duration=$(("$DURATION_FORWARD"*"$SEGMENT_TIME"))
            fi
        fi
		local l_duration_forward="$(printf "$LOCAL_DURATION_FORWARD_SETTINGS_STRING" "$DURATION_FORWARD" "$full_duration")"
        
		local l_buffer_size="$(printf "$LOCAL_BUFFER_SIZE_SETTINGS_STRING" "$BUFFER_SIZE")"
		local l_segment_time="$(printf "$LOCAL_SEGMENT_TIME_SETTINGS_STRING" "$SEGMENT_TIME")"
		local l_work_directory="$(printf "$LOCAL_WORK_DIRECTORY_SETTINGS_STRING" "$WORK_DIRECTORY")"
		local l_merge_adjacent_clips="$(printf "$LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING" "$MERGE_ADJACENT_CLIPS")"
		local lock_emoji
		local l_save_clip_data_locked="$FALSE"
		if [[ "$MERGE_ADJACENT_CLIPS" == "$TRUE" ]]; then
			lock_emoji="$LOCKED_EMOJI"
			l_save_clip_data_locked="$TRUE"
			SAVE_CLIP_DATA="$TRUE"
		fi
		local l_save_clip_data="$(printf "$LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING" "$lock_emoji" "$SAVE_CLIP_DATA" "$lock_emoji")"
		local l_delete_data_clips="$(printf "$LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING" "$streamer")"
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
$save_clip_data
$delete_data_clips
$global_lang
EOF
# TODO добавить сюда переменную merge_adjacent_clips
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
$l_save_clip_data
$l_delete_data_clips
EOF
# TODO добавить сюда переменную l_merge_adjacent_clips
)
    fi
    menu=$(cat <<EOF
$menu
$back
EOF
)
    if ! [[ "$streamer" == "$NONE_STREAMER" ]]; then
		menu=$(cat <<EOF
$menu
$LINE_STRING
$local_settings_comment
EOF
)
	fi
    
    local sel="$(grap_menu "$menu" "Settings")"
	local ret_global="0"
	local ret_local="0"


    case "$sel" in
        "$duration_forward")
            change_variable_menu "DURATION_FORWARD" "$CONFIG_FILE" "$(build_comment "$DURATION_FORWARD_COMMENT")"
            ;;
        "$duration_back")
            change_variable_menu "DURATION_BACK" "$CONFIG_FILE" "$(build_comment "$DURATION_BACK_COMMENT")"
            ;;
        "$buffer_size")
            change_variable_menu "BUFFER_SIZE" "$CONFIG_FILE" "$(build_comment "$BUFFER_SIZE_GLOBAL_COMMENT")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$segment_time")
            change_variable_menu "SEGMENT_TIME" "$CONFIG_FILE" "$(build_comment "$SEGMENT_TIME_GLOBAL_COMMENT")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$work_directory")
            change_variable_menu "WORK_DIRECTORY" "$CONFIG_FILE" "$(build_comment "$WORK_DIRECTORY_GLOBAL_COMMENT")"
            [[ ! "$?" == "1" ]] && restart_all_buffers
            ;;
        "$merge_adjacent_clips")
            change_variable_menu "MERGE_ADJACENT_CLIPS" "$CONFIG_FILE" "$(build_comment "$MERGE_ADJACENT_CLIPS_COMMENT")"
            ;;
		"$save_clip_data")
			if [[ "$g_save_clip_data_locked" == "$FALSE" ]]; then
				change_variable_menu "SAVE_CLIP_DATA" "$CONFIG_FILE" "$(build_comment "$SAVE_CLIP_DATA_COMMENT")"
			fi
			;;
        "$delete_data_clips")
			if confirmatoin "$CONFIRM_DELETE_DATA" "$CANCEL" "$GLOBAL_DELETE_DATA_COMMENT"; then
				delete_all_clip_data
			fi
            ;;
		"$global_lang")
			set_locale_menu
			;;
        *)
            ret_global="$TRUE"
            ;;
    esac
    if ! [[ "$streamer" == "$NONE_STREAMER" ]]; then
		local config_file="$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION"
        case "$sel" in
            "$l_duration_forward")
                change_local_variable_menu "DURATION_FORWARD" "$config_file" "$(build_comment "$DURATION_FORWARD_COMMENT")"
                ;;
            "$l_duration_back")
				change_local_variable_menu "DURATION_BACK" "$config_file" "$(build_comment "$DURATION_BACK_COMMENT")"
                ;;
            "$l_buffer_size")
				change_local_variable_menu "BUFFER_SIZE" "$config_file" "$(build_comment "$(printf "$BUFFER_SIZE_LOCAL_COMMENT" "$streamer")")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_segment_time")
				change_local_variable_menu "SEGMENT_TIME" "$config_file" "$(build_comment "$(printf "$SEGMENT_TIME_LOCAL_COMMENT" "$streamer")")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_work_directory")
				change_local_variable_menu "WORK_DIRECTORY" "$config_file" "$(build_comment "$(printf "$WORK_DIRECTORY_LOCAL_COMMENT" "$streamer")")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_merge_adjacent_clips")
				change_local_variable_menu "MERGE_ADJACENT_CLIPS" "$config_file" "$(build_comment "$MERGE_ADJACENT_CLIPS_COMMENT")"
                ;;
			"$l_save_clip_data")
				if [[ "$l_save_clip_data_locked" == "$FALSE" ]]; then
					change_local_variable_menu "SAVE_CLIP_DATA" "$config_file" "$(build_comment "$SAVE_CLIP_DATA_COMMENT")"
				fi
				;;
            "$l_delete_data_clips")
				local comment
				printf -v comment "$LOCAL_DELETE_DATA_COMMENT" "$streamer"
				if confirmatoin "$(printf "$LOCAL_CONFIRM_DELETE_DATA" "$streamer")" "$CANCEL" "$comment"; then
					delete_data_for_streamer "$streamer"
				fi
                ;;
            *)
                ret_local="$TRUE"
                ;;
        esac
    fi
    if [[ "$ret_global" == "$TRUE" && "$ret_local" == "$TRUE" ]] || [[ "$ret_global" == "$TRUE" && "$streamer" == "$NONE_STREAMER" ]]; then
        return
    fi
    settings_menu "$streamer"
}

############################################
# МЕНЮ СТРИМЕРА
############################################

streamer_menu() {
    local current_streamer_nick=$(get_current)
	load_all_config_for_streamer "$current_streamer_nick"

    [[ "$current_streamer_nick" == "" || "$current_streamer_nick" == "$NONE_STREAMER" ]] && current_streamer_nick="$NONE_STREAMER"
	local toggle
    if is_running "$current_streamer_nick"; then
        toggle="$STOP_BUFFER_EMOJI $ONLINE_INDICATOR $STOP_BUFFER_BUTTON"
    else
        toggle="$START_BUFFER_EMOJI $OFFLINE_INDICATOR $START_BUFFER_BUTTON"
    fi

    local clip="$CLIP_EMOJI $CLIP_BUTTON"
    local full_clip="$CLIP_EMOJI $FULL_CLIP_BUTTON"
    local remove_streamer="$REMOVE_EMOJI $REMOVE_STREAMER_BUTTON"
    local settings="$SETTINGS_EMOJI $SETTINGS_BUTTON"
    local reload="$RELOAD_EMOJI $RELOAD_BUTTON"
    local exit="$EXIT_EMOJI $EXIT_BUTTON"
    
	local online_emoji_indicator
    if [[ "$ENABLE_ONLINE_CHECK" == "$TRUE" ]]; then
        online_emoji_indicator=" $(get_streaming_indicator "$current_streamer_nick")"
    fi
	local menu
	local active_streamer_string
    if [[ "$current_streamer_nick" == "$NONE_STREAMER" ]]; then
        active_streamer_string="$ACTIVE_STREAMER_EMOJI $ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER $online_emoji_indicator"
        menu=$(cat <<EOF
$active_streamer_string
$settings
$reload
$exit
EOF
    )
    else
		active_streamer_string="$ACTIVE_STREAMER_EMOJI $(printf "$ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE" $current_streamer_nick) $online_emoji_indicator"
        menu=$(cat <<EOF
$active_streamer_string
$toggle
$clip
$full_clip
$remove_streamer
$settings
$reload
$exit
EOF
    )
    fi

    if [[ ! "$current_streamer_nick" == "$NONE_STREAMER" && ! -f "$CONFIG_FILES/$current_streamer_nick.conf" ]]; then
        init_local_config "$current_streamer_nick"
    fi

    local choice="$(grap_menu "$menu" "Photographer")"

    case "$choice" in
        "$active_streamer_string")
            local sel=$(streamer_list)
            [[ -z "$sel" ]] && sel="$current_streamer_nick"
            set_variable "$CONFIG_FILE" "CURRENT_STREAMER" "$sel"
            ;;
        "$toggle")
            toggle_buffer "$current_streamer_nick"
            ;;
        "$clip")
            {
				MODE="--clip"
				sleep 0.1 && clip &
				wait "$!"
            } 2> >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat >&2 ) > >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat)
            ;;
        "$full_clip")
            {
				MODE="--full-clip"
				sleep 0.1 && clip &
				wait "$!"
            } 2> >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat >&2 ) > >( [[ "$SILENCE_LOG" == "$TRUE" ]] && cat >/dev/null || cat)
            ;;
        "$remove_streamer")
            kill_streamer_buffer "$current_streamer_nick"
            sed -i "/^$current_streamer_nick$/d" "$STREAMERS_FILE"
            set_variable "$CONFIG_FILE" "CURRENT_STREAMER" "$NONE_STREAMER"
            ;;
        "$settings")
            settings_menu "$current_streamer_nick"
            ;;
        "$exit")
            exit 0
            ;;
        "$reload")
            ;;
        *)
            exit 0
            ;;
    esac
    streamer_menu
}


streamer_menu
