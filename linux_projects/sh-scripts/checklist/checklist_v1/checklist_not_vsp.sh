#!/bin/bash
#===============================================================================
#
#          FILE: checklist_not_vsp.sh
#
#         USAGE: ./checklist_not_vsp.sh
#
#   DESCRIPTION:
#                Checklist for ARM with OS Linux (Ubuntu, Mint, Debian)
#       OPTIONS: ---
#  Dependencies: zenity, qrencode
#          BUGS: 2 DISKS BUG (if HDD + SSD on PC) ??? (NTC)
#         TESTS:
#                B4COM (TNC-500 & SSD) - PASSED
#                Lenovo (ARM & HDD) - PASSED
#         NOTES:
#       Version: 1.6
#     Changelog:
#                v1.6
#                1. Re-worked WIFICHECK from current to lspci | egrep -i 'wifi|wlan|wireless'
#                2. BLUETOOTHCHECK moved to global variables from functions.
#                3. Function __get_bios => __thinclient now contains a "MAC" variable. in $WIFICHECK case.
#                4. Function __get_bios => __dev now contains a WIFICHECK (Dynamically MAC info) & BLUETOOTHCHECK.
#                5. Re-worked FIO & ZNO gets & fields in functions (__checklist_thinclient_vsp, __checklist_thinclient_ms, __checklist_dev)
#                v1.5
#                1. Added checklist_thinclient_ms function.
#                2. Added write-error function.
#                3. Added bitlocker check. (NTC)
#                v1.4
#                1. Added source files (headers).
#                2. Functions & Params moved to file params_functions.sh.
#                3. Exit codes moved to file exit_codes.sh.
#                v1.3
#                1. Reduced QR-code blocks size from 24 to 12.
#                2. Added wi-fi & bleutooth checker after TYPERM check (if wi-fi/bluetooth not configured error exit).
#                3. Re-worked param "OSINSTALLDATE" (now get info from /etc/os-version).
#                4. Added ID (identificator) for SQL Request ID & Checklist ID bundles).
#                v1.2
#                1. Added RadioButtons  devision (MS __checklist_thinclient_ms , VSP  __checklist_thinclient_vsp, Dev  __checklist_dev).
#                2. Added exit codes.
#                3. Added write-log function.
#                4. Re-worked __qr-generation function.
#                5. Added __get_bios function.
#                v1.1
#                1. Added QR-code generation & information for engineers about this.
#                2. Added SQL format datetime on write-json (records current dt at the time of filling).
#                3. Added local variables.
#                v1.0
#                1. Added __write-json function.
#                2. Added engineer & request info writeble fields.
#          TODO:
#                1.
#        AUTHOR: Sag1r1_1zum1 <dkapitsev@gmail.com> a.k.a. D1pl1k
#  ORGANIZATION:
#       CREATED: 08/25/2022 13:57
#      REVISION: 22/09/2022 01:50
#===============================================================================#
#set -x
source ./exit_codes.sh
source ./params_functions.sh
#===============================================================================#
main(){
    local SIZE="--width=500 --height=240"
    if [[ ! -d $MainDirPath ]]; then
        mkdir -p $MainDirPath > /dev/null 2&>1
    fi
    zenity --info --text="После заполнения чек-листа появится QR-код, который нужно отскранировать в приложении Sprint. В случае отсутствия заполненного чек-листа и отсканированного QR-кода проведенные работы будут считаться фродом!" --ellipsize
        case $? in
            1)
                zenity --error --text="Чек-лист должен быть заполнен!" --ellipsize
                main ;;
        esac
    TYPERM=$(zenity $SIZE --list --radiolist \
        --title="Выберите тип рабочего места" \
        --column="" --column="Рабочее место" \
        "", "ВСП Тонкий клиент" \
        "", "Массовые специальности (ОЦ,ЦКР,ЕРКЦ,МЦЭ,МЦЗК)" \
        "", "Ноутбук разработчика (Sigma)")

    case $TYPERM in
        "Массовые специальности (ОЦ,ЦКР,ЕРКЦ,МЦЭ,МЦЗК)")
            __checklist_thinclient_ms ;;
        "ВСП Тонкий клиент")
            __checklist_thinclient_vsp ;;
        "Ноутбук разработчика (Sigma)")
            __checklist_dev ;;
    esac
    case $? in
        0)
            write-error "[Exit Not Choosen Error]. Exit code is: $EXIT_NOT_CHOOSEN"
            exit $EXIT_NOT_CHOOSEN ;;
        *)
            write-error "[Exit Another Error]. Exit code is: $EXIT_ANOTHER_ERROR"
            exit $EXIT_ANOTHER_ERROR ;;
    esac
}
#===============================================================================#
main
#===============================================================================#
