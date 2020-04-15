<#
.SYNOPSIS
    Upgrade vCSA on ESXi host
.DESCRIPTION
    Uses the json template to deploy the vCSA 7.0 on an ESXi host.
    Primarily meant for use in home lab but can be modified for production use.
    Assumes deployment is initiated from a Windows OS and VCSA iso is mounted.
.EXAMPLE
    PS C:\> .\vcsa_deploy.ps1 -RepoPath "C:\git"
    Runs template verification
    Looks for json template in c:\git\lab-scripts\VMware\vcsa\lab_vcsa_installation.json

    PS C:\> .\vcsa_deploy.ps1 -RepoPath "C:\git" -Install:$true
    Deploys vCSA to ESXi host specified in the json template
.INPUTS
    -RepoPath
        Path to git folder where lab-scripts repo was cloned
    [Boolean]
    -Install
        $true - Installs vCSA based on json template
        $false (Default) - Runs template verification
.OUTPUTS
    Logs in %localappdata%\Temp\vcsaCliInstaller-*
.NOTES
    General notes
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [String]
    $RepoPath,
    [Parameter()]
    [Boolean]
    $Upgrade = $false
)

while (!(Test-Path -Path $RepoPath)) {
    $RepoPath = Read-Host -Prompt "Path to git repo folder where lab-scripts repo was cloned"
}
$Template = "\lab-scripts\VMware\vcsa\lab_vcsa_upgrade_vc.json"
$TemplatePath = ($RepoPath + $Template).Replace("\\", "\")

$OpticalDrive = (Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object VolumeName -EQ "VMware VCSA").DeviceID
$Installer = "\vcsa-cli-installer\win32\vcsa-deploy.exe"
$InstallerPath = $OpticalDrive + $Installer

$Args = @(
    "--no-ssl-certificate-verification"
    "--accept-eula"
    "--acknowledge-ceip"
)

if ($Upgrade) {
    # Upgrade VCSA
    & $InstallerPath upgrade @Args --log-dir "$env:SystemDrive\temp\vcsa_upgrade" $TemplatePath
} else {
    # Perform Prechecks
    & $InstallerPath upgrade @Args --precheck-only $TemplatePath
    Write-Host "`nTo install, run with -Install:`$true`n"
}
