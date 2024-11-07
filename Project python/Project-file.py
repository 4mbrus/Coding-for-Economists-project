#Let's start by understanding the folder structure, and performing some operations
import os
print (os.getcwd())
working_dir="c:/Users/Ambrus/Documents/CEU/Coding for Economists/Coding-for-Economists-project/Project python/asia-industry" #Change the directory to the downloaded data's folder
os.chdir(working_dir)
print(os.listdir())

#I am only goin to use the raw data, so I can delete the files
files_to_delete = os.listdir("clean")
os.chdir("clean")
for i in range(len(files_to_delete)):
    os.remove(str(files_to_delete[i]))
os.chdir(working_dir)

import pandas as pd #In order to work with data tables I am going to use the Pandas library

#Opening the raw folder
os.chdir("raw")
print(os.listdir())
data=pd.read_csv("worldbank-monthly-asia-2019_long.csv")
print(data.head())


data.drop(["Series Code", "Time Code"], axis=1, inplace=True) #I am dropping two variables that I am not going to need
print(data.info())

data["Value"]=data["Value"] / 1_000_000_000 #these are very high values so I divide them by one billion 

print(data["Series"].unique()) #All of the values of this variable have some unnecessary characters after them

data["Series"] = data["Series"].replace({
    'Industrial Production, constant US$,,,': 'Industrial Production, billions of constant US$', #I indicate here that I divided these values by one billion
    'Exchange rate, new LCU per USD extended backward, period average,,': 'Exchange rate, new LCU per USD extended backward, period average',
    'CPI Price, seas. adj.,,,' : 'CPI Price, seas. adj.',
    'CPI Price, % y-o-y, not seas. adj.,,': 'CPI Price, % y-o-y, not seas. adj.',
    'Industrial Production, constant US$, seas. adj.,,': 'Industrial Production, constant US$, seas. adj.',
    'Nominal Effecive Exchange Rate,,,,' : 'Nominal Effecive Exchange Rate',
    'Real Effective Exchange Rate,,,,': 'Real Effective Exchange Rate'
})

#I dont want monthly and quarterly data, so I convert Time to string and keep only the rows where the string is shorter than 6
data["Time"]=data["Time"].astype("string")
data=data[data["Time"].str.len() < 6]
data["Time"]=data["Time"].astype("int") #We can now change the data type to intiger
# I am also going to remove the year 2018 beacuse it is not a full year (The README file states the dataset is only until 2018 June)
data=data[data['Time'] != "2018"]

# I want to see the year on year change of the Values variable
data["YoY Change"]=data["Value"].pct_change(fill_method=None)*100

#Now the 'CPI Price, % y-o-y, not seas. adj.' value that the "Series" variable can take has become redundant. Let's remove it.
data=data[data['Series'] != "CPI Price, % y-o-y, not seas. adj."]
print(data["Series"].unique())

os.chdir(working_dir)
os.chdir("clean")
data.to_csv('cleaned_data.csv', mode="w") #Let's save the cleaned data set

#Let's create a list of the 5 countries with the largest industrial production
top5_ip=data[(data["Time"] == "2017") & (data["Series"] == "Industrial Production, billions of constant US$")].nlargest(5, "Value")[["Country","Value"]]
print(top5_ip[0:2]) #From the output we now know that the two largers industrial producers are China and the USA

#Let's create a graph for the YoY growth of China vs the USA interms of industrial production
print(data.loc[(data["Country"] == "China") & (data["Series"] == "Industrial Production, billions of constant US$")]) #In this table we can see that there is data available for YoY from 1992 to 2017

import matplotlib.pyplot as plt

x=data.loc[(data["Country"] == "China") & (data["Series"] == "Industrial Production, billions of constant US$"), 'Time'] #I want the Time to be on the X axis
y1=data.loc[(data["Country"] == "China") & (data["Series"] == "Industrial Production, billions of constant US$"), 'YoY Change']
y2=data.loc[(data["Country"] == "United States") & (data["Series"] == "Industrial Production, billions of constant US$"), 'YoY Change'] #And the industrial production of the two countries on the Y axis

plt.plot(x,y1, label="China", color='red')
plt.plot(x,y2, label="USA", color='blue')
plt.legend(loc="upper right")
plt.title("Year on Year Growth of Industrial Production of China and the USA 1992-2017")
plt.xlabel("Year")
plt.ylabel("% Growth")
plt.grid()
plt.show()

print("Value and YoY change of Industrial production of China (in billions, constant USD)") #Let's make a summary statistic table of Chinas industrial production
print(data.loc[(data["Country"] == "China") & (data["Series"] == "Industrial Production, billions of constant US$"), ["YoY Change","Value"] ].describe())