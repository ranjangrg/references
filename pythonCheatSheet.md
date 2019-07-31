# Python Cheat Sheet

##	"This is a line".rstrip("/n")
Ignores `/n` at the end of the string. If no arg given, ignores all whitespace characters. Similarly, `lstrip` ignores whitespace towards left of the string. Use `strip` to ignore all whitespace char all around.

## Read CSV file
```python
import csv 
data = []
with open('file.csv','rb') as csvfile: 
	reader = csv.reader(csvfile, delimiter=',', quotechar='|') 
	for row in reader:
		#add data to list or other data structure
	data.append(row)
```

## List comprehension
```python
S = [x**2 for x in range(10)]	#S = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
V = [2**i for i in range(13)]	#V = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
M = [x for x in S if x % 2 == 0] #M = [0, 4, 16, 36, 64]
```

## Sort a list containing tuples
```python
sorted_by_second = sorted(data, key=lambda tup: tup[1])
# OR 
data.sort(key=lambda tup: tup[1])  # sorts in place
# Example:
a = [(7, 14), (7, 12), (7, 6), (7, 10), (7, 8)]
sorted(a, key=lambda tup: tup[1])
gives
[(7, 6), (7, 8), (7, 10), (7, 12), (7, 14)]
Sorts using tup[1] i.e. second element of the tuple.
```

## `max(aList, key=lambda item: item[1])`
Finds max in a list of tuples based on the second element of the pair.
Example:
```python
aList = [(100,1), (1,2)] then
max(aList, key=lambda item: item[1]) gives (1,2)
```

## Retreive files from http
```python
import urllib.request
response = urllib.request.urlopen('http://www.example.com/')
html = response.read()

import urllib.request
urllib.request.urlretrieve('http://www.example.com/songs/mp3.mp3', 'mp3.mp3')
```

## Add third element to a tuple(/w 2 elems)
```python
a = ('2',)
b = 'z'
new = a + (b,)
```

## Separate Co-ordinates/ tuples (useful for plotting graphs with tuples)
```python
x = [1, 2, 3]
y = [4, 5, 6]
zip (x, y) # Gives [(1, 4), (2, 5), (3, 6)] after being cast to list i.e. list(zip(x, y))
```

## Reading config files
First, 
```python
import configparser
ourConfig = configparser.ConfigParser()
ourConfig.read("event.conf") # file path/name
```
Useful methods:
```python
ourConfig.get('column') # gives the 'column' part of the conf file
ourConfig.get('column', 'deeperColumn') # gives the 'deeperColumn' part from the column section of the conf file
ourConfig.sections() # gives the sections e.g.location, lt, rt etc
ourConfig.items('vehicle') # gives the items inside the vehicle section
```

## Using pip from cmd line
```python
py -m pip install <<package>>
```
> Note: Sometimes the command starts with `python -m` ... Check which command python uses in cmd prompt or terminal. Test it by running py, python, etc; whichever works.

## Log and Export all packages list.
```python
py pip freeze > packageList.txt
```
This will log all the packages installed to a file "`packageList.txt`".
Run command below in terminal/cmd prompt to install all the packages back:

```python
py pip install -r packageList.txt
```

## MySQL get Column Names from Query
`cursor.description` will give you a tuple of tuples where [0] for each is the column header.
```python
keys = [i[0] for i in cursor.description]
```

## Useful Print format
```python
print("{0:<10}: {1:<10}".format(name, surname), end = "\t")
```
>`<`				Right Aligned
>`{0:<10}`	At least 10 characters long. Width for this string will be at least 10 chars.

## Making request from dataservers etc
```python
import requests
url = 'https://updates.opendns.com/nic/update?hostname='
username = 'username'
password = 'password'
print(requests.get(url, auth=(username, password)).content)
```

## Install PyQt for Python 3 in Linux (Ubuntu)
```python
sudo apt-get install qtcreator pyqt5-dev-tools
```

## Python Pandas - read CSV
```python
import pandas as pd
df = pd.read_csv("fileName", sep=',', header=0) # first line is header
```

## Python Pandas - print all data in dataframe
```python
print (df.to_string())
```

## Print formatted strings
```python
name = "name last"
print ("{0: <5}".format(name))	# 5 spaced
```

## If pip install fails at "... failed building wheel ..."
```python
pip install <package-name> --no-cache-dir
```

## Creating and using "virtualenv"
Steps (Use `pip` instead of `pip3` for default Python instead of Python3.x:
1.	`$ pip3 install virtualenv`
2.	Create a dir to hold the environment and files.
`$ mkdir ./python_env01`
3.	Get in the directory created above and create environment
`$ cd ./python_env01`
`$ virtualenv new_project01`
4.	Activate environment
`$ source new_project01/bin/activate`
5.	Now we are in the environment. Use `pip3` to install packages.
`$ pip3 install numpy`
6.	ALWAYS, deactivate once done with the environment
`$ deactivate`
>note: Don't use `sudo` as it will bypass the environment altogether as `root` user

## Renaming "virtualenv" project name
Adjust variable names within these files: (source: https://stackoverflow.com/a/44075783)
```python
<environment directory>/bin/pip 	# line 1 (She bang; change path)
<environment directory>/bin/activate	# line 42 (VIRTUAL_ENV; change path)
```

## 