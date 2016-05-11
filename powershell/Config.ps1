configuration Config
{
    Import-DscResource -ModuleName CommonConfigModule

    Node $AllNodes.Where({ $_.Role -contains 'SqlServer' }).NodeName
    {
        SqlServer SqlServer
        {
            ISOFile = $Node.SqlServerISOFile
            TempFolder = "c:\temp"
            InstallConfig = $Node.SqlServerInstallConfig
            SQLPassword = $Node.SqlServerSAPassword
        } 
    }

    Node $AllNodes.Where({ $_.Role -contains 'WebServer' }).NodeName
    {
        WebServer WebServer
        {
            
        } 
        
        Sitecore Sitecore
        {
            DatabaseServer = ".\SQLEXPRESS"
            DatabaseUser = "sa"
            DatabasePassword = "Vagrant123"
            Name = "demo"
            IISSiteHeader = ""
            IISPort = 3223
            IISSiteName = "Default Web Site"
            Path = "c:\sitecore\website"
            DatabaseLocation = "c:\sitecore\database"
            DataLocation = "c:\sitecore\data"
            ShareName = "sitecore"
            UserName = $Node.UserName
            Password = $Node.Password
        }
    }
}
