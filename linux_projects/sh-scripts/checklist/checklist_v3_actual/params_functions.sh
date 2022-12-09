#===============================================================================#
MainDirPath=/home/izuna/info/files
ErrFile=$MainDirPath/exit_info.log
yml=$MainDirPath/pid_vid.yml

NAME=$(hostname)
MANUFACTURER=$(sudo dmidecode -t chassis | grep 'Manufacturer' | awk '{print $2" "$3" "$4" "$5" "$6}')
MARKMODEL=$(sudo dmidecode -t System | grep -i "Product" | sed s/X//g | awk '{print $3}' )
SERIALNUMBER=$(sudo dmidecode -t System | grep -i "Serial Number" | awk '{print $3}')

BITLOCKERINFO=$(blkid | grep -i -e 'TYPE='| awk '{print $4}' | sed -r 's/TYPE=//g' | sed -r 's/"//g')
RAM=$(free -h | awk '/^Mem/ {print $2 }' | sed -r 's/Gi/GB/g')

DISKSIZE=$(df -h / | awk '/dev/ {print $2}' | sort -du | sed -r 's/G/GB/g')
DISKUSEDSIZE=$(df -h / | awk '/dev/ {print $3}' | sort  -du | sed -r 's/G/GB/g')
DISKFREESIZE=$(df -h / | awk '/dev/ {print $4}' | sort  -du | sed -r 's/G/GB/g')
DISKPERCENTUSEDSIZE=$(df -h / | awk '/dev/ {print $5}' | sort  -du | sed -r 's/G/GB/g')
DISKS_BY_NAMES=$(lsblk -s | awk '/disk/' | sed -s 's/└─//g' | awk '{print $1}' | uniq)
COUNT_SYSTEM_DISKS=$(lsblk -s | awk '/disk/' | sed -s 's/└─//g' | awk '{print $1}' | uniq | wc -l)

WIFICHECK=$(lspci | egrep -i 'wifi|wlan|wireless')
BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}')

OSVERSION=$(cat /etc/os-release | grep -i 'VERSION_ID' | sed -s 's/=/ /' | sed -s 's/"//g' | awk '{print $2}' | sed s/v//g)
OSINSTALLDATE=$(stat -c %w /)
DATETIME=$(date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-")
SIZE="--width=750 --height=550"

#get info for each system disk cycle
if [ $COUNT_SYSTEM_DISKS -ge 1 ]; then
    for item in $DISKS_BY_NAMES
    do
        case $item in
            *nv*)
                DISKTYPE="SSD" ;;
            *sd*)
                DISKTYPE_ADDITIONAL="HDD" ;;
        esac
    done
fi

FSTAB_INFO=$(cat /etc/fstab | awk '{print $2}' | uniq)
for item in $FSTAB_INFO
do
  FSTAB_GREP=$(df -h | grep -i '$item')
done

if [[ $FSTAB_GREP == " " ]]; then
 echo "empty"
 exit 1;
else
 d_size=$(df -h | egrep -i "$item" | awk '/dev/ {print $2}')
 d_used_size=$(df -h | egrep -i "$item" | awk '/dev/ {print $3}' | sort  -du | sed -r 's/G/GB/g')
 d_free_size=$(df -h  | egrep -i "$item" | awk '/dev/ {print $4}' | sort  -du | sed -r 's/G/GB/g')
 d_percent_size=$(df -h | egrep -i "$item" | awk '/dev/ {print $5}' | sort  -du | sed -r 's/G/GB/g')
fi


if [[ $BITLOCKERINFO == "*crypto*" ]]; then
    BITLOCKER="Enabled"
else
    BITLOCKER="Disabled"
fi

#===============================================================================#
get-date(){
    date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-"
}
#===============================================================================#
write-log(){
    echo "$@" | tee -a $LogFile > /dev/null 2>&1
}
#===============================================================================#
write-error(){
    echo "[$(get-date)]: $@"| tee -a $ErrFile > /dev/null 2>&1
}
#===============================================================================#
__get_bios(){
    __thinclient(){
        case $WIFICHECK in
            "")
                MAC=$(cat /sys/class/net/e*/address)
                WIFI="TRUE"
                resultwifi="$WIFI Wi-Fi Отключен" ;;
            *)
                WIFI="FALSE"
                zenity --error --text="Необходимо отключить Wi-Fi модуль в BIOS и перезапустить чек-лист!" --ellipsize
                write-error "[Wi-Fi Error]. Exit code is: $EXIT_WIFI"
                exit $EXIT_WIFI ;;
        esac
        case $BLUETOOTHCHECK in
            "(dead)")
                BLUETOOTH="TRUE"
                resultblth="$BLUETOOTH Bluetooth Отключен" ;;
            "(running)")
                BLUETOOTH="FALSE"
                zenity --error --text="Необходимо отключить Bluetooth модуль в BIOS и перезапустить чек-лист!" --ellipsize
                write-error "[Bluetooth Error]. Exit code is: $EXIT_BLUETOOTH"
                exit $EXIT_BLUETOOTH ;;
            *)
                BLUETOOTH="FALSE"
                zenity --error --text="Необходимо отключить Bluetooth модуль в BIOS и перезапустить чек-лист!" --ellipsize
                write-error "[Bluetooth Error]. Exit code is: $EXIT_BLUETOOTH"
                exit $EXIT_BLUETOOTH ;;
        esac
    }
    __dev(){
        if [[ ! -z "$WIFICHECK" ]]; then
                WIFI="Enabled"
                MAC=$(cat /sys/class/net/w*/address)
        elif [[ -z "$WIFICHECK" ]]; then
                WIFI="Disabled"
                MAC=$(cat /sys/class/net/e*/address)
        else
                WIFI="Unknown Status"
        fi
    case $BLUETOOTHCHECK in
        "(running)")
            BLUETOOTH="Enabled" ;;
        "(dead)")
            BLUETOOTH="Disabled" ;;
        *)
            BLUETOOTH="Unknown Status" ;;
    esac
    }
}
#===============================================================================#
__checklist_dev(){
    rm -r $ErrFile > /dev/null 2>&1
    write-error "================================================="
    __get_bios && __dev
    local SIZE="--width=750 --height=550"
    PRIMARYINFO=$(zenity --forms --title="Информация о работах" --width=400 --height=150 \
                --text="Заполните следующие поля" \
                --separator="," \
                --add-entry="Ф.И.О. инженера" \
                --add-entry="Номер ЗНО (не ID запроса)")
    FIO=$(echo $PRIMARYINFO | awk -F ',' '{print $1}')
    ZNO=$(echo $PRIMARYINFO | awk -F ',' '{print $2}')

    numbers=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
    numbers_output=$(echo "${numbers[*]}")

    for number in $numbers_output
        do
            if [[ "$FIO" == *"$number"* ]]; then
                exit $EXIT_DIGITS_IN_FIO
            fi
        done

    letters=('a' 'b' 'c' 'd' 'f' 'g' 'h' 'j' 'k' 'l' 'm' 'n' 'p' 'q' 'r' 's' 't' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'А' 'а' 'Б' 'б' 'В' 'в' 'Г' 'г' 'Д' 'д' 'Е' 'е' 'Ё' 'ё' 'Ж' 'ж' 'З' 'з' 'И' 'и' 'Й' 'й' 'К' 'к' 'Л' 'л' 'М' 'м' 'Н' 'н' 'О' 'о' 'П' 'п' 'С' 'с' 'Т' 'т' 'У' 'у' 'Ф' 'ф' 'Х' 'х' 'Ц' 'ц' 'Ч' 'ч' 'Ш' 'ш' 'Щ' 'щ' 'Ъ' 'ъ' 'Ы' 'ы' 'Ь' 'ь' 'Э' 'э' 'Ю' 'ю' 'Я' 'я')
    letters_output=$(echo "${letters[*]}")

    for letter in $letters_output
        do
            if [[ "$ZNO" == *"$letter"* ]]; then
                exit $EXIT_LETTERS_IN_ZNO
            fi
        done

    case $FIO in
        "")
            zenity --error --text "Поле ФИО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac
    case $ZNO in
        "")
            zenity --error --text "Поле ЗНО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac

    zenity --list --title="Чек-лист Linux СБС" $SIZE --text="Информация" --column="Параметр" --column="Результат" \
        "Инженер проводивший работы" "$FIO" \
        "Номер запроса по которому проводились работы" "$ZNO" \
        "Имя АРМ" "$NAME" \
        "MAC Адрес" "$MAC" \
        "WiFi" "$WIFI" \
        "Bluetooth" "$BLUETOOTH" \
        "Изготовитель" "$MANUFACTURER" \
        "Модель и марка АРМ" "$MARKMODEL" \
        "Серийный номер" "$SERIALNUMBER" \
        "Bitlocker" "$BITLOCKER" \
        "Размер ОЗУ" "$RAM" \
        "Тип жеского диска" "$DISKTYPE" \
        "Тип дополнительного жеского диска" "$DISKTYPE_ADDITIONAL" \
        "Жесткий диск объем\свободно\%" "$DISKSIZE \ $DISKFREESIZE\ $DISKPERCENTUSEDSIZE" \
        "Версия образа ОС" "$OSVERSION" \
        "Время последней заливки ОС" "$OSINSTALLDATE" \
        --ok-label="Получить QR-код" \
        --cancel-label="Выход"

    case $? in
        0)
            __qr-generation
            __write-json ;;
        1)
            zenity --info --text="Вы отменили чек-лист. Данные не сохранены." --ellipsize
            write-error "[Exit By Hands Error]. Exit code is: $EXIT_BY_HANDS"
            exit $EXIT_BY_HANDS ;;
    esac
}
#===============================================================================#
__checklist_thinclient_ms(){
    rm -r $ErrFile > /dev/null 2>&1
    write-error "================================================="
    __get_bios && __thinclient
    local SIZE="--width=750 --height=500"
    PRIMARYINFO=$(zenity --forms --title="Информация о работах" --width=400 --height=150 \
                    --text="Заполните следующие поля" \
                    --separator="," \
                    --add-entry="Ф.И.О. инженера" \
                    --add-entry="Номер ЗНО (не ID запроса)")
    FIO=$(echo $PRIMARYINFO | awk -F ',' '{print $1}')
    ZNO=$(echo $PRIMARYINFO | awk -F ',' '{print $2}')

    numbers=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
    numbers_output=$(echo "${numbers[*]}")

    for number in $numbers_output
        do
            if [[ "$FIO" == *"$number"* ]]; then
                exit $EXIT_DIGITS_IN_FIO
            fi
        done

    letters=('a' 'b' 'c' 'd' 'f' 'g' 'h' 'j' 'k' 'l' 'm' 'n' 'p' 'q' 'r' 's' 't' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'А' 'а' 'Б' 'б' 'В' 'в' 'Г' 'г' 'Д' 'д' 'Е' 'е' 'Ё' 'ё' 'Ж' 'ж' 'З' 'з' 'И' 'и' 'Й' 'й' 'К' 'к' 'Л' 'л' 'М' 'м' 'Н' 'н' 'О' 'о' 'П' 'п' 'С' 'с' 'Т' 'т' 'У' 'у' 'Ф' 'ф' 'Х' 'х' 'Ц' 'ц' 'Ч' 'ч' 'Ш' 'ш' 'Щ' 'щ' 'Ъ' 'ъ' 'Ы' 'ы' 'Ь' 'ь' 'Э' 'э' 'Ю' 'ю' 'Я' 'я')
    letters_output=$(echo "${letters[*]}")

    for letter in $letters_output
        do
            if [[ "$ZNO" == *"$letter"* ]]; then
                exit $EXIT_LETTERS_IN_ZNO
            fi
        done

    case $FIO in
        "")
            zenity --error --text "Поле ФИО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac
    case $ZNO in
        "")
            zenity --error --text "Поле ЗНО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac

        zenity --list --title="Чек-лист Linux СБС" $SIZE --text="Информация" --column="Параметр" --column="Результат" \
        "Инженер проводивший работы" "$FIO" \
        "Номер запроса по которому проводились работы" "$ZNO" \
        "Имя АРМ" "$NAME" \
        "MAC Адрес" "$MAC" \
        "WiFi" "$WIFI" \
        "Bluetooth" "$BLUETOOTH" \
        "Изготовитель" "$MANUFACTURER" \
        "Модель и марка АРМ" "$MARKMODEL" \
        "Серийный номер" "$SERIALNUMBER" \
        "Bitlocker" "$BITLOCKER" \
        "Размер ОЗУ" "$RAM" \
        "Тип жеского диска" "$DISKTYPE" \
        "Жесткий диск объем\свободно\%" "$DISKSIZE \ $DISKFREESIZE\ $DISKPERCENTUSEDSIZE" \
        "Версия образа ОС" "$OSVERSION" \
        "Время последней заливки ОС" "$OSINSTALLDATE" \
        --ok-label="Получить QR-код" \
        --cancel-label="Выход"

    case $? in
        0)
            __qr-generation ;;
        1)
            zenity --info --text="Вы отменили чек-лист. Данные не сохранены." --ellipsize
            write-error "[Exit By Hands Error]. Exit code is: $EXIT_BY_HANDS"
            exit $EXIT_BY_HANDS ;;
    esac
}
#===============================================================================#
__checklist_thinclient_vsp(){
    LogFile=$MainDirPath/checklist.log
    CheckFile=$MainDirPath/check_sbs
    rm -r $LogFile $ErrFile > /dev/null 2>&1
    write-error "================================================="
    __get_bios && __thinclient
    local SIZE="--width=700 --height=500"

    zenity --info --text="Для настройки рабочего места необходимо воспользоваться инструкцией расположенной на WiKi СБС." --width 700 --height 150

    if [ $? -eq 0 ]; then
        PRIMARYINFO=$(zenity --forms --title="Информация о работах" --width=400 --height=150 \
                --text="Заполните следующие поля" \
                --separator="," \
                --add-entry="Ф.И.О. инженера проводившего работы" \
                --add-entry="Номер ЗНО (не ID запроса)")
    FIO=$(echo $PRIMARYINFO | awk -F ',' '{print $1}')
    ZNO=$(echo $PRIMARYINFO | awk -F ',' '{print $2}')

    numbers=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
    numbers_output=$(echo "${numbers[*]}")

    for number in $numbers_output
        do
            if [[ "$FIO" == *"$number"* ]]; then
                exit $EXIT_DIGITS_IN_FIO
            fi
        done

    letters=('a' 'b' 'c' 'd' 'f' 'g' 'h' 'j' 'k' 'l' 'm' 'n' 'p' 'q' 'r' 's' 't' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'А' 'а' 'Б' 'б' 'В' 'в' 'Г' 'г' 'Д' 'д' 'Е' 'е' 'Ё' 'ё' 'Ж' 'ж' 'З' 'з' 'И' 'и' 'Й' 'й' 'К' 'к' 'Л' 'л' 'М' 'м' 'Н' 'н' 'О' 'о' 'П' 'п' 'С' 'с' 'Т' 'т' 'У' 'у' 'Ф' 'ф' 'Х' 'х' 'Ц' 'ц' 'Ч' 'ч' 'Ш' 'ш' 'Щ' 'щ' 'Ъ' 'ъ' 'Ы' 'ы' 'Ь' 'ь' 'Э' 'э' 'Ю' 'ю' 'Я' 'я')
    letters_output=$(echo "${letters[*]}")

    for letter in $letters_output
        do
            if [[ "$ZNO" == *"$letter"* ]]; then
                exit $EXIT_LETTERS_IN_ZNO
            fi
        done

    case $FIO in
        "")
            zenity --error --text "Поле ФИО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac
    case $ZNO in
        "")
            zenity --error --text "Поле ЗНО не может быть пустым! Необходимо заполнить все поля!" --ellipsize
            rm -r $JSON > /dev/null 2>&1
            write-error "[Empty Fields Error]. Exit code is: $EXIT_EMPTY_FIELDS"
            exit $EXIT_EMPTY_FIELDS ;;
    esac

    elif [ $? -eq 1 ]; then
        zenity --warning --text "Вы отменили чек-лист. Данные не сохранены" --width 350 --height 150
        write-error "[Exit By Hands Error]. Exit code is: $EXIT_BY_HANDS"
        exit $EXIT_BY_HANDS;
    fi
####----Get equipment-----####
    lsv=$(lsusb -v | grep -i 'idVendor' | awk '{print $2}')
    lsp=$(lsusb -v | grep -i 'idProduct' | awk '{print $2}')
#===============================================================================                                                                                                                                                             #
#massive check ls (YAML)
    posL=
    bpL=
    webcL=
    YML_GREP_V=$(cat $yml | grep -i "$lsv" | awk -F ':' '{print $2}' | sed -r 's/ //g' | sed -r 's/"//g')
    YML_GREP_P=$(cat $yml | grep -i "$lsp" | awk -F ':' '{print $2}' | sed -r 's/ //g' | sed -r 's/"//g')
    for item in $YML_GREP_V
        do
            ITEM_GREP_V=$(cat $yml | grep "$item" | awk -F ':' '{print $2}' | sed -r 's/"//g' | sed -r 's/ //g')
            EQUIPMENT_NAME=$(cat $yml| grep "$ITEM_GREP_V" | awk -F ':' '{print $1}' | sed -r 's/"//g' | sed -r 's/ //g')

            case $EQUIPMENT_NAME in
                *All*|*Infocr*)
                    tmname="$EQUIPMENT_NAME"
                    tmL="TRUE" ;;
                *Mertech|*NewL*|*Data*|*HoneyW*|*Zebr*|*Motor*)
                            brcdname="$EQUIPMENT_NAME"
                            brcdL="TRUE" ;;
                *Veri*|*PAX*|*Ingenico*)
                            posname="$EQUIPMENT_NAME"
                            pos="TRUE" ;;
                *)
                    exit 1 ;;
            esac
        done
    for item in $YML_GREP_P
        do
            ITEM_GREP_P=$(cat $yml | grep "$item" | awk -F ':' '{print $2}' | sed -r 's/"//g' | sed -r 's/ //g')
            WEBCAM_EQUIPMENT_NAME=$(cat $yml | grep "$ITEM_GREP_P" | awk -F ':' '{print $1}' | sed -r 's/"//g' | sed -r 's/ //g')
            case $WEBCAM_EQUIPMENT_NAME in
                    *A4TECH*)
                        webcname="A4TECH"
                        webcL="TRUE" ;;
                    *Logitech*)
                            webcname="Logitech"
                            webcL="TRUE" ;;
                    *Microsoft*)
                            webcname="Microsoft"
                            webcL="TRUE" ;;
                    *Genius*)
                            webcname="Genius"
                            webcL="TRUE" ;;
                    *KREZ*)
                            webcname="KREZ"
                            webcL="TRUE";;
                    *CanyonCNE*)
                            webcname="Canyon"
                            webcL="TRUE" ;;
                    *Aveo*)
                            webcname="Aveo"
                            webcL="TRUE" ;;
                    *CBR*)
                            webcname="CBR"
                            webcL="TRUE" ;;
                    *Arkmicro*)
                            webcname="Arkmicro"
                            webcL="TRUE" ;;
                    *Microdia*)
                            webcname="Microdia"
                            webcL="TRUE" ;;
                    *Defender*)
                            webcname="Defender"
                            webcL="TRUE" ;;
                    *HP*)
                            webcname="HP"
                            webcL="TRUE" ;;
                    *Suyin*)
                            webcname="Suyin"
                            webcL="TRUE" ;;
                    *D-LINK*)
                            webcname="D-LINK"
                            webcL="TRUE" ;;
                    *Creative*)
                            webcname="Creative"
                            webcL="TRUE" ;;
                    *Realtek*)
                            webcname="Realtek"
                            webcL="TRUE" ;;
            esac
    done

if [[ $posL != "TRUE" ]]; then
        posL="FALSE"
        posname="Неизвестно"
fi
if [[ $tmL != "TRUE" ]]; then
        tmL="FALSE"
        tmname="Неизвестно"
fi
if [[ $webcL != "TRUE" ]]; then
        webcL="FALSE"
        webcname="Неизвестно"
fi

#MFU
    case $mfunames in
        Lexma)
            mfuname='Lexmark'
            mfuL=TRUE ;;
        Xerox)
            mfuname='Xerox'
            mfuL=TRUE ;;
        *)
            mfuL=FALSE
            mfuname='Неизвестно' ;;
    esac

#BP
    if [[ $bpls == '///dev/null' ]]; then
        bpL=TRUE
        bpname='EPSON'
    elif [[ $bplsO == 'usb://EPSON/TM-P2.01' ]]; then
        bpL=TRUE
        bpname='EPSON'
    elif [[ $bplsO == 'usb://Unknown/Printer' ]]; then
        bpL=TRUE
        bpname='Olivetty'
    else
        bpL=FALSE
        bpname='Неизвестно'
    fi


####----CHEKS----####
#TM
    case $tmL in
        TRUE)
            resulttm="$tmL TM $tmname" ;;
        *)
            resulttm="$tmL TM $tmname" ;;
    esac

#MFU
    case $mfuL in
        TRUE)
            resultmfu="$mfuL МФУ $mfuname" ;;
        *)
            resultmfu="$mfuL МФУ $mfuname" ;;
    esac

#WEB-CAM
    case $webcL in
        TRUE)
            resultwebcam="$webcL Web-камера $webcname" ;;
        *)
            resultwebcam="$webcL Web-камера $webcname" ;;
    esac

#TERM TYPE
    TYPETERM=$(zenity --width=500 --height=240 --list --radiolist \
        --title="Выберите модель терминала" \
        --column="" --column="Модель терминала" \
        "", "SmartPos" \
        "", "Не SmartPos")

#SmartPos
    if [[ $TYPETERM == 'SmartPos' ]]; then
        resultbp="FALSE БанковскийПринтер SmartPos"
        resultbrcd="FALSE СШК SmartPos"
        resultpos="FALSE POS SmartPos"

#VeriFone
    elif [[ $TYPETERM == 'Не SmartPos' ]]; then

    case $posL in
        TRUE)
            resultpos="$posL POS $posname" ;;
        *)
            resultpos="$posL POS $posname" ;;
    esac

    case $bpL in
        TRUE)
            resultbp="$bpL БанковскийПринтер $bpname" ;;
        *)
            resultbp="$bpL БанковскийПринтер $bpname" ;;
    esac
    case $brcdL in
        TRUE)
            resultbrcd="$brcdL СШК $brcdname" ;;
        *)
            resultbrcd="$brcdL СШК $brcdname" ;;
    esac
    elif [ $? -eq 1 ]; then
        zenity --warning --text "Вы отменили чек-лист. Данные не сохранены" --width 350 --height 150
        rm -r $LogFile > /dev/null 2>&1
        write-error "[Exit By Hands Error]. Exit code is: $EXIT_BY_HANDS"
        exit $EXIT_BY_HANDS;
    fi
####----Start----####
    list=$(zenity --list --checklist $SIZE \
        --title="Чек-лист СБС ТК Linux ВСП" --ok-label="Записать и получить QR-код" --cancel-label="Выход" \
        --separator '\n' \
        --text="Проверка оборудования" \
        --column="Настроено" \
        --column="Оборудование" \
        --column="Значение" \
        $resultwifi \
        $resultblth \
        $resultbrcd\
        $resulttm \
        $resultmfu \
        $resultbp \
        $resultpos \
        $resultwebcam)

    if [ $? -eq 1 ]; then
        zenity --info --text "Выход. Отмена записи данных."  --width 500 --height 150
        rm -r $LogFile > /dev/null 2>&1
        write-error "[Exit By Hands Error]. Exit code is: $EXIT_BY_HANDS"
        exit $EXIT_BY_HANDS;
    fi

    zenity --question --text "Вы подтверждаете, что настройки произведены согласно памятки СБС по настройке ТК Linux? \n$list" --ok-label="Подтверждаю" --cancel-label="Перезапустить чек-лист" --width 700 --height 200
    if [ $? -eq 0 ]; then
        write-log "FIO: $FIO"
        write-log "ZNO: $ZNO"
        write-log "Date: $DATETIME"
    #wifi
    if [[ $wifiL != 'TRUE' && $list != *Wi-Fi* ]] ; then
        write-log "WiFi: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $wifiL = 'TRUE' && $list = *Wi-Fi* ]]; then
        write-log "WiFi: 1" #настроено автоматом
    elif [[ $wifiL != 'TRUE' && $list = *Wi-Fi* ]] ; then
        write-log "WiFi: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $wifiL == 'TRUE' && $list != *Wi-Fi* ]] ; then
        write-log "WiFi: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #blth
    if [[ $bltL != 'TRUE' && $list != *Bluetooth* ]] ; then
        write-log "BLTH: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $bltL = 'TRUE' && $list = *Bluetooth* ]]; then
        write-log "BLTH: 1" #настроено автоматом
    elif [[ $bltL != 'TRUE' && $list = *Bluetooth* ]] ; then
        write-log "BLTH: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $bltL == 'TRUE' && $list != *Bluetooth* ]] ; then
        write-log "BLTH: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #BRCD
    if [[ $brcdL != 'TRUE' && $list != *СШК* ]] ; then
        write-log "BRCD: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $brcdL = 'TRUE' && $list = *СШК* ]]; then
        write-log "BRCD: 1" #настроено автоматом
    elif [[ $brcdL != 'TRUE' && $list = *СШК* ]] ; then
        write-log "BRCD: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $brcdL == 'TRUE' && $list != *СШК* ]] ; then
        write-log "BRCD: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #tm
    if [[ $tmL != 'TRUE' && $list != *TM* ]] ; then
        write-log "TM: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $tmL = 'TRUE' && $list = *TM* ]]; then
        write-log "TM: 1" #настроено автоматом
    elif [[ $tmL != 'TRUE' && $list = *TM* ]] ; then
        write-log "TM: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $tmL == 'TRUE' && $list != *TM* ]] ; then
        write-log "TM: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #MFU
    if [[ $mfuL != 'TRUE' && $list != *МФУ* ]] ; then
        write-log "MFU: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $mfuL = 'TRUE' && $list = *МФУ* ]]; then
        write-log "MFU: 1" #настроено автоматом
    elif [[ $mfuL != 'TRUE' && $list = *МФУ* ]] ; then
        write-log "MFU: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $mfuL == 'TRUE' && $list != *МФУ* ]] ; then
        write-log "MFU: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #BP
    if [[ $bpL != 'TRUE' && $list != *БанковскийПринтер* ]] ; then
        write-log "BP: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $bpL = 'TRUE' && $list = *БанковскийПринтер* ]]; then
        write-log "BP: 1" #настроено автоматом
    elif [[ $bpL != 'TRUE' && $list = *БанковскийПринтер* ]] ; then
        write-log "BP: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $bpL == 'TRUE' && $list != *БанковскийПринтер* ]] ; then
        write-log "BP: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #POS
    if [[ $posL != 'TRUE' && $list != *POS* ]] ; then
        write-log "POS: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $posL = 'TRUE' && $list = *POS* ]]; then
        write-log "POS: 1" #настроено автоматом
    elif [[ $posL != 'TRUE' && $list = *POS* ]] ; then
        write-log "POS: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $posL == 'TRUE' && $list != *POS* ]] ; then
        write-log "POS: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi
    #WebCam
    if [[ $webcL != 'TRUE' && $list != *Web* ]] ; then
        write-log "WebCam: 0" #не настроено автоматом и не выставлено в ручную
    elif [[ $webcL = 'TRUE' && $list = *Web* ]]; then
        write-log "WebCam: 1" #настроено автоматом
    elif [[ $webcL != 'TRUE' && $list = *Web* ]] ; then
        write-log "WebCam: 2" #не настроено автоматом - выставлено "настроено" в ручную
    elif [[ $webcL == 'TRUE' && $list != *Web* ]] ; then
        write-log "WebCam: 3" #настроено автоматом - выставлено "не настроено" в ручную
    fi

    zenity --info --text "Данные записаны" --width 200 --height 150
    cat $LogFile | awk 'begin{IFS= " "} {print $2" "$3" "$4}' > $CheckFile
    __qr-generation
    exit 0;
    elif [ $? -eq 1 ]; then
        zenity --info --text "Отмена. Чек-лист будет запущен заново. Данные не записаны." --width 300 --height 150
        rm -r $LogFile > /dev/null 2>&1
        __checklist_thinclient_vsp
    fi

    chkf=$(cat $CheckFile | wc -l)
    if [ $chkf -ne 11 ]; then
        zenity --error --text "Чек-лист заполнен не корректно. Данные не сохранены."
        rm -r $LogFile $CheckFile> /dev/null 2>&1
        exit 1;
    fi
}
#===============================================================================#
__qr-generation(){
    local SIZE="--width=1920 --height=1080" #OR 1920 x 1080 - better (but need -s 24/6) mb make it local SIZE 250 x 350
    QRPATH=$MainDirPath/sbs_qr.png
    local QRPCNAME=$(hostname)
    local QRRANDOMNUMBERGENERATE=$(echo $[ $RANDOM %999 + 100 ])
    local QRRANDOMPCGENERATE=$(hostname | tr -s "-" " ")
    QRID=$(echo "$QRRANDOMPCGENERATE-$QRRANDOMNUMBERGENERATE")
    QRRESULT=$(echo "$QRID;$FIO;$ZNO;$QRPCNAME;$DATETIME")

    qrencode -s 12 -l H -o $QRPATH "$QRRESULT"
    zenity --list --imagelist $SIZE --column="" "$QRPATH" --title="QR-код СБС" --text "Отсканируйте QR-код в приложении Sprint"

    if [[ $? -eq 0 ]]; then
        zenity --question --text="Вы отсканировали QR-код в приложении Sprint?" --ellipsize
        case $? in
            1)
                zenity --error --text="Необходимо отсканировать QR-код в приложении Sprint!" --ellipsize
                __qr-generation
        esac
    elif [[ $? -eq 1 ]]; then
        zenity --error --text="Необходимо отсканировать QR-код в приложении Sprint!" --ellipsize
        __qr-generation
    fi
}
#===============================================================================#
__write-json(){
JSON=$MainDirPath/config.json
cat <<EOF>$JSON
        {
            "arm_info":{
                "PCName": "$NAME",
                "MAC": "$MAC",
                "WiFi": "$WIFI",
                "Bluetooth": "$BLUETOOTH",
                "Manufacturer": "$MANUFACTURER",
                "MarkModel": "$MARKMODEL",
                "SerialNumber": "$SERIALNUMBER",
                "Bitlocker": "$BITLOCKER",
                "RamSize": "$RAM",
                "DiskType": "$DISKTYPE",
                "DiskInfo":[
                    {"Type":"$DISKTYPE", "Size":"$DISKSIZE", "Free":"$DISKFREESIZE", "Used":"$DISKPERCENTUSEDSIZE"}
                ]
            },
            "os_info":{
                "OSVersion": "$OSVERSION",
                "OSInstallDate": "$OSINSTALLDATE"
            }
        }
EOF
}

                #"AdditionalDiskType": "$DISKTYPE_ADDITIONAL",
#===============================================================================#
<< "com"
numbers=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9')
numbers_output=$(echo "${numbers[*]}")

for number in $numbers_output
do
  if [[ "$name" == *"$number"* ]]; then
    echo "err"
    exit 12
  fi
done

letters=('a' 'b' 'c' 'd' 'f' 'g' 'h' 'j' 'k' 'l' 'm' 'n' 'p' 'q' 'r' 's' 't' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' 'А' 'а' 'Б' 'б' 'В' 'в' 'Г' 'г' 'Д' 'д' 'Е' 'е' 'Ё' 'ё' 'Ж' 'ж' 'З' 'з' 'И' 'и' 'Й' 'й' 'К' 'к' 'Л' 'л' 'М' 'м' 'Н' 'н' 'О' 'о' 'П' 'п' 'С' 'с' 'Т' 'т' 'У' 'у' 'Ф' 'ф' 'Х' 'х' 'Ц' 'ц' 'Ч' 'ч' 'Ш' 'ш' 'Щ' 'щ' 'Ъ' 'ъ' 'Ы' 'ы' 'Ь' 'ь' 'Э' 'э' 'Ю' 'ю' 'Я' 'я')
letters_output=$(echo "${letters[*]}")

for letter in $letters_output
do
  if [[ "$zno" == *"$letter"* ]]; then
    echo "error"
    exit 13
  fi
done
com
