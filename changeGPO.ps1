
#GPO PANIC CHANGE
$GPO = Get-GPO -Name "AndrewDriveGPO"
$GPID = $GPO.Id
$GPDom = $GPO.DomainName

#Path should be consistent
#Test first
if (Test-Path "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml") {
    $file = "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml"
    [xml]$xml = Get-Content $file
    $path = $xml.Drives.Drive.Properties.GetAttribute("path")
    $path = "\\FILEDCBCLUSTER\ITNEU"
    # $path = '******'
    $xml.Drives.Drive.Properties.SetAttribute("path", $path)
    $xml.Save($file)
}