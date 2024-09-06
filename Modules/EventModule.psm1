function Register-ClippyEvent {
    param (
        [scriptblock]$Action,
        [timespan]$Delay
    )
    $job = Start-Job -ScriptBlock $Action
    Register-ScheduledJob -Name "ClippyEvent" -ScriptBlock $Action -Trigger (New-JobTrigger -Once -At (Get-Date).Add($Delay))
    return $job
}

Export-ModuleMember -Function Register-ClippyEvent