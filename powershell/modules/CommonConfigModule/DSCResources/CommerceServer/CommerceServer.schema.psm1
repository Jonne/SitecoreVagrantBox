configuration CommerceServer
{
    Param (
    [string]$TempFolder,
    [string]$InstallerFile,
    [string]$CSConfigFile
  )
    File Installer
    {
        SourcePath = $InstallerFile
        DestinationPath = "$TempFolder\$(split-path $InstallerFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }

    File CSConfig
    {
        SourcePath = $CSConfigFile
        DestinationPath = "$TempFolder\$(split-path $CSConfigFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }    

    WindowsFeature IdentityFoundation
    {
        Name = "Windows-Identity-Foundation"
        Ensure = "Present"
        IncludeAllSubFeature = $True
    }    

    Script CommerceServer
    {
        DependsOn = "[File]Installer", "[File]CSConfig", "[WindowsFeature]IdentityFoundation"
        GetScript = {
        }
        TestScript = {
            Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\CommerceServer"
        }
        SetScript = {
        
            $CSConfigFile = "$($using:TempFolder)\$(split-path $using:CSConfigFile -leaf -resolve)"

            $installer = "$($using:TempFolder)\$(split-path $using:InstallerFile -leaf -resolve)"

            write-verbose "Running installer: $installer -quiet CSCONFIGXML=$CSConfigFile NOSTAGING"

            & "$installer" -quiet CSCONFIGXML="$CSConfigFile" NOSTAGING
            
            $timeout = New-TimeSpan -Minutes 10
            $sw = [diagnostics.stopwatch]::StartNew() 

            do
            {
                Write-Verbose " -- Checking if Commerce Server is successfully installed -- "

                $result = Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\CommerceServer"

                Start-Sleep -seconds 5
            }
            while($sw.elapsed -lt $timeout -And -Not $result)
            
            if(-Not $result){
                throw "CommerceServer was not successfully installed in the specified time..."
            } 
        }
    }
}
