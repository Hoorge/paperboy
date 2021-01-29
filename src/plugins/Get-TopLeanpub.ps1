param(
    $topic = 'powershell'
)

$file = New-TemporaryFile
Remove-Item $file -ErrorAction SilentlyContinue
$process = Start-Process pwsh.exe "-c python '$PSScriptRoot\leanpub.py' '$topic' | out-file $file -verbose" -PassThru

# $content = Invoke-Expression "python 'D:\Workspace\Repository\DashBoard\leanpub.py' 'powershell'"

while(1){
    if(($content = Get-Content $file -ErrorAction SilentlyContinue)){
        Start-Sleep -Seconds 5
        break
    }
}

foreach($item in $content){
    $item |
    ConvertFrom-Json |
    Foreach-Object {
        [PScustomObject]@{
            Rank = $_.rank
            Title = "<a class=`"fancylink`" href=`"{0}`">{1}</a>" -f $_.url, $_.title
            Author = $_.author
        }
    } 
}

$process | Stop-Process
Get-Process chrome |  Where-Object MainWindowTitle -like "*Leanpub*" | Stop-Process