$GPO = Get-GPO -All
 
$GPO = Get-GPO -All
 
foreach ($Policy in $GPO){

        $GPOID = $Policy.Id
        $GPODom = $Policy.DomainName
        $GPODisp = $Policy.DisplayName

         if (Test-Path "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml")
         {
             [xml]$DriveXML = Get-Content "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml"

                    foreach ( $drivemap in $DriveXML.Drives.Drive )

                        {New-Object PSObject -Property @{
                            GPOName = $GPODisp
                            DriveLetter = $drivemap.Properties.Letter + ":"
                            DrivePath = $drivemap.Properties.Path
                            DriveAction = $drivemap.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
                            DriveLabel = $drivemap.Properties.label
                            DrivePersistent = $drivemap.Properties.persistent.Replace("0","False").Replace("1","True")
                            DriveFilterGroup = $drivemap.Filters.FilterGroup.Name
                            GUID = $GPOID
                        } 
                    } 
        } 
} 