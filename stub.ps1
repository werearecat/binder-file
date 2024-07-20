param(
    [string]$file_ending1 = "YOUR_FILE_ENDING_HERE1",
    [string]$file_ending2 = "YOUR_FILE_ENDING_HERE2",
    [bool]$remove = $false
)

function Delete-TempFile {
    param (
        [string]$tempFile
    )
    try {
        Remove-Item -Path $tempFile -Force
        Write-Host 'Temp file deleted successfully.'
    } catch {
        Write-Error 'Error deleting temp file:'
    }
}

function Main {
    $tempDir1 = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "1." + $file_ending1)
    $tempDir2 = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "2." + $file_ending2)
    $b64stuff1 = "BASE64ENCODEDSTUFFHERE1"
    $b64stuff2 = "BASE64ENCODEDSTUFFHERE2"
    $decoded1 = [System.Convert]::FromBase64String($b64stuff1)
    $decoded2 = [System.Convert]::FromBase64String($b64stuff2)

    Set-Content -Path $tempDir1 -Value $decoded1 -Encoding Byte
    Set-Content -Path $tempDir2 -Value $decoded2 -Encoding Byte

    $cmdArgs = $args

    $allArgs1 = @("/C", "start", $tempDir1) + $cmdArgs
    $allArgs2 = @("/C", "start", $tempDir2) + $cmdArgs

    Start-Process -FilePath "cmd.exe" -ArgumentList $allArgs1 -NoNewWindow -Wait
    if ($remove) {
        Delete-TempFile -tempFile $tempDir1
    }

    Start-Process -FilePath "cmd.exe" -ArgumentList $allArgs2 -NoNewWindow -Wait
    if ($remove) {
        Delete-TempFile -tempFile $tempDir2
    }
}

Main @PSBoundParameters
