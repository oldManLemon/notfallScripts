
#GPO PANIC CHANGE
$GPO = Get-GPO -Name "AndrewDriveGPO"
$GPID = $GPO.Id
$GPDom = $GPO.DomainName

#Path should be consistent

function changeDrivePathDetails {
    Param($GPDomain, $GPID)
    #Changes path to a newly specified path
    if (Test-Path "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml") {
        $file = "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml"
        #OK Drivemaps contain more than one map... some my suggest obviosuly
        [xml]$xml = Get-Content $file
        foreach ( $drivemap in $xml.Drives.Drive ) {
            $path = $drivemap.Properties.GetAttribute("path")
            Write-Output "OLD path: "$path
            $path = pathCreator -Path $path
            Write-Output "New path: "$path
            Write-Output "*************************`n"
            #$xml.Drives.Drive.Properties.SetAttribute("path", $path)
            #$xml.Save($file)
        }
        
    }
}#End changeDrivePathDetails

function isItStationDriveCode {
    #Check name of file to cleanup in future
    Param([string]$String)
    if ($String.length -eq 3) {
        return 0
    }
    else {
        return 1
    }
}

function pathCreator {
    Param($Path)
    #Returns new path based on the old Path
    
    #No blanks
    if($Path.length -eq 0){
        return $path
    }

    #Analyse the current path
    $f, $strings = $Path.Split("\")
    $station = $strings[1].ToUpper()
    
    if ($station -eq 'FILEDCBCLUSTER') {
        #Ignore if already in right place
        return $path
    }
    

    $folder = $strings[2]
    $newPath = "\\FILEDCBCLUSTER\"
    #Figuring out stations
    #Speed Up with REGEX CURRENTLY SLOW
    switch -Wildcard ($station) {
        "FILEFRA*" {
            "Frankfurt"
            return $newPath + "FRA_" + $folder + "$"
        }
        "DCMUC*" {
            "Munich"
            return $newPath + "MUC_" + $folder + "$"
        }
        "FILEHAM*" {
            "Hamburg"
            return $newPath + "HAM_" + $folder + "$"
        }
        "DCHQ*" {
            "HQ"
            return $newPath + "HQ_" + $folder + "$"
        }
        "DCCNG*" {
            "Koeln"
            return $newPath + "CNG_" + $folder + "$"
        }
        "DCDUS*" {
            "Duesseledorf"
            return $newPath + "DUS_" + $folder + "$"
        }
        "DCBER*" {
            "Berlin"
            return $newPath + "BER_" + $folder + "$"
        }
        "FILEBRE*" {
            "Bremen"
            return $newPath + "BRE_" + $folder + "$"
        }
        "FILEHAJ*" {
            "Hannover"
            return $newPath + "HAJ_" + $folder + "$"
        }
        "DCEG*" {
            "DELETEME"
            return '******'
        }
        default {
            $station
            "Not suppose to happen"
            return '******'
        }
    }
    

}

#Scan and Change
$GPO = Get-GPO -All
 
foreach ($Policy in $GPO) {

    $GPOID = $Policy.Id
    $GPODom = $Policy.DomainName
    $GPODisp = $Policy.DisplayName
    changeDrivePathDetails -GPI $GPOID -GPDomain $GPODom
} 

#Paths to Test
#These two are some fresh bullshit! 
#Solution: Check for the underscore remove but what side is it??? 
# \\DCBER01\BER_Stationdrive
# \\filefra01\Stationdrive_FRA


#Copy Permissions
# Get-Acl -Path C:\Folder1 | Set-Acl -Path C:\Folder2


# \\filefra01\company
# \\FILEDCBCLUSTER\ITNEU

# pathCreator -Path "\\DCDUS01\sekretariat"
# changeDrivePathDetails -GPDomain $GPDom -GPID $GPID