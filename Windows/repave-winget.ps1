<#
.SYNOPSIS
    Reinstall apps on a fresh workstation
.DESCRIPTION
    Script to reinstall preferred apps using winget and configure customized
    settings on a new pc.
.NOTES
    Works best with Windows 11
    Run using an administrator terminnal

    If repaving a workstation, deactivate the following applicationns
      - PhaseOne Capture One Pro
      - RoyalApps Royal TS
      - Solarwinds Standard Toolset
.EXAMPLE
    repave-winget.ps1
    Installs all winget software including Chocolatey. Chocolatey is used to
    manage apps not available in winget.
    Skips Python and WSL installation. WSL may have compatibility issues with
    VMware Workstation.
.EXAMPLE
    repave-winget.ps1 -PyVersion 3.12.2 -InstallWSL:$true
    Installs all winget software and Chocolatey managed apps.
    Installs specified Python version and WSL with Ubuntu
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    # Install utilities
    [Parameter()]
    [bool]
    $Utilities = $true,
    # Install general apps
    [Parameter(Mandatory = $false)]
    [bool]
    $Apps = $true,
    # Install gaming apps
    [Parameter(Mandatory = $false)]
    [bool]
    $Games = $true,
    # Install internet apps
    [Parameter(Mandatory = $false)]
    [bool]
    $Internet = $true,
    # Install sysadmin tools
    [Parameter(Mandatory = $false)]
    [bool]
    $SysAdmin = $true,
    # Install programming tools
    [Parameter(Mandatory = $false)]
    [bool]
    $Programming = $true,
    # Install app suites
    [Parameter(Mandatory = $false)]
    [bool]
    $Suites = $true,
    # Install Windows Store apps
    [Parameter(Mandatory = $false)]
    [bool]
    $WinStore = $true,
    # Python version to install
    [Parameter(Mandatory = $false)]
    [string]
    $PyVersion,
    # Install WSL
    [Parameter(Mandatory = $false)]
    [bool]
    $InstallWSL = $false
)

Set-ExecutionPolicy Bypass -Scope Process -Force

# Install via winget
$utilsList = [PSCustomObject]@{
    Install     = $Utilities
    InstallList = (
        "7zip.7zip",
        "Balena.Etcher",
        "REALiX.HWiNFO",
        "Logitech.OptionsPlus",
        "Rufus.Rufus"
    )
}


$appsList = [PSCustomObject]@{
    Install     = $Apps
    InstallList = (
        "Audient.EVO",
        "Bitwarden.Bitwarden",
        "CPUID.CPU-Z",
        "DygmaLabs.Bazecor",
        "Flameshot.Flameshot",
        "FlorianHoech.DisplayCAL",
        "Microsoft.PowerToys",
        "PeterPawlowski.foobar2000",
        "RaspberryPiFoundation.RaspberryPiImager",
        "TechPowerUp.GPU-Z",
        "VideoLAN.VLC"
    )
}

$gamesList = [PSCustomObject]@{
    Install     = $Games
    InstallList = (
        "Bethesda.Launcher",
        "ElectronicArts.Origin",
        "EpicGames.EpicGamesLauncher",
        "Logitech.LGS",
        "Valve.Steam"
    )
}

$internetList = [PSCustomObject]@{
    Install     = $Internet
    InstallList = (
        "Mozilla.Firefox",
        "Google.GoogleDrive",
        "Google.Chrome",
        "Google.ChromeRemoteDesktop"
    )
}

$sysadminList = [PSCustomObject]@{
    Install     = $SysAdmin
    InstallList = (
        "Anaconda.Anaconda3",
        "GlavSoft.TightVNC",
        "JanDeDobbeleer.OhMyPosh",
        "Kubernetes.minikube",
        "Microsoft.PowerShell",
        "Microsoft.SQLServerManagementStudio",
        "Microsoft.VisualStudioCode",
        "Postman.Postman",
        "RoyalApps.RoyalTS.V7",
        "WiresharkFoundation.Wireshark"
    )
}

$programmingList = [PSCustomObject]@{
    Install     = $Programming
    InstallList = (
        "Git.Git",
        "GitHub.GitHubDesktop",
        "JetBrains.PyCharm.Community"
    )
}

$installByTag = [PSCustomObject]@{
    Install     = $Suites
    InstallList = (
        "sysinternals"
    )
}

# Windows store apps
$installByID = [PSCustomObject]@{
    Install     = $WinStore
    InstallList = (
        "9NRSP6BRXBZQ"  # Bible by Olive Tree
    )
}


$appInstallList = (
    $utilsList,
    $appsList,
    $gamesList,
    $internetList,
    $sysadminList,
    $programmingList
)

foreach ($list in $appInstallList) {
    if ($list.Install -eq $true) {
        foreach ($app in $list.InstallList) {
            & winget.exe install $app --accept-package-agreements
        }
    }
}

# if ($installByTag.Install -eq $true) {
#     foreach ($app in $installByTag.InstallList) {
#         & winget.exe install --tag $app --accept-package-agreements --source winget
#     }
# }

if ($installByID.Install -eq $true) {
    foreach ($app in $installByID.InstallList) {
        & winget.exe install --id $app --accept-package-agreements
    }
}


# Chocolatey setup and installation
& winget install Chocolatey.Chocolatey --accept-package-agreements

$chocoPath = "C:\ProgramData\chocolatey\choco.exe"

# Run in new shell since choco isn't on the current shell's path
powershell.exe -command "$chocoPath install veeam-agent -y"
powershell.exe -command "$chocoPath install vmwareworkstation -y"


# Python installation
if ($PyVersion) {
    $PyPath = @(
        $env:LOCALAPPDATA + "\Programs\Python3*\python.exe"
        $env:ProgramFiles + "\Python3*\python.exe"
        ${env:ProgramFiles(x86)} + "\Python3*\python.exe"
        $env:SystemDrive + "\Python3*\python.exe"
    )

    # Check for previous installations
    $PythonInstalled = $false
    foreach ($path in $PyPath) {
        if (Test-Path -Path $path) {
            $PythonInstalled = $true
        }
    }

    # Download and install python3
    if ($PythonInstalled -eq $false) {
        Write-Host "Python installation not detected in standard locations.`nDownloading Python 3"
        $Url = "https://www.python.org/ftp/python/$PyVersion/python-$PyVersion-amd64.exe"
        $Destination = $Env:TEMP + "\python-$PyVersion.exe"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($Url, $Destination)
        do {
            Start-Sleep -Seconds 30
        } until (Test-Path -Path $destination)
        Write-Host "Installing Python 3"
        . $Destination /quiet InstallAllUsers=1 PrependPath=1 Include_debug=1 Include_symbols=1
        do {
            Start-Sleep -Seconds 60
        } until (Test-Path -Path (${env:ProgramFiles} + "\Python3*\Scripts\pip.exe"))
        Start-Sleep -Seconds 30
    }
    $Version = & py --version
    Write-Host "$Version is installed.`nInstalling packages"

    # Upgrade pip before installing extensions
    py -m pip install --upgrade pip

    # Pip install other packages
    py -m pip install pipx
    py -m pipx ensurepath

    py -m pipx install poetry --include-deps
    py -m pipx install black
    py -m pipx install bandit
    py -m pipx install pytest --include-deps
    py -m pipx install ipykernel --include-deps
}


# Configure WSL
if ($InstallWSL -eq $true) {
    try {
        & wsl --install
    } catch {
        Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -NoRestart
        Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online -All -NoRestart
        $wslUri = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $file = "C:\temp\wsl_update_x64.msi"
        Invoke-WebRequest -Uri $wslUri -UseBasicParsing -OutFile $file
        & msiexec.exe /i $file
        & wsl --set-default-version 2
        & wsl --update
        & wsl --install -d Ubuntu
    }

}


<# handle manually

AMD Software, AOCL, Ryzen Master
Audeze HQ
WinPcap
argyll
GNS3
CaptureOne
Droplr
Synergy
LM Studio

#>
