﻿#
# Module manifest for module 'BT'
#
# Generated by: Stephen Whittier
#
# Generated on: 02/11/2015
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '2B9E5FFD-5D1D-4126-B0E4-25F9AE7A12FE'

# Author of this module
Author = 'Stephen Whittier'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2015 swhittier. All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell Module For Development Tasks at BlueTube, LLC.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = '.\Show-InfoMessage.ps1', '.\Invoke-SitePreDeploy.ps1', '.\Start-SiteBuild.ps1', '.\Show-Exception.ps1', '.\Show-ErrorMessage.ps1',
                '.\Start-BuildMohawk.ps1', '.\Start-BuildKarastan.ps1', '.\Start-BuildMohawkGroup.ps1', '.\Invoke-DBBackup.ps1', '.\Invoke-DBRestore.ps1',
                '.\Restart-AppPool.ps1', '.\Show-WarningMessage.ps1', '.\Invoke-MohawkAzCopy.ps1', '.\Invoke-PrepRemoteDebug.ps1', '.\Start-BuildRRTS.ps1',
                '.\Start-BuildRTS.ps1', '.\Start-BuildMohawkFlooring.ps1'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}