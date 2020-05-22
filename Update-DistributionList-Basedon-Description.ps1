# This powershell script use to update distribution list based on first 3 letters of AD account description 
# Import AD and Exchange Powershell module
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-DLUpdate.log"
# Get users filter on description fields content and OU 
# Modify this line to match what you need on your AD
$users = get-aduser -Filter {description -like "*" -and Title -like "*"} -SearchBase "OU=Your OU,DC=Your-domain,DC=COM" -Properties description, Title, MemberOf, info 
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userDesc = $user.description
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
     #Check if user title is begin with Contractor - Contractors are not in these DL group
     $uTitle = $userTitle.substring(0,[math]::min(10,$userTitle.length) )
     If ($uTitle.Tolower() -eq "contractor")
     {continue
         Write-Output "Should not see this"
     }
     Else {
         #Assign 3 letters of account description to proper DL
         $uDesc = $userDesc.substring(0,[math]::min(3,$userTitle.length) )
         If ($uDesc.Tolower() -eq "asc")
         {$dl = "Distribution1"}
         ElseIf ($uDesc.Tolower() -eq "aus")
         {$dl = "Distribution2"}
         ElseIf ($uDesc.Tolower() -eq "cor")
         {$dl = "Distribution3"}
         ElseIf ($uDesc.Tolower() -eq "aff")
         {$dl = "Distribution4"}
         ElseIf ($uDesc.Tolower() -eq "aaz")
         {$dl = "Distribution5"}
         ElseIf ($uDesc.Tolower() -eq "ais")
         {$dl = "Distribution6"}
         Else {$dl = $userDesc
         }
     Write-Output "$username is member of $dl" >> $LogFile   
     }    
     # Check if dl group exist
     $dlc = Get-ADGroup -LDAPFilter "(SAMAccountName=$dl)"
     If ($dlc -eq $null) 
        {write-Output "Group $dl is not exist, $username account has non standard description" >> $LogFile
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
    ElseIf ($ADgroup -eq "Distribution3" -and $ADgroup -ne $dl){
    Write-Output "$username should not belong to this $ADgroup, removing" >> $LogFile
    Remove-ADgroupmember -Identity $ADgroup –members $username -confirm:$False
    }
    ElseIf ($ADgroup -eq "Distribution2" -and $ADgroup -ne $dl){
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
    Else{
    Write-Output "do nothing with this group" > $null
    }
  }     
$i++
}
#Total accounts has been update
write-Output "Total $i accounts have been updated" >> $LogFile
