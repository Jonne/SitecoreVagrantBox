configuration Config
{
    Import-DscResource -ModuleName CommonConfigModule

    Node $AllNodes.Where({ $_.Role -contains 'SqlServer' }).NodeName
    {
        SqlServer SqlServer
        {
            ISOFile = $Node.SqlServer.ISOFile
            TempFolder = $Node.TempFolder
            InstallConfig = $Node.SqlServer.InstallConfig
            SQLPassword = $Node.SqlServer.SAPassword
        } 
    }

    Node $AllNodes.Where({ $_.Role -contains 'WebServer' }).NodeName
    {
        WebServer WebServer
        {
            
        } 
    }
    
    Node $AllNodes.Where({ $_.Role -contains 'Sitecore' }).NodeName
    {
        Sitecore Sitecore
        {
            TempFolder = $Node.TempFolder
            InstallerFile = $Node.Sitecore.Installer
            LicenseFile = $Node.Sitecore.License
            Name = $Node.Sitecore.Name
            WWWRoot = $Node.WWWRoot 
            SQLServer = "."
            SQLUser = "sa"
            SQLPassword = $Node.SqlServerSAPassword
        }
    }
}
