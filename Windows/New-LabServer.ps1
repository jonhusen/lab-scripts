#

# User supplied parameters
$hostname = Read-Host -Prompt "New hostname"
$IpAddress = Read-Host -Prompt "IP address"
$prefix = Read-Host -Prompt "Network prefix"
$gateway = Read-Host -Prompt "Default gateway"
$DnsAddress = "10.0.100.11"

$ethernet = Get-NetAdapter | Where-Object {$_.Name -like "ethernet*"}

# Configure host
New-NetIPAddress -IPAddress $IpAddress -InterfaceIndex $ethernet.ifIndex -AddressFamily IPv4 -PrefixLength $prefix -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceIndex $ethernet.ifIndex -ServerAddresses $DnsAddress
Set-TimeZone -Id "Eastern Standard Time"
if ($hostname -ne '') {
    Rename-Computer -NewName $hostname
}
# Check for updates
# needs work
$AutoUpdates = New-Object -ComObject "Microsoft.Update.AutoUpdate"
$AutoUpdates.DetectNow()

Start-Job { echo 6 a a | sconfig }

Restart-Computer
