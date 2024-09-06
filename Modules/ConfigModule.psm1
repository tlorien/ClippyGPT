Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-DefaultConfig {
    return @{
        UserName = ""
        OpenAIKey = ""
        WeatherAPIKey = ""
        EnableUnpromptedPopUps = $false
        EnableStoryMode = $true
    }
}

function Test-Config {
    param (
        [string]$resourcePath
    )
    $configPath = Join-Path -Path $resourcePath -ChildPath "config.json"
    $defaultConfig = Get-DefaultConfig

    if (Test-Path $configPath) {
        $config = Get-Content -Path $configPath | ConvertFrom-Json
        foreach ($key in $defaultConfig.Keys) {
            if (-not $config.PSObject.Properties.Name -contains $key) {
                $config | Add-Member -NotePropertyName $key -NotePropertyValue $defaultConfig.$key
            }
        }
        $config | ConvertTo-Json | Set-Content -Path $configPath
        return $config
    } else {
        $defaultConfig | ConvertTo-Json | Set-Content -Path $configPath
        return $defaultConfig
    }
}

function Initialize-Config {
    param (
        [string]$resourcePath
    )

    $configPath = Join-Path -Path $resourcePath -ChildPath "config.json"
    if (-not (Test-Path $configPath)) {
        $config = ShowConfigDialog -ConfigPath $configPath
    } else {
        $config = Get-Content -Path $configPath | ConvertFrom-Json
    }
    return $config
}

function ShowConfigDialog {
    param (
        [string]$ConfigPath
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Enter Configuration"
    $form.Size = New-Object System.Drawing.Size(300, 300)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.BackColor = [System.Drawing.Color]::LightYellow
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font

    $labels = @("Enter your name:", "Enter your OpenAI API key:", "Enter your Weather API key:", "Enable Unprompted Pop-Ups", "Enable Story Mode")
    $keys = @("UserName", "OpenAIKey", "WeatherAPIKey", "EnableUnpromptedPopUps", "EnableStoryMode")
    $controls = @()
    $top = 20

    for ($i = 0; $i -lt $labels.Length; $i++) {
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10, $top)
        $label.Size = New-Object System.Drawing.Size(280, 20)
        $label.Text = $labels[$i]
        $form.Controls.Add($label)
        $top += 20

        if ($i -lt 3) {
            $textbox = New-Object System.Windows.Forms.TextBox
            $textbox.Location = New-Object System.Drawing.Point(10, $top)
            $textbox.Size = New-Object System.Drawing.Size(260, 20)
            $form.Controls.Add($textbox)
            $controls += $textbox
            $top += 30
        } else {
            $checkbox = New-Object System.Windows.Forms.CheckBox
            $checkbox.Location = New-Object System.Drawing.Point(10, $top)
            $checkbox.Size = New-Object System.Drawing.Size(280, 20)
            $checkbox.Text = $labels[$i]
            $form.Controls.Add($checkbox)
            $controls += $checkbox
            $top += 30
        }
    }

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(110, $top)
    $okButton.Size = New-Object System.Drawing.Size(75, 23)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})

    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $config = @{}
        for ($i = 0; $i -lt $keys.Length; $i++) {
            if ($i -lt 3) {
                $config[$keys[$i]] = $controls[$i].Text
            } else {
                $config[$keys[$i]] = $controls[$i].Checked
            }
        }
        $config | ConvertTo-Json | Set-Content -Path $ConfigPath
        return $config
    }
    return $null
}

Export-ModuleMember -Function Get-DefaultConfig, Test-Config, Initialize-Config, ShowConfigDialog