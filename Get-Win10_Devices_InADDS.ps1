Import-Module ActiveDirectory

Get-ADComputer -SearchBase "OU=Test, DC=RedKaffe, DC=com" -Properties * -Filter "OperatingSystem -like 'Windows 10*'" | Export-Csv c:\temp\Test_windows10comps.csv -NoTypeInformation 
