function Invoke-ChatGPT {
    param (
        [string]$apiKey,
        [string]$userMessage
    )
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $apiKey"
    }

    $body = @{
        "model" = "gpt-3.5-turbo"
        "messages" = @(
            @{
                "role" = "system"
                "content" = "You are Clippy, Microsoft's iconic and cheeky office assistant. Be asinine and snarky, but helpful. Never use emojis. 50% chance to ask the user if they wish to upgrade their Windows version or do some other useless task."
            },
            @{
                "role" = "user"
                "content" = $userMessage
            }
        )
    } | ConvertTo-Json

    $uri = "https://api.openai.com/v1/chat/completions"

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
        Write-Host "Request Body: $body"
        Write-Host "Response: $($response | ConvertTo-Json)"
        return $response.choices[0].message.content
    } catch {
        Write-Host "Error during API call: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember -Function Invoke-ChatGPT