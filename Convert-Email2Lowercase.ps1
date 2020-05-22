# Powershell script to change email to lower case in AD account mail field
# This script require MS exchange powershell module and AD module
# Import AD and Exchange Powershell module
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-LowercaseEmail.log"
# Query AD for OU user and put it in an array.
# Modify this line match to your AD. 
$users = get-aduser -Filter {mail -like "*"} -SearchBase "OU=Employees,OU=US,OU=AM,DC=Your-Domain,DC=com" -Property mail | select samaccountname,mail
$i = 0
#For Loop to check each user one at a time
foreach ($user in $users)
 {
#If the user email field is not empty convert to lowercase.
    If ($user.mail -ne $null)
       {
           $sam = $user.SamAccountName
           $email = $user.mail.Tolower()
           # Write to log file
           write-Output "Update account $sam" >> $LogFile
           # Update account
           Set-ADUser -identity $sam -EmailAddress $email
       }
 $i++  
 }
#Total accounts has been update
write-Output "Total $i accounts have been updated" >> $LogFile
