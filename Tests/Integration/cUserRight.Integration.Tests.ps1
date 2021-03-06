#requires -Version 4.0 -Modules Pester

$Global:DSCModuleName = 'cUserRightsAssignment'
$Global:DSCResourceName = 'cUserRight'

#region Header

$ModuleRoot = Split-Path -Path $Script:MyInvocation.MyCommand.Path -Parent | Split-Path -Parent | Split-Path -Parent

if (
    (-not (Test-Path -Path (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests') -PathType Container)) -or
    (-not (Test-Path -Path (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -PathType Leaf))
)
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests'))
}
else
{
    & git @('-C', (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests'), 'pull')
}

Import-Module -Name (Join-Path -Path $ModuleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment -DSCModuleName $Global:DSCModuleName -DSCResourceName $Global:DSCResourceName -TestType Integration

#endregion

# Begin Testing
try
{
    #region Integration Tests

    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).Config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration - Ensure is set to Present" {

        $ConfigurationName = 'cUserRight_Present'

        #region Default Tests

        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command ('{0} -OutputPath "{1}"' -f $ConfigurationName, $TestEnvironment.WorkingFolder)
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should Not Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should Not Throw
        }

        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $Current = Get-DscConfiguration | Where-Object {$_.ConfigurationName -eq $ConfigurationName}
            $Current.Ensure | Should Be 'Present'
            $Current.Constant | Should Be $TestParameters.Constant
            $Current.Principal | Should Be $TestParameters.Principal
        }

    }

    Describe "$($Global:DSCResourceName)_Integration - Ensure is set to Absent" {

        $ConfigurationName = 'cUserRight_Absent'

        #region Default Tests

        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command ('{0} -OutputPath "{1}"' -f $ConfigurationName, $TestEnvironment.WorkingFolder)
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should Not Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should Not Throw
        }

        #endregion

        It 'Should have set the resource and all the parameters should match' {
            $Current = Get-DscConfiguration | Where-Object {$_.ConfigurationName -eq $ConfigurationName}
            $Current.Ensure | Should Be 'Absent'
            $Current.Constant | Should Be $TestParameters.Constant
            $Current.Principal | Should Be $TestParameters.Principal
        }

    }

    #endregion
}
finally
{
    #region Footer

    Restore-TestEnvironment -TestEnvironment $TestEnvironment

    #endregion
}
