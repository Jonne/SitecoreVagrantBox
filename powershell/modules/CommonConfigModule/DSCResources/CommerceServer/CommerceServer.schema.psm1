configuration CommerceServer
{
    Param (
    [string]$TempFolder,
    [string]$InstallerFile,
    [string]$CSConfigFile,
    [string]$SiteName,
    [string]$WebServiceSiteName
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

    Script Site
    {
        DependsOn = "[Script]CommerceServer"
        GetScript = {
        }
        TestScript = {
            $w = Get-CSSites | Where {$_-eq "$using:SiteName"}
            return $w.count -eq 1
        }
        SetScript = {

            $csSiteName = $using:SiteName
            $webServiceSiteName = $using:WebServiceSiteName

            # Create Site
            New-CSSite $csSiteName

            # Create resources
            Add-CSCatalogResource $csSiteName
            Add-CSInventoryResource $csSiteName
            Add-CSMarketingResource $csSiteName
            Add-CSOrdersResource $csSiteName
            Add-CSProfilesResource $csSiteName

            # Todo: The following requires webdeploy 3 to be installed 
            # New-CSWebService -Name $csSiteName -Resource Catalog -IISSite $webServiceSiteName;
            # New-CSWebService -Name $csSiteName -Resource Orders -IISSite $webServiceSiteName;
            # New-CSWebService -Name $csSiteName -Resource Profiles -IISSite $webServiceSiteName;
            # New-CSWebService -Name $csSiteName -Resource Marketing -IISSite $webServiceSiteName;            
        }
    }    
}
