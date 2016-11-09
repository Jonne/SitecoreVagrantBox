@{
    AllNodes = @(
        @{
            NodeName="*"
            UserName="vagrant"
            Password="vagrant"
            Tempfolder="c:\temp"
            WWWRoot = "c:\inetpub\wwwroot"
            
            SqlServer = @{
                InstallConfig = "c:\vagrant\files\sqlserver.ini"
                ISOFile = "c:\vagrant\files\en_sql_server_2014_developer_edition_with_service_pack_1_x64_dvd_6668542.iso"
                SAPassword = "Vagrant123"    
            }
            
            Sitecore = @{
                Installer = "c:\vagrant\files\Sitecore 8.2 rev. 160729.exe"
                License = "c:\vagrant\files\license.xml"
                Name = "demo"
                DeploymentHelpersFolder = "c:\vagrant\files\DeploymentHelpers"
            }
            
            Mongo = @{
                DataFolder = "c:\mongo\data"
                ConfigFile = "c:\vagrant\files\mongod.cfg"
                MSIFile = "c:\vagrant\files\mongodb-win32-x86_64-2008plus-ssl-3.2.6-signed.msi"
                InstallerAppName = "MongoDB 3.2.6 2008R2Plus SSL (64 bit)"
                ServiceExe = "MongoDB\Server\3.2\bin\mongod.exe" 
            }

            SXA = @{
                Package = "c:\vagrant\files\Sitecore Experience Accelerator 1.0.0 for 8.2.zip"
            }

            CommerceServer = @{
                Installer = "c:\vagrant\files\CommerceServer-11.4.148.exe"
                CSConfigFile = "c:\vagrant\files\CSConfig.xml"
            }

            Role=@("SqlServer", "WebServer", "MongoDB", "Sitecore", "SXA", "CommerceServer")
         }
        @{
            NodeName="localhost"        
         }
    )
}
