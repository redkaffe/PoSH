cls
# Populate LAB AD with "Real" users and OUs

# Number Of Users to create
$nrOfUsers = 500

# Number of Letters from Firstname in User Name
$lettersUNamefName = 3

# Number of Letters from Lastname in User Name
$lettersUNamelName = 3

# Name of the AD
# Default is the domain where your user are.
$activeLabDomain = new-object DirectoryServices.DirectoryEntry
$labDomain = $activeLabDomain.distinguishedName

# LAB OU
$labOU = "Lab OU"

# OUs to create
$labOUs = "Finance", "Production", "Marketing", "Informatique", "Ressources Humaines", "VIPs"

# OU structure under each OU
$OUStructure = "Utilisateurs", "Groupes", "Ordinateurs","Service Accounts", "Admins"

# Country
$userCountry = "France", "Suisse", "Belgique", "Canada"

# Path to the file with Firstnames
$fNameFileFixed = "c:\scripts\prenoms.txt"
# Path to the file with Lastnames
$lNameFileFixed = "c:\scripts\noms.txt"


# Creating the "root" Lab OU
$search = [System.DirectoryServices.DirectorySearcher]"[ADSI]LDAP://$labDomain"
$search.Filter = "(&(name=$labOU)(objectCategory=organizationalunit))"
$result = $search.FindOne()

if ($result -eq $null) {
    $labADSIDomain = [ADSI]"LDAP://$labDomain"
    $objOU = $labADSIDomain.Create("OrganizationalUnit", "ou=" + $labOU)
    $objOU.SetInfo()
    Write-Host $labOU "créé"
}
else
{
    Write-Host $labOU "existe"
}

# Creating all OUs in the Lab OU
$labDomainOU = [ADSI]"LDAP://ou=$labOU,$labDomain"
foreach ($labUnit in $labOUs) {
    $search = [System.DirectoryServices.DirectorySearcher]$labDomainOU
    $search.Filter = "(&(name=$labUnit)(objectCategory=organizationalunit))"
    $result = $search.FindOne()
    if ($result -eq $null) {
        $objOU = $labDomainOU.Create("OrganizationalUnit", "ou=" + $labUnit)
        $objOU.SetInfo()

        Write-Host $labUnit "créé"
    }
    else
    {
        Write-Host $labUnit "existe"
    }

}


for($i = 0;$i -lt $nrOfUsers ;$i++) {
    $firstName = Get-Content $fNameFileFixed | Get-Random -ErrorAction SilentlyContinue
    $lastName = Get-Content $lNameFileFixed | Get-Random -ErrorAction SilentlyContinue
    
    $mylabOUs = $labOUs | Get-Random
    
    $userFirstName = $firstName -creplace('ä','a') -creplace('ö','o')  -creplace('ë','e') -creplace('ê','e') -creplace('é','e') -creplace('è','e')
    $userFirstName = $userFirstName.ToLower()
    $userShortFirstName = $userFirstName.Substring(0,$lettersUNamefName)
    
    $userLastName = $lastName -creplace('ä','a') -creplace('ö','o')  -creplace('ë','e') -creplace('ê','e') -creplace('é','e') -creplace('è','e')
    $userLastName = $userLastName.ToLower()
    $userShortLastName = $userLastName.Substring(0,$lettersUNamelName)
    
        $userNumber = Get-Random -Minimum 10000 -Maximum 99999
    
    $userSAM = $userShortFirstName + $userShortLastName + $userNumber
    
    
    
    $userLastTele = Get-Random -Minimum 1000 -Maximum 9999
    $userTele = "+468-440 " + $userLastTele
    
    $myUserCountry = $userCountry | Get-Random
    
    switch ($myUserCountry) 
    { 
        'France' {$userCoutryCode = "fr"} 
        'Belgique' {$userCoutryCode = "be"} 
        'Suisse' {$userCoutryCode = "ch"} 
        'Canada' {$userCoutryCode = "ca"} 
        default {$userCoutryCode = "local"}
    }
  
    $userEmail = $userFirstName + "." + $userLastName + "@lab." + $userCoutryCode
    
    $userDescription = $firstName + " " + $lastName + " dans " + $mylabOUs + " en " + $myUserCountry
    
    $userPrincipalName = $userFirstName + "." + $userLastName + "@lab.local"
    
    $displayName = $LastName + ", " + $FirstName
    
    # Creating the User
    $objOU = new-object DirectoryServices.DirectoryEntry("LDAP://OU=$myLabOUs,OU=$labOU," + $labDomain)
    $objUser = $objOU.Create("user", "cn=$FirstName $LastName")
    $objUser.Put("sAMAccountName", $userSAM)
    $objUser.Put("userPrincipalName",$userPrincipalName)
    $objUser.Put("displayName",$displayName)
    $objUser.put("mail", $userEmail)
    $objUser.put("department", $myLabOUs)
    $objUser.put("company","Lab Corp.")
    $objUser.put("employeeNumber", $userNumber)
    $objUser.put("telephoneNumber", $userTele)
    $objUser.put("wWWHomePage", "http://www.google.com")
    
    $objUser.SetInfo()
    Write-Host "Created - " $firstName $lastName "($userSAM) in" $mylabOUs 
    
    $objUser.Put("givenName", $firstName)
    $objUser.Put("sn", $lastName)
    $objUser.Put("description", $userDescription)
    $objUser.SetInfo()

    # Password
    $objUser.psbase.invoke("setpassword", "P@ssw0rd")
    $objUser.SetInfo()

    # Enable the account
    $objUser.psbase.invokeset('accountdisabled', $false)
    $objUser.SetInfo()

    # Change password at next login
    $objUser.PwdLastSet = 0
    $objUser.Setinfo()

}
  