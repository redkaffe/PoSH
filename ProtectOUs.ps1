$searchbase = "DC=CORP,DC=REDKAFFE,DC=COM" 
         
#Protect Organizational units against accidental deletion 
import-module activedirectory 
Get-ADOrganizationalUnit -searchbase $searchbase -filter * -Properties ProtectedFromAccidentalDeletion | where {$_.ProtectedFromAccidentalDeletion -eq $false} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true
