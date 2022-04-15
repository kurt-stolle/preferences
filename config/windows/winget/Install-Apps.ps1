# Install apps by ID
$apps = @(
    @{name = "Microsoft.PowerShell" }, 
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
    @{name = "Microsoft.PowerToys" }, 
    @{name = "Git.Git" }, 
    @{name = "Docker.DockerDesktop" },
);
Foreach ($app in $apps) {
    # Check if the app is already installed
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-Host "Installing:" $app.name

        if ($app.source -ne $null) {
            winget install --exact --scope machine --silent $app.name --source $app.source
        }
        else {
            winget install --exact --scope machine --silent $app.name
        }
    }
    else {
        Write-Host "Skipping Install of " $app.name
    }
}

# Remove apps we do not need
Write-Output "Removing Apps"

$apps = "*3DPrint*", "Microsoft.MixedReality.Portal"
Foreach ($app in $apps)
{
  Write-host "Uninstalling:" $app
  Get-AppxPackage -allusers $app | Remove-AppxPackage
}