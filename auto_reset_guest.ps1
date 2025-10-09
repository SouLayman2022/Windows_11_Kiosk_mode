# ======================================
# Guest Auto Reset Script (Dyafe - stable)
# ======================================
$GuestUser    = "Dyafe"
$DaysInactive = 0
$DefaultFiles = "C:\GuestDefaults"
$LogFile      = "C:\Scripts\guest_reset_log.txt"

# ======================================
# Logging start
# ======================================
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $LogFile -Value ""
Add-Content -Path $LogFile -Value "[$timestamp] --- Script started ---"

try {
    # Check if account exists
    $user = Get-LocalUser -Name $GuestUser -ErrorAction SilentlyContinue
    if (-not $user) {
        Add-Content -Path $LogFile -Value "User $GuestUser not found."
        exit
    }

    # Retrieve last logon (Security event 4624)
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID      = 4624
        Data    = $GuestUser
    } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 1

    if ($events) {
        $lastLogon = $events.TimeCreated
        $daysSinceLogon = (New-TimeSpan -Start $lastLogon -End (Get-Date)).Days
        Add-Content -Path $LogFile -Value "Last logon: $lastLogon ($daysSinceLogon days ago)"
    }
    else {
        $daysSinceLogon = $DaysInactive + 1
        Add-Content -Path $LogFile -Value "No previous logon found, assuming inactive."
    }

    # ======================================================
    # Reset logic
    # ======================================================
    if ($daysSinceLogon -ge $DaysInactive) {
        Add-Content -Path $LogFile -Value "Inactivity >= $DaysInactive days. Resetting account..."

        # Force logoff if user is logged in
        $sessions = quser | Select-String $GuestUser
        if ($sessions) {
            Add-Content -Path $LogFile -Value "User is currently logged in - logging off..."
            try {
                $sessionId = ($sessions -split '\s+')[2]
                logoff $sessionId /V
                Start-Sleep -Seconds 5
            } catch {
                Add-Content -Path $LogFile -Value "Couldn't log off $GuestUser - continuing."
            }
        }

        # Remove user account
        try {
            Remove-LocalUser -Name $GuestUser -ErrorAction Stop
            Add-Content -Path $LogFile -Value "Account object removed."
        } catch {
            Add-Content -Path $LogFile -Value "Error removing account: $($_.Exception.Message)"
        }

        # Remove old profile folder
        $guestProfile = "C:\Users\$GuestUser"
        if (Test-Path $guestProfile) {
            try {
                Remove-Item -Path $guestProfile -Recurse -Force -ErrorAction Stop
                Add-Content -Path $LogFile -Value "Old profile folder deleted."
            } catch {
                Add-Content -Path $LogFile -Value "Failed to delete profile folder: $($_.Exception.Message)"
            }
        }

        # Recreate user
        try {
            New-LocalUser -Name $GuestUser -NoPassword -ErrorAction Stop
            Add-LocalGroupMember -Group "Users" -Member $GuestUser
            Add-Content -Path $LogFile -Value "Account recreated."
        } catch {
            Add-Content -Path $LogFile -Value "Error recreating account: $($_.Exception.Message)"
        }

        # Copy default files
        Start-Sleep -Seconds 5
        if (Test-Path $DefaultFiles) {
            Copy-Item -Path "$DefaultFiles\*" -Destination "C:\Users\$GuestUser" -Recurse -Force -ErrorAction SilentlyContinue
            Add-Content -Path $LogFile -Value "Default files copied."
        }

        Add-Content -Path $LogFile -Value "Reset completed successfully."
    }
    else {
        Add-Content -Path $LogFile -Value "Account active recently. No action taken."
    }
}
catch {
    Add-Content -Path $LogFile -Value ("Error: " + $_.Exception.Message)
}

Add-Content -Path $LogFile -Value "--- Script finished ---"
Add-Content -Path $LogFile -Value ""
