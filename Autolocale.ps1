## Edit to reflect the Garena current and prefered locale.
## @downthecrop

$old = "th_TH"
$new = "en_US"

param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Kill-Tree {
    Param([int]$ppid)
    Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ppid } | ForEach-Object { Kill-Tree $_.ProcessId }
    Stop-Process -Id $ppid
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

'running with full privileges'

try {
    $client_process = Get-CimInstance Win32_Process -Filter "name = 'RiotClientServices.exe'"
    $command = $client_process.CommandLine -replace($old, $new)
    Kill-Tree $client_process.ProcessId
    cmd.exe /c $command
    exit
}
catch {}
