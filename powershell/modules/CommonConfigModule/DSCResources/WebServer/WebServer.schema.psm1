configuration WebServer
{
    WindowsFeature IIS
    {
      Ensure = "Present"
      Name = "Web-Server"
    }

    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }

    WindowsFeature IISManagementTools
    {
        Name = "Web-Mgmt-Tools"
        Ensure = "Present"
        IncludeAllSubFeature = $True
    }
}
