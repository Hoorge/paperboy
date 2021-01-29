import requests, string, sys, re
from bs4 import BeautifulSoup

baseURL = 'https://github.com/'
githubURL =  "https://github.com/trending/{}".format(sys.argv[2])
github_repo = {}

if sys.argv[1] == 'weekly':
    githubURL = githubURL + '?since=weekly'
    key='StarsThisWeek'
elif sys.argv[1] == 'monthly':
    githubURL = githubURL + '?since=monthly'
    key='StarsThisMonth'
else:
    key='StarsToday'

# requesting the web URL
page = requests.get(githubURL)
soup = BeautifulSoup(page.content, 'html.parser')
#print(soup.prettify()) # Parses the content and a readable format
article_tags = soup.find_all('article', {"class": "Box-row"})

for article in article_tags:
    try:
        reponame = article.find_all('h1')[0].find_all('a')[0].get('href')
        description = article.find_all('p', {"class": "col-9 text-gray my-1 pr-4"})[0].get_text().strip()
        stars = article.find_all('a', {"class": "muted-link d-inline-block mr-3"})[0].get_text().strip()
        forks = article.find_all('a', {"class": "muted-link d-inline-block mr-3"})[1].get_text().strip()
        numStars = article.find_all('span', {"class": "d-inline-block float-sm-right"})[0].get_text().strip().split(' ')[0]
        github_repo["Repo"] =  reponame.lstrip('/')
        github_repo["RepoURL"] = "https://github.com" + reponame
        github_repo["Description"] = description
        github_repo["Stars"] = stars
        github_repo["Forks"] = forks
        github_repo["NumOfStarsToday"] = numStars
        print(github_repo)
    except:
        continue