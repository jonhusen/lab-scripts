# New lab dc with dns & dhcp

# User supplied parameters
$hostname = Read-Host -Prompt "New hostname"
$IpAddress = Read-Host -Prompt "IP address"
$prefix = Read-Host -Prompt "Network prefix"
$gateway = Read-Host -Prompt "Default gateway"
$DnsAddress = "10.0.100.11"

$newDomain = Read-Host -Prompt "Is this a new domain? Y/N"

# Domain config options
$domainName = "husen.local"
$DbPath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysvolPath = "C:\Windows\SYSVOL"
$dns = $true
$dhcp = $true


$ethernet = Get-NetAdapter | Where-Object {$_.Name -like "ethernet*"}

# Configure host
New-NetIPAddress -IPAddress $IpAddress -InterfaceIndex $ethernet.ifIndex -AddressFamily IPv4 -PrefixLength $prefix -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex $ethernet.ifIndex -ServerAddresses $DnsAddress
Set-TimeZone -Id "Eastern Standard Time"
Rename-Computer -NewName $hostname

# Check for updates
# needs work
$AutoUpdates = New-Object -ComObject "Microsoft.Update.AutoUpdate"
$AutoUpdates.DetectNow()

Start-Job { echo 6 a a | sconfig }

Restart-Computer

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
if ($dns) {
    Install-WindowsFeature DNS -IncludeManagementTools
}
if ($dhcp) {
    Install-WindowsFeature DHCP -IncludeManagementTools
}

if ($newDomain -eq "y") {
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath $DbPath `
        -DomainMode "WinThreshold" `
        -DomainName $domainName `
        -DomainNetbiosName $domainName.Split(".")[0] `
        -ForestMode "WinThreshold" `
        -InstallDns:$dns `
        -LogPath $LogPath `
        -NoRebootOnCompletion:$false `
        -SysvolPath $SysvolPath `
        -Force:$true
}
else {
    # Install additional dc in existing domain

}
