import requests, string, sys, re
from bs4 import BeautifulSoup

# githubURL = 'https://github.com/trending/developers/powershell?since=weekly'
githubURL =  "https://github.com/trending/developers/{}".format(sys.argv[2])
github_dev = {}

if sys.argv[1] == 'weekly' or sys.argv[1] == 'Weekly':
    githubURL = githubURL + '?since=weekly'
elif sys.argv[1] == 'monthly' or sys.argv[1] == 'Monthly':
    githubURL = githubURL + '?since=monthly'
else:
    pass

# print(githubURL)

# requesting the web URL
page = requests.get(githubURL)
soup = BeautifulSoup(page.content, 'html.parser')
#print(soup.prettify()) # Parses the content and a readable format
article_tags = soup.find_all('article', {"class": "Box-row"})

for article in article_tags:
    try:
        dev_name = article.find_all('h1')[0].text.strip()
        dev_alias = article.find_all('h1')[0].find('a').get('href')
        dev_url = 'https://github.com{}'.format(dev_alias)
        dev_popular_repo = article.find_all('h1', {"class": "h4 lh-condensed"})[0].find('a')
        dev_popular_repo_url = 'https://github.com{}'.format(dev_popular_repo.get('href'))
        dev_popular_repo_name = dev_popular_repo.text.strip()
        dev_popular_repo_description = article.find_all('div', {"class": "f6 text-gray mt-1"})[0].text.strip()
        github_dev["dev_name"] =  dev_name
        github_dev["dev_url"] = dev_url
        github_dev["dev_popular_repo_name"] = dev_popular_repo_name
        github_dev["dev_popular_repo_url"] = dev_popular_repo_url
        github_dev["dev_popular_repo_description"] = dev_popular_repo_description
        print(github_dev)
    except:
        continue