param(
    $Search = 'powershell',
    $Count = 500,
    $order = 'date',
    $type = 'video'
    # $Search = 'powershell'
    # $Count = 10
    # $order = 'date'
    # $type = 'video'
    # $metric = 'views,comments,favoritesAdded,favoritesRemoved,likes,dislikes,shares'
)
Write-Verbose "Searching Youtube | keyword=$Search count=$Count order=$order type=$type" 

$results = python.exe  ./src/plugins/Youtube.py --q $Search --order $order --type $type --developer-key $configs['DEVELOPER_KEY'] --youtube-api-service-name $configs['YOUTUBE_API_SERVICE_NAME'] --youtube-api-version $configs['YOUTUBE_API_VERSION']

$youtubeObjs = foreach ($item in $results)
{
    $item | ConvertFrom-Json
}

$yt = $youtubeObjs | ForEach-Object {
    [PSCustomObject] @{
        kind             = $_.kind
        id               = $_.id
        date             = [datetime]$_.Date #Parse-CustomDate -DateString ($_.date -replace "\.000Z", "") -DateFormat 'yyyy-MM-ddTHH:mm:ss'
        title            = $_.title
        description      = $_.description
        channelTitle     = $_.channelTitle
    }
}

# $yt | Select-Object -First $Count #| ft -AutoSize


# python.exe .\Youtube_Analytics.py --filters="video==0LKeledvyngD"
