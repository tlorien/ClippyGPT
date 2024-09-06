$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "Modules"
$resourcePath = Join-Path -Path $PSScriptRoot -ChildPath "Resources"

Write-Host "Modules Path: $modulePath"
Write-Host "Resources Path: $resourcePath"

try {
    Write-Host "Loading UIComponent module from: $(Join-Path -Path $modulePath -ChildPath 'UIComponent.psm1')"
    Import-Module (Join-Path -Path $modulePath -ChildPath "UIComponent.psm1") -ErrorAction Stop
    Write-Host "Loading ChatGPTModule module from: $(Join-Path -Path $modulePath -ChildPath 'ChatGPTModule.psm1')"
    Import-Module (Join-Path -Path $modulePath -ChildPath "ChatGPTModule.psm1") -ErrorAction Stop
    Write-Host "Loading ConfigModule module from: $(Join-Path -Path $modulePath -ChildPath 'ConfigModule.psm1')"
    Import-Module (Join-Path -Path $modulePath -ChildPath "ConfigModule.psm1") -ErrorAction Stop
    Write-Host "Loading EventModule module from: $(Join-Path -Path $modulePath -ChildPath 'EventModule.psm1')"
    Import-Module (Join-Path -Path $modulePath -ChildPath "EventModule.psm1") -ErrorAction Stop
} catch {
    Write-Error "Failed to load modules: $_"
    exit
}

$config = Test-Config -resourcePath $resourcePath
if (-not $config) {
    $config = Initialize-Config -resourcePath $resourcePath
    if (-not $config) {
        $config = ShowConfigDialog -ConfigPath (Join-Path -Path $resourcePath -ChildPath "config.json")
    }
    if ($config) {
        Show-ClippyPopup -Message "Hello, $($config.UserName)! How can I assist you today?" -ImagePath (Join-Path -Path $resourcePath -ChildPath "clippy.png")
    } else {
        Show-ClippyPopup -Message "Configuration setup is incomplete. Please restart the application and ensure all configuration details are provided." -ImagePath (Join-Path -Path $resourcePath -ChildPath "clippy.png")
        return
    }
} else {
    Show-ClippyPopup -Message "Hello, $($config.UserName)! How can I assist you today?" -ImagePath (Join-Path -Path $resourcePath -ChildPath "clippy.png")
}

$apiKey = $config.OpenAIKey
Write-Host "Using API Key: $apiKey"

function Global:clippy {
    param ([string]$Command)

    $resourcePath = Join-Path -Path $PSScriptRoot -ChildPath "Resources"
    $config = Test-Config -resourcePath $resourcePath

    if ($config -and $config.OpenAIKey) {
        Write-Host "Using API Key: $($config.OpenAIKey)"
        $response = Invoke-ChatGPT -userMessage $Command -ApiKey $config.OpenAIKey
    } else {
        Write-Host "API Key is not configured."
        $response = "API key is missing or not configured correctly."
    }

    Show-ClippyPopup -Message $response -ImagePath (Join-Path -Path $resourcePath -ChildPath "clippy.png")
}


# Example Usage:
# Just type "clippy" followed by your command or prompt in the terminal:
# clippy "Tell me a joke"
# clippy "weather"