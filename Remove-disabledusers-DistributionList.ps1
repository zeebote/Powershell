# Powershell script remove disabled user in distribution list
# Import AD and Exchange Powershell module
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-UpdateDisabledUser.log"
$DisabledUsers = @()
# Search based OU and distribution list name - modify this line to match with your AD
$DLGroups = get-adgroup -Filter {Name -like "Dept-*"} -SearchBase "OU=Dept-DLs,OU=AM,DC=Your-domain,DC=com"
foreach ($group in $DLGroups)
{
$DisabledUsers += (Get-ADGroupMember -identity $group -recursive | Get-AdUser -Properties SamAccountName | Where {$_.Enabled -eq $False} | select -expand SamAccountName)
}

Write-Output "Removing disabled users..." >> $Logfile 
foreach ($user in $DisabledUsers)
{

    foreach ($group in $DLGroups)
    {
        If ((Get-AdUser $user -properties MemberOf).MemberOf -contains $group)
        {
        Write-Output "Remove disabled account $user from $group" >> $Logfile
        # remove-adgroupmember $group –members $user -confirm:$False
        }
    }

}

