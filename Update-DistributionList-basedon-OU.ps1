# Powershell script update distribution list based on OU 
# Import AD and Exchange Powershell module
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-DLEployees.log"
# Get users filter OU - US
$users = get-aduser -Filter {description -like "*" -and Title -like "*"} -SearchBase "OU=Employees,OU=US,DC=Your-domain,DC=com" -Properties Title, MemberOf
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userGroups = $user.MemberOf
  $userTitle = $user.Title

  # Check user employees DL 
  $dl = "US-Employees"
 
  #Check if user title is begin with Contractor - Contractors are not in these DL group
     $uTitle = $userTitle.substring(0,[math]::min(10,$userTitle.length) )
     If ($uTitle.Tolower() -eq "contractor")
     {continue
         Write-Output "Should not see this"
     }
     Else {
     Write-Output "$username should be member of $dl" >> $LogFile
     $members = Get-ADGroupMember -Identity $dl -Recursive | Select -ExpandProperty SamAccountName
         If ($members -contains $username) {
         write-Output "$username is already a member of $dl" > $null
         } Else {
           write-Output "$username is not a member of $dl, adding..." >> $LogFile
           Add-ADGroupMember -Identity $dl -Members $username 
           }
     }
$i++
}
write-Output "There are $i members in $dl" >> $LogFile

# Get users filter OU - CA
$users = get-aduser -Filter {description -like "*" -and Title -like "*"} -SearchBase "OU=Employees,OU=CA,DC=Your-domain,DC=com" -Properties Title, MemberOf
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userGroups = $user.MemberOf
  $userTitle = $user.Title

  # Check user employees DL 
  $dl = "CA-Employees"
 
  #Check if user title is begin with Contractor - Contractors are not in these DL group
     $uTitle = $userTitle.substring(0,[math]::min(10,$userTitle.length) )
     If ($uTitle.Tolower() -eq "contractor")
     {continue
         Write-Output "Should not see this"
     }
     Else {
     Write-Output "$username should be a member of $dl" >> $LogFile
     $members = Get-ADGroupMember -Identity $dl -Recursive | Select -ExpandProperty SamAccountName
         If ($members -contains $username) {
         write-Output "$username is already a member of $dl" > $null
         } Else {
           write-Output "$username is not a member of $dl, adding..." >> $LogFile
           Add-ADGroupMember -Identity $dl -Members $username 
           }
     }
$i++
}
write-Output "There are $i members in $dl" >> $LogFile

# Get users filter OU - BR
$users = get-aduser -Filter {description -like "*" -and Title -like "*"} -SearchBase "OU=Employees,OU=BR,DC=Your-domain,DC=com" -Properties Title, MemberOf
$i = 0
foreach ($user in $users)
{
  $username  = $user.SamAccountName
  $userGroups = $user.MemberOf
  $userTitle = $user.Title

  # Check user employees DL 
  $dl = "BR-Employees"
 
  #Check if user title is begin with Contractor - Contractors are not in these DL group
     $uTitle = $userTitle.substring(0,[math]::min(10,$userTitle.length) )
     If ($uTitle.Tolower() -eq "contractor")
     {continue
         Write-Output "Should not see this"
     }
     Else {
     Write-Output "$username should be a member of $dl" >> $LogFile
     $members = Get-ADGroupMember -Identity $dl -Recursive | Select -ExpandProperty SamAccountName
         If ($members -contains $username) {
         write-Output "$username is already a member of $dl" > $null
         } Else {
           write-Output "$username is not a member of $dl, adding..." >> $LogFile
           Add-ADGroupMember -Identity $dl -Members $username 
           }
     }
$i++
}
write-Output "There are $i members in $dl" >> $LogFile
