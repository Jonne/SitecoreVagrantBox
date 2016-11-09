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
           
    Node $AllNodes.Where({ $_.Role -contains 'MongoDB' }).NodeName
    {
        MongoDB MongoDB
        {
            TempFolder = $Node.TempFolder
            DataFolder = $Node.Mongo.DataFolder
            ConfigFile = $Node.Mongo.ConfigFile
            MSIFile = $Node.Mongo.MSIFile
            InstallerAppName = $Node.Mongo.InstallerAppName
            ServiceExe = $Node.Mongo.ServiceExe
        }
    }
    
    Node $AllNodes.Where({ $_.Role -contains 'Sitecore' }).NodeName
    {
        Sitecore Sitecore
        {
            TempFolder = $Node.TempFolder
            InstallerFile = $Node.Sitecore.Installer
            LicenseFile = $Node.Sitecore.License
            Instance = $Node.Sitecore.Name
            WWWRoot = $Node.WWWRoot 
            SQLServer = "."
            SQLUser = "sa"
            SQLPassword = $Node.SqlServer.SAPassword
            DeploymentHelpersFolder = $Node.Sitecore.DeploymentHelpersFolder
        }
    }

    Node $AllNodes.Where({ $_.Role -contains 'SXA' }).NodeName
    {
        SXA SXA
        {
            Package = $Node.SXA.Package
            Instance = $Node.Sitecore.Name
            WWWRoot = $Node.WWWRoot 
        }
    }    

    Node $AllNodes.Where({ $_.Role -contains 'CommerceServer' }).NodeName
    {
        CommerceServer CommerceServer
        {
            TempFolder = $Node.TempFolder
            InstallerFile = $Node.CommerceServer.Installer
            CSConfigFile = $Node.CommerceServer.CSConfigFile
        }
    }    
}
