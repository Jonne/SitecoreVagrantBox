@{
    AllNodes = @(
        @{
            NodeName="*"
            UserName="vagrant"
            Password="vagrant"
            SqlServerInstallConfig = "c:\vagrant\files\sqlserver.ini"
            SqlServerISOFile = "c:\vagrant\files\en_sql_server_2014_developer_edition_with_service_pack_1_x64_dvd_6668542.iso"
            SqlServerSAPassword = "Vagrant123"
            Role=@("SqlServer", "WebServer")
         }
        @{
            NodeName="localhost"
         }
    )
}
