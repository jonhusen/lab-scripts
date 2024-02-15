<# Repave Workstation

Deactivate before repave
PhaseOne Capture One Pro
Solarwinds Standard Toolset

#>

# Configure WSL
#try {
#    & wsl --install
#} catch {
#    Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -NoRestart
#    Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online -All -NoRestart
#    $wslUri = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
#    $file = "C:\temp\wsl_update_x64.msi"
#    Invoke-WebRequest -Uri $wslUri -UseBasicParsing -OutFile $file
#    & msiexec.exe /i $file
#    & wsl --set-default-version 2
#    & wsl --update
#    & wsl --install -d Ubuntu
#}

# Configure Windows features
#Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -All -NoRestart

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Utilities
chocolatey install 7zip.install -y
chocolatey install autohotkey.portable -y
chocolatey install etcher -y
chocolatey install hwinfo -y
#chocolatey install javaruntime -y  # Metapackage for latest jre
#chocolatey install setpoint -y
chocolatey install logitech-options -y
chocolatey install mousewithoutborders -y
chocolatey install rufus -y
chocolatey install sysinternals -y
chocolatey install veeam-agent -y
chocolatey install WinPcap -y

# Apps
#chocolatey install adobereader -y
chocolatey install argyll -y
#chocolatey install audacity -y
#chocolatey install audacity-lame -y
chocolatey install bitwarden -y
#chocolatey install calibre -y
chocolatey install cpu-z -y
chocolatey install dispcalgui -y
chocolatey install foobar2000 -y
#chocolatey install googleearthpro -y
chocolatey install gpu-z -y
#chocolatey install handbrake -y
#chocolatey install iperf3 -y
#chocolatey install itunes -y
#chocolatey install kodi -y
#chocolatey install lastpass -y
chocolatey install rpi-imager -y
chocolatey install steam -y
chocolatey install vlc -y

# Internet
#chocolatey install AzurePowerShell -y
#chocolatey install dropbox -y
#chocolatey install filezilla -y
chocolatey install Firefox -y
chocolatey install google-drive-file-stream -y
chocolatey install googlechrome -y
chocolatey install nordvpn -y
#chocolatey install teamviewer -y

# Dev/sysadmin
chocolatey install anaconda3 -y
#chocolatey install baretail -y
#chocolatey install docker-desktop -y
#chocolatey install fiddler4 -y
chocolatey install git.install -y
chocolatey install github-desktop -y
chocolatey install git-credential-manager-for-windows -y
#chocolatey install intellijidea-community -y
chocolatey install minikube -y
#chocolatey install mRemoteNG -y
chocolatey install pingplotter -y
chocolatey install postman -y
chocolatey install putty -y
#chocolatey install python -y
#chocolatey install python2 -y
#chocolatey install pip -y
chocolatey install PyCharm-community -y
chocolatey install royalts-v5 -y
chocolatey install sql-server-management-studio -y
chocolatey install tftpd32 -y
#chocolatey install tightvnc -y
chocolatey install spf13-vim -y
#chocolatey install virtualbox -y
#chocolatey install virtualbox.extensionpack -y
#chocolatey install vagrant -y
chocolatey install VSCode -y
#chocolatey install visualstudio2017community -y
#chocolatey install vmwarevsphereclient -y
chocolatey install vmwareworkstation -y
chocolatey install wireshark -y


# Uninstall from Chocolatey to allow built-in autoupdaters
choco uninstall steam --skippowershell --skipautouninstaller
choco uninstall google-drive-file-stream --skippowershell --skipautouninstaller

# Python installation
$PyVer = "3.10.1"

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
    $Url = "https://www.python.org/ftp/python/$PyVer/python-$PyVer-amd64.exe"
    $Destination = $Env:TEMP + "\python-$PyVer.exe"
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
$Version = py --version
Write-Host "$Version is installed.`nInstalling packages"

# Upgrade pip before installing extensions
py -m pip install --upgrade pip

# Pip install other packages
py -m pip install pipx
py -m pipx ensurepath

py -m pipx install poetry
py -m pipx install black
py -m pipx install bandit
py -m pipx install pytest
py -m pipx install ipykernel --include-deps

<# Other Software

Olive Tree Bible Study
Capture One 20
Cisco AnyConnect
Droplr
GNS3
HP Support Assistant
HP SoftPaq Download Manager
MS Office 365
MS Teams
pluralsight offline player
Solarwinds toolset
Synergy
Precision TP drivers
Audeze HQ
Corsair iCUE
Veeam Clients
Audient Evo
Battle.net
Bethesda launcher
Overwatch
Light Harminic control panel
thinkorswim

#>
