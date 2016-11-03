configuration SXA
{
  Param (
    [string]$Package,
    [string]$WWWRoot,
    [string]$Instance
  )

    File AddSXAPackage
    {
        SourcePath = "$Package"
        DestinationPath = "$WWWRoot\$Instance\Data\packages"
        Type = "File"
        Ensure = "Present"
    }
    
    Script InstallPSE
    {
        DependsOn = "[file]AddSXAPackage"
        GetScript = {
            @{ Feature = "Install PowerShell Extensions" }
        }
        TestScript = {
            Test-Path "$using:WWWRoot\$using:Instance\Website\App_Config\Include\Foundation\Sitecore.XA.Foundation.Mvc.config"
        }
        SetScript = {
            $siteName = $using:Instance
            $sitecoreFolder = "$($using:WWWRoot)\$($siteName)\Data\packages"   
        
            $module = $using:Package
    
            $query = (Split-Path -Path $module -Leaf)
                    
            Write-Verbose "Calling package upload tool for $using:query"
        
            $url = "http://localhost/install/InstallModules.aspx?modules=$query"
            $result = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 600 -OutFile ".\$siteName-PackageResponse-$query.log" -PassThru
            
            if($result.StatusCode -ne 200) {
                Write-Verbose "StatusCode: $($result.StatusCode)"
                throw "Package install failed for $query"
            }
            else {
                Write-Verbose "Install ok"
            }
            
            $file = Join-Path $sitecoreFolder $query
            Remove-Item $file -Force
        }
    }
}
