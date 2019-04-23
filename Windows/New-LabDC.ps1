# New lab dc with dns & dhcp options

# Select and validate AD deployment config
$ADDeployConfig = Read-Host -Prompt "AD Deployment type
    1. Add DC to existing domain
    2. Add new domain to existing forest
    3. New forest

    Select option number above"

while ($ADDeployConfig -ne "1" -and $ADDeployConfig -ne "2" -and $ADDeployConfig -ne "3") {
    $ADDeployConfig = Read-Host -Prompt "AD Deployment type
        1. Add DC to existing domain
        2. Add new domain to existing forest
        3. New forest

        Select option number above"
}

# Domain config options
$DomainName = "husen.local"
$DbPath = "C:\Windows\NTDS"
$LogPath = "C:\Windows\NTDS"
$SysvolPath = "C:\Windows\SYSVOL"
$SiteName = "Default-First-Site-Name"
$InstallDns = $true
$InstallDhcp = $true
$NoGlobalCatalog = $false
$ForestMode = "WinThreshold"
$DomainMode = "WinThreshold"

$DomainCredentials = Get-Credential -UserName ("{0}\administrator" -f $DomainName.Split(".")[0]) -Message ("Domain credentials for {0} domain" -f $DomainName.Split(".")[0])

# Install DC roles
Write-Host -Object "Installing AD DS"
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Write-Host -Object "Installing DNS"
if ($InstallDns) {
    Install-WindowsFeature DNS -IncludeManagementTools
}

Write-Host -Object "Installing DHCP"
if ($InstallDhcp) {
    Install-WindowsFeature DHCP -IncludeManagementTools
}

# Configure DC
switch ($ADDeployConfig) {
    1 {
        Write-Host "Adding DC to existing domain"
        Import-Module ADDSDeployment
        Install-ADDSDomainController `
            -NoGlobalCatalog:$NoGlobalCatalog `
            -CreateDnsDelegation:$false `
            -Credential $DomainCredentials `
            -CriticalReplicationOnly:$false `
            -DatabasePath $DbPath `
            -DomainName $DomainName `
            -InstallDns:$InstallDns `
            -LogPath $LogPath `
            -NoRebootOnCompletion:$false `
            -SiteName $SiteName `
            -SysvolPath $SysvolPath `
            -Force:$true
    }
    2 {
        Write-Host "Adding child domain to existing forest"
        $ChildDomain = Read-Host -Prompt "Name of new child domain"
        Import-Module ADDSDeployment
        Install-ADDSDomain `
            -NoGlobalCatalog:$NoGlobalCatalog `
            -CreateDnsDelegation:$true `
            -Credential $DomainCredentials `
            -DatabasePath $DbPath `
            -DomainMode $DomainMode `
            -DomainType "ChildDomain" `
            -InstallDns:$InstallDns `
            -LogPath $LogPath `
            -NewDomainName $ChildDomain `
            -NewDomainNetbiosName $ChildDomain.ToUpper() `
            -ParentDomainName $DomainName.Split(".")[0] `
            -NoRebootOnCompletion:$false `
            -SiteName $SiteName `
            -SysvolPath $SysvolPath `
            -Force:$true
    }
    3 {
        Write-Host "Configuring new forest"
        Import-Module ADDSDeployment
        Install-ADDSForest `
            -CreateDnsDelegation:$false `
            -DatabasePath $DbPath `
            -DomainMode $DomainMode `
            -DomainName $DomainName `
            -DomainNetbiosName ($DomainName.Split(".")[0]).ToUpper() `
            -ForestMode $ForestMode `
            -InstallDns:$InstallDns `
            -LogPath $LogPath `
            -NoRebootOnCompletion:$false `
            -SysvolPath $SysvolPath `
            -Force:$true
    }

    Default {}
}
