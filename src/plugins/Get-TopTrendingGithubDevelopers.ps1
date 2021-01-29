param(
    $topic="PowerShell",
    $Duration = 'Weekly',
    $Count = 5
)
Write-Verbose "Fetching popular GitHub Developers ($Duration)" 
$Github  = Invoke-Expression -Command "python.exe ./src/plugins/GithubDeveloperTrends.py $Duration $topic"
$all = Foreach($dev in $Github){
    [pscustomobject](Convert-PythonDictionaryToPowershellHashTable $dev)
}

# $all | Select-Object repo,stars*,*count, d* -First $Count | ft -AutoSize
$all
