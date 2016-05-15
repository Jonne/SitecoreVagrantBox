configuration SqlServer
{
  Param (
    [string]$ISOFile,
    [string]$TempFolder,
    [string]$InstallConfig,
    [string]$SQLPassword
  )    
  
    WindowsFeature NetFramework35Core
    {
        Name = "NET-Framework-Core"
        Ensure = "Present"
    }

    WindowsFeature NetFramework45Core
    {
        Name = "NET-Framework-45-Core"
        Ensure = "Present"
    }
    
    File SQLServerIso
    {
        SourcePath = "$ISOFile"
        DestinationPath = "$TempFolder\$(split-path $ISOFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    File SQLServerIniFile
    {
        SourcePath = "$InstallConfig"
        DestinationPath = "$TempFolder\$(split-path $InstallConfig -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    Script InstallSQLServer
    {
        DependsOn = "[file]SQLServerIso", "[file]SQLServerIniFile"
        GetScript = 
        {
            $sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
            $res = $sqlInstances -ne $null -and $sqlInstances -gt 0
            $vals = @{ 
                Installed = $res; 
                InstanceCount = $sqlInstances.count 
            }
            $vals
        }
        TestScript =
        {
            $sqlInstances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
            $res = $sqlInstances -ne $null -and $sqlInstances -gt 0
            if ($res) {
                Write-Verbose "SQL Server is already installed"
            } else {
                Write-Verbose "SQL Server is not installed"
            }
            $res
        }
        SetScript = 
        {
            $tmp = $using:TempFolder
            $iso = $using:ISOFile
            $config = $using:InstallConfig
            $pwd = $using:SQLPassword
            
            $isoFile = "$tmp\$(split-path $iso -leaf -resolve)"
            $configFile = "$tmp\$(split-path $config -leaf -resolve)"
            
            $setupDriveLetter = (Mount-DiskImage -ImagePath "$($isoFile)" -PassThru | Get-Volume).DriveLetter + ":"
            if ($setupDriveLetter -eq $null) {
                throw "Could not mount SQL install iso"
            }
            Write-Verbose "Drive letter for iso is: $setupDriveLetter"
                        
            $cmd = "$($setupDriveLetter)\Setup.exe /ConfigurationFile=$configFile /SAPWD=$pwd /IAcceptSQLServerLicenseTerms /SQLSVCPASSWORD=$pwd /AGTSVCPASSWORD=$pwd"
            Write-Verbose "Running SQL Install - check %programfiles%\Microsoft SQL Server\120\Setup Bootstrap\Log\ for logs..."
            Invoke-Expression $cmd | Write-Verbose
                        
            Dismount-DiskImage -ImagePath "$isoFile"
        }
    }
}
