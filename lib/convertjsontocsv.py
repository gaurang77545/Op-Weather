import json
import csv
with open("./my_json.json") as file:
    data = json.load(file)

fname = "output.csv"

with open(fname, "w") as file:
    csv_file = csv.writer(file,lineterminator='\n')
    csv_file.writerow(["Name","Age","Marks","Country"])
    for item in data["result"]:
        csv_file.writerow([item['name'],item['age'],item['marks'],item['country']])