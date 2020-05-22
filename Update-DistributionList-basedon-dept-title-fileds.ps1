# Powershell update distribution list based on account title and dept. fields
# Import AD and Exchange Powershell module
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-UserDeptUpdate.log"
# Get users filter on department and title fields' content and OU 
# change this line to match with your AD
$users = get-aduser -Filter {Department -like "*" -and Title -like "*"} -SearchBase "OU=AM,DC=Your-domain,DC=com" -Properties Department, Title, MemberOf 
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userdept = $user.Department
  $userTitle = $user.Title
  $userGroups = $user.MemberOf
  #Check if user title is begin with Contractor - Contractors are seperated in different group
  $uTitle = $userTitle.substring(0,[math]::min(10,$userTitle.length) )
  If ($uTitle.Tolower() -eq "contractor")
    {$dept = "_AM-Dept-" + $userdept.ToString() + "-Contractors"}
    Else {$dept = "_AM-Dept-" + $userdept.ToString()}
  # Check if dept. group exist
  $dl = Get-ADGroup -LDAPFilter "(SAMAccountName=$dept)"
  If ($dl -eq $null) 
  {write-Output "Group $dept is not exist, create it" >> $LogFile
  write-Output "Adding $username to new $dept group" >> $LogFile
  New-DistributionGroup -Name $dept -Members $username -Type "Security" -OrganizationalUnit "OU=AM-Dept-Dls,OU=AM,DC=main,DC=INTGIN,DC=NET"
  }
    #Check if user already membership of dept. DL
    Else {$members = Get-ADGroupMember -Identity $dept -Recursive | Select -ExpandProperty SamAccountName
         If ($members -contains $username) {
         write-Output "$username is already a member of $dept" > $null
         } Else {
           write-Output "$username is not a member of $dept, adding..." >> $LogFile
           Add-ADGroupMember -Identity $dept -Members $username 
           }
    }
  # Check if user belong to wrong dept. DL 
  Foreach ($usergroup in $userGroups) {
  $ADgroup = (Get-ADGroup $usergroup).Name
  $DLstart = $ADgroup.Substring(0,[math]::min(8,$ADgroup.length) )
  # Write-Output $DLstart >> $LogFile
  # Write-Output $dept >> $LogFile
    If ($DLstart -eq "_AM-Dept" -and $ADgroup -ne $dept){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
  }     
$i++
}
#Total accounts has been update
write-Output "Total $i accounts have been updated" >> $LogFile
