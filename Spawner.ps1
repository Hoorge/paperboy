[cmdletbinding()]
param(
    $subject = "powershell"
)

$scriptstart = Get-Date

. "$PSScriptRoot\src\utils\functions.ps1" # dot source required functions

# get the twitter and youtube API secrets and tokens
$configs = @{}
Get-Content ./secrets.txt | 
Where-Object { !$_.StartsWith("#") -and ![string]::IsNullOrEmpty($_) } | 
ForEach-Object {
    $key, $value = $_.split('=')
    $configs[$key] = $value
}

# TODO: optimize the fetch calls to a single function iterating over various plugins like: youtube, twitter, reddit, leanpub etc

#region fetch-data
Write-Host " [+] Fetching top Github Repo trends on topic: `'$subject`'" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$github = & "$PSScriptRoot\src\plugins\Get-TopTrendingGithubRepos.ps1" $subject 'weekly'
$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

Write-Host " [+] Fetching top Github Developer trends on topic: `'$subject`'" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$github_dev = & "$PSScriptRoot\src\plugins\Get-TopTrendingGithubDevelopers.ps1" $subject 'weekly'
$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

Write-Host " [+] Fetching top Tweets on topic: `'$subject`'" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$twitter = & "$PSScriptRoot\src\plugins\Get-TopTweets.ps1" "#$subject" 10
$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

Write-Host " [+] Fetching top Reddit posts on /r/$subject" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$reddit = & "$PSScriptRoot\src\plugins\Get-TopSubReddits.ps1" $subject 10
$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

# TODO: api quota exceeded test another time
# Write-Host " [+] Fetching new Youtube videos on topic: `'$subject`'" -ForegroundColor Cyan -NoNewline
# $start = Get-Date
# $youtube = & "$PSScriptRoot\src\plugins\Get-Youtube.ps1" $subject
# $end = Get-Date
# Write-Host " [Done]" -ForegroundColor Green -NoNewline
# Write-Host " $($end-$start)" -ForegroundColor DarkGray

Write-Host " [+] Fetching bestseller books from Leanpub on topic: `'$subject`'" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$leanpub = & "$PSScriptRoot\src\plugins\Get-TopLeanpub.ps1" $subject
# $leanpub = & ".\src\plugins\Get-TopLeanpub.ps1" $subject # for testing
$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

#endregion fetch-data

#region select-data-for-table
Write-Host " [+] Selecting data to represent in tabular form" -ForegroundColor Cyan -NoNewline
$start = Get-Date

$github_html = $github |
Select-Object   @{n = "Repository"; e = { "<a class=`"fancylink`" href=" + $_.RepoURL + ">" + $_.Repo + "</a>" } }, 
Description,
Stars,
Forks,
@{n = "Num Of Stars Today"; e = { $_.NumOfStarsToday } } |
ConvertTo-Html -Fragment


$github_dev_html = $github_dev |
Select-Object   @{n = "Developer"; e = { "<a class=`"fancylink`" href=" + $_.dev_url + ">" + $_.dev_name + "</a>" } }, 
@{n = "Popular Repository"; e = { "<a class=`"fancylink`" href=" + $_.dev_popular_repo_url + ">" + $_.dev_popular_repo_name + "</a>" } }, 
@{n = "Repository Description"; e = { $_.dev_popular_repo_description } } |
ConvertTo-Html -Fragment

                
$twitter_html = $twitter |
Select-Object   @{n = "Twitter Handle"; e = { "<a class=`"fancylink`" href=https://twitter.com/" + $_.screen_name + ">@" + $_.screen_name + "</a>" } },
@{n = "Retweet Count"; e = { $_.retweet_count } },
@{n = "Favorite Count"; e = { $_.favorite_count } },
@{n = "Status"; e = { $_.text } },
@{n = "Status URL"; e = { "<a class=`"fancylink`" href=" + $_.url + ">[Tweet]</a>" } } |
ConvertTo-Html -Fragment                                
                
$reddit_html = $reddit |
Select-Object   @{n = "Author"; e = { "<a class=`"fancylink`" href=https://www.reddit.com/user/" + $_.author + ">/u/" + $_.author + "</a>" } },
@{n = "Title"; e = { $_.title } },
@{n = "Ups"; e = { $_.ups } },
@{n = "Num of Comments"; e = { $_.numcomments } },
@{n = "URL"; e = { "<a class=`"fancylink`" href=" + $_.url + ">[Post]</a>" } } |
ConvertTo-Html -Fragment                                
                
$youtube_html = $youtube |
Select-Object   @{n = "Channel"; e = { $_.channelTitle } },
@{n = "Title"; e = { $_.title } },
@{n = "URL"; e = { "<a class=`"fancylink`" href=https://youtu.be/" + ($_.id).videoid + ">[Video]</a>" } } |
ConvertTo-Html -Fragment           
                
$leanpub_html = $leanpub | ConvertTo-Html -Fragment


# TODO: write a function to to sanitize captured data instead of sanitizing individual HTML fragments here
$youtube_html = $youtube_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""
$github_html = $github_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""
$github_dev_html = $github_dev_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""
$reddit_html = $reddit_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""
$twitter_html = $twitter_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""
$leanpub_html = $leanpub_html -replace "&lt;", "<" -replace "&gt;", ">" -replace "&quot;", "`""


$end = Get-Date
Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray
#endregion select-data-for-table

#region generate-html

# TODO: choose best results from each plugins and auto populate the "editor's pick" section
# right now it is simply a template with harcoded info, which is edited manually

Write-Host " [+] Embedding data and generating HTML" -ForegroundColor Cyan -NoNewline
$start = Get-Date
$template = Get-Content .\template.html
$output = $template | foreach { $ExecutionContext.InvokeCommand.ExpandString($_) }
$output | Out-File "$env:TEMP\newsletter.html" -verbose
$end = Get-Date

Write-Host " [Done]" -ForegroundColor Green -NoNewline
Write-Host " $($end-$start)" -ForegroundColor DarkGray

#endregion generate-html
$scriptend = Get-Date
Write-Host "`n`nTotal time elapsed: $($scriptend-$Scriptstart)" -ForegroundColor Magenta