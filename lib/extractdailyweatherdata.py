#!/usr/bin/python3
# Script to fetch the temperature and other info of a city from weather app
import requests
import json
from datetime import datetime,timedelta
import time
import json
import csv


def writecsv(dte,i):
    dt=str(int(dte))
    combinedurl='https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=37.4219983&lon=-122.084&dt='+dt+'&appid=b00a6fcec885b5e53be85ac4d7847543'
    response = requests.get(weather_url)
    # response will be in json format and we need to change it to pythonic format
    weather_data = response.json()
    fname = "output.csv"
    if(i==1):
            with open(fname, "w") as file:
                csv_file = csv.writer(file,lineterminator='\n')
                csv_file.writerow(["dt","temp","pressure","humidity","wind_speed","main"])
                for item in weather_data["hourly"]:
                    csv_file.writerow([item['dt'],item['temp'],item['pressure'],item['humidity'],item['wind_speed'],item['weather'][0]['main']])
    if(i==0):
            with open(fname, "a") as file:
                csv_file = csv.writer(file,lineterminator='\n')
                for item in weather_data["hourly"]:
                    csv_file.writerow([item['dt'],item['temp'],item['pressure'],item['humidity'],item['wind_speed'],item['weather'][0]['main']])
# Enter your API key
api_key = "b00a6fcec885b5e53be85ac4d7847543"

# Get city name from user
#city_name = input("Enter city name : ")

# API url
weather_url = 'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=37.4219983&lon=-122.084&dt=1647952953&appid=b00a6fcec885b5e53be85ac4d7847543'

# Get the response from weather url
response = requests.get(weather_url)

# response will be in json format and we need to change it to pythonic format
weather_data = response.json()

today = datetime.today()
today_minusone=datetime.timestamp(datetime.today() - timedelta(days=1))
today_minustwo=datetime.timestamp(datetime.today() - timedelta(days=2))
today_minusthree=datetime.timestamp(datetime.today() - timedelta(days=3))
today_minusfour=datetime.timestamp(datetime.today() - timedelta(days=4))
today_minusfive=datetime.timestamp(datetime.today() - timedelta(days=5))
writecsv(today_minusone,1)
writecsv(today_minustwo,0)
writecsv(today_minusthree,0)
writecsv(today_minusfour,0)
writecsv(today_minusfive,0)
print("Today's date:", today)
print(today_minusone)
print(today_minustwo)
print(today_minusthree)
print(today_minusfour)
print(today_minusfive)
todaytimestamp = datetime.timestamp(today)

print(todaytimestamp)
print(weather_data["current"])



