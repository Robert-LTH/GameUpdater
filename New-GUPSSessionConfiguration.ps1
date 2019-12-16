function New-GUPSSessionConfiguration {
    param(
        [string[]]$Path
    )
    $Version = "0.1"
    $PSSessionConfigurationName = "GameUpdater Test v$Version"

    $PSSessionConfigurationFilePath = ".\GameUpdater v$Version.pssc"
    $TranscriptDirectory = "C:\ProgramData\JEAConfiguration\Transcripts"
    $VisibleExternalCommands = $Path

    Write-Host "##################################"
    Write-Host "### GameUpdater Test v$Version ####"
    Write-Host "##################################"
    if ((Get-PSSessionConfiguration -Name $PSSessionConfigurationName)) {
        
    }
    Write-Host "Creating a PSSessionConfiguration"

    #$UserSID = [System.Security.Principal.NTAccount]::new($Username).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $UserSID = 'S-1-5-11'

    if (-not [bool](Test-WSMan -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Orange "PSRemoting has not been enabled, trying to enable!"
        try {
            Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null
            Write-Host -ForegroundColor Green "Enabled PSRemoting using command 'Enable-PSRemoting -Force -SkipNetworkProfileCheck'"
        } catch {
            throw "Failed to enable PSRemoting: $_"
        }
    }
    

    Write-Host "Creating session configuration file at '$PSSessionConfigurationFilePath'"
    New-PSSessionConfigurationFile -Path $PSSessionConfigurationFilePath -Verbose -SessionType RestrictedRemoteServer -TranscriptDirectory $TranscriptDirectory -LanguageMode NoLanguage -VisibleExternalCommands $VisibleExternalCommands -ExecutionPolicy Restricted -RunAsVirtualAccount | Out-Null
    Write-Host "Created file, need to test it"

    try {
        Test-PSSessionConfigurationFile -Path $PSSessionConfigurationFilePath -Verbose | Out-Null
        Write-Host -ForegroundColor Green "Test of session configuration file was successful!"
    } catch {
        throw "Failed to verify configuration file!"
    }
    
    try {
        Register-PSSessionConfiguration -Path $PSSessionConfigurationFilePath -Name $PSSessionConfigurationName -Force | Out-Null
        Write-Host -ForegroundColor Green "Successfully registered the configuration"
    } catch {
        throw "Failed to register the configuration!"
    }

    Write-Host "Add 'Authenticated Users' with Read+Execute to the ACL of the configuration"
    try {
        $existingSDDL = Get-PSSessionConfiguration -Name $PSSessionConfigurationName | Select-Object -ExpandProperty SecurityDescriptorSddl
        $SecurityDescriptor = New-Object -TypeName Security.AccessControl.CommonSecurityDescriptor  -ArgumentList $isContainer,$isDS, $existingSDDL
        $accessType = "Allow"
        # Read + Execute
        $accessMask = -1610612736
        $inheritanceFlags = "none"
        $propagationFlags = "none"
        $SecurityDescriptor.DiscretionaryAcl.AddAccess($accessType,$UserSID,$accessMask,$inheritanceFlags,$propagationFlags)
        Set-PSSessionConfiguration -WarningAction Ignore -Name $PSSessionConfigurationName -SecurityDescriptorSddl $SecurityDescriptor.GetSddlForm("All") | Out-Null
        Write-Host -ForegroundColor Green "'Authenticated Users' was added to the ACL!"
    } catch {
        throw "Failed to add 'Authenticated Users' to the ACL of the configuration: $_"
    }
    
    Write-host "Remove the configuration file at '$PSSessionConfigurationFilePath'"
    Remove-Item -Path $PSSessionConfigurationFilePath
}
