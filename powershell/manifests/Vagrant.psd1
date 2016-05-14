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
                Installer = "c:\vagrant\files\Sitecore 8.1 rev. 160302.exe"
                License = "c:\vagrant\files\license.xml"
                Name = "demo"
            }
            Role=@("SqlServer", "WebServer", "Sitecore")
         }
        @{
            NodeName="localhost"
         }
    )
}
