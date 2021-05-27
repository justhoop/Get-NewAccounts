function Get-ManagerName ([string]$ManagerDN) {
    if ($ManagerDN) {
        $NewName = Get-ADUser -Identity $ManagerDN -Properties SamAccountName
        Return $NewName.SamAccountName   
    }
}

function Get-AccountAge ($user, $now, $agelimit) {
    try {
        $AccountCreated = New-TimeSpan -Start $user.WhenCreated -end $now
        If($AccountCreated.Days -lt $agelimit){
            return $AccountCreated.Days
        }
    }
    catch {
        Write-Host "Failed at "$user.name
    }
    
}

$scriptdir = (Split-Path $script:MyInvocation.MyCommand.Path)
$ou = "OU" + ((get-aduser $env:username).DistinguishedName -split "\,OU(.*)")[1]
$agelimit = 90
$users = Get-ADUser -Filter * -properties WhenCreated, Manager -Searchbase $ou
$now = (Get-Date)
$list = "User,Manager,AccountAge`r`n"
foreach($user in $users){
    $age = Get-AccountAge -user $user -now $now -agelimit $agelimit
    if ($age) {
        $manager = Get-ManagerName($user.manager)
        $list += $user.SamAccountName + "," + $manager + "," + $age + "`r`n"
    }
}

$list | Out-File -FilePath $scriptdir"\newbs.csv" -Encoding ascii 