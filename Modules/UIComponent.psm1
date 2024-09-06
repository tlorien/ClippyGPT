function Show-ClippyPopup {
    param (
        [string]$Message,
        [string]$ImagePath,
        [string]$Orientation = "Left",  # Either "Left" or "Below"
        [System.Collections.Hashtable]$Buttons = @{}
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = 'None'
    $form.BackColor = [System.Drawing.Color]::Black
    $form.TransparencyKey = $form.BackColor
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true
    $form.Width = 400
    $form.Height = 250

    $bubblePanel = New-Object System.Windows.Forms.Panel
    $bubblePanel.BackColor = [System.Drawing.Color]::FromArgb(255, 255, 224)
    $bubblePanel.Size = New-Object System.Drawing.Size(250, 120)
    $bubblePanel.BorderStyle = 'None'

    $bubblePanel.add_Paint({
        param($panel, $paintEventArgs)
        $graphics = $paintEventArgs.Graphics
        if ($null -ne $graphics) {
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $brush = New-Object System.Drawing.SolidBrush($bubblePanel.BackColor)
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray)
            $rect = New-Object System.Drawing.Rectangle(0, 0, $bubblePanel.Width, $bubblePanel.Height)
            $graphics.FillRectangle($brush, $rect)
            $graphics.DrawRectangle($pen, $rect)
        }
    })

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Size = New-Object System.Drawing.Size(230, 80)
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.BackColor = [System.Drawing.Color]::Transparent
    $label.TextAlign = 'TopLeft'

    $closeButton = New-Object System.Windows.Forms.Button
    $closeButton.Text = "X"
    $closeButton.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $closeButton.Size = New-Object System.Drawing.Size(20, 20)
    $closeButton.Location = New-Object System.Drawing.Point(($bubblePanel.Width - 25), 5)
    $closeButton.BackColor = [System.Drawing.Color]::FromArgb(200, 200, 180)
    $closeButton.FlatStyle = 'Flat'
    $closeButton.ForeColor = [System.Drawing.Color]::DarkGray
    $closeButton.FlatAppearance.BorderSize = 0
    $closeButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    $closeButton.Add_Click({
        $form.Close()
    })

    $clippyImage = [System.Drawing.Image]::FromFile($ImagePath)
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Image = $clippyImage
    $pictureBox.SizeMode = 'StretchImage'
    $pictureBox.Size = New-Object System.Drawing.Size(100, 100)
    $pictureBox.BackColor = [System.Drawing.Color]::Transparent

    if ($Orientation -eq "Below") {
        $bubblePanel.Location = New-Object System.Drawing.Point(($form.Width - $bubblePanel.Width) / 2, 10)
        $pictureBox.Location = New-Object System.Drawing.Point(($form.Width - $pictureBox.Width) / 2, $bubblePanel.Bottom + 10)
    } else {
        $bubblePanel.Location = New-Object System.Drawing.Point(120, 10)
        $clippyTop = ($bubblePanel.Height - $pictureBox.Height) / 2 + $bubblePanel.Top
        $pictureBox.Location = New-Object System.Drawing.Point(10, $clippyTop)
    }

    $buttonHeight = 30
    $buttonWidth = 75
    $nextButtonTop = $bubblePanel.Bottom + 10
    $buttonBackColor = [System.Drawing.Color]::FromArgb(255, 255, 224)
    $buttonBorderColor = [System.Drawing.Color]::Gray

    foreach ($key in $Buttons.Keys) {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $key
        $button.Location = New-Object System.Drawing.Point(120, $nextButtonTop)
        $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $button.BackColor = $buttonBackColor
        $button.FlatStyle = 'Flat'
        $button.FlatAppearance.BorderColor = $buttonBorderColor
        $button.Add_Click($Buttons[$key])
        $form.Controls.Add($button)
        $nextButtonTop += $buttonHeight + 10
    }

    $bubblePanel.Controls.Add($label)
    $bubblePanel.Controls.Add($closeButton)
    $form.Controls.Add($bubblePanel)
    $form.Controls.Add($pictureBox)

    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::Run($form)
}

Export-ModuleMember -Function Show-ClippyPopup