if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
    Import-Module posh-git
	Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
	Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
	Set-PSReadLineOption -PredictionSource History

    function prompt {
        #Assign Windows Title Text
        $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"

        #Configure current user, current folder and date outputs
        $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
        $Date = Get-Date -Format 'dddd hh:mm:ss tt'

        # Test for Admin / Elevated
        $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

        #Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
        $LastCommand = Get-History -Count 1
        if ($lastCommand) { $RunTime = ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalSeconds }

        if ($RunTime -ge 60) {
            $ts = [timespan]::fromseconds($RunTime)
            $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
            $ElapsedTime = -join ($min, " min ", $sec, " sec")
        }
        else {
            $ElapsedTime = [math]::Round(($RunTime), 2)
            $ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
        }

        # $host.ui.RawUI.ForegroundColor = "Green"
        Write-host ($(if ($IsAdmin) { ' Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
        Write-Host "$($CmdPromptUser.Name.split("\")[1])@" -ForegroundColor Yellow -NoNewline           
        $oc = $host.ui.RawUI.ForegroundColor
        $host.UI.RawUI.ForegroundColor = "DarkCyan"
        $Host.UI.Write([System.Net.Dns]::GetHostName())
        $host.UI.RawUI.ForegroundColor = $oc
        $Host.UI.Write(" :: ")


        # $host.UI.RawUI.ForegroundColor = "Yellow"
        $host.UI.RawUI.ForegroundColor =  "DarkCyan"
        $Host.UI.Write(([string]$pwd).Replace("C:\Users\dawid.stasiak", "~"))
        $gitStatus = Write-VcsStatus
        $Host.UI.Write($gitStatus)
	    $message =  " $date "
        $startposx = $Host.UI.RawUI.windowsize.width - $message.length
        $startposy = $Host.UI.RawUI.CursorPosition.Y
        $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $startposx,$startposy
        $host.UI.RawUI.ForegroundColor = $oc
        $Host.UI.Write($message)
        $Host.UI.Write($([char]0x2192))
        
        return " "
    }
}
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
