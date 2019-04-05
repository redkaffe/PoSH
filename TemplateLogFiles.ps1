
Function Log-Message(){
    Param ($Message = ".")
    $Message = "$(Get-Date -DisplayHint Time): $Message"
    Write-Verbose $Message
    Write-Output $Message | Out-File $logFile -Append -Force
 }
 
#region Timing In
$StartScript = Get-Date
#
#========== Création du LogFile sous le répertoire d'execution avec comme nom le nom du Script.ps1.Log=============###
#
$logPath = $MyInvocation.MyCommand.Definition | Split-Path -Parent
$logFile = "$logPath\$($myInvocation.MyCommand).log" 
Log-Message "=============== Début d'execution du script.....  ================================================================="
#endregion Timing in

#region Timing Out
#Fonction de calcul du temps d'execution du script
#
$StopScript = Get-Date
$timespan = new-timespan -seconds $(($StopScript-$startScript).totalseconds) 
$ScriptTime = '{0:00}h:{1:00}m:{2:00}s' -f $timespan.Hours,$timespan.Minutes,$timespan.Seconds
#
Log-Message "============ Fin d'execution du script..... en $ScriptTime ========================================================"
#endregion Timing Out
#=================================================########### 
