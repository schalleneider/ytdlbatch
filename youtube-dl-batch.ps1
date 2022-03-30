
# Usage

# -Path -> input must be a txt file with one youtube link per line.
# .\youtube-dl-batch.ps1 -Path .\links.txt -OutPath "C:\mp3-out\"

# CsvPath -> input must be a csv file with one music information per row. Coumn specification: 'Id','Music','Artist','Anime','Type','Link'
# .\youtube-dl-batch.ps1 -CsvPath .\database.csv -OutPath "C:\mp3-out\"

[CmdletBinding()]
param
(
    [string] $Path = "",
    [string] $CsvPath = "",
    [string] $OutPath = "C:\mp3-out\",
    [switch] $TruncateFileName = $false
)

begin
{
    Function Remove-InvalidFileNameChars 
    {
        param
        (
            [String]$Name
        )
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
        $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
        return ($Name -replace $re)
    }
}

process
{
    if ($Path.Length -gt 0) {
        Get-Content -Path $Path | % {
            .\bin\youtube-dl.exe -x --audio-format mp3 -o ($OutPath + "%(title)s.%(ext)s") "$_"
        }
    }
    elseif ($CsvPath.Length -gt 0) {
        Import-Csv -Path $CsvPath -Header 'Id','Music','Artist','Anime','Type','Link' | % {    
            $mp3FileName = ("'{0}'_'{1}'_'{2}'_'{3} - {4}'" -f $_.Id, $_.Artist, $_.Music, $_.Anime, $_.Type)
            $mp3FileName = Remove-InvalidFileNameChars -Name $mp3FileName
            
            if ($TruncateFileName -and ($OutPath + $mp3FileName).Length -gt 200)
            {
                $mp3FileName = $mp3FileName.Substring(0, 200 - ($OutPath).Length)
            }
            
            $ytLink = $_.Link
            if ($ytLink.Length -gt 0) {
                .\bin\youtube-dl.exe -x --audio-format mp3 -o ($OutPath + $mp3FileName + ".%(ext)s") "$ytLink"
            }
        }
    }
    else {
        Write-Host "Missing parameter."
    }
}