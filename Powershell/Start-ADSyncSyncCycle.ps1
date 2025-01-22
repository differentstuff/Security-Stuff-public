Write-Output "- Starting AD Sync -"

try {
    # Start the sync as a job
    $job = Start-Job -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
    
    Write-Output "Waiting for sync to complete..."
    
    # Wait for job to complete and get results
    Wait-Job -Job $job | Out-Null
    $result = Receive-Job -Job $job
    
    Write-Output "`nSync completed at $(Get-Date -Format 'HH:mm:ss') with Status: $($result.Result)"
}
catch {
    Write-Output "Error during AD Sync: $_"
}
finally {
    # Cleanup the job
    if ($job) { Remove-Job -Job $job -Force }
}

Write-Output "`nPress Enter to exit..."
Read-Host