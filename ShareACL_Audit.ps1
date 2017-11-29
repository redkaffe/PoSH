$folder = "\\localhost\temp"

$tempfile = "c:\tmp\ACL_Audit.csv"

$items = Get-ChildItem $folder -Recurse #-ErrorAction SilentlyContinue

foreach ($item in $items) {
    try {
        $obj_acl = get-acl $item.FullName -ErrorAction Stop
        $acls = $obj_acl.access | where {($_.isinherited -eq $false) -and (($_.identityreference -like "Domain1\*") -or ($_.identityreference -like "Domain2\*"))}
    }
    catch { <#SilentlyContinue#> }
    
    foreach ($acl in $acls) {
        $props = @{'Path' = $item.PSParentPath.Split(':')[2];
                    'Name' = $item.Name;
                    'Domain' = $acl.IdentityReference.Value.Split('\')[0];
                    'ID' = $acl.IdentityReference.Value.Split('\')[1];
                    'Rights' = $acl.FileSystemRights;
                    'AccessType' = $acl.AccessControlType}

        $obj = New-Object -TypeName PSObject -Property $props
        $obj | Export-Csv $tempfile -Append
    }
} 

#$output = Import-Csv $tempfile
