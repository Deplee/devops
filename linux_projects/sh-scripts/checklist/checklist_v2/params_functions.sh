#===============================================================================#
MainDirPath=/home/tcadmin/info/files
ErrFile=$MainDirPath/exit_info.log
yml=$MainDirPath/pid_vid.yml
NAME=$(hostname)
#MAC=$(ifconfig -a | grep ether | gawk '{print $2}')
MANUFACTURER=$(sudo dmidecode -t chassis | grep 'Manufacturer' | awk '{print $2" "$3" "$4" "$5" "$6}')
MARKMODEL=$(sudo dmidecode -t System | grep -i "Product" | sed s/X//g | awk '{print $3}' )
SERIALNUMBER=$(sudo dmidecode -t System | grep -i "Serial Number" | awk '{print $3}')
BITLOCKERINFO=$(blkid | grep -i -e 'TYPE='| awk '{print $4}' | sed -r 's/TYPE=//g' | sed -r 's/"//g')
RAM=$(free -h | awk '/^Память/ {print $2 }' | sed -r 's/Gi/GB/g')
DISKTYPE_TK=$(lsblk -d -o name,rota | awk '/^nvme/ {print $2}')
DISKTYPE_ARM=$(lsblk -d -o name,rota | awk '/^sd/ {print $2}')
DISKSIZE=$(df -h / | awk '/dev/ {print $2}' | sort -du | sed -r 's/G/GB/g')
DISKUSEDSIZE=$(df -h / | awk '/dev/ {print $3}' | sort  -du | sed -r 's/G/GB/g')
DISKFREESIZE=$(df -h / | awk '/dev/ {print $4}' | sort  -du | sed -r 's/G/GB/g')
DISKPERCENTUSEDSIZE=$(df -h / | awk '/dev/ {print $5}' | sort  -du | sed -r 's/G/GB/g')
WIFICHECK=$(lspci | egrep -i 'wifi|wlan|wireless')
BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}')
if [[ $DISKTYPE_TK -eq 0 ]]; then
    DISKTYPE="SSD"
elif [[ $DISKTYPE_TK -eq 1 ]]; then
    DISKTYPE="HDD"
elif [[ $DISKTYPE_ARM -eq 0 ]]; then
    DISKTYPE="SSD"
elif [[ $DISKTYPE_ARM -eq 1 ]]; then
    DISKTYPE="HDD"
else
    DISKTYPE="Unknown"
fi

if [[ $BITLOCKERINFO == "*crypto*" ]]; then
    BITLOCKER="TRUE"
else
    BITLOCKER="FALSE"
fi

OSVERSION=$(cat /etc/os-version  | grep 'osversion' | awk '{print $2}' | sed s/v//g)
OSINSTALLDATE=$(cat /etc/os-version | grep -i 'installdate' | cut -c13-50 | tr -s '"' ' ' && echo "${OSINSTALLDATE:1}" > /dev/null 2>&1)
#OSINSTALLDATE=$(ls -clt / | tail -n 1 | awk '{print $7, $6, $8}') #OLD
#WIFICHECK=$(nmcli d | grep ^[w-z] | awk '{print $1}') #OLD
#BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}') #OLD
DATETIME=$(date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-")
SIZE="--width=750 --height=550"
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
        #WIFICHECK=$(nmcli d | grep ^[w-z] | awk '{print $1}')
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
        #BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}')
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
	#WIFICHECK=$(lspci | egrep -i 'wifi|wlan|wireless')
	if [[ ! -z "$WIFICHECK" ]]; then
		WIFI="TRUE"
		MAC=$(cat /sys/class/net/w*/address)
	elif [[ -z "$WIFICHECK" ]]; then
		WIFI="FALSE"
		MAC=$(cat /sys/class/net/e*/address)
	else
		WIFI="Unknown"
	fi
    #BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}')
    case $BLUETOOTHCHECK in
        "(running)")
            BLUETOOTH="TRUE" ;;
        "(dead)")
            BLUETOOTH="FALSE" ;;
        *)
            BLUETOOTH="Unknown" ;;
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
            __qr-generation
            __write-json ;;
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
#idProduct (web-cam)
    #lswebc=$(lsusb -v | grep idProduct | grep -e '0x082B' -e '0x0836' -e '0x2284' -e '0x0810' -e '0x0819' -e '0x0825' -e '0x3420' -e '0x6340' -e '0x2700' -e '0x0d01' -e '0x0110' -e '0x3399' -e '0x62e0' -e '0x62c0' -e '0x58bb' -e '0xe207' -e '0xe261' -e '0x260e' -e '0x4083' -e '0x0829' -e '0x0824' -e '0x081b' -e '0x081d ' -e '0x0826' -e '0x0821' -e '0x080a' -e '0x082d' -e '0x0804' -e '0x0807' -e '0x0823' -e '0x0822' -e '0x0805' -e '0x09a5' -e '0x3500' -e '0x3450' -e '0xc40a' -e '0x58b0' -e '0x0772' -e '0x0766' -e '0x0761' -e '0x0728' -e '0x2622' -e '0x705e' -e '0x7089' -e '0x2625' -e '0x605e' -e '0x705f'| awk '{print $2}')
#idVendor (pos,brcd,tm)
    #lsbrcd=$(lsusb -v | grep idVendor | grep -e '0x05e0' -e '0x05f9' -e '0x0c2e' -e '0x1eab' -e '0x0536' -e '0x2dd6' | awk '{print $2}')
    #lstm=$(lsusb -v | grep idVendor | grep -e '0x067b' -e '0xa420' | awk '{print $2}')
    #lspos=$(lsusb -v | grep idVendor | grep -e '0x11ca' -e '0x1234' -e '0x079b' | awk '{print $2}')
#printres list
    #bpls=$( lpstat -v | grep '///dev/null' | awk '{print $4}')
    #bplsO=$(lpstat -v | grep usb:// | awk '{print $4$5$6}')
    #mfunames=$(lpc status  | grep -e "Lexmark" -e  "Xerox" | awk '{print $1}' | tr -s ':' ' ' | head -n1 | cut -c1-5)
#massive ls (YAML)
    lsv=$(lsusb -v | grep -i 'idVendor' | awk '{print $2}')
    lsp=$(lsusb -v | grep -i 'idProduct' | awk '{print $2}')
####----GET MODELS----####
#===============================================================================                                                                                                                                                             #
#BRCD
#DELETED#

#TM
#DELETED#

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

#POS
#DELETED#

#WEBCAM
#DELETED#


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
    #d=$(date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-")
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
#Next steps removed
<<"REMOVED"
rm -r $LogFile > /dev/null 2>&1
while :
    do
    checklist
done
REMOVED
#===============================================================================#
__qr-generation(){
    local SIZE="--width=1920 --height=1080" #OR 1920 x 1080 - better (but need -s 24/6) mb make it local SIZE 250 x 350
    QRPATH=$MainDirPath/sbs_qr.png
    local QRPCNAME=$(hostname)
    local QRRANDOMNUMBERGENERATE=$(echo $[ $RANDOM %999 + 100 ])
    local QRRANDOMPCGENERATE=$(hostname | tr -s "-" " " | awk '{print $3}')
    QRID=$(echo "$QRRANDOMPCGENERATE-$QRRANDOMNUMBERGENERATE")
    #local QRDATETIME=$(date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-")
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
JSON=$MainDirPath/linux_checklist.json
cat <<EOF>$JSON
        {
            "work_info":{
                "Engineer": "$FIO",
                "RequestNumber": "$ZNO",
                "DateTime": "$DATETIME",
                "ID": "$QRID"
            },
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
                    {"Size":"$DISKSIZE", "Free":"$DISKFREESIZE", "Used %":"$DISKPERCENTUSEDSIZE"}
                ]
            },
            "os_info":{
                "OSVersion": "$OSVERSION",
                "OSIntallDate": "$OSINSTALLDATE"
            }
        }
EOF
}

#===============================================================================#
