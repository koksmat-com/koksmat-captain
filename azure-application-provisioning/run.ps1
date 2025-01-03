<#---
title: Add a certificate to an application and share the secret with the owner
---
## Add a certificate to an application and share the secret with the owner


#>
$root = [System.IO.Path]::GetFullPath(( join-path $PSScriptRoot ..)) 

. "$root/.koksmat/pwsh/check-env.ps1" "GRAPH_APPID", "GRAPH_APPSECRET", "GRAPH_APPDOMAIN", "OWNER_UPN", "TARGET_APPID"

$subject = "CN=$env:OWNER_UPN"

try {

  <#
### Generate a certificate
#>

  . "$PSScriptRoot/generate-cert.ps1" 

  New-Cert -SubjectName $subject -BaseFileName "exchange"


  <#
 ### Add the certificate to the application
 #> 
  $certDir = $env:CERTDIR 
  $pfx = Get-Content -Path (join-path $certDir "exchange.b64pfx") -Raw 
  $cert = Get-Content -Path (join-path $certDir "exchange.b64cer") -Raw 

  
  . "$PSScriptRoot/add-cert.ps1"  -ApplicationId $env:TARGET_APPID -Subject $subject  -certBase64 $cert

  <#
### Share the secret with the owner
#>
  . "$PSScriptRoot/share-secret.ps1" -pfxBase64 $pfx 

}
catch {
  write-host "Error: $_" -ForegroundColor:Red
  
}

