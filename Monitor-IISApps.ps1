# Powershell monitor an application on IIS, restart the app pool if the application down and send an notification email
# Setup Url to your IIS application
# 
$HTTP_Request = [System.Net.WebRequest]::Create('http://www.cosoco.com/CustomerService/')
$HTTP_Response = $HTTP_Request.GetResponse()
# Get response code
$HTTP_Status = [int]$HTTP_Response.StatusCode
# If return error code restart the app pool and send email
if($HTTP_Status -ne 200)
{
    # Email notifocation 
    Send-emailnotification -From customerservice@cosoco.com -To youremail@cosoco.com -SMTPServer yourSMTP.server.com
    # Restart app pool
    Restart-WebItem "IIS:\AppPools\CustomerService"
    } 
# Send email function
Function Send-emailnotification
{
	param
	(
		
		[Parameter(Mandatory=$true,Position=0)]
	    [String]$From,
		[Parameter(Mandatory=$true,Position=1)]
	    [String[]]$To,
		[Parameter(Mandatory=$true,Position=2)]
	    [String]$SMTPServer
	)
	try
	{	

		$EmailBody= "Customer Service app is down, application pool CustomerService is restart in process... Please check http://www.cosoco.com/CustomerService/Default.asp"
		#Email subject
		$EmailSubj= "Customer service is down" 
		#Create SMTP client
		$SMTPClient = New-Object Net.Mail.SMTPClient($SmtpServer)  
		#Create mailmessage object 
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = "$From"
		Foreach($EmailTo in $To)
		{
		 $emailMessage.To.Add($EmailTo)
		}
		$emailMessage.Subject = $EmailSubj
		$emailMessage.Body = $EmailBody
		#Send email
		$SMTPClient.Send($emailMessage)
	}
	Catch
	{
		Write-Error $_
	}

}
