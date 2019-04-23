# Configure lab DHCP failover

$name = "dc01-dc00-Failover"
$partnerServer = "dc00.husen.local"
$partnerv4Address = "10.0.100.10"
$scopeId = Get-DhcpServerv4Scope
$sharedSecret = "DhcpSecret01"

Add-DhcpServerInDC `
    -DnsName $partnerServer `
    -IPAddress $partnerv4Address

Add-DhcpServerv4Failover `
    -ComputerName $env:COMPUTERNAME `
    -Name $name `
    -PartnerServer $partnerServer `
    -ScopeId $scopeId.ScopeId.IpAddressToString `
    -SharedSecret $sharedSecret `
    -Force
