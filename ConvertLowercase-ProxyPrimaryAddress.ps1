# Powershell script to change email to lower case Primary email in AD account proxy attributes
# This script require AD powershell module
# Import AD Powershell module
import-module activedirectory
# Setup log file name
$timer = (Get-Date -Format yyy-mm-dd-hhmm)
$LogFile = "c:\scripts\Logs\" + $timer + "-LowercaseProxyEmail.log"
# Filter OU and account
# Change this line to match with your AD
$users = get-aduser -Filter {mail -like "*"} -SearchBase "OU=AM,DC=Your-domain,DC=com" -Properties mail, proxyAddresses 
$i = 0
foreach ($user in $users)
{
#If the ProxyAddresses field is not empty convert to lowercase.		
    If ($user.proxyAddresses -ne $null)
       {
	    $name = $user.Name
	    $sam = $user.SamAccountName
        $email = $user.mail.Tolower()
	    $proxy = $user.proxyAddresses
        # Write to log file proxy attributes before update just in case need to change back" 	   
            Write-Output "Before updating for account: $sam" >> LogFile
            write-Output $proxy >> LogFile
            Set-ADUser -identity $sam -remove @{proxyAddresses = ("SMTP:" + $user.mail)}
	    Set-ADUser -identity $sam -Add @{proxyAddresses = ("SMTP:" + $email)}	
       }
$i++    
}
#Total accounts has been update
write-Output "Total $i accounts have been updated" >> $LogFile
