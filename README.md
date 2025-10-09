# 🧩 Guest Auto Reset Script for Windows 11

## 📝 Overview

This PowerShell script automatically resets a Windows 11 guest account after a certain number of inactive days.
It is designed for shared computers, kiosks, classrooms, or public-use PCs where user privacy and system cleanliness are important.

When the guest account hasn’t been used for a defined period (for example, 5 days), the script will:

Log off the account if it’s currently active.

Delete the local user account.

Remove the corresponding profile folder from C:\Users.

Recreate the account with a clean profile.

Optionally restore a default environment (shortcuts, wallpapers, etc.) from a template folder.

Write a detailed log of every action performed.

The result is a self-maintaining guest profile that automatically resets itself without administrator intervention.

## ⚙️ How It Works

The script checks the last logon time of the guest user (from Windows Security Event 4624).

It compares that timestamp to the current date.

If the account has been inactive for more than the configured number of days, it:

Logs off the account (if currently logged in).

Deletes the user account (Remove-LocalUser).

Deletes the profile folder (C:\Users\<GuestName>).

Recreates the account with no password and reassigns it to the “Users” group.

Copies all contents from C:\GuestDefaults into the new profile directory.

Every action and error is logged to C:\Scripts\guest_reset_log.txt.

## 🧱 File Structure

    C:\

├─ Scripts\
│ ├─ auto_reset_guest.ps1 # The main PowerShell script
│ └─ guest_reset_log.txt # Activity log file (auto-generated)
└─ GuestDefaults\ # Folder containing default files for new guest accounts
├─ Desktop\
 ├─ Documents\
 └─ any other folders/files you want to copy

## ⚡ Configuration

    Edit these variables at the top of the script:

    $GuestUser    = "Dyafe"               # Guest account name
    $DaysInactive = 5                     # Days of inactivity before reset
    $DefaultFiles = "C:\GuestDefaults"    # Folder with default files
    $LogFile      = "C:\Scripts\guest_reset_log.txt"

## Notes:

    The script must be run as Administrator.
    If the account is currently logged in, it will be logged off before reset.
    If you change the guest username, update $GuestUser accordingly.

## 🚀 Setup Instructions

1. Create the Guest Account (if it doesn’t exist)

   Run in PowerShell (Admin):
   New-LocalUser -Name "Dyafe" -NoPassword
   Add-LocalGroupMember -Group "Users" -Member "Dyafe"

2. Prepare Default Files

   Create a folder C:\GuestDefaults and put inside any files or shortcuts that you want every new guest profile to have.
   For example:
   C:\GuestDefaults\Desktop\Welcome.txt
   C:\GuestDefaults\Documents\

3. Save the Script
   Create a folder C:\Scripts and place auto_reset_guest.ps1 inside it.

## ⏰ Automate with Task Scheduler

To make the reset automatic, you’ll create a scheduled task that runs the script every day.

Step-by-Step:

Open Task Scheduler → Create Task...

General Tab

Name: Auto Reset Dyafe Guest

Check Run with highest privileges

Configure for: Windows 10 or Windows 11

Run whether user is logged on or not

Triggers Tab

New → Daily → Recur every 1 day
(You can also use “Repeat task every 12 hours” if you prefer more frequent checks)

Actions Tab

Action: Start a program

Program/script:
powershell.exe
Add arguments:
-ExecutionPolicy Bypass -File "C:\Scripts\auto_reset_guest.ps1"

Conditions Tab

Uncheck Start the task only if the computer is on AC power (optional)

Settings Tab

Check Run task as soon as possible after a scheduled start is missed

Check If the task fails, restart every 1 hour, up to 3 times

Click OK, then enter your admin password when prompted.

## 📘 Log Output Example

[2025-10-09 13:45:42] --- Script started ---
Last logon: 2025-10-04 09:22:31 (5 days ago)
Inactivity >= 7 days. Resetting account...
User is currently logged in - logging off...
Account object removed.
Old profile folder deleted.
Account recreated.
Default files copied.
Reset completed successfully.
--- Script finished ---

## 💡 Tips

To test immediately, set $DaysInactive = 0 and run the script manually.

## 🔒 Why This Script Is Useful

Ensures user privacy — all personal data from the guest session is wiped.

Maintains system performance by removing leftover profiles and cache.

Provides a consistent starting environment for every new guest login.

Requires no manual intervention once configured.

## 🧠 Author Notes

this scripts is 100% safe and dosen't have many lines, It was developed to automate guest account removale on Windows 11.
It combines PowerShell automation with Windows Task Scheduler for a clean.
I can see this used as a kiosk mode in many scenarios, such as:
Cybercafés or gaming centers – quickly clear guest sessions to prevent leftover data from affecting new users.

Libraries or community centers – provide safe, standardized access for visitors without manual account maintenance.

Shelters, schools, or public facilities – ensure sensitive information is not retained and accounts remain clean.

Home guest accounts – maintain privacy and system cleanliness for family members or visitors, automatically removing inactive guest accounts after a defined period.
