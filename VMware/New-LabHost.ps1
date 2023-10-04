<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

[CmdletBinding()]
param (
    # vCenter hostname
    [Parameter(Mandatory = $true)]
    [string]
    $vCenter,
    # vCenter Credentials
    [Parameter(Mandatory = $true)]
    [pscredential]
    $Credential,
    # New ESXi hostname
    [Parameter(Mandatory = $true)]
    [string]
    $NewHost,
    # iSCSI storage network prefixes (comma separated)
    [Parameter()]
    [string]
    $StorageNetworks,
    # Storage subnet mask
    [Parameter()]
    [string]
    $StorageSubnet = "255.255.255.0",
    # iSCSI storage targets (comma separated)
    [Parameter()]
    [string]
    $iSCSITargets
)

Connect-VIServer -Server $vCenter -Credential $Credential

$vmHost = Get-VMHost -Name $NewHost
$vmk = Get-VMHostNetworkAdapter -VMHost $vmHost -VMKernel | Sort-Object
$deviceIP = $vmk[0].IP.Split(".")[-1]  # Last octet of the host ip
$labVDS = Get-VDSwitch -Name "DSwitch"

# Storage Config
$storageNetworks = $StorageNetworks.Split(",").Trim()
$vmk = Get-VMHostNetworkAdapter -VMHost $vmHost -VMKernel

foreach ($StorageNet in $storageNetworks) {
    if ($vmk.Name -notcontains "vmk1") {
        $ip = $StorageNet + $deviceIP
        $storageParams = @{
            IP            = $ip
            SubnetMask    = $StorageSubnet
            Mtu           = 9000
            PortGroup     = Get-VDPortgroup | Where-Object { $_.Name -like "*storage20" }
            VirtualSwitch = $labVDS
            VMHost        = $vmHost
            Confirm       = $false
        }
        New-VMHostNetworkAdapter @storageParams
    }
    if ($vmk.Name -notcontains "vmk2") {
        $ip = $StorageNet + $deviceIP
        $storageParams = @{
            IP            = $ip
            SubnetMask    = $StorageSubnet
            Mtu           = 9000
            PortGroup     = Get-VDPortgroup | Where-Object { $_.Name -like "*storage21" }
            VirtualSwitch = $labVDS
            VMHost        = $vmHost
            Confirm       = $false
        }
        New-VMHostNetworkAdapter @storageParams
    }
}

Get-VMHostStorage -VMHost $vmHost | Set-VMHostStorage -SoftwareIScsiEnabled $true

$iscsiTargets = $iSCSITargets.Split(",").Trim()
foreach ($tgt in $iSCSITargets) {
    Set-IScsiHbaTarget -Target $tgt -Server $vmHost
}
