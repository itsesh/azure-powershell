﻿#
# Script module for module '%MODULE-NAME%' that is executed when '%MODULE-NAME%' is imported in a PowerShell session.
#
# Generated by: Microsoft Corporation
#
# Generated on: %DATE%
#

$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

if (%ISAZMODULE%)
{
    if ($PSVersionTable.PSVersion -lt [Version]'5.1')
    {
        throw "PowerShell versions lower than 5.1 are not supported in Az. Please upgrade to PowerShell 5.1 or higher."
    }

    Test-DotNet
}

try
{
    if (Test-Path -Path "$PSScriptRoot\StartupScripts")
    {
        Get-ChildItem "$PSScriptRoot\StartupScripts" | ForEach-Object {
            . $_.FullName
        }
    }
}
catch
{
    throw "Import-Module failed."
}

if (Get-Module %AZORAZURERM%.profile)
{
    Write-Warning "%AZORAZURERM%.Profile already loaded. Az and AzureRM module cannot be run side-by-side, please run 'Uninstall-AzureRm' to remove all AzureRm modules from your machine. More information can be found here: aka.ms/azps-migration-guide"
    throw "%AZORAZURERM%.Profile already loaded. Az and AzureRM module cannot be run side-by-side, please run 'Uninstall-AzureRm' to remove all AzureRm modules from your machine. More information can be found here: aka.ms/azps-migration-guide"
}

$preloadPath = (Join-Path $PSScriptRoot -ChildPath "PreloadAssemblies")
if($PSEdition -eq 'Desktop' -and (Test-Path $preloadPath))
{
    try
    {
        Get-ChildItem -Path $preloadPath -Filter "*.dll" | ForEach-Object {
            Add-Type -Path $_.FullName -ErrorAction Ignore | Out-Null
        }
    }
    catch {}
}

$netCorePath = (Join-Path $PSScriptRoot -ChildPath "NetCoreAssemblies")
if($PSEdition -eq 'Core' -and (Test-Path $netCorePath))
{
    try
    {
        $loadedAssemblies = ([System.AppDomain]::CurrentDomain.GetAssemblies() | %{New-Object -TypeName System.Reflection.AssemblyName -ArgumentList $_.FullName} )
        Get-ChildItem -Path $netCorePath -Filter "*.dll" | ForEach-Object {
            $assemblyName = ([System.Reflection.AssemblyName]::GetAssemblyName($_.FullName))
            $matches = ($loadedAssemblies | Where-Object {$_.Name -eq $assemblyName.Name})
            if (-not $matches)
            {
                Add-Type -Path $_.FullName -ErrorAction Ignore | Out-Null
            }
        }
    }
    catch {}
}


%IMPORTED-DEPENDENCIES%

$FilteredCommands = %DEFAULTRGCOMMANDS%

if ($Env:ACC_CLOUD -eq $null)
{
    $FilteredCommands | ForEach-Object {

        $existingDefault = $false
        foreach ($key in $global:PSDefaultParameterValues.Keys)
        {
    	    if ($_ -like "$key")
    	        {
        	    $existingDefault = $true
    	        }
	    }

        if (!$existingDefault)
        {
            $global:PSDefaultParameterValues.Add($_,
                {
                    if ((Get-Command Get-AzContext -ErrorAction Ignore) -eq $null)
                    {
                        $context = Get-AzureRmContext
                    }
                    else
                    {
                        $context = Get-AzContext
                    }
                    if (($context -ne $null) -and $context.ExtendedProperties.ContainsKey("Default Resource Group")) {
                        $context.ExtendedProperties["Default Resource Group"]
                    }
                })
        }
    }
}

function Test-DotNet
{
    try
    {
        if (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' | Get-ItemPropertyValue -Name Release | Foreach-Object { $_ -lt 461808 })
        {
            throw ".NET Framework versions lower than 4.7.2 are not supported in Az.  Please upgrade to .NET Framework 4.7.2 or higher."
        }
    }
    catch
    {
        Write-Verbose ".NET Framework version check failed."
    }
}