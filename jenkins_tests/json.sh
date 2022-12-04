#!/bin/bash
date=$(date +%Y-%m-%d_%H:%M:%S | sed -r 's/_/ / g')

cat<<EOF>config.json

        {
            "arm_info":{
                "PCName": "groovy",
                "MAC": "dsfsdffdsfsf",
                "WiFi": "Enabled",
                "Bluetooth": "Enabled",
                "Manufacturer": "ASUSTeK COMPUTER INC.  ",
                "MarkModel": "TUF",
                "SerialNumber": "K5NRCV01J921193",
                "Bitlocker": "Disabled",
                "RamSize": "7,2GB",
                "MainDiskType": "SSD",
                "DiskInfo":[
                    {"Type":"SSD", "Size":"117GB", "Free":"88GB", "Used":"22%"}
                ]
            },
            "os_info":{
                "OSVersion": "22.04",
                "OSInstallDate": "$date"
            }
        }
EOF
