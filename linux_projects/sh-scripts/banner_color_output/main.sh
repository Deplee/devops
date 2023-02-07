#!/bin/bash
source /home/izuna/sh-code/my-project/trap_exception
source /home/izuna/sh-code/my-project/output_color
bannerColor "You running ${BASH_SOURCE[0]}" "yellow" "*"
bannerColor "Programm Started... Wait" "red" "*"

MainDirPath=/home/izuna/sh-code/my-project

NAME=$(hostname)
MANUFACTURER=$(sudo dmidecode -t chassis | grep 'Manufacturer' | awk '{print $2" "$3" "$4" "$5" "$6}')
MARKMODEL=$(sudo dmidecode -t System | grep -i "Product" | sed s/X//g | awk '{print $3}' )
SERIALNUMBER=$(sudo dmidecode -t System | grep -i "Serial Number" | awk '{print $3}')
BITLOCKERINFO=$(blkid | grep -i -e 'TYPE='| awk '{print $4}' | sed -r 's/TYPE=//g' | sed -r 's/"//g')
RAM=$(free -h | awk '/^Mem/ {print $2 }' | sed -r 's/Gi/GB/g')

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

DISKSIZE=$(df -h / | awk '/dev/ {print $2}' | sort -du | sed -r 's/G/GB/g')
DISKUSEDSIZE=$(df -h / | awk '/dev/ {print $3}' | sort  -du | sed -r 's/G/GB/g')
DISKFREESIZE=$(df -h / | awk '/dev/ {print $4}' | sort  -du | sed -r 's/G/GB/g')
DISKPERCENTUSEDSIZE=$(df -h / | awk '/dev/ {print $5}' | sort  -du | sed -r 's/G/GB/g')
WIFICHECK=$(lspci | egrep -i 'wifi|wlan|wireless')
BLUETOOTHCHECK=$(systemctl status bluetooth.service | grep 'Active:' | awk '{print $3}')
DISKS_BY_NAMES=$(lsblk -s | awk '/disk/' | sed -s 's/└─//g' | awk '{print $1}' | uniq)
COUNT_SYSTEM_DISKS=$(lsblk -s | awk '/disk/' | sed -s 's/└─//g' | awk '{print $1}' | uniq | wc -l)

#get info for each system disk cycle
if [ $COUNT_SYSTEM_DISKS -ge 1 ]; then #gt
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
 size=$(df -h | egrep -i "$item" | awk '/dev/ {print $2}')
 used_size=$(df -h | egrep -i "$item" | awk '/dev/ {print $3}' | sort  -du | sed -r 's/G/GB/g')
 free_size=$(df -h  | egrep -i "$item" | awk '/dev/ {print $4}' | sort  -du | sed -r 's/G/GB/g')
 percent_size=$(df -h | egrep -i "$item" | awk '/dev/ {print $5}' | sort  -du | sed -r 's/G/GB/g')
fi

if [[ $BITLOCKERINFO == "*crypto*" ]]; then
    BITLOCKER="Enabled"
else
    BITLOCKER="Disabled"
fi

OSVERSION=$(cat /etc/os-release | grep -i 'VERSION_ID' | sed -s 's/=/ /' | sed -s 's/"//g' | awk '{print $2}' | sed s/v//g)
OSINSTALLDATE=$(stat -c %w /)
DATETIME=$(date +%Y-%d-%m_%H:%M:%S.00 | tr -s "_" " " | tr -s "/" "-")

__write-json(){
JSON=$MainDirPath/info.json
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
                "MainDiskType": "$DISKTYPE",
                "AdditionalDiskType": "$DISKTYPE_ADDITIONAL",
                "DiskInfo":[
                    {"Type":"$DISKTYPE", "Size":"$DISKSIZE", "Free":"$DISKFREESIZE", "Used %":"$DISKPERCENTUSEDSIZE"},
                    {"Type":"$DISKTYPE_ADDITIONAL", "Size":"$size", "Free":"$free_size", "Used %":"$percent_size"}
                ]
            },
            "os_info":{
                "OSVersion": "$OSVERSION",
                "OSIntallDate": "$OSINSTALLDATE"
            }
        }
EOF
}
__write-json
bannerColor 'Programm Ended' "red" "*"
bannerColor "JSON format info in $JSON" "yellow" "*"
