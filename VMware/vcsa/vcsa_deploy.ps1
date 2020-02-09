<#
.SYNOPSIS
    Install VCSA on ESXi host
.DESCRIPTION
    Uses the json template to deploy the VCSA on an ESXi host.
    Primarily meant for use in home lab but can be modified for production use.
    Assumes deployment is initiated from a Windows OS.
.EXAMPLE
    PS C:\> .\vcsa_deploy.ps1 -RepoPath "C:\git"
    Runs template verification
    Looks for json template in c:\git\lab-scripts\VMware\vcsa\lab_vcsa_installation.json

    PS C:\> .\vcsa_deploy.ps1 -RepoPath "C:\git" -Install:$true
    Deploys VCSA to ESXi host specified in the json template
.INPUTS
    -RepoPath
        Path to git folder where lab-scripts repo was cloned
    [Boolean]
    -Install
        $true - Installs VCSA based on json template
        $false (Default) - Runs template verification
.OUTPUTS
    Logs in %localappdata%\Temp\vcsaCliInstaller-*
.NOTES
    General notes
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $RepoPath,
    [Parameter()]
    [Boolean]
    $Install = $false
)

if (!($RepoPath)) {
    $RepoPath = Read-Host -Prompt "Path to git repo folder where lab-scripts repo was cloned"
}
$Template = "\lab-scripts\VMware\vcsa\lab_vcsa_installation.json"
$TemplatePath = ($RepoPath + $Template).Replace("\\", "\")

$OpticalDrive = (Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object VolumeName -EQ "VMware VCSA").DeviceID
$Installer = "\vcsa-cli-installer\win32\vcsa-deploy.exe"
$InstallerPath = $OpticalDrive + $Installer

$Args = @(
    "--no-esx-ssl-verify"
    "--accept-eula"
    "--acknowledge-ceip"
)

if ($Install) {
    # Install VCSA
    & $InstallerPath install @Args $TemplatePath
}
else {
    # Verify template
    & $InstallerPath install @Args --verify-template-only $TemplatePath
    Write-Host "`nTo install, run with -Install:`$true`n"
}
