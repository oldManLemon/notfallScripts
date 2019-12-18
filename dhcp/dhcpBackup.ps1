#Back Up for Server DHCP

#Note this path applys to the local dirve of the DHCP server
# Backup-DhcpServer -ComputerName "dcber01.intern.ahs-de.com" -Path "C:\Windows\system32\dhcp\manBackup"

#This path confusingly refers to the local path of machine running the script. Fun I know!!!
# $testExportFolder = Test-Path "\\dcber01.intern.ahs-de.com\C$\exportdir"
# $testExportFolder
# if(-Not ($testExportFolder)){
#     mkdir "\\dcber01.intern.ahs-de.com\C$\exportdir"
# }
# Export-DhcpServer -ComputerName "dcber01.intern.ahs-de.com" -File "\\dcber01.intern.ahs-de.com\C$\exportdir\dhcpexport.xml"


#list gathered from here https://cnf.ahs-de.com/pages/viewpage.action?pageId=5572026

#generate list

$DHCPSERVERS = Get-DhcpServerInDc

foreach ($server in $DHCPSERVERS) {
    $server.DnsName
    $writeFlag = $true
    #Note this path applys to the local dirve of the DHCP server
    try{Backup-DhcpServer -ComputerName $server.DnsName -Path "C:\Windows\system32\dhcp\manBackup"}
    catch{
        Write-Host "Probably not working" -ForegroundColor DarkCyan
        $writeFlag = $false
    }
    # This path confusingly refers to the local path of machine running the script. Fun I know!!!
    $ExportFolder ="\\"+$server.DnsName+"\C$\exportdir"
    $testExportFolder = Test-Path $ExportFolder
    $testExportFolder
    if(-Not ($testExportFolder)){
        try{mkdir $ExportFolder}
        catch{
            Write-Host "Denied" -ForegroundColor Red
            $writeFlag = $false
        }
    }
    try{
        Export-DhcpServer -ComputerName $server.DnsName -File $ExportFolder+"\dhcpexport.xml"
    }catch{
        Write-Host "Cannot Do this" -ForegroundColor Red
        $writeFlag = $false
    }
    

    #Copy Everything to here
    if(-Not ($writeFlag)){
        $DhcpBackupPath = "\\" + $server.DnsName + "\C$\Windows\system32\dhcp\manBackup" 
        $DhcpBackupPath
        $LocalBackupPath = "C:\Users\ahase\Documents\localBase\scripts\panic\dhcp\backupData\"+$server.DnsName
        Copy-Item $DhcpBackupPath -Destination $LocalBackupPath -Recurse
        #Copy Exports
        $DhcpExportsXmlFile = $ExportFolder+"\dhcpexport.xml"
        $LocalDhcpExportsXmlFile = "C:\Users\ahase\Documents\localBase\scripts\panic\dhcp\backupData\exports"+$server.DnsName
        Copy-Item -Path $DhcpExportsXmlFile -Destination $LocalDhcpExportsXmlFile
    }
  

}
