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

	LANG_SETTINGS_STRING="Language"
}

################################
# Russian
################################

local_russian() {
	DURATION_FORWARD_COMMENT="При использовании full-clip скрипт ожидает указанное количество новых сегментов.\nПри использовании clip это значение прибавляется к duration_back и сохраняет указанное количество сегментов, которые уже были созданы.\nЗначение должно быть целым числом."
	DURATION_BACK_COMMENT="Указывает, сколько сегментов назад по времени будет взято для создания клипа.\nЗначение должно быть целым числом."
	BUFFER_SIZE_COMMENT="Размер буфера в сегментах.\nЗначение должно быть целым числом."
	SEGMENT_TIME_COMMENT="Длительность сегмента в секундах.\n!ПРИ ИЗМЕНЕНИИ ЭТОЙ ПЕРЕМЕННОЙ ВСЕ БУФЕРЫ СТРИМОВ БУДУТ ПЕРЕЗАПУЩЕНЫ!\nЗначение должно быть целым числом."
	WORK_DIRECTORY_COMMENT="Каталог, в котором будут размещаться фрагменты стрима и итоговые клипы.\nЗначение должно быть целым числом."
	MERGE_ADJACENT_CLIPS_COMMENT="Ноль -- временные файлы (из которых состоят сегменты клипа) будут удалены.\nЕдиница -- временные файлы не будут удалены.\nЗначение должно быть целым числом."

	CANCEL="Отмена"
	CONFIRM_DELETE_DATA="ДА, УДАЛИТЬ ВСЕ ДАННЫЕ"
	LOCAL_CONFIRM_DELETE_DATA="Да, удалить данные для"
	GLOBAL_DELETE_DATA_COMMENT="Вы подтверждаете, что хотите\nудалить исходные данные ВСЕХ клипов?"
	LOCAL_DELETE_DATA_COMMENT="Вы подтверждаете, что\nудалили исходные данные всех клипов от %s?"

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
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Длительность = %s сегментов (%s сек)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Длительность назад = %s сегментов (%s сек)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Размер буфера = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Длительность сегмента = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Рабочая директория = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Объединять соседние клипы = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Удалить ВСЕ данные клипов"
	BACK_SETTINGS_STRING="Назад"
	GLOBAL_SETTINGS_COMMENT="Локальные переменные имеют более высокий приоритет\nи будут использоваться вместо глобальных, если они не пустые"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Настройки стримера (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="локальный Длительность назад = %s сегментов (%s сек)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="локальный Длительность вперёд = %s сегментов (%s сек)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="локальный Размер буфера = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="локальная Длительность сегмента = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="локальная Рабочая директория = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="локальное Объединение соседних клипов = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Удалить все данные клипов для %s"

	CLIP_CREATING_CLIP="Создание клипа..."
	CLIP_LAST_SEGMENT_FILE="Последний сегмент: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Сегменты ещё не были созданы"
	CLIP_WAIT_FOR_DATA_CLIP="Ожидание %s секунд для получения данных для клипа"
	CLIP_SEGMENT_SAVED_STRING="Сегменты сохранены по пути: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Удаление %s"
	CLIP_FINISHED_CLIP_LOCATION="Готовый клип находится по пути: %s"

	RESTART_ALL_BUFFERS="Перезапустить все буферы"

	DELETE_DATA_FOR_STREAMER="Удаление папки данных для %s"

	CHANGE_VARIABLE_TITLE="Изменить переменную:"
	CHANGE_VARIABLE_BACK="Назад"
	CHANGE_VARIABLE_INVITATION="%s Введите новое значение для переменной %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Добавить стримера %s"
	STREAMER_LIST_TITLE="Выберите активного стримера"

	ADD_STREAMER_MENU_INVITATION="%s Добавьте стримера здесь %s"
	ADD_STREAMER_MENU_TITLE="Добавить стримера:"

	CHECK_GLOBAL_CONFIG_ERROR="Файл глобальной конфигурации недействителен. Этот файл будет сброшен к настройкам по умолчанию."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Переменная MERGE_ADJACENT_CLIPS может быть только 1 или 0."
}

################################
# French
################################

local_french() {
	DURATION_FORWARD_COMMENT="Lors de l'utilisation de full-clip, le script attend le nombre indiqué de nouveaux segments.\nLors de l'utilisation de clip, cette valeur est ajoutée à duration_back et le nombre indiqué de segments déjà créés sera enregistré.\nLa valeur doit être un entier."
	DURATION_BACK_COMMENT="Indique combien de segments en arrière seront utilisés pour créer le clip.\nLa valeur doit être un entier."
	BUFFER_SIZE_COMMENT="Taille du tampon en segments.\nLa valeur doit être un entier."
	SEGMENT_TIME_COMMENT="Durée d'un segment en secondes.\n!LORSQUE VOUS MODIFIEZ CETTE VARIABLE, TOUS LES TAMPONS DE STREAM SERONT REDÉMARRÉS !\nLa valeur doit être un entier."
	WORK_DIRECTORY_COMMENT="Répertoire où seront enregistrés les fragments du stream et les clips générés.\nLa valeur doit être un entier."
	MERGE_ADJACENT_CLIPS_COMMENT="0 -- les fichiers temporaires (segments du clip) seront supprimés.\n1 -- les fichiers temporaires ne seront pas supprimés.\nLa valeur doit être un entier."

	CANCEL="Annuler"
	CONFIRM_DELETE_DATA="OUI, SUPPRIMER TOUTES LES DONNÉES"
	LOCAL_CONFIRM_DELETE_DATA="Oui, supprimer les données de"
	GLOBAL_DELETE_DATA_COMMENT="Confirmez-vous vouloir\nsupprimer les données originales de TOUS les clips ?"
	LOCAL_DELETE_DATA_COMMENT="Confirmez-vous avoir supprimé\nles données originales de tous les clips de %s ?"

	STOP_BUFFER_BUTTON="Arrêter le tampon"
	START_BUFFER_BUTTON="Démarrer le tampon"
	CLIP_BUTTON="Créer un clip"
	FULL_CLIP_BUTTON="Clip complet"
	REMOVE_STREAMER_BUTTON="Supprimer le streamer"
	SETTINGS_BUTTON="Paramètres"
	RELOAD_BUTTON="Recharger"
	EXIT_BUTTON="Quitter"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Sélectionner le streamer actif"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer actif → [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Paramètres globaux"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Durée vers l'avant = %s segments (%s s)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Durée vers l'arrière = %s segments (%s s)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Taille du tampon = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Durée du segment = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Répertoire de travail = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Fusionner les clips adjacents = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Supprimer TOUTES les données des clips"
	BACK_SETTINGS_STRING="Retour"
	GLOBAL_SETTINGS_COMMENT="Les variables locales ont priorité\nsur les variables globales si elles ne sont pas vides"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Paramètres du streamer (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="Durée locale vers l'avant = %s segments (%s s)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="Durée locale vers l'arrière = %s segments (%s s)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="Taille du tampon local = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="Durée locale du segment = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="Répertoire de travail local = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="Fusion locale des clips adjacents = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Supprimer toutes les données de clips pour %s"

	CLIP_CREATING_CLIP="Création du clip..."
	CLIP_LAST_SEGMENT_FILE="Dernier segment : %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Les segments ne sont pas encore disponibles"
	CLIP_WAIT_FOR_DATA_CLIP="Attente de %s secondes pour obtenir les données du clip"
	CLIP_SEGMENT_SAVED_STRING="Segments enregistrés dans : %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Suppression de %s"
	CLIP_FINISHED_CLIP_LOCATION="Clip enregistré dans : %s"

	RESTART_ALL_BUFFERS="Redémarrer tous les tampons"

	DELETE_DATA_FOR_STREAMER="Suppression du dossier de données pour %s"

	CHANGE_VARIABLE_TITLE="Modifier la variable :"
	CHANGE_VARIABLE_BACK="Retour"
	CHANGE_VARIABLE_INVITATION="%s Entrez une nouvelle valeur pour la variable %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Ajouter un streamer %s"
	STREAMER_LIST_TITLE="Définir le streamer actif"

	ADD_STREAMER_MENU_INVITATION="%s Ajouter un streamer ici %s"
	ADD_STREAMER_MENU_TITLE="Ajouter un streamer :"

	CHECK_GLOBAL_CONFIG_ERROR="Le fichier de configuration globale n'est pas valide. Il sera réinitialisé avec les paramètres par défaut."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS ne peut être que 0 ou 1."
}

################################
# Spanish
################################

local_spanish() {
	DURATION_FORWARD_COMMENT="Al usar full-clip, el script esperará el número indicado de segmentos nuevos.\nAl usar clip, este valor se suma a duration_back y se guardará el número indicado de segmentos ya creados.\nEl valor debe ser un número entero."
	DURATION_BACK_COMMENT="Indica cuántos segmentos hacia atrás se usarán para crear el clip.\nEl valor debe ser un número entero."
	BUFFER_SIZE_COMMENT="Tamaño del búfer en segmentos.\nEl valor debe ser un número entero."
	SEGMENT_TIME_COMMENT="Duración de cada segmento en segundos.\n¡AL CAMBIAR ESTA VARIABLE, TODOS LOS BÚFERES DE STREAM SE REINICIARÁN!\nEl valor debe ser un número entero."
	WORK_DIRECTORY_COMMENT="Directorio donde se guardarán los fragmentos del stream y los clips generados.\nEl valor debe ser un número entero."
	MERGE_ADJACENT_CLIPS_COMMENT="0 -- los archivos temporales (segmentos del clip) se eliminarán.\n1 -- los archivos temporales no se eliminarán.\nEl valor debe ser un número entero."

	CANCEL="Cancelar"
	CONFIRM_DELETE_DATA="SÍ, ELIMINAR TODOS LOS DATOS"
	LOCAL_CONFIRM_DELETE_DATA="Sí, eliminar datos de"
	GLOBAL_DELETE_DATA_COMMENT="¿Confirmas que deseas\neliminar los datos originales de TODOS los clips?"
	LOCAL_DELETE_DATA_COMMENT="¿Confirmas que has eliminado\nlos datos originales de todos los clips de %s?"

	STOP_BUFFER_BUTTON="Detener búfer"
	START_BUFFER_BUTTON="Iniciar búfer"
	CLIP_BUTTON="Crear clip"
	FULL_CLIP_BUTTON="Clip completo"
	REMOVE_STREAMER_BUTTON="Eliminar streamer"
	SETTINGS_BUTTON="Configuración"
	RELOAD_BUTTON="Recargar"
	EXIT_BUTTON="Salir"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Seleccionar streamer activo"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Streamer activo → [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Configuración global"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Duración hacia adelante = %s segmentos (%s s)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Duración hacia atrás = %s segmentos (%s s)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Tamaño del búfer = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Duración del segmento = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Directorio de trabajo = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Unir clips adyacentes = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Eliminar TODOS los datos de clips"
	BACK_SETTINGS_STRING="Atrás"
	GLOBAL_SETTINGS_COMMENT="Las variables locales tienen prioridad\nsobre las globales si no están vacías"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Configuración del streamer (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="Duración local hacia adelante = %s segmentos (%s s)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="Duración local hacia atrás = %s segmentos (%s s)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="Tamaño del búfer local = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="Duración local del segmento = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="Directorio de trabajo local = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="Unir clips adyacentes (local) = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Eliminar todos los datos de clips de %s"

	CLIP_CREATING_CLIP="Creando clip..."
	CLIP_LAST_SEGMENT_FILE="Último segmento: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Los segmentos aún no están disponibles"
	CLIP_WAIT_FOR_DATA_CLIP="Esperando %s segundos para obtener datos del clip"
	CLIP_SEGMENT_SAVED_STRING="Segmentos guardados en: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Eliminando %s"
	CLIP_FINISHED_CLIP_LOCATION="Clip guardado en: %s"

	RESTART_ALL_BUFFERS="Reiniciar todos los búferes"

	DELETE_DATA_FOR_STREAMER="Eliminando carpeta de datos de %s"

	CHANGE_VARIABLE_TITLE="Cambiar variable:"
	CHANGE_VARIABLE_BACK="Atrás"
	CHANGE_VARIABLE_INVITATION="%s Introduce un nuevo valor para la variable %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Añadir streamer %s"
	STREAMER_LIST_TITLE="Seleccionar streamer activo"

	ADD_STREAMER_MENU_INVITATION="%s Añadir streamer aquí %s"
	ADD_STREAMER_MENU_TITLE="Añadir streamer:"

	CHECK_GLOBAL_CONFIG_ERROR="El archivo de configuración global no es válido. Se restaurará a los valores predeterminados."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variable MERGE_ADJACENT_CLIPS solo puede ser 0 o 1."
}

################################
# German
################################

local_german() {
	DURATION_FORWARD_COMMENT="Bei Verwendung von full-clip wartet das Skript auf die angegebene Anzahl neuer Segmente.\nBei Verwendung von clip wird dieser Wert zu duration_back addiert und die angegebene Anzahl bereits erstellter Segmente gespeichert.\nDer Wert muss eine ganze Zahl sein."
	DURATION_BACK_COMMENT="Gibt an, wie viele Segmente in der Vergangenheit zur Erstellung des Clips verwendet werden.\nDer Wert muss eine ganze Zahl sein."
	BUFFER_SIZE_COMMENT="Größe des Puffers in Segmenten.\nDer Wert muss eine ganze Zahl sein."
	SEGMENT_TIME_COMMENT="Segmentdauer in Sekunden.\n!WENN SIE DIESE VARIABLE ÄNDERN, WERDEN ALLE STREAM-PUFFER NEU GESTARTET!\nDer Wert muss eine ganze Zahl sein."
	WORK_DIRECTORY_COMMENT="Verzeichnis, in dem die Stream-Fragmente und die fertigen Clips gespeichert werden.\nDer Wert muss eine ganze Zahl sein."
	MERGE_ADJACENT_CLIPS_COMMENT="0 -- temporäre Dateien (aus denen die Clip-Segmente bestehen) werden gelöscht.\n1 -- temporäre Dateien werden nicht gelöscht.\nDer Wert muss eine ganze Zahl sein."

	CANCEL="Abbrechen"
	CONFIRM_DELETE_DATA="JA, ALLE DATEN LÖSCHEN"
	LOCAL_CONFIRM_DELETE_DATA="Ja, Daten löschen für"
	GLOBAL_DELETE_DATA_COMMENT="Bestätigen Sie, dass Sie\ndie Originaldaten ALLER Clips löschen möchten?"
	LOCAL_DELETE_DATA_COMMENT="Bestätigen Sie, dass Sie\ndie Originaldaten aller Clips von %s gelöscht haben?"

	STOP_BUFFER_BUTTON="Puffer stoppen"
	START_BUFFER_BUTTON="Puffer starten"
	CLIP_BUTTON="Clip erstellen"
	FULL_CLIP_BUTTON="Vollständiger Clip"
	REMOVE_STREAMER_BUTTON="Streamer entfernen"
	SETTINGS_BUTTON="Einstellungen"
	RELOAD_BUTTON="Neu laden"
	EXIT_BUTTON="Beenden"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Aktiven Streamer auswählen"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Aktiver Streamer → [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Globale Einstellungen"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Dauer vorwärts = %s Segmente (%s s)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Dauer rückwärts = %s Segmente (%s s)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Puffergröße = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segmentdauer = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Arbeitsverzeichnis = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Benachbarte Clips zusammenführen = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="ALLE Clip-Daten löschen"
	BACK_SETTINGS_STRING="Zurück"
	GLOBAL_SETTINGS_COMMENT="Lokale Variablen haben eine höhere Priorität\nund werden anstelle globaler Variablen verwendet, wenn sie nicht leer sind"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Streamer-Einstellungen (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="Lokale Dauer vorwärts = %s Segmente (%s s)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="Lokale Dauer rückwärts = %s Segmente (%s s)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="Lokale Puffergröße = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="Lokale Segmentdauer = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="Lokales Arbeitsverzeichnis = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="Lokales Zusammenführen benachbarter Clips = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Alle Clip-Daten für %s löschen"

	CLIP_CREATING_CLIP="Clip wird erstellt..."
	CLIP_LAST_SEGMENT_FILE="Letztes Segment: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Die Segmente sind noch nicht verfügbar"
	CLIP_WAIT_FOR_DATA_CLIP="Warte %s Sekunden, um Daten für den Clip zu erhalten"
	CLIP_SEGMENT_SAVED_STRING="Segmente gespeichert unter: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Lösche %s"
	CLIP_FINISHED_CLIP_LOCATION="Fertiger Clip gespeichert unter: %s"

	RESTART_ALL_BUFFERS="Alle Puffer neu starten"

	DELETE_DATA_FOR_STREAMER="Datenordner für %s wird gelöscht"

	CHANGE_VARIABLE_TITLE="Variable ändern:"
	CHANGE_VARIABLE_BACK="Zurück"
	CHANGE_VARIABLE_INVITATION="%s Geben Sie einen neuen Wert für die Variable %s ein %s"

	STREAMER_LIST_ADD_STREAMER="%s Streamer hinzufügen %s"
	STREAMER_LIST_TITLE="Aktiven Streamer festlegen"

	ADD_STREAMER_MENU_INVITATION="%s Streamer hier hinzufügen %s"
	ADD_STREAMER_MENU_TITLE="Streamer hinzufügen:"

	CHECK_GLOBAL_CONFIG_ERROR="Die globale Konfigurationsdatei ist ungültig. Sie wird auf die Standardeinstellungen zurückgesetzt."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Die Variable MERGE_ADJACENT_CLIPS kann nur 0 oder 1 sein."
}

################################
# Chinese
################################

local_chinese() {
	DURATION_FORWARD_COMMENT="使用 full-clip 时，脚本会等待指定数量的新分段。\n使用 clip 时，该值会加到 duration_back，并保存指定数量的已创建分段。\n该值必须是整数。"
	DURATION_BACK_COMMENT="指定用于创建剪辑的过去分段数量。\n该值必须是整数。"
	BUFFER_SIZE_COMMENT="缓冲区大小（以分段计）。\n该值必须是整数。"
	SEGMENT_TIME_COMMENT="分段时长（秒）。\n!如果更改此变量，所有流缓冲区将重新启动！\n该值必须是整数。"
	WORK_DIRECTORY_COMMENT="用于存储流分段和生成剪辑的目录。\n该值必须是整数。"
	MERGE_ADJACENT_CLIPS_COMMENT="0 -- 删除临时文件（剪辑分段文件）。\n1 -- 不删除临时文件。\n该值必须是整数。"

	CANCEL="取消"
	CONFIRM_DELETE_DATA="是的，删除所有数据"
	LOCAL_CONFIRM_DELETE_DATA="是的，删除数据："
	GLOBAL_DELETE_DATA_COMMENT="确认删除\n所有剪辑的原始数据？"
	LOCAL_DELETE_DATA_COMMENT="确认您已删除\n%s 的所有剪辑原始数据？"

	STOP_BUFFER_BUTTON="停止缓冲"
	START_BUFFER_BUTTON="启动缓冲"
	CLIP_BUTTON="创建剪辑"
	FULL_CLIP_BUTTON="完整剪辑"
	REMOVE_STREAMER_BUTTON="移除主播"
	SETTINGS_BUTTON="设置"
	RELOAD_BUTTON="重新加载"
	EXIT_BUTTON="退出"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="选择活跃主播"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="当前主播 → [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="全局设置"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="前向时长 = %s 分段 (%s 秒)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="后向时长 = %s 分段 (%s 秒)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="缓冲区大小 = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="分段时长 = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="工作目录 = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="合并相邻剪辑 = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="删除所有剪辑数据"
	BACK_SETTINGS_STRING="返回"
	GLOBAL_SETTINGS_COMMENT="本地变量优先级更高\n如果存在则会覆盖全局变量"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="主播设置 (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="本地前向时长 = %s 分段 (%s 秒)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="本地后向时长 = %s 分段 (%s 秒)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="本地缓冲区大小 = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="本地分段时长 = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="本地工作目录 = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="本地合并相邻剪辑 = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="删除 %s 的所有剪辑数据"

	CLIP_CREATING_CLIP="正在创建剪辑..."
	CLIP_LAST_SEGMENT_FILE="最后分段: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="分段尚未生成"
	CLIP_WAIT_FOR_DATA_CLIP="等待 %s 秒以获取剪辑数据"
	CLIP_SEGMENT_SAVED_STRING="分段已保存至: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="删除 %s"
	CLIP_FINISHED_CLIP_LOCATION="剪辑已保存至: %s"

	RESTART_ALL_BUFFERS="重启所有缓冲区"

	DELETE_DATA_FOR_STREAMER="正在删除 %s 的数据目录"

	CHANGE_VARIABLE_TITLE="更改变量:"
	CHANGE_VARIABLE_BACK="返回"
	CHANGE_VARIABLE_INVITATION="%s 请输入变量 %s 的新值 %s"

	STREAMER_LIST_ADD_STREAMER="%s 添加主播 %s"
	STREAMER_LIST_TITLE="设置活跃主播"

	ADD_STREAMER_MENU_INVITATION="%s 在此添加主播 %s"
	ADD_STREAMER_MENU_TITLE="添加主播:"

	CHECK_GLOBAL_CONFIG_ERROR="全局配置文件无效，将重置为默认设置。"
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR 变量 MERGE_ADJACENT_CLIPS 只能为 0 或 1。"
}

################################
# Ukrainian
################################

local_ukrainian() {
	DURATION_FORWARD_COMMENT="При використанні full-clip скрипт чекатиме на вказану кількість нових сегментів.\nПри використанні clip це значення додається до duration_back, і буде збережено вказану кількість уже створених сегментів.\nЗначення має бути цілим числом."
	DURATION_BACK_COMMENT="Вказує кількість сегментів у минулому, які використовуються для створення кліпу.\nЗначення має бути цілим числом."
	BUFFER_SIZE_COMMENT="Розмір буфера в сегментах.\nЗначення має бути цілим числом."
	SEGMENT_TIME_COMMENT="Тривалість сегмента у секундах.\n!ЯКЩО ВИ ЗМІНИТЕ ЦЮ ЗМІННУ, ВСІ БУФЕРИ СТРІМІВ БУДУТЬ ПЕРЕЗАПУЩЕНІ!\nЗначення має бути цілим числом."
	WORK_DIRECTORY_COMMENT="Каталог, у якому зберігаються фрагменти стриму та готові кліпи.\nЗначення має бути цілим числом."
	MERGE_ADJACENT_CLIPS_COMMENT="0 -- тимчасові файли (з яких складаються сегменти кліпу) будуть видалені.\n1 -- тимчасові файли не будуть видалені.\nЗначення має бути цілим числом."

	CANCEL="Скасувати"
	CONFIRM_DELETE_DATA="ТАК, ВИДАЛИТИ ВСІ ДАНІ"
	LOCAL_CONFIRM_DELETE_DATA="Так, видалити дані для"
	GLOBAL_DELETE_DATA_COMMENT="Підтвердьте, що ви хочете\nвидалити вихідні дані ВСІХ кліпів?"
	LOCAL_DELETE_DATA_COMMENT="Підтвердьте, що ви видалили\nвихідні дані всіх кліпів для %s?"

	STOP_BUFFER_BUTTON="Зупинити буфер"
	START_BUFFER_BUTTON="Запустити буфер"
	CLIP_BUTTON="Створити кліп"
	FULL_CLIP_BUTTON="Повний кліп"
	REMOVE_STREAMER_BUTTON="Видалити стримера"
	SETTINGS_BUTTON="Налаштування"
	RELOAD_BUTTON="Перезавантажити"
	EXIT_BUTTON="Вийти"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Виберіть активного стримера"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Активний стример → [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Глобальні налаштування"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Тривалість вперед = %s сегментів (%s с)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Тривалість назад = %s сегментів (%s с)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Розмір буфера = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Тривалість сегмента = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Робочий каталог = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Об’єднувати сусідні кліпи = %s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Видалити ВСІ дані кліпів"
	BACK_SETTINGS_STRING="Назад"
	GLOBAL_SETTINGS_COMMENT="Локальні змінні мають вищий пріоритет\nі використовуються замість глобальних, якщо вони не порожні"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Налаштування стримера (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="Локальна тривалість вперед = %s сегментів (%s с)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="Локальна тривалість назад = %s сегментів (%s с)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="Локальний розмір буфера = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="Локальна тривалість сегмента = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="Локальний робочий каталог = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="Локальне об’єднання сусідніх кліпів = %s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Видалити всі дані кліпів для %s"

	CLIP_CREATING_CLIP="Створення кліпу..."
	CLIP_LAST_SEGMENT_FILE="Останній сегмент: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="Сегменти ще не створені"
	CLIP_WAIT_FOR_DATA_CLIP="Очікування %s секунд для отримання даних кліпу"
	CLIP_SEGMENT_SAVED_STRING="Сегменти збережено у: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Видалення %s"
	CLIP_FINISHED_CLIP_LOCATION="Готовий кліп збережено у: %s"

	RESTART_ALL_BUFFERS="Перезапустити всі буфери"

	DELETE_DATA_FOR_STREAMER="Видалення каталогу даних для %s"

	CHANGE_VARIABLE_TITLE="Змінити змінну:"
	CHANGE_VARIABLE_BACK="Назад"
	CHANGE_VARIABLE_INVITATION="%s Введіть нове значення змінної %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Додати стримера %s"
	STREAMER_LIST_TITLE="Встановити активного стримера"

	ADD_STREAMER_MENU_INVITATION="%s Додайте стримера тут %s"
	ADD_STREAMER_MENU_TITLE="Додати стримера:"

	CHECK_GLOBAL_CONFIG_ERROR="Глобальний файл конфігурації недійсний. Його буде скинуто до стандартних налаштувань."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR Змінна MERGE_ADJACENT_CLIPS може бути лише 0 або 1."
}

################################
# Esperanto
################################

local_esperanto() {
	DURATION_FORWARD_COMMENT="Kiam oni uzas full-clip, la skripto atendas la indikitan nombron da novaj segmentoj.\nKiam oni uzas clip, ĉi tiu valoro aldoniĝas al la valoro de duration_back kaj konservas la indikitan nombron da jam kreitaj segmentoj.\nLa valoro devas esti entjera nombro."
	DURATION_BACK_COMMENT="Indikas kiom da segmentoj reen en la tempo estos uzataj por krei la klipon.\nLa valoro devas esti entjera nombro."
	BUFFER_SIZE_COMMENT="La grandeco de la bufro en segmentoj.\nLa valoro devas esti entjera nombro."
	SEGMENT_TIME_COMMENT="Segmenta tempo en sekundoj.\n!KIAM VI ŜANĜAS ĈI TIUN VARIABLON, ĈIUJ BUFROJ DE LA FLUOJ ESTOS RESTARTIGITAJ!\nLa valoro devas esti entjera nombro."
	WORK_DIRECTORY_COMMENT="La dosierujo kie la fragmentoj de la fluo kaj la rezultaj klipoj estos konservataj.\nLa valoro devas esti entjera nombro."
	MERGE_ADJACENT_CLIPS_COMMENT="Nulo — provizoraj dosieroj (el kiuj konsistas la klipaj segmentoj) estos forigitaj.\nUnu — provizoraj dosieroj ne estos forigitaj.\nLa valoro devas esti entjera nombro."
	SAVE_CLIP_DATA_COMMENT="Se ĉi tiu opcio estas ŝaltita, la segmentoj uzataj por krei klipojn estos konservataj.\nSe ĝi estas malŝaltita, tiuj provizoraj datumoj estos forigitaj post la kreado de la klipo.\nSe la kunigo de apudaj klipoj estas ŝaltita, ĉi tiu opcio ĉiam estas konsiderata ŝaltita.\nLa valoro povas esti nur nulo aŭ unu."

	CANCEL="Nuligi"
	CONFIRM_DELETE_DATA="JES, FORIGI ĈIUJN DATUMOJN"
	LOCAL_CONFIRM_DELETE_DATA="Jes, forigi datumojn por %s"
	GLOBAL_DELETE_DATA_COMMENT="Ĉu vi konfirmas, ke vi\nforigos la originajn datumojn de ĈIUJ klipoj?"
	LOCAL_DELETE_DATA_COMMENT="Ĉu vi konfirmas, ke vi\nforigis la originajn datumojn de ĉiuj klipoj de %s?"

	STOP_BUFFER_BUTTON="Haltigi bufron"
	START_BUFFER_BUTTON="Startigi bufron"
	CLIP_BUTTON="Klipo"
	FULL_CLIP_BUTTON="Plena klipo"
	REMOVE_STREAMER_BUTTON="Forigi streamiston"
	SETTINGS_BUTTON="Agordoj"
	RELOAD_BUTTON="Reŝargi"
	EXIT_BUTTON="Eliri"
	ACTIVE_STREAMER_STRING_WHERE_NONE_STREAMER="Elekti aktivan streamiston"
	ACTIVE_STREAMER_STRING_WHERE_STREAMER_NOT_NONE="Aktiva streamisto => [%s]"

	GLOBAL_SETTINGS_SUBMENU_SUBMENU_TITLE="Tutmondaj agordoj"
	GLOBAL_DURATION_FORWARD_SETTINGS_STRING="Daŭro antaŭen = %s segmentoj (%s sek)"
	GLOBAL_DURATION_BACK_SETTINGS_STRING="Daŭro reen = %s segmentoj (%s sek)"
	GLOBAL_BUFFER_SIZE_SETTINGS_STRING="Bufra grandeco = %s"
	GLOBAL_SEGMENT_TIME_SETTINGS_STRING="Segmenta tempo = %s"
	GLOBAL_WORK_DIRECTORY_SETTINGS_STRING="Labora dosierujo = %s"
	GLOBAL_MERGE_CLIPS_SETTINGS_STRING="Kunigi apudajn klipojn = %s"
	GLOBAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sKonservi datumojn de klipaj segmentoj = %s%s"
	GLOBAL_DELETE_DATA_SETTINGS_STRING="Forigi ĈIUJN klipajn datumojn"
	BACK_SETTINGS_STRING="Reen"
	GLOBAL_SETTINGS_COMMENT="Lokaj variabloj havas pli altan prioritaton\nkaj estos uzataj anstataŭ la tutmondaj se ili ne estas malplenaj"

	LOCAL_STREAMER_SUBMENU_TITLE_SETTINGS_STRING="Agordoj de streamisto (%s)"
	LOCAL_DURATION_BACK_SETTINGS_STRING="loka Daŭro antaŭen = %s segmentoj (%s sek)"
	LOCAL_DURATION_FORWARD_SETTINGS_STRING="loka Daŭro reen = %s segmentoj (%s sek)"
	LOCAL_BUFFER_SIZE_SETTINGS_STRING="loka Bufra grandeco = %s"
	LOCAL_SEGMENT_TIME_SETTINGS_STRING="loka Segmenta tempo = %s"
	LOCAL_WORK_DIRECTORY_SETTINGS_STRING="loka Labora dosierujo = %s"
	LOCAL_MERGE_ADJACENT_CLIPS_SETTINGS_STRING="loka Kunigi apudajn klipojn = %s"
	LOCAL_SAVE_CLIP_DATA_SETTINGS_STRING="%sKonservi datumojn de klipaj segmentoj = %s%s"
	LOCAL_DELETE_DATA_CLIPS_SETTINGS_STRING="Forigi ĉiujn klipajn datumojn por %s"

	CLIP_CREATING_CLIP="Kreado de klipo..."
	CLIP_LAST_SEGMENT_FILE="La lasta segmento: %s"
	CLIP_SEGMENTS_NOT_BEEN_CREATED="La segmentoj ankoraŭ ne estis kreitaj"
	CLIP_WAIT_FOR_DATA_CLIP="Ni atendas %s sekundojn por ricevi datumojn por la klipo"
	CLIP_SEGMENT_SAVED_STRING="La segmentoj estas konservitaj laŭ la vojo: %s"
	CLIP_REMOVE_CLIP_DATA_STRING="Forigi %s"
	CLIP_FINISHED_CLIP_LOCATION="La preta klipo troviĝas ĉe: %s"
	CLIP_REMOVING_DATA_DIR="Forigante %s klipan datuman dosierujon"

	RESTART_ALL_BUFFERS="Restartigi ĉiujn bufrojn"

	DELETE_DATA_FOR_STREAMER="Forigante datuman dosierujon por %s"

	CHANGE_VARIABLE_TITLE="Ŝanĝi variablon:"
	CHANGE_VARIABLE_BACK="Reen"
	CHANGE_VARIABLE_INVITATION="%s Enigu novan valoron por la variablo %s %s"

	STREAMER_LIST_ADD_STREAMER="%s Aldoni streamiston %s"
	STREAMER_LIST_TITLE="Agordi aktivan streamiston"

	ADD_STREAMER_MENU_INVITATION="%s Aldoni streamiston ĉi tie %s"
	ADD_STREAMER_MENU_TITLE="Aldoni streamiston:"

	CHECK_GLOBAL_CONFIG_ERROR="La tutmonda agorda dosiero ne estas valida. Ĉi tiu dosiero estos restarigita al la defaŭltaj agordoj."
	CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS="$CHECK_GLOBAL_CONFIG_ERROR La variablo MERGE_ADJACENT_CLIPS povas esti nur 1 aŭ 0."

	LANG_SETTINGS_STRING="Lingvo"
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

localize "$DEFAULT_LANG"
if [[ -z "$L_LANG" && -z "$LOCALE_LANG" ]]; then 
	lang="$(locale_code_to_self_name_converter "$LANG")"
elif ! [[ -z "$L_LANG" ]]; then
	lang="$(locale_code_to_self_name_converter "$L_LANG")"
elif ! [[ -z "$LOCALE_LANG" ]]; then
	lang="$LOCALE_LANG"
fi
localize "$lang"


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
        ehse
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
    fi
    if ! [[ "$MERGE_ADJACENT_CLIPS" == "1" || "$MERGE_ADJACENT_CLIPS" == "0" ]]; then
        init_global_config;
        echo "$CHECK_GLOBAL_CONFIG_ERROR_MERGE_ADJACENT_CLIPS" >&2;
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
	load_all_config_for_streamer "$CURRENT_STREAMER"
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

clip() {
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
$merge_adjacent_clips
$save_clip_data
$delete_data_clips
$global_lang
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
$l_save_clip_data
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
