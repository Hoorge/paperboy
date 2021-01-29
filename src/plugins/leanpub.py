import requests, string, sys, re, time, json
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

leanpubURL =  "https://leanpub.com/bookstore?search={}".format(sys.argv[1])
book = {}
browser = webdriver.Chrome()
browser.get(leanpubURL)
time.sleep(3)
soup = BeautifulSoup(browser.page_source, 'html.parser')
# div_tags = soup.find_all('div', {"class": "lane-item--book"}) 
div_tags = soup.find_all('a',{"class": "ListItem__Text"}) 

i=1
book = {}
for div in div_tags:
    if i == 11:
        break
    book["rank"] = i
    book["url"] = "https://leanpub.com{}".format(div['href'])
    book["title"] = str(div.findAll('h3',{"class": "ListItem__Title"})[0].text)
    book["author"] = str(div.findAll('div', {"class": "names"})[0].findAll('span')).replace("[","").replace("]","")
    print(json.dumps(book))
    i=i+1