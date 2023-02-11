import mysql.connector
import requests
import json
import schedule
import time

# start

def sqlQueryTomorrow():
    try:
        connection = mysql.connector.connect(host='*',
                                            database='duty',
                                            user='*',
                                            password='*'
                                            )

        # exectute sql query
        tomorrow_sql_query = "SELECT engineer FROM calendar WHERE calendar_date=(SELECT CURDATE() + INTERVAL 1 DAY);"
        cursor = connection.cursor()
        cursor.execute(tomorrow_sql_query)
        # get all records
        records = cursor.fetchall()
        engineer = []
        test =[]
        for row in records:
            for field in row:
                engineer.append(row[0])
                #return engineer[0]
    except mysql.connector.Error as e:
        print("Error reading data from MySQL table", e)
    finally:
        if connection.is_connected():
            connection.close()
            cursor.close()
            print("MySQL connection is closed")
            return engineer

def sqlQueryToday():
    try:
        connection = mysql.connector.connect(host='*',
                                            database='duty',
                                            user='*',
                                            password='*'
                                            )

        # exectute sql query
        today_sql_query = "SELECT engineer FROM calendar WHERE calendar_date=(SELECT CURDATE());"
        cursor = connection.cursor()
        cursor.execute(today_sql_query)
        # get all records
        records = cursor.fetchall()
        engineer = []
        test =[]
        for row in records:
            for field in row:
                engineer.append(row[0])
                #return engineer[0]
    except mysql.connector.Error as e:
        print("Error reading data from MySQL table", e)
    finally:
        if connection.is_connected():
            connection.close()
            cursor.close()
            print("MySQL connection is closed")
            return engineer
# Notify to Rocket.Chat

def RocketNotifyToday():
    name_engineer=sqlQueryToday()
    data = {
                        "channel": "*",
                        "alias": "Devops Duty Bot",
                        "avatar": "https://icon-icons.com/downloadimage.php?id=183522&*=2924/PNG/512/&file=forbidden_drink_bottles_bottle_prohibition_signal_icon_183522.png",
                                    "text": "Today Duty is @" + name_engineer[0],
                                    "color": "#C6201E",
                    }
    chat_url = "*"
    print (chat_url)
    headers = { 'Content-Type' : 'application/json',
    'X-Auth-Token': '*',
    'X-User-Id': '*'}
    response = requests.post(chat_url, headers=headers, json=data)

    print("Status Code", response.status_code)
    print("JSON Response ", response.json())
    # DEBUG VALUE
    #print(name_engineer)


def RocketNotifyTomorrow():

    name_engineer=sqlQueryTomorrow()
    data = {
                        "channel": "*",
                        "alias": "Devops Duty Bot",
                        "avatar": "https://icon-icons.com/downloadimage.php?id=183522&*=2924/PNG/512/&file=forbidden_drink_bottles_bottle_prohibition_signal_icon_183522.png",
                                    "text": 'Tomorrow duty is @' + name_engineer[0] ,
                                    "color": "#C6201E",
                    }
    chat_url = "*"
    print (chat_url)
    headers = { 'Content-Type' : 'application/json',
    'X-Auth-Token': '*',
    'X-User-Id': '*'}
    response = requests.post(chat_url, headers=headers, json=data)

    print("Status Code", response.status_code)
    print("JSON Response ", response.json())
    # DEBUG VALUE
    #print(name_engineer)

#RocketNotifyToday()


#schedule.every().day.at("02:40").do(RocketNotifyToday)
schedule.every().day.at("02:00").do(RocketNotifyToday)
schedule.every().day.at("10:00").do(RocketNotifyTomorrow)
while True:
    schedule.run_pending()
    time.sleep(1)

