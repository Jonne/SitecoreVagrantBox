configuration MongoDB
{
  Param (
    [string]$TempFolder,
    [string]$DataFolder,
    [string]$ConfigFile,
    [string]$MSIFile,
    [string]$InstallerAppName,
    [string]$ServiceExe
  )
    File MongoDataFolders
    {
        Type = "Directory"
        DestinationPath = "$DataFolder\db"
        Ensure = "Present"
    }
    
    File MongoLogFolders
    {
        Type = "Directory"
        DestinationPath = "$DataFolder\log"
        Ensure = "Present"
    }
    
    File MongoConfigFile
    {
        SourcePath = $ConfigFile
        DestinationPath = "$DataFolder\$(split-path $ConfigFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    Script UpdateMongoConfigFile
    {
        DependsOn = "[file]MongoConfigFile"
        GetScript = {
        }
        TestScript = {
            $False
        }
        SetScript = {
            $config = $using:ConfigFile
            $mongoDataFolder = $using:DataFolder
            
            $configFile = "$(split-path $config -leaf -resolve)"
                
            $text = Get-Content "$mongoDataFolder\$configFile" | Out-String
            $text = $text.Replace("`$MongoDataFolder", $mongoDataFolder)
            $text | Out-File "$mongoDataFolder\$configFile"
        }
    }
    
    File MongoMSI
    {
        SourcePath = $MSIFile
        DestinationPath = "$TempFolder\$(split-path $MSIFile -leaf -resolve)"
        Type = "File"
        Ensure = "Present"
    }
    
    Package MongoDB
    {
        DependsOn = "[file]MongoMSI"
        Ensure = "Present"
        Path = "$TempFolder\$(split-path $MSIFile -leaf -resolve)"
        Arguments = 'ADDLOCAL="all"'
        Name = "$InstallerAppName"
        ProductId = ""
    }    
    
    Script MongoService
    {
        DependsOn = "[package]MongoDB", "[script]UpdateMongoConfigFile"
        GetScript = {
            $instances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mongo*" -and $_.PathName -match "mongod.exe" } | % { $_.Caption }
            $res = $instances -ne $null -and $instances -gt 0
            $vals = @{ 
                Installed = $res; 
                InstanceCount = $sqlInstances.count 
            }
            $vals
        }
        TestScript = {
            $instances = gwmi win32_service -computerName localhost | ? { $_.Name -match "mongo*" -and $_.PathName -match "mongod.exe" } | % { $_.Caption }
            $res = $instances -ne $null -and $instances -gt 0
            if ($res) {
                Write-Verbose "MongoDB is already running as a service"
            } else {
                Write-Verbose "MongoDB is not running as a service"
            }
            $res
        }
        SetScript = {
            $config = $using:ConfigFile
            $dataFolder = $using:DataFolder
            $configFile = "$(split-path $config -leaf -resolve)"
            $service = $using:ServiceExe
    
            $MongoExe = "$using:Env:ProgramFiles\$service"
            $ConfigFile = "$dataFolder\$configFile"
    
            &$MongoExe --config $ConfigFile --install
        }
    }
    
    Service StartMongoService
    {
        DependsOn = "[script]MongoService"
        StartupType =  "Automatic"
        Name = "MongoDB"
        State = "Running"
    }
}