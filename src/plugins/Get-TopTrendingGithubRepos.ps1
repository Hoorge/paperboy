param(
    $topic="PowerShell",
    $Duration = 'Weekly',
    $Count = 5
)
Write-Verbose "Fetching popular GitHub repositories ($Duration)" 
$Github  = Invoke-Expression -Command "python.exe ./src/plugins/GithubRepoTrends.py $Duration $topic"
$all = Foreach($repo in $Github){
    [pscustomobject](Convert-PythonDictionaryToPowershellHashTable $repo)
}

# $all | Select-Object repo,stars*,*count, d* -First $Count | ft -AutoSize
$all
