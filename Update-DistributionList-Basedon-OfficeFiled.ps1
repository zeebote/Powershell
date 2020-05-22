# Powershell script update distribution list based on AD account office field.
# Import AD and Exchange Powershell module
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-DLOfficeUpdate.log"
# Get users filter on description fields content and OU
# Change this line match with your domain and OU 
$users = get-aduser -Filter {physicalDeliveryOfficeName -like "*" -and Title -like "*"} -SearchBase "OU=OU,DC=Your-domain,DC=com" -Properties physicalDeliveryOfficeName, MemberOf, info
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userOffice = $user.physicalDeliveryOfficeName
  $userGroups = $user.MemberOf
  $userTitle = $user.Title
  $usernotes = $user.info
  #Check if user has exception rules
  If ($usernotes -ne $null -and $usernotes.Tolower() -eq "exception dls"){
     write-Output "$username account has exception rule, skip..." >> $LogFile
     continue
     Write-Output "Should not see this"   
  }
  Else {
         #Assign DL to first 4 letters of office field
         $uOffice = $userOffice.substring(0,[math]::min(20,$userOffice.length) )
         If ($uOffice.Tolower() -eq "camh")
         {$dl = "Distribution1"}
         ElseIf ($uOffice.Tolower() -eq "txrs" -or $uOffice.Tolower() -eq "txal")
         {$dl = "Distribution2"}
         ElseIf ($uOffice.Tolower() -eq "us - chicago")
         {$dl = "Distribution3"}
         ElseIf ($uOffice.Tolower() -eq "accan")
         {$dl = "Distribution4"}
         ElseIf ($uOffice.Tolower() -eq "casd")
         {$dl = "Distribution5"}
         ElseIf ($uOffice.Tolower() -eq "acbrz")
         {$dl = "Distribution6"}
         ElseIf ($uOffice.Tolower() -eq "us - acton")
         {$dl = "Distribution7"}
         ElseIf ($uOffice.Tolower() -eq "acmex")
         {$dl = "Distribution8"}
         Else {$dl = $userOffice
         }
     Write-Output "$username is member of $dl" >> $LogFile   
         
     # Check if dl group exist
     $dlc = Get-ADGroup -LDAPFilter "(SAMAccountName=$dl)"
     If ($dlc -eq $null) 
        {write-Output "Group $dl is not exist, $username is a remote user or has non standard office location" >> $LogFile
        continue
        }
     #Assign user to proper DL
     Else {
     $members = Get-ADGroupMember -Identity $dl -Recursive | Select -ExpandProperty SamAccountName
         If ($members -contains $username) {
         write-Output "$username is already a member of $dl" > $null
         } Else {
           write-Output "$username is not a member of $dl, adding..." >> $LogFile
           Add-ADGroupMember -Identity $dl -Members $username 
           }
     } 
  }

  # Check if user belong to wrong DL 
  Foreach ($usergroup in $userGroups) {
  $ADgroup = (Get-ADGroup $usergroup).Name
    If ($ADgroup -eq "Distribution1" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution2" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution3" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution4" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution5" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution6" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution7" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution8" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    Else{
    Write-Output "do nothing with this group" > $null
    }
  }     
$i++
}
#Total accounts has been update
write-Output "Total $i accounts have been updated" >> $LogFile
