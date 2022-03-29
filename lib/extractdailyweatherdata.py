#!/usr/bin/python3
# Script to fetch the temperature and other info of a city from weather app
import requests
import json
from datetime import datetime, timedelta
import time
import json
import csv
import pandas as pd
import numpy as np
import sklearn
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import mean_squared_error, r2_score
import joblib
from sklearn.preprocessing import RobustScaler
import csv
from sklearn.svm import SVR
import sklearn.svm as svm
from sklearn.linear_model import LinearRegression

def writecsv(dte, i):
    dt = str(int(dte))
    combinedurl = 'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=37.4219983&lon=-122.084&dt=' + \
        dt+'&appid=b00a6fcec885b5e53be85ac4d7847543'
    response = requests.get(combinedurl)
    # response will be in json format and we need to change it to pythonic format
    weather_data = response.json()
    fname = "output.csv"
    if(i == 1):
        with open(fname, "w", newline='') as file:
            csv_file = csv.writer(file, lineterminator='\n')
            x = csv.DictWriter(file, fieldnames=[
                               "dt", "temp", "pressure", "humidity", "wind_speed", "main"])
            x.writeheader()
            for item in weather_data["hourly"]:
                csv_file.writerow([item['dt'], item['temp']-273, item['pressure'],
                                  item['humidity'], item['wind_speed'], item['weather'][0]['main']])
            csv_file.writerow([weather_data['current']['dt'], weather_data['current']['temp']-273, weather_data['current']['pressure'],
                                  weather_data['current']['humidity'], weather_data['current']['wind_speed'], weather_data['current']['weather'][0]['main']])
    if(i == 0):
        with open(fname, "a") as file:
            csv_file = csv.writer(file, lineterminator='\n')
            for item in weather_data["hourly"]:
                csv_file.writerow([item['dt'], item['temp']-273, item['pressure'],
                                  item['humidity'], item['wind_speed'], item['weather'][0]['main']])
            csv_file.writerow([weather_data['current']['dt'], weather_data['current']['temp']-273, weather_data['current']['pressure'],
                                  weather_data['current']['humidity'], weather_data['current']['wind_speed'], weather_data['current']['weather'][0]['main']])
def get_the_weather(date):
    data1 = pd.read_csv("output.csv")
    #print('Date to be found is'+str(date))
    #weather = data1.day
    temp = data1.dt
    count=0
    for i in temp:
        #print(i)
        if (str(i)==str(date)):
            #print('finally found'+str(i))
            x=indexreturn(count)
            return x
        count+=1
    #print('count is'+str(count))
def indexreturn(count):
   # print('Entered hahahah')
    data1 = pd.read_csv("output.csv")
    count2=0
   # print('count to be found is'+str(count))
    for j in data1.temp:
        #print(str(count2))
        if(count2==count):
            #print('hahahahah')
            return str(j)
        count2+=1
def predict_weather(dt):
    clf = joblib.load('weather_predictor.pkl')
    print("The temperature is predicted to be: " + str(clf.predict(np.array(dt).reshape(-1,1))[0][0]))
    print("The temperature was actually: " + str(get_the_weather(int(dt))))
    print("-" * 48)
    print("\n")
def train_data():
    data = pd.read_csv("output.csv")
    x = data.dt.values.reshape(-1,1)
    y = data.temp.values.reshape(-1,1)
    #print(x)
    X_train, X_test, y_train, y_test = train_test_split(x, y,test_size=0.15,random_state=123,)
   # print(X_train)
    #X_train=X_train.values.reshape(-1,1)
    scaler = preprocessing.StandardScaler().fit(X_train)
    X_train_scaled = scaler.transform(X_train)
    
    pipeline = make_pipeline(preprocessing.StandardScaler(), 
                            RandomForestRegressor(n_estimators=25,random_state=123))

    hyperparameters = { 'randomforestregressor__max_features' : ['auto', 'sqrt', 'log2'],
                    'randomforestregressor__max_depth': [None, 5, 3, 1], }

    clf = LinearRegression()
    clf.fit(X_train, y_train)
    pred = clf.predict(X_test)
    print ("R2 Score is"+str(r2_score(y_test, pred)))
    print ("Mean Squared Error is"+str(mean_squared_error(y_test, pred)))
    joblib.dump(clf, 'weather_predictor.pkl')
    
# Enter your API key
api_key = "b00a6fcec885b5e53be85ac4d7847543"

# Get city name from user
#city_name = input("Enter city name : ")

# API url
weather_url = 'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=37.4219983&lon=-122.084&dt=1648581452&appid=b00a6fcec885b5e53be85ac4d7847543'

# Get the response from weather url
response = requests.get(weather_url)

# response will be in json format and we need to change it to pythonic format
weather_data = response.json()

today = datetime.today()
today_minusone = datetime.timestamp(datetime.today() - timedelta(days=1))
today_minustwo = datetime.timestamp(datetime.today() - timedelta(days=2))
today_minusthree = datetime.timestamp(datetime.today() - timedelta(days=3))
today_minusfour = datetime.timestamp(datetime.today() - timedelta(days=4))
today_minusfive = datetime.timestamp(datetime.today() - timedelta(days=5))
writecsv(today_minusone, 1)
writecsv(today_minustwo, 0)
writecsv(today_minusthree, 0)
writecsv(today_minusfour, 0)
writecsv(today_minusfive, 0)
train_data()
predict_weather(today_minusone)

predict_weather(today_minustwo)
predict_weather(today_minusthree)
# predict_weather(today_minusfour)
# predict_weather(today_minusfive)
# print(data.temp)
# print("Today's date:", today)
# print(today_minusone)
# print(today_minustwo)
# print(today_minusthree)
# print(today_minusfour)
# print(today_minusfive)
# todaytimestamp = datetime.timestamp(today)

# print(todaytimestamp)
print(weather_data["current"])
