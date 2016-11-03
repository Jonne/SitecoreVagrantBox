configuration Sitecore
{
  Param (
    [string]$TempFolder,
    [string]$InstallerFile,
    [string]$LicenseFile,
    [string]$WWWRoot,
    [string]$SQLServer,
    [string]$SQLUser,
    [string]$SQLPassword,
    [string]$Instance,
    [string]$DeploymentHelpersFolder
  )
    File SitecoreInstaller
    {
        SourcePath = "$InstallerFile"
        DestinationPath = "$TempFolder\$(split-path $InstallerFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    File SitecoreLicense
    {
        SourcePath = "$LicenseFile"
        DestinationPath = "$TempFolder\$(split-path $LicenseFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    Script ExtractSitecore 
    {
        DependsOn = "[File]SitecoreInstaller"
        GetScript = {
        }
        TestScript = {
            $tmp = $using:TempFolder
            Test-Path "$using:tmp\SupportFiles"
        }
        SetScript = {
            $tmp = $using:TempFolder
            $installer = $using:InstallerFile
    
            Push-Location $tmp
    
            $path = "$tmp\$(split-path $installer -leaf -resolve)"
    
            &$path /q /ExtractCab | out-null
    
            Pop-Location
        }
    }
         
    Script RemoveDefaultWebsite {
        SetScript = {
            # Check if WebAdministration module is present for IIS cmdlets
            if(!(Get-Module -ListAvailable -Name WebAdministration))
            {
                Throw "Please ensure that WebAdministration module is installed."
            }
            Remove-Website "Default Web Site"
        }
        TestScript = {
            $w = Get-Website | where {$_.name -eq "Default Web Site"}
            return $w.count -eq 0
        }
        GetScript = {
            $installStatus = Get-Website | where {$_.name -eq "Default Web Site"}
            @{
                SetScript = $SetScript
                TestScript = $TestScript
                Result = [String]$installStatus;
            } 
        }
    }

    Script SC8
    {
        DependsOn = "[Script]ExtractSitecore", "[File]SitecoreLicense"
        GetScript = {
        }
        TestScript = {
            $wwwRoot = $using:WWWRoot
            $instance = $using:Instance
            $iisFolder = "$using:wwwRoot\$using:instance"
    
            Test-Path $iisFolder
        }
        SetScript = {
            $registryPath =  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\"
    
            if(-not (Test-path $registryPath)){
                throw "The instance-testing path in the registry could not be found - not a 64bit machine?"
            }
    
            $scRegistryPath = "$registryPath\Sitecore CMS\"
    
            $instanceNumber = "1"
    
            if( Test-path $scRegistryPath ){
                Push-Location $scRegistryPath
    
                $lastID = dir | Get-ItemProperty -Name InstanceID | Sort-Object -property InstanceID -Descending | Select-Object -ExpandProperty InstanceID -First 1
    
                if( -not [string]::IsNullOrWhiteSpace($lastID)){
                    Write-Verbose "Previous instance found: $lastID "
    
                    $instanceString = $lastID.Remove(0,10)
                    $instanceNumber = [int]::Parse($instanceString)
                    $instanceNumber = $instanceNumber + 1
                } else {
                    Write-Verbose "No previous instance found"
                }
    
                Pop-Location
            } else {
                Write-Verbose "No previous instance found"
            }
    
            Write-Verbose "Using instance number: $instanceNumber"
    
            $instanceID = "InstanceId$instanceNumber"
    
            $tmp = $using:TempFolder
            $licenseFile = $using:LicenseFile
            $license = "$tmp\$(split-path $licenseFile -leaf -resolve)"
            $site = $using:Instance
            $siteAppPool = "$($site)_AppPool"
            $sitePrefix = "$($site)_"
                    
            $sqlServer = $using:SQLServer
            $sqlUser = $using:SQLUser
            $sqlPassword = $using:SQLPassword
    
            $wwwRoot = $using:WWWRoot
    
            msiexec.exe /qn /i "$tmp\SupportFiles\exe\Sitecore.msi" "TRANSFORMS=:$instanceID;:ComponentGUIDTransform5.mst" "MSINEWINSTANCE=1" "LOGVERBOSE=1" "SC_LANG=en-US" "SC_FULL=1" "SC_INSTANCENAME=$site" "SC_LICENSE_PATH=$license" "SC_SQL_SERVER_USER=$sqlUser" "SC_SQL_SERVER=$sqlServer" "SC_SQL_SERVER_PASSWORD=$sqlPassword" "SC_DBPREFIX=$sitePrefix" "SC_PREFIX_PHYSICAL_FILES=1" "SC_SQL_SERVER_CONFIG_USER=$sqlUser" "SC_SQL_SERVER_CONFIG_PASSWORD=$sqlPassword" "SC_DBTYPE=MSSQL" "INSTALLLOCATION=$wwwRoot\$site" "SC_DATA_FOLDER=$wwwRoot\$site\Data" "SC_DB_FOLDER=$wwwRoot\$site\Databases" "SC_MDF_FOLDER=$wwwRoot\$site\Databases\MDF" "SC_LDF_FOLDER=$wwwRoot\$site\Databases\LDF" "SC_NET_VERSION=4" "SITECORE_MVC=0" "SC_INTEGRATED_PIPELINE_MODE=1" "SC_IISSITE_NAME=$site" "SC_IISAPPPOOL_NAME=$siteAppPool" "SC_IISSITE_PORT=80" "SC_IISSITE_ID=" "/l*+v" "$tmp\Install.log" | out-null
        }
    }
    
    Script CreateShare 
    {
        DependsOn = "[Script]SC8"
        GetScript = {
        }
        TestScript = {
             if(Get-WmiObject Win32_Share -filter "name='Sitecore'"){
                Write-Verbose "Sitecore share already exists"
                $True
             } else {
                 Write-Verbose "Sitecore share does not yet exist"
                $False
             }
        }
        SetScript = {
            $wwwRoot = $using:WWWRoot
            $site = $using:Instance
            $folderPath = "$wwwRoot\SC8\Website" 
            
            Write-Verbose "Creating share: $folderPath"
            
            $Shares=[WMICLASS]"WIN32_Share"
            
            $Shares.Create($folderPath,"Sitecore",0)
        }
    }

    File AddRemoteDeploy
    {
        DependsOn = "[script]SC8"
        SourcePath = "$DeploymentHelpersFolder"
        DestinationPath = "$WWWRoot\SC8\website\install"
        Type = "Directory"
        Recurse = $True
        Ensure = "Present"
    }

    Script WarmSitecore
    {
        DependsOn = "[script]SC8"
        GetScript = {
        }
        TestScript = {
            $false
        }
        SetScript = {
            $url = "http://localhost"
    
            Write-Verbose "Starting Sitecore..."
    
            $result = $null
    
            do
            {
                Write-Verbose " -- trying to start Sitecore -- "
                try
                {
                    $result = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 0
                }
                catch
                {
                    Write-Verbose " -- start failed - retying [$($result.StatusCode)] -- " 
                }
            }
            while($result.StatusCode -ne 200)
            Write-Verbose "Public site started..."
    
            $url = $url + "sitecore/"
    
            do
            {
                Write-Verbose " -- Retry starting Admin -- "
                try
                {
                    $result = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 0
                }
                catch
                {
                    Write-Verbose " -- start failed - retying [$($result.StatusCode)] -- " 
                }
            }
            while($result.StatusCode -ne 200)
            Write-Verbose "Admin site started..."
        }
    }
}