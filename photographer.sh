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
STREAM_EMOJ="🎥"
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
	DURATION_FORWARD_COMMENT="When using full-clip, the script waits for the specified number of new segments.\nWhen using clip, this value is added to the value of the duration_back and saves the specified number of segments that have already been created.\nThe value must be an integer."
	DURATION_BACK_COMMENT="Specifies how many segments back in time will be taken to create the clip.\nThe value must be an integer."
	BUFFER_SIZE_COMMENT="The size of the buffer in segments.\nThe value must be an integer."
	SEGMENT_TIME_COMMENT="Segment time in seconds.\n!WHEN YOU CHANGE THIS VARIABLE, THE ALL STREAM BUFFERS WILL BE RESTARTED!\nThe value must be an integer."
	WORK_DIRECTORY_COMMENT="The directory where the stream fragments and the resulting clips will be placed.\nThe value must be an integer."
	MERGE_ADJACENT_CLIPS_COMMENT="Zero -- temporary files (which make up the clip segments) will be deleted.\nOne -- temporary files will not be deleted.\nThe value must be an integer."
	SAVE_CLIP_DATA_COMMENT="If this option is enabled, the segments used to create clips will be preserved.\nIf it is disabled, these temporary data will be removed after the clip is created.\nIf merging adjacent clips is enabled, this option is always considered enabled.\nThe value must be either zero or one."

	CANCEL="Cancel"
	CONFIRM_DELETE_DATA="YES, DELETE ALL DATA"
	LOCAL_CONFIRM_DELETE_DATA="Yes, delete data for %s"
	GLOBAL_DELETE_DATA_COMMENT="Do you confirm that you will\ndelete the original data of ALL clips?"
	LOCAL_DELETE_DATA_COMMENT="Do you confirm that you have\ndeleted the original data of all clips from %s?"

	STOP_BUFFER_BUTTON="Stop buffer"
	START_BUFFER_BUTTON="Start buffer"
	CLIP_BUTTON="Clip"
	FULL_CLIP_BUTTON="Full Clip"
	REMOVE_STREAMER_BUTTON="Remove streamer"
	SETTINGS_BUTTON="Settings"
	RELOAD_BUTTON="Reload"
	EXIT_BUTTON="Exit"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Select active streamer"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Active streamer => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Global settings"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s segments (%s sec)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s segments (%s sec)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Buffer size = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segment time = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Work directory = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Merge adjacent clips = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sPreserve clip segment data = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Delete ALL clip data"
	BACK_SETTINGS_STRING="Back"
	GLOBAL_SETTINGS_COMMENT="Local variables have a higher priority and will be.\nused instead of global ones if they are not empty"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Streamer (%s) settings"
	LOCAL_DURATION_BACK_SETTINGS_STRING="local Duration forward = %s segments (%s sec)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="local Duration back = %s segments (%s sec)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="local Buffer size = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="local Segment time = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="local Work directory = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="local Merge adjacent clips = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sPreserve clip segment data = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Delete all clip data for %s"

	CLIP_CREATING_CLIP="Creating a clip..."
	CLIP_LAST_SEGMENT_FILE="The last segment: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="The segments have not been created yet"
	CLIP_WAIT_FOR_DATA_CLIP="We wait %s seconds to get data for the clip"
	CLIP_SEGMENT_SAVED_STRING="The segments are saved along the path: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Remove %s"
	CLIP_FINISHED_CLIP_LOCATION="The finished clip is located at: %s"
	CLIP_REMOVING_DATA_DIR="Removing %s clip data dir"

	RESTART_ALL_BUFFERS="Restart all buffers "

	DELETE_DATA_FOR_STREAMER="Removing data folder for %s"

	CHANGE_VARIABLE_TITLE="Change variable:"
	CHANGE_VARIABLE_BACK="Back"
	CHANGE_VARIABLE_INVITATION="%s Enter a new value for the variable %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Add streamer %s"
	STREAMER_LIST_TITLE="Set active streamer"

	ADD_STREAMER_MENU_INVITATION="%s Add streamer here %s"
	ADD_STREAMER_MENU_TITLE="Add streamer:"

	CHECK_GLOBAL_CONFIG_ERROR="The global configuration file is not valid. This file will be reset to the default settings."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR The MERGE_ADJACENT_CLIPS variable can only be 1 or 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR The SAVE_CLIP_DATA variable can only be equal to 1 or 0."

	LANG_SETTINGS_STRING="Language"

	HELP="
Usage:
  script [OPTIONS]

Interface options:
  --ui-config PATH          Path to UI configuration file.
  --use-wofi                Use wofi as the user interface.
  --use-rofi                Use rofi as the user interface.
  --use-fzf                 Use fzf as the user interface.
                            Automatically enables silent log mode and adjusts UI layout.

Buffer control:
  --start-buffer            Start the stream buffering process
                            (downloads the stream into the buffer).

Streamer options:
  --streamer NAME           Set the streamer nickname to operate on.

Clip creation:
  --clip                    Create a clip from the buffered segments.
  --full-clip               Wait for additional future segments before creating the clip.

Clip timing options:
  --duration-back N         Number of segments before the trigger point.
  --duration-forward N      Number of segments after the trigger point.
  --segment-time N          Duration of each segment in seconds.

Buffer options:
  --buffer-size N           Buffer size in segments.

Clip data options:
  --save-clip-data          Preserve the segment files used to create clips.

Working directory:
  --directory PATH          Directory for stream fragments and resulting clips.

Title options:
  --title TEXT              Title for the resulting clip.

Language:
  --lang CODE               Interface language (example: en, ru, es).

Behavior options:
  --silence-log             Disable log output.
  --flip-pointers           Flip the decorative pointers that indicate
                            the input field direction in the UI.
  --invert-comments         Reverse the order of comment lines in the UI.
  --eneble-online-check     Enable checking whether the streamer is online.

Argument parsing:
  --                        Pass remaining arguments to the GUI parser.
                            If used again later, arguments will be parsed
                            by the main script again.

Help:
  -h, --help                Show this help message and exit.
	"
}

################################
# Russian
################################

local_russian() {
	DURATION_FORWARD_COMMENT="При использовании full-clip скрипт ожидает указанное количество новых сегментов.\nПри использовании clip это значение добавляется к значению duration_back и сохраняет указанное количество сегментов, которые уже были созданы.\nЗначение должно быть целым числом."
	DURATION_BACK_COMMENT="Указывает, сколько сегментов назад во времени будет взято для создания клипа.\nЗначение должно быть целым числом."
	BUFFER_SIZE_COMMENT="Размер буфера в сегментах.\nЗначение должно быть целым числом."
	SEGMENT_TIME_COMMENT="Время сегмента в секундах.\n!КОГДА ВЫ ИЗМЕНЯЕТЕ ЭТУ ПЕРЕМЕННУЮ, ВСЕ БУФЕРЫ СТРИМОВ БУДУТ ПЕРЕЗАПУЩЕНЫ!\nЗначение должно быть целым числом."
	WORK_DIRECTORY_COMMENT="Каталог, в котором будут размещаться фрагменты стрима и итоговые клипы.\nЗначение должно быть целым числом."
	MERGE_ADJACENT_CLIPS_COMMENT="Ноль -- временные файлы (которые составляют сегменты клипа) будут удалены.\nОдин -- временные файлы не будут удалены.\nЗначение должно быть целым числом."
	SAVE_CLIP_DATA_COMMENT="Если эта опция включена, сегменты, использованные для создания клипов, будут сохранены.\nЕсли она отключена, эти временные данные будут удалены после создания клипа.\nЕсли объединение соседних клипов включено, эта опция всегда считается включённой.\nЗначение должно быть либо ноль, либо один."

	CANCEL="Отмена"
	CONFIRM_DELETE_DATA="ДА, УДАЛИТЬ ВСЕ ДАННЫЕ"
	LOCAL_CONFIRM_DELETE_DATA="Да, удалить данные для %s"
	GLOBAL_DELETE_DATA_COMMENT="Вы подтверждаете, что\nудалите исходные данные ВСЕХ клипов?"
	LOCAL_DELETE_DATA_COMMENT="Вы подтверждаете, что\nудалили исходные данные всех клипов из %s?"

	STOP_BUFFER_BUTTON="Остановить буфер"
	START_BUFFER_BUTTON="Запустить буфер"
	CLIP_BUTTON="Клип"
	FULL_CLIP_BUTTON="Полный клип"
	REMOVE_STREAMER_BUTTON="Удалить стримера"
	SETTINGS_BUTTON="Настройки"
	RELOAD_BUTTON="Перезагрузить"
	EXIT_BUTTON="Выход"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Выберите активного стримера"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Активный стример => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Глобальные настройки"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s сегментов (%s сек)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s сегментов (%s сек)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Размер буфера = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Время сегмента = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Рабочий каталог = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Объединять соседние клипы = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sСохранять данные сегментов клипа = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Удалить ВСЕ данные клипов"
	BACK_SETTINGS_STRING="Назад"
	GLOBAL_SETTINGS_COMMENT="Локальные переменные имеют более высокий приоритет и\nбудут использоваться вместо глобальных, если они не пустые"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Настройки стримера (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="локальный Duration forward = %s сегментов (%s сек)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="локальный Duration back = %s сегментов (%s сек)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="локальный размер буфера = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="локальное время сегмента = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="локальный рабочий каталог = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="локальное объединение соседних клипов = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sСохранять данные сегментов клипа = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Удалить все данные клипов для %s"

	CLIP_CREATING_CLIP="Создание клипа..."
	CLIP_LAST_SEGMENT_FILE="Последний сегмент: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Сегменты ещё не созданы"
	CLIP_WAIT_FOR_DATA_CLIP="Ожидаем %s секунд, чтобы получить данные для клипа"
	CLIP_SEGMENT_SAVED_STRING="Сегменты сохранены по пути: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Удалить %s"
	CLIP_FINISHED_CLIP_LOCATION="Готовый клип находится по адресу: %s"
	CLIP_REMOVING_DATA_DIR="Удаление каталога данных клипа %s"

	RESTART_ALL_BUFFERS="Перезапустить все буферы "

	DELETE_DATA_FOR_STREAMER="Удаление папки данных для %s"

	CHANGE_VARIABLE_TITLE="Изменить переменную:"
	CHANGE_VARIABLE_BACK="Назад"
	CHANGE_VARIABLE_INVITATION="%s Введите новое значение для переменной %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Добавить стримера %s"
	STREAMER_LIST_TITLE="Выбрать активного стримера"

	ADD_STREAMER_MENU_INVITATION="%s Добавьте стримера здесь %s"
	ADD_STREAMER_MENU_TITLE="Добавить стримера:"

	CHECK_GLOBAL_CONFIG_ERROR="Файл глобальной конфигурации недействителен. Этот файл будет сброшен к настройкам по умолчанию."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Переменная MERGE_ADJACENT_CLIPS может быть только 1 или 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR Переменная SAVE_CLIP_DATA может быть равна только 1 или 0."

	LANG_SETTINGS_STRING="Язык"

	HELP="
Использование:
  script [OPTIONS]

Параметры интерфейса:
  --ui-config PATH          Путь к файлу конфигурации интерфейса.
  --use-wofi                Использовать wofi как пользовательский интерфейс.
  --use-rofi                Использовать rofi как пользовательский интерфейс.
  --use-fzf                 Использовать fzf как пользовательский интерфейс.
                            Автоматически включает тихий режим логов и
                            настраивает расположение интерфейса.

Управление буфером:
  --start-buffer            Запустить процесс буферизации стрима
                            (скачивание стрима в буфер).

Параметры стримера:
  --streamer NAME           Указать ник стримера для работы.

Создание клипа:
  --clip                    Создать клип из буферизированных сегментов.
  --full-clip               Подождать дополнительные будущие сегменты
                            перед созданием клипа.

Параметры времени клипа:
  --duration-back N         Количество сегментов до точки триггера.
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
  --title TEXT              Заголовок для итогового клипа.

Язык:
  --lang CODE               Язык интерфейса (пример: en, ru, es).

Параметры поведения:
  --silence-log             Отключить вывод логов.
  --flip-pointers           Перевернуть декоративные указатели,
                            обозначающие направление поля ввода в UI.
  --invert-comments         Изменить порядок строк комментариев в UI.
  --eneble-online-check     Включить проверку того, находится ли стример онлайн.

Разбор аргументов:
  --                        Передать оставшиеся аргументы парсеру GUI.
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
	DURATION_FORWARD_COMMENT="Lors de l'utilisation de full-clip, le script attend le nombre spécifié de nouveaux segments.\nLors de l'utilisation de clip, cette valeur est ajoutée à la valeur de duration_back et enregistre le nombre spécifié de segments déjà créés.\nLa valeur doit être un entier."
	DURATION_BACK_COMMENT="Indique combien de segments en arrière dans le temps seront utilisés pour créer le clip.\nLa valeur doit être un entier."
	BUFFER_SIZE_COMMENT="La taille du tampon en segments.\nLa valeur doit être un entier."
	SEGMENT_TIME_COMMENT="Durée du segment en secondes.\n!LORSQUE VOUS MODIFIEZ CETTE VARIABLE, TOUS LES TAMPONS DE FLUX SERONT REDÉMARRÉS !\nLa valeur doit être un entier."
	WORK_DIRECTORY_COMMENT="Le répertoire où seront placés les fragments du flux et les clips résultants.\nLa valeur doit être un entier."
	MERGE_ADJACENT_CLIPS_COMMENT="Zéro -- les fichiers temporaires (qui constituent les segments du clip) seront supprimés.\nUn -- les fichiers temporaires ne seront pas supprimés.\nLa valeur doit être un entier."
	SAVE_CLIP_DATA_COMMENT="Si cette option est activée, les segments utilisés pour créer les clips seront conservés.\nSi elle est désactivée, ces données temporaires seront supprimées après la création du clip.\nSi la fusion des clips adjacents est activée, cette option est toujours considérée comme activée.\nLa valeur doit être soit zéro soit un."

	CANCEL="Annuler"
	CONFIRM_DELETE_DATA="OUI, SUPPRIMER TOUTES LES DONNÉES"
	LOCAL_CONFIRM_DELETE_DATA="Oui, supprimer les données pour %s"
	GLOBAL_DELETE_DATA_COMMENT="Confirmez-vous que vous\nallez supprimer les données originales de TOUS les clips ?"
	LOCAL_DELETE_DATA_COMMENT="Confirmez-vous que vous avez\nsupprimé les données originales de tous les clips de %s ?"

	STOP_BUFFER_BUTTON="Arrêter le tampon"
	START_BUFFER_BUTTON="Démarrer le tampon"
	CLIP_BUTTON="Clip"
	FULL_CLIP_BUTTON="Clip complet"
	REMOVE_STREAMER_BUTTON="Supprimer le streamer"
	SETTINGS_BUTTON="Paramètres"
	RELOAD_BUTTON="Recharger"
	EXIT_BUTTON="Quitter"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Sélectionnez un streamer actif"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer actif => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Paramètres globaux"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s segments (%s sec)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s segments (%s sec)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Taille du tampon = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Durée du segment = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Répertoire de travail = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Fusionner les clips adjacents = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConserver les données des segments du clip = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Supprimer TOUTES les données des clips"
	BACK_SETTINGS_STRING="Retour"
	GLOBAL_SETTINGS_COMMENT="Les variables locales ont une priorité plus élevée et\nseront utilisées à la place des variables globales si elles ne sont pas vides"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Paramètres du streamer (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="local Duration forward = %s segments (%s sec)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="local Duration back = %s segments (%s sec)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="taille du tampon locale = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="durée du segment locale = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="répertoire de travail local = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="fusion locale des clips adjacents = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConserver les données des segments du clip = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Supprimer toutes les données des clips pour %s"

	CLIP_CREATING_CLIP="Création du clip..."
	CLIP_LAST_SEGMENT_FILE="Dernier segment : %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Les segments n'ont pas encore été créés"
	CLIP_WAIT_FOR_DATA_CLIP="Nous attendons %s secondes pour obtenir les données du clip"
	CLIP_SEGMENT_SAVED_STRING="Les segments sont enregistrés dans le chemin : %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Supprimer %s"
	CLIP_FINISHED_CLIP_LOCATION="Le clip final se trouve à : %s"
	CLIP_REMOVING_DATA_DIR="Suppression du dossier de données du clip %s"

	RESTART_ALL_BUFFERS="Redémarrer tous les tampons "

	DELETE_DATA_FOR_STREAMER="Suppression du dossier de données pour %s"

	CHANGE_VARIABLE_TITLE="Modifier la variable :"
	CHANGE_VARIABLE_BACK="Retour"
	CHANGE_VARIABLE_INVITATION="%s Entrez une nouvelle valeur pour la variable %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Ajouter un streamer %s"
	STREAMER_LIST_TITLE="Définir le streamer actif"

	ADD_STREAMER_MENU_INVITATION="%s Ajouter un streamer ici %s"
	ADD_STREAMER_MENU_TITLE="Ajouter un streamer :"

	CHECK_GLOBAL_CONFIG_ERROR="Le fichier de configuration global n'est pas valide. Ce fichier sera réinitialisé aux paramètres par défaut."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS ne peut être que 1 ou 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR La variable SAVE_CLIP_DATA ne peut être égale qu'à 1 ou 0."

	LANG_SETTINGS_STRING="Langue"

	HELP="
Utilisation :
  script [OPTIONS]

Options d'interface :
  --ui-config PATH          Chemin vers le fichier de configuration de l'interface.
  --use-wofi                Utiliser wofi comme interface utilisateur.
  --use-rofi                Utiliser rofi comme interface utilisateur.
  --use-fzf                 Utiliser fzf comme interface utilisateur.
                            Active automatiquement le mode silencieux des logs et
                            ajuste la disposition de l'interface.

Contrôle du tampon :
  --start-buffer            Démarrer le processus de mise en tampon du flux
                            (télécharge le flux dans le tampon).

Options du streamer :
  --streamer NAME           Définir le pseudo du streamer à utiliser.

Création de clip :
  --clip                    Créer un clip à partir des segments mis en tampon.
  --full-clip               Attendre des segments futurs supplémentaires
                            avant de créer le clip.

Options de durée du clip :
  --duration-back N         Nombre de segments avant le point de déclenchement.
  --duration-forward N      Nombre de segments après le point de déclenchement.
  --segment-time N          Durée de chaque segment en secondes.

Options du tampon :
  --buffer-size N           Taille du tampon en segments.

Options des données du clip :
  --save-clip-data          Conserver les fichiers de segments utilisés
                            pour créer les clips.

Répertoire de travail :
  --directory PATH          Répertoire pour les fragments du flux et les clips résultants.

Options du titre :
  --title TEXT              Titre du clip résultant.

Langue :
  --lang CODE               Langue de l'interface (exemple : en, ru, es).

Options de comportement :
  --silence-log             Désactiver la sortie des logs.
  --flip-pointers           Inverser les pointeurs décoratifs indiquant
                            la direction du champ de saisie dans l'interface.
  --invert-comments         Inverser l'ordre des lignes de commentaires dans l'interface.
  --eneble-online-check     Activer la vérification si le streamer est en ligne.

Analyse des arguments :
  --                        Passer les arguments restants à l'analyseur GUI.
                            S'il est utilisé à nouveau plus tard, les arguments seront
                            analysés à nouveau par le script principal.

Aide :
  -h, --help                Afficher ce message d'aide et quitter.
	"
}

################################
# Spanish
################################

local_spanish() {
	DURATION_FORWARD_COMMENT="Cuando se usa full-clip, el script espera el número especificado de nuevos segmentos.\nCuando se usa clip, este valor se añade al valor de duration_back y guarda el número especificado de segmentos que ya han sido creados.\nEl valor debe ser un número entero."
	DURATION_BACK_COMMENT="Especifica cuántos segmentos hacia atrás en el tiempo se tomarán para crear el clip.\nEl valor debe ser un número entero."
	BUFFER_SIZE_COMMENT="El tamaño del búfer en segmentos.\nEl valor debe ser un número entero."
	SEGMENT_TIME_COMMENT="Tiempo de segmento en segundos.\n¡CUANDO CAMBIES ESTA VARIABLE, TODOS LOS BÚFERES DE STREAM SE REINICIARÁN!\nEl valor debe ser un número entero."
	WORK_DIRECTORY_COMMENT="El directorio donde se colocarán los fragmentos del stream y los clips resultantes.\nEl valor debe ser un número entero."
	MERGE_ADJACENT_CLIPS_COMMENT="Cero -- los archivos temporales (que componen los segmentos del clip) serán eliminados.\nUno -- los archivos temporales no serán eliminados.\nEl valor debe ser un número entero."
	SAVE_CLIP_DATA_COMMENT="Si esta opción está habilitada, los segmentos usados para crear clips se conservarán.\nSi está deshabilitada, estos datos temporales se eliminarán después de crear el clip.\nSi la fusión de clips adyacentes está habilitada, esta opción siempre se considera habilitada.\nEl valor debe ser cero o uno."

	CANCEL="Cancelar"
	CONFIRM_DELETE_DATA="SÍ, ELIMINAR TODOS LOS DATOS"
	LOCAL_CONFIRM_DELETE_DATA="Sí, eliminar datos para %s"
	GLOBAL_DELETE_DATA_COMMENT="¿Confirmas que\neliminarás los datos originales de TODOS los clips?"
	LOCAL_DELETE_DATA_COMMENT="¿Confirmas que has\neliminado los datos originales de todos los clips de %s?"

	STOP_BUFFER_BUTTON="Detener búfer"
	START_BUFFER_BUTTON="Iniciar búfer"
	CLIP_BUTTON="Clip"
	FULL_CLIP_BUTTON="Clip completo"
	REMOVE_STREAMER_BUTTON="Eliminar streamer"
	SETTINGS_BUTTON="Configuración"
	RELOAD_BUTTON="Recargar"
	EXIT_BUTTON="Salir"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Selecciona un streamer activo"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer activo => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Configuración global"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s segmentos (%s seg)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s segmentos (%s seg)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Tamaño del búfer = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Tiempo de segmento = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Directorio de trabajo = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Fusionar clips adyacentes = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConservar datos de segmentos del clip = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Eliminar TODOS los datos de clips"
	BACK_SETTINGS_STRING="Volver"
	GLOBAL_SETTINGS_COMMENT="Las variables locales tienen mayor prioridad y\nse usarán en lugar de las globales si no están vacías"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Configuración del streamer (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="local Duration forward = %s segmentos (%s seg)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="local Duration back = %s segmentos (%s seg)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="Tamaño del búfer local = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="Tiempo de segmento local = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="Directorio de trabajo local = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="Fusionar clips adyacentes (local) = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sConservar datos de segmentos del clip = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Eliminar todos los datos de clips para %s"

	CLIP_CREATING_CLIP="Creando un clip..."
	CLIP_LAST_SEGMENT_FILE="Último segmento: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Los segmentos aún no han sido creados"
	CLIP_WAIT_FOR_DATA_CLIP="Esperamos %s segundos para obtener datos para el clip"
	CLIP_SEGMENT_SAVED_STRING="Los segmentos se guardaron en la ruta: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Eliminar %s"
	CLIP_FINISHED_CLIP_LOCATION="El clip final se encuentra en: %s"
	CLIP_REMOVING_DATA_DIR="Eliminando el directorio de datos del clip %s"

	RESTART_ALL_BUFFERS="Reiniciar todos los búferes "

	DELETE_DATA_FOR_STREAMER="Eliminando carpeta de datos para %s"

	CHANGE_VARIABLE_TITLE="Cambiar variable:"
	CHANGE_VARIABLE_BACK="Volver"
	CHANGE_VARIABLE_INVITATION="%s Introduce un nuevo valor para la variable %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Añadir streamer %s"
	STREAMER_LIST_TITLE="Establecer streamer activo"

	ADD_STREAMER_MENU_INVITATION="%s Añadir streamer aquí %s"
	ADD_STREAMER_MENU_TITLE="Añadir streamer:"

	CHECK_GLOBAL_CONFIG_ERROR="El archivo de configuración global no es válido. Este archivo se restablecerá a la configuración predeterminada."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS solo puede ser 1 o 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR La variable SAVE_CLIP_DATA solo puede ser 1 o 0."

	LANG_SETTINGS_STRING="Idioma"

	HELP="
Uso:
  script [OPTIONS]

Opciones de interfaz:
  --ui-config PATH          Ruta al archivo de configuración de la interfaz.
  --use-wofi                Usar wofi como interfaz de usuario.
  --use-rofi                Usar rofi como interfaz de usuario.
  --use-fzf                 Usar fzf como interfaz de usuario.
                            Activa automáticamente el modo de registro silencioso
                            y ajusta el diseño de la interfaz.

Control del búfer:
  --start-buffer            Iniciar el proceso de almacenamiento en búfer del stream
                            (descarga el stream en el búfer).

Opciones del streamer:
  --streamer NAME           Establecer el apodo del streamer con el que operar.

Creación de clips:
  --clip                    Crear un clip a partir de los segmentos almacenados en búfer.
  --full-clip               Esperar segmentos futuros adicionales antes de crear el clip.

Opciones de tiempo del clip:
  --duration-back N         Número de segmentos antes del punto de activación.
  --duration-forward N      Número de segmentos después del punto de activación.
  --segment-time N          Duración de cada segmento en segundos.

Opciones del búfer:
  --buffer-size N           Tamaño del búfer en segmentos.

Opciones de datos del clip:
  --save-clip-data          Conservar los archivos de segmentos utilizados
                            para crear clips.

Directorio de trabajo:
  --directory PATH          Directorio para fragmentos del stream y clips resultantes.

Opciones de título:
  --title TEXT              Título para el clip resultante.

Idioma:
  --lang CODE               Idioma de la interfaz (ejemplo: en, ru, es).

Opciones de comportamiento:
  --silence-log             Desactivar la salida de logs.
  --flip-pointers           Invertir los punteros decorativos que indican
                            la dirección del campo de entrada en la interfaz.
  --invert-comments         Invertir el orden de las líneas de comentarios en la interfaz.
  --eneble-online-check     Activar la verificación de si el streamer está en línea.

Análisis de argumentos:
  --                        Pasar los argumentos restantes al analizador de GUI.
                            Si se usa nuevamente más tarde, los argumentos serán
                            analizados otra vez por el script principal.

Ayuda:
  -h, --help                Mostrar este mensaje de ayuda y salir.
	"
}

################################
# German
################################

local_german() {
	DURATION_FORWARD_COMMENT="Bei Verwendung von full-clip wartet das Skript auf die angegebene Anzahl neuer Segmente.\nBei Verwendung von clip wird dieser Wert zum Wert von duration_back hinzugefügt und speichert die angegebene Anzahl von Segmenten, die bereits erstellt wurden.\nDer Wert muss eine ganze Zahl sein."
	DURATION_BACK_COMMENT="Gibt an, wie viele Segmente in der Zeit zurück verwendet werden, um den Clip zu erstellen.\nDer Wert muss eine ganze Zahl sein."
	BUFFER_SIZE_COMMENT="Die Größe des Puffers in Segmenten.\nDer Wert muss eine ganze Zahl sein."
	SEGMENT_TIME_COMMENT="Segmentdauer in Sekunden.\n!WENN SIE DIESE VARIABLE ÄNDERN, WERDEN ALLE STREAM-PUFFER NEU GESTARTET!\nDer Wert muss eine ganze Zahl sein."
	WORK_DIRECTORY_COMMENT="Das Verzeichnis, in dem die Stream-Fragmente und die resultierenden Clips abgelegt werden.\nDer Wert muss eine ganze Zahl sein."
	MERGE_ADJACENT_CLIPS_COMMENT="Null -- temporäre Dateien (die die Clip-Segmente bilden) werden gelöscht.\nEins -- temporäre Dateien werden nicht gelöscht.\nDer Wert muss eine ganze Zahl sein."
	SAVE_CLIP_DATA_COMMENT="Wenn diese Option aktiviert ist, werden die zur Erstellung von Clips verwendeten Segmente beibehalten.\nWenn sie deaktiviert ist, werden diese temporären Daten nach der Erstellung des Clips entfernt.\nWenn das Zusammenführen benachbarter Clips aktiviert ist, gilt diese Option immer als aktiviert.\nDer Wert muss entweder null oder eins sein."

	CANCEL="Abbrechen"
	CONFIRM_DELETE_DATA="JA, ALLE DATEN LÖSCHEN"
	LOCAL_CONFIRM_DELETE_DATA="Ja, Daten für %s löschen"
	GLOBAL_DELETE_DATA_COMMENT="Bestätigen Sie, dass Sie\ndie Originaldaten ALLER Clips löschen?"
	LOCAL_DELETE_DATA_COMMENT="Bestätigen Sie, dass Sie\ndie Originaldaten aller Clips von %s gelöscht haben?"

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

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Globale Einstellungen"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s Segmente (%s Sek)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s Segmente (%s Sek)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Puffergröße = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segmentdauer = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Arbeitsverzeichnis = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Benachbarte Clips zusammenführen = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sSegmentdaten des Clips beibehalten = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="ALLE Clip-Daten löschen"
	BACK_SETTINGS_STRING="Zurück"
	GLOBAL_SETTINGS_COMMENT="Lokale Variablen haben eine höhere Priorität und\nwerden anstelle der globalen verwendet, wenn sie nicht leer sind"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Streamer (%s) Einstellungen"
	LOCAL_DURATION_BACK_SETTINGS_STRING="lokal Duration forward = %s Segmente (%s Sek)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="lokal Duration back = %s Segmente (%s Sek)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="lokale Puffergröße = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="lokale Segmentdauer = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="lokales Arbeitsverzeichnis = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="lokales Zusammenführen benachbarter Clips = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sSegmentdaten des Clips beibehalten = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Alle Clip-Daten für %s löschen"

	CLIP_CREATING_CLIP="Clip wird erstellt..."
	CLIP_LAST_SEGMENT_FILE="Letztes Segment: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Die Segmente wurden noch nicht erstellt"
	CLIP_WAIT_FOR_DATA_CLIP="Wir warten %s Sekunden, um Daten für den Clip zu erhalten"
	CLIP_SEGMENT_SAVED_STRING="Die Segmente wurden unter folgendem Pfad gespeichert: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="%s entfernen"
	CLIP_FINISHED_CLIP_LOCATION="Der fertige Clip befindet sich unter: %s"
	CLIP_REMOVING_DATA_DIR="Entferne Clip-Datenverzeichnis %s"

	RESTART_ALL_BUFFERS="Alle Puffer neu starten "

	DELETE_DATA_FOR_STREAMER="Datenordner für %s wird entfernt"

	CHANGE_VARIABLE_TITLE="Variable ändern:"
	CHANGE_VARIABLE_BACK="Zurück"
	CHANGE_VARIABLE_INVITATION="%s Geben Sie einen neuen Wert für die Variable %s ein %s"

	STREAMER_LIST_ADD_STREAMER="%s Streamer hinzufügen %s"
	STREAMER_LIST_TITLE="Aktiven Streamer festlegen"

	ADD_STREAMER_MENU_INVITATION="%s Streamer hier hinzufügen %s"
	ADD_STREAMER_MENU_TITLE="Streamer hinzufügen:"

	CHECK_GLOBAL_CONFIG_ERROR="Die globale Konfigurationsdatei ist ungültig. Diese Datei wird auf die Standardeinstellungen zurückgesetzt."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Die Variable MERGE_ADJACENT_CLIPS kann nur 1 oder 0 sein."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR Die Variable SAVE_CLIP_DATA kann nur 1 oder 0 sein."

	LANG_SETTINGS_STRING="Sprache"

	HELP="
Verwendung:
  script [OPTIONS]

Schnittstellenoptionen:
  --ui-config PATH          Pfad zur UI-Konfigurationsdatei.
  --use-wofi                Wofi als Benutzeroberfläche verwenden.
  --use-rofi                Rofi als Benutzeroberfläche verwenden.
  --use-fzf                 Fzf als Benutzeroberfläche verwenden.
                            Aktiviert automatisch den stillen Log-Modus und
                            passt das UI-Layout an.

Puffersteuerung:
  --start-buffer            Startet den Stream-Pufferprozess
                            (lädt den Stream in den Puffer).

Streamer-Optionen:
  --streamer NAME           Setzt den Streamer-Namen, mit dem gearbeitet wird.

Clip-Erstellung:
  --clip                    Erstellt einen Clip aus den gepufferten Segmenten.
  --full-clip               Wartet auf zusätzliche zukünftige Segmente,
                            bevor der Clip erstellt wird.

Clip-Zeitoptionen:
  --duration-back N         Anzahl der Segmente vor dem Auslösepunkt.
  --duration-forward N      Anzahl der Segmente nach dem Auslösepunkt.
  --segment-time N          Dauer jedes Segments in Sekunden.

Pufferoptionen:
  --buffer-size N           Puffergröße in Segmenten.

Clip-Datenoptionen:
  --save-clip-data          Behalte die Segmentdateien, die zum Erstellen
                            der Clips verwendet wurden.

Arbeitsverzeichnis:
  --directory PATH          Verzeichnis für Stream-Fragmente und resultierende Clips.

Titeloptionen:
  --title TEXT              Titel für den resultierenden Clip.

Sprache:
  --lang CODE               Sprache der Benutzeroberfläche (Beispiel: en, ru, es).

Verhaltensoptionen:
  --silence-log             Log-Ausgabe deaktivieren.
  --flip-pointers           Die dekorativen Zeiger umkehren, die
                            die Richtung des Eingabefelds im UI anzeigen.
  --invert-comments         Reihenfolge der Kommentarzeilen im UI umkehren.
  --eneble-online-check     Überprüfung aktivieren, ob der Streamer online ist.

Argumentverarbeitung:
  --                        Übergibt die verbleibenden Argumente an den GUI-Parser.
                            Wenn später erneut verwendet, werden die Argumente
                            erneut vom Hauptskript verarbeitet.

Hilfe:
  -h, --help                Diese Hilfemeldung anzeigen und beenden.
	"
}

################################
# Chinese
################################

local_chinese() {
	DURATION_FORWARD_COMMENT="使用 full-clip 时，脚本会等待指定数量的新分段。\n使用 clip 时，该值会加到 duration_back 的值上，并保存已创建的指定数量的分段。\n该值必须是整数。"
	DURATION_BACK_COMMENT="指定向过去回溯多少个分段来创建剪辑。\n该值必须是整数。"
	BUFFER_SIZE_COMMENT="缓冲区大小（以分段为单位）。\n该值必须是整数。"
	SEGMENT_TIME_COMMENT="分段时间（秒）。\n!当你修改此变量时，所有流缓冲区都会被重启！\n该值必须是整数。"
	WORK_DIRECTORY_COMMENT="用于存放流片段和生成的剪辑的目录。\n该值必须是整数。"
	MERGE_ADJACENT_CLIPS_COMMENT="零 -- 临时文件（构成剪辑分段的文件）将被删除。\n一 -- 临时文件不会被删除。\n该值必须是整数。"
	SAVE_CLIP_DATA_COMMENT="如果启用此选项，用于创建剪辑的分段将被保留。\n如果禁用，则在创建剪辑后这些临时数据将被删除。\n如果启用了合并相邻剪辑，此选项始终被视为启用。\n该值必须是 0 或 1。"

	CANCEL="取消"
	CONFIRM_DELETE_DATA="是的，删除所有数据"
	LOCAL_CONFIRM_DELETE_DATA="是的，删除 %s 的数据"
	GLOBAL_DELETE_DATA_COMMENT="你确认要\n删除所有剪辑的原始数据吗？"
	LOCAL_DELETE_DATA_COMMENT="你确认已经\n删除来自 %s 的所有剪辑原始数据吗？"

	STOP_BUFFER_BUTTON="停止缓冲"
	START_BUFFER_BUTTON="启动缓冲"
	CLIP_BUTTON="剪辑"
	FULL_CLIP_BUTTON="完整剪辑"
	REMOVE_STREAMER_BUTTON="移除主播"
	SETTINGS_BUTTON="设置"
	RELOAD_BUTTON="重新加载"
	EXIT_BUTTON="退出"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="选择活动主播"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="当前主播 => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="全局设置"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s 个分段 (%s 秒)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s 个分段 (%s 秒)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="缓冲区大小 = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="分段时间 = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="工作目录 = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="合并相邻剪辑 = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%s保留剪辑分段数据 = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="删除所有剪辑数据"
	BACK_SETTINGS_STRING="返回"
	GLOBAL_SETTINGS_COMMENT="本地变量优先级更高，\n如果不为空将替代全局变量使用"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="主播 (%s) 设置"
	LOCAL_DURATION_BACK_SETTINGS_STRING="本地 Duration forward = %s 个分段 (%s 秒)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="本地 Duration back = %s 个分段 (%s 秒)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="本地缓冲区大小 = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="本地分段时间 = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="本地工作目录 = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="本地合并相邻剪辑 = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%s保留剪辑分段数据 = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="删除 %s 的所有剪辑数据"

	CLIP_CREATING_CLIP="正在创建剪辑..."
	CLIP_LAST_SEGMENT_FILE="最后一个分段: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="分段尚未创建"
	CLIP_WAIT_FOR_DATA_CLIP="等待 %s 秒以获取剪辑数据"
	CLIP_SEGMENT_SAVED_STRING="分段已保存到路径: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="删除 %s"
	CLIP_FINISHED_CLIP_LOCATION="完成的剪辑位于: %s"
	CLIP_REMOVING_DATA_DIR="正在删除剪辑数据目录 %s"

	RESTART_ALL_BUFFERS="重启所有缓冲区 "

	DELETE_DATA_FOR_STREAMER="正在删除 %s 的数据文件夹"

	CHANGE_VARIABLE_TITLE="修改变量:"
	CHANGE_VARIABLE_BACK="返回"
	CHANGE_VARIABLE_INVITATION="%s 请输入变量 %s 的新值 %s"

	STREAMER_LIST_ADD_STREAMER="%s 添加主播 %s"
	STREAMER_LIST_TITLE="设置活动主播"

	ADD_STREAMER_MENU_INVITATION="%s 在这里添加主播 %s"
	ADD_STREAMER_MENU_TITLE="添加主播:"

	CHECK_GLOBAL_CONFIG_ERROR="全局配置文件无效。该文件将被重置为默认设置。"
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR 变量 MERGE_ADJACENT_CLIPS 只能是 1 或 0。"
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR 变量 SAVE_CLIP_DATA 只能是 1 或 0。"

	LANG_SETTINGS_STRING="语言"

	HELP="
用法:
  script [OPTIONS]

界面选项:
  --ui-config PATH          UI 配置文件路径。
  --use-wofi                使用 wofi 作为用户界面。
  --use-rofi                使用 rofi 作为用户界面。
  --use-fzf                 使用 fzf 作为用户界面。
                            自动启用静默日志模式并调整界面布局。

缓冲控制:
  --start-buffer            启动流缓冲过程
                            （将流下载到缓冲区）。

主播选项:
  --streamer NAME           设置要操作的主播昵称。

剪辑创建:
  --clip                    从缓冲分段创建剪辑。
  --full-clip               在创建剪辑之前等待额外的未来分段。

剪辑时间选项:
  --duration-back N         触发点之前的分段数量。
  --duration-forward N      触发点之后的分段数量。
  --segment-time N          每个分段的持续时间（秒）。

缓冲选项:
  --buffer-size N           缓冲区大小（分段数）。

剪辑数据选项:
  --save-clip-data          保留用于创建剪辑的分段文件。

工作目录:
  --directory PATH          存放流片段和生成剪辑的目录。

标题选项:
  --title TEXT              生成剪辑的标题。

语言:
  --lang CODE               界面语言（例如: en, ru, es）。

行为选项:
  --silence-log             禁用日志输出。
  --flip-pointers           翻转 UI 中指示输入方向的装饰指针。
  --invert-comments         反转 UI 中注释行的顺序。
  --eneble-online-check     启用检查主播是否在线。

参数解析:
  --                        将剩余参数传递给 GUI 解析器。
                            如果稍后再次使用，参数将再次由主脚本解析。

帮助:
  -h, --help                显示此帮助信息并退出。
	"
}

################################
# Ukrainian
################################

local_ukrainian() {
	DURATION_FORWARD_COMMENT="Під час використання full-clip скрипт очікує вказану кількість нових сегментів.\nПід час використання clip це значення додається до значення duration_back і зберігає вказану кількість сегментів, які вже були створені.\nЗначення має бути цілим числом."
	DURATION_BACK_COMMENT="Вказує, скільки сегментів назад у часі буде використано для створення кліпу.\nЗначення має бути цілим числом."
	BUFFER_SIZE_COMMENT="Розмір буфера в сегментах.\nЗначення має бути цілим числом."
	SEGMENT_TIME_COMMENT="Час сегмента в секундах.\n!КОЛИ ВИ ЗМІНЮЄТЕ ЦЮ ЗМІННУ, УСІ БУФЕРИ СТРІМІВ БУДУТЬ ПЕРЕЗАПУЩЕНІ!\nЗначення має бути цілим числом."
	WORK_DIRECTORY_COMMENT="Каталог, у якому будуть розміщені фрагменти стріму та отримані кліпи.\nЗначення має бути цілим числом."
	MERGE_ADJACENT_CLIPS_COMMENT="Нуль -- тимчасові файли (які складають сегменти кліпу) будуть видалені.\nОдин -- тимчасові файли не будуть видалені.\nЗначення має бути цілим числом."
	SAVE_CLIP_DATA_COMMENT="Якщо цю опцію увімкнено, сегменти, використані для створення кліпів, будуть збережені.\nЯкщо її вимкнено, ці тимчасові дані буде видалено після створення кліпу.\nЯкщо увімкнено об'єднання сусідніх кліпів, ця опція завжди вважається увімкненою.\nЗначення має бути або нуль, або один."

	CANCEL="Скасувати"
	CONFIRM_DELETE_DATA="ТАК, ВИДАЛИТИ ВСІ ДАНІ"
	LOCAL_CONFIRM_DELETE_DATA="Так, видалити дані для %s"
	GLOBAL_DELETE_DATA_COMMENT="Ви підтверджуєте, що\nвидалите оригінальні дані ВСІХ кліпів?"
	LOCAL_DELETE_DATA_COMMENT="Ви підтверджуєте, що\nвидалили оригінальні дані всіх кліпів з %s?"

	STOP_BUFFER_BUTTON="Зупинити буфер"
	START_BUFFER_BUTTON="Запустити буфер"
	CLIP_BUTTON="Кліп"
	FULL_CLIP_BUTTON="Повний кліп"
	REMOVE_STREAMER_BUTTON="Видалити стримера"
	SETTINGS_BUTTON="Налаштування"
	RELOAD_BUTTON="Перезавантажити"
	EXIT_BUTTON="Вихід"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Виберіть активного стримера"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Активний стример => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Глобальні налаштування"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s сегментів (%s сек)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s сегментів (%s сек)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Розмір буфера = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Час сегмента = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Робочий каталог = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Об'єднувати сусідні кліпи = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sЗберігати дані сегментів кліпу = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Видалити ВСІ дані кліпів"
	BACK_SETTINGS_STRING="Назад"
	GLOBAL_SETTINGS_COMMENT="Локальні змінні мають вищий пріоритет і\nбудуть використовуватися замість глобальних, якщо вони не порожні"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Налаштування стримера (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="локальний Duration forward = %s сегментів (%s сек)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="локальний Duration back = %s сегментів (%s сек)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="локальний розмір буфера = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="локальний час сегмента = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="локальний робочий каталог = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="локальне об'єднання сусідніх кліпів = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sЗберігати дані сегментів кліпу = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Видалити всі дані кліпів для %s"

	CLIP_CREATING_CLIP="Створення кліпу..."
	CLIP_LAST_SEGMENT_FILE="Останній сегмент: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Сегменти ще не створені"
	CLIP_WAIT_FOR_DATA_CLIP="Чекаємо %s секунд, щоб отримати дані для кліпу"
	CLIP_SEGMENT_SAVED_STRING="Сегменти збережені за шляхом: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Видалити %s"
	CLIP_FINISHED_CLIP_LOCATION="Готовий кліп знаходиться за адресою: %s"
	CLIP_REMOVING_DATA_DIR="Видалення каталогу даних кліпу %s"

	RESTART_ALL_BUFFERS="Перезапустити всі буфери "

	DELETE_DATA_FOR_STREAMER="Видалення папки даних для %s"

	CHANGE_VARIABLE_TITLE="Змінити змінну:"
	CHANGE_VARIABLE_BACK="Назад"
	CHANGE_VARIABLE_INVITATION="%s Введіть нове значення для змінної %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Додати стримера %s"
	STREAMER_LIST_TITLE="Встановити активного стримера"

	ADD_STREAMER_MENU_INVITATION="%s Додайте стримера тут %s"
	ADD_STREAMER_MENU_TITLE="Додати стримера:"

	CHECK_GLOBAL_CONFIG_ERROR="Файл глобальної конфігурації недійсний. Цей файл буде скинуто до налаштувань за замовчуванням."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Змінна MERGE_ADJACENT_CLIPS може бути лише 1 або 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR Змінна SAVE_CLIP_DATA може бути лише 1 або 0."

	LANG_SETTINGS_STRING="Мова"

	HELP="
Використання:
  script [OPTIONS]

Параметри інтерфейсу:
  --ui-config PATH          Шлях до файлу конфігурації інтерфейсу.
  --use-wofi                Використовувати wofi як інтерфейс користувача.
  --use-rofi                Використовувати rofi як інтерфейс користувача.
  --use-fzf                 Використовувати fzf як інтерфейс користувача.
                            Автоматично вмикає тихий режим логів і
                            налаштовує розташування інтерфейсу.

Керування буфером:
  --start-buffer            Запустити процес буферизації стріму
                            (завантажує стрім у буфер).

Параметри стримера:
  --streamer NAME           Встановити нік стримера для роботи.

Створення кліпу:
  --clip                    Створити кліп із буферизованих сегментів.
  --full-clip               Дочекатися додаткових майбутніх сегментів
                            перед створенням кліпу.

Параметри часу кліпу:
  --duration-back N         Кількість сегментів до точки тригера.
  --duration-forward N      Кількість сегментів після точки тригера.
  --segment-time N          Тривалість кожного сегмента в секундах.

Параметри буфера:
  --buffer-size N           Розмір буфера в сегментах.

Параметри даних кліпу:
  --save-clip-data          Зберігати файли сегментів, використані
                            для створення кліпів.

Робочий каталог:
  --directory PATH          Каталог для фрагментів стріму та отриманих кліпів.

Параметри заголовка:
  --title TEXT              Заголовок для отриманого кліпу.

Мова:
  --lang CODE               Мова інтерфейсу (приклад: en, ru, es).

Параметри поведінки:
  --silence-log             Вимкнути вивід логів.
  --flip-pointers           Перевернути декоративні вказівники,
                            що показують напрямок поля введення в UI.
  --invert-comments         Змінити порядок рядків коментарів у UI.
  --eneble-online-check     Увімкнути перевірку, чи стример онлайн.

Розбір аргументів:
  --                        Передати решту аргументів парсеру GUI.
                            Якщо використати знову пізніше, аргументи
                            будуть знову оброблені основним скриптом.

Довідка:
  -h, --help                Показати це повідомлення довідки та вийти.
	"
}

################################
# Esperanto
################################

local_esperanto() {
	DURATION_FORWARD_COMMENT="Kiam oni uzas full-clip, la skripto atendas la specifitan nombron de novaj segmentoj.\nKiam oni uzas clip, ĉi tiu valoro estas aldonita al la valoro de duration_back kaj konservas la specifitan nombron de segmentoj, kiuj jam estis kreitaj.\nLa valoro devas esti entjero."
	DURATION_BACK_COMMENT="Specifas kiom da segmentoj reen en la tempo estos prenitaj por krei la klipon.\nLa valoro devas esti entjero."
	BUFFER_SIZE_COMMENT="La grandeco de la bufro en segmentoj.\nLa valoro devas esti entjero."
	SEGMENT_TIME_COMMENT="Segmenta tempo en sekundoj.\n!KIAM VI ŜANĜAS ĈI TIUN VARIABLON, ĈIUJ FLUAJ BUFROJ ESTOS RESTARTIGITAJ!\nLa valoro devas esti entjero."
	WORK_DIRECTORY_COMMENT="La dosierujo kie la fluaj fragmentoj kaj la rezultaj klipoj estos metitaj.\nLa valoro devas esti entjero."
	MERGE_ADJACENT_CLIPS_COMMENT="Nulo -- provizoraj dosieroj (kiuj konsistigas la klipsegmentojn) estos forigitaj.\nUnu -- provizoraj dosieroj ne estos forigitaj.\nLa valoro devas esti entjero."
	SAVE_CLIP_DATA_COMMENT="Se ĉi tiu opcio estas ebligita, la segmentoj uzitaj por krei klipojn estos konservitaj.\nSe ĝi estas malebligita, ĉi tiuj provizoraj datumoj estos forigitaj post la kreo de la klipo.\nSe kunfandado de apudaj klipoj estas ebligita, ĉi tiu opcio ĉiam estas konsiderata ebligita.\nLa valoro devas esti aŭ nulo aŭ unu."

	CANCEL="Nuligi"
	CONFIRM_DELETE_DATA="JES, FORIGI ĈIUJN DATUMOJN"
	LOCAL_CONFIRM_DELETE_DATA="Jes, forigi datumojn por %s"
	GLOBAL_DELETE_DATA_COMMENT="Ĉu vi konfirmas, ke vi\nforigos la originalajn datumojn de ĈIUJ klipoj?"
	LOCAL_DELETE_DATA_COMMENT="Ĉu vi konfirmas, ke vi\nforigis la originalajn datumojn de ĉiuj klipoj el %s?"

	STOP_BUFFER_BUTTON="Halti bufron"
	START_BUFFER_BUTTON="Starti bufron"
	CLIP_BUTTON="Klipo"
	FULL_CLIP_BUTTON="Plena klipo"
	REMOVE_STREAMER_BUTTON="Forigi streameron"
	SETTINGS_BUTTON="Agordoj"
	RELOAD_BUTTON="Reŝargi"
	EXIT_BUTTON="Eliri"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Elektu aktivan streameron"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Aktiva streamero => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Tutmondaj agordoj"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duration forward = %s segmentoj (%s sek)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duration back = %s segmentoj (%s sek)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Bufrograndeco = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segmenta tempo = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Labora dosierujo = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Kunfandi apudajn klipojn = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sKonservi klipsegmentajn datumojn = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Forigi ĈIUJN klipdatumojn"
	BACK_SETTINGS_STRING="Reen"
	GLOBAL_SETTINGS_COMMENT="Lokaj variabloj havas pli altan prioritaton kaj\nestos uzataj anstataŭ la tutmondaj se ili ne estas malplenaj"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Agordoj de streamero (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="loka Duration forward = %s segmentoj (%s sek)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="loka Duration back = %s segmentoj (%s sek)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="loka bufrograndeco = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="loka segmenta tempo = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="loka labora dosierujo = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="loka kunfandado de apudaj klipoj = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sKonservi klipsegmentajn datumojn = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Forigi ĉiujn klipdatumojn por %s"

	CLIP_CREATING_CLIP="Kreado de klipo..."
	CLIP_LAST_SEGMENT_FILE="La lasta segmento: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="La segmentoj ankoraŭ ne estis kreitaj"
	CLIP_WAIT_FOR_DATA_CLIP="Ni atendas %s sekundojn por ricevi datumojn por la klipo"
	CLIP_SEGMENT_SAVED_STRING="La segmentoj estas konservitaj laŭ la vojo: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Forigi %s"
	CLIP_FINISHED_CLIP_LOCATION="La preta klipo troviĝas ĉe: %s"
	CLIP_REMOVING_DATA_DIR="Forigado de klipdatuma dosierujo %s"

	RESTART_ALL_BUFFERS="Restartigi ĉiujn bufrojn "

	DELETE_DATA_FOR_STREAMER="Forigado de datuma dosierujo por %s"

	CHANGE_VARIABLE_TITLE="Ŝanĝi variablon:"
	CHANGE_VARIABLE_BACK="Reen"
	CHANGE_VARIABLE_INVITATION="%s Enigu novan valoron por la variablo %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Aldoni streameron %s"
	STREAMER_LIST_TITLE="Agordi aktivan streameron"

	ADD_STREAMER_MENU_INVITATION="%s Aldonu streameron ĉi tie %s"
	ADD_STREAMER_MENU_TITLE="Aldoni streameron:"

	CHECK_GLOBAL_CONFIG_ERROR="La tutmonda agorda dosiero ne estas valida. Ĉi tiu dosiero estos restarigita al la defaŭltaj agordoj."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variablo MERGE_ADJACENT_CLIPS povas esti nur 1 aŭ 0."
	CHECK_GLOBAL_CONFIG_ERROR_SAVE_CLIP_DATA="$CHECK_GLOBAL_CONFIG_ERROR La variablo SAVE_CLIP_DATA povas esti nur 1 aŭ 0."

	LANG_SETTINGS_STRING="Lingvo"

	HELP="
Uzo:
  script [OPTIONS]

Interfacaj opcioj:
  --ui-config PATH          Vojo al UI-agorda dosiero.
  --use-wofi                Uzi wofi kiel uzantinterfacon.
  --use-rofi                Uzi rofi kiel uzantinterfacon.
  --use-fzf                 Uzi fzf kiel uzantinterfacon.
                            Aŭtomate ebligas silentan protokolreĝimon kaj
                            adaptas la aranĝon de la UI.

Bufrokontrolo:
  --start-buffer            Starti la fluan bufroprocezon
                            (elŝutas la fluon en la bufron).

Streamero-opcioj:
  --streamer NAME           Agordi la kromnomon de la streamero por labori kun ĝi.

Kreado de klipo:
  --clip                    Krei klipon el la bufritaj segmentoj.
  --full-clip               Atendi pliajn estontajn segmentojn antaŭ krei la klipon.

Tempo-opcioj de klipo:
  --duration-back N         Nombro de segmentoj antaŭ la ekiga punkto.
  --duration-forward N      Nombro de segmentoj post la ekiga punkto.
  --segment-time N          Daŭro de ĉiu segmento en sekundoj.

Bufro-opcioj:
  --buffer-size N           Bufrograndeco en segmentoj.

Klipdatumaj opcioj:
  --save-clip-data          Konservi la segmentajn dosierojn uzitajn
                            por krei klipojn.

Labora dosierujo:
  --directory PATH          Dosierujo por fluaj fragmentoj kaj rezultaj klipoj.

Titolo-opcioj:
  --title TEXT              Titolo por la rezultanta klipo.

Lingvo:
  --lang CODE               Lingvo de la interfaco (ekzemplo: en, ru, es).

Kondutaj opcioj:
  --silence-log             Malŝalti protokolan eligon.
  --flip-pointers           Inversigi la dekoraciajn montrilojn kiuj indikas
                            la direkton de la eniga kampo en la UI.
  --invert-comments         Inversigi la ordon de komentlinioj en la UI.
  --eneble-online-check     Ebligi kontrolon ĉu la streamero estas enrete.

Argumenta analizo:
  --                        Transdoni la ceterajn argumentojn al la GUI-analizilo.
                            Se uzata denove poste, la argumentoj estos
                            denove analizitaj de la ĉefa skripto.

Helpo:
  -h, --help                Montri ĉi tiun helpmesaĝon kaj eliri.
	"
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
                print_help
                exit 0
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
    local sel="$(grap_menu "$full_menu" "$STREAMER_LIST_TITLE")"
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
$POINTER_BACK_EMOJI $CHANGE_VARIABLE_BACK
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
    printf "$DELETE_DATA_FOR_STREAMER" "$(realpath "$CLIPS/$streamer/$CLIPS_DATA_DIR")" >&2

    rm -rf "$(realpath "$CLIPS/$streamer/$CLIPS_DATA_DIR")"
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
			printf "$CLIP_REMOVE_CLIP_DATA_STRING\n" "$clip_data_dir"
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
	
	if ! [[ "$MERGE_ADJACENT_CLIPS" == "$TRUE" || "$SAVE_CLIP_DATA" == "$TRUE" ]]; then
		printf "$CLIP_REMOVING_DATA_DIR\n" "$clip_data_dir"
		rm -rf "$clip_data_dir"
	fi

	printf "$CLIP_FINISHED_CLIP_LOCATION\n" "$OUTFILE"
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
	local glogal_settings_submenu_title="$(printf "$GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE" "$SETTINGS_EMOJI")"
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
    
    local back="$POINTER_BACK_EMOJI $BACK_SETTINGS_STRING"
    local global_settings_comment="$(build_comment "$GLOBAL_SETTINGS_COMMENT")"
	local global_lang="$LANG_EMOJI $LANG_SETTINGS_STRING"


    local global_seg_time
    printf -v global_seg_time "$SEGMENT_TIME"

    if [[ ! "$streamer" == "$NONE_STREAMER" ]]; then
        if [[ ! -f "$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION" && ! "$streamer" == "$NONE_STREAMER" ]]; then
            init_local_config "$streamer"
        fi
        source "$CONFIG_FILES/$streamer$STREAMER_CONFIG_EXTENSION"
		local l_streamer_settings_submenu_title="$SETTINGS_EMOJI $(printf "$LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING" "$streamer")"
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
            change_variable_menu "BUFFER_SIZE" "$CONFIG_FILE" "$(build_comment "$BUFFER_SIZE_COMMENT")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$segment_time")
            change_variable_menu "SEGMENT_TIME" "$CONFIG_FILE" "$(build_comment "$SEGMENT_TIME_COMMENT")"
            [[ ! "$?" == "1" ]] && restart_all_buffers 
            ;;
        "$work_directory")
            change_variable_menu "WORK_DIRECTORY" "$CONFIG_FILE" "$(build_comment "$WORK_DIRECTORY_COMMENT")"
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
				change_local_variable_menu "BUFFER_SIZE" "$config_file" "$(build_comment "$BUFFER_SIZE_COMMENT")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_segment_time")
				change_local_variable_menu "SEGMENT_TIME" "$config_file" "$(build_comment "$SEGMENT_TIME_COMMENT")"
                [[ ! "$?" == "1" ]] && restart_buffer "$streamer"
                ;;
            "$l_work_directory")
				change_local_variable_menu "WORK_DIRECTORY" "$config_file" "$(build_comment "$WORK_DIRECTORY_COMMENT")"
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
