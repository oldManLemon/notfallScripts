
#GPO PANIC CHANGE
# $GPO = Get-GPO -Name "AndrewDriveGPO"
# $GPID = $GPO.Id
# $GPDom = $GPO.DomainName

#Path should be consistent

function changeDrivePathDetails {
    Param($GPDom, $GPID)
    
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
function scrubber {
    Param([string]$Segment)
    
    switch ($Segment) {
        "MUC" { return "" }
        "HAM" { return "" }
        "HQ" { return "" }
        "BRE" { return "" }
        "CGN" { return "" }
        "BER" { return "" }
        "HAJ" { return "" }
        "FRA" { return "" }
        Default { return $Segment }
    }
}

function suffixPrefixScrubber {
    Param([string]$String)
    $first, $second = $String.Split("_")
    if ($second.length -eq 0) {
        return $String
    }
    else {
        $first = scrubber -Segment $first
        $second = scrubber -Segment $second
        return $first + $second
    }
}

function pathCreator {
    Param($Path)
    #Returns new path based on the old Path
    #No blanks
    if ($Path.length -eq 0) {
        return $Path
    }
    #Analyse the current path
    $f, $strings = $Path.Split("\")
    $station = $strings[1].ToUpper()
    if ($station -eq 'FILEDCBCLUSTER') {
        #Ignore if already in right place
        return $Path
    }
    #Dealing with folder trees
    if ($strings.length -gt 3) {
        for ($i = 2; $i -lt $strings.length; $i++) {
            if ($i -eq ($strings.length - 1)) {
                $segment = suffixPrefixScrubber -String $strings[$i]
                $folder += $segment
            }
            else {
                $segment = suffixPrefixScrubber -String $strings[$i]
                $folder += $segment + "\"
            }
            
        }
    }
    else {
        $segment = suffixPrefixScrubber -String $strings[2]
        $folder += $segment
    }
    #Figuring out stations
    #Speed Up with REGEX CURRENTLY SLOW
    $newPath = "\\FILEDCBCLUSTER\"
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
        "DCCGN*" {
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
            return $Path
        }
    }
    
}



#Paths to Test
#These two are some fresh bullshit! 
#Solution: Check for the underscore remove but what side is it??? 
# \\DCBER01\BER_Stationdrive
# \\filefra01\Stationdrive_FRA


#Copy Permissions
# Get-Acl -Path C:\Folder1 | Set-Acl -Path C:\Folder2

# \\FILEHAJ01\USERSHARE$\%USERNAME%\Documents
# \\filefra01\company
# \\FILEDCBCLUSTER\ITNEU

# pathCreator -Path "\\filefra01\company"
# pathCreator -Path "\\FILEHAJ01\USERSHARE$\%USERNAME%\Documents"
# pathCreator -Path "\\filefra01\FRA_tiger"
# pathCreator -Path "\\filefra01\tiger_FRA"
# $X = suffixPrefixScrubber "FRA_tiger"
# $Y = suffixPrefixScrubber "tiger_FRA"
# $Z = suffixPrefixScrubber "tiger"
# suffixPrefixScrubber "CGN_GGR"


# $X
# $Y
# $Z
# changeDrivePathDetails -GPDomain $GPDom -GPID $GPID


#  .d8888.  .o88b.  .d88b.  d8888b. d88888b 
#  88'  YP d8P  Y8 .8P  Y8. 88  `8D 88'     
#  `8bo.   8P      88    88 88oodD' 88ooooo 
#    `Y8b. 8b      88    88 88~~~   88~~~~~ 
#  db   8D Y8b  d8 `8b  d8' 88      88.     
#  `8888Y'  `Y88P'  `Y88P'  88      Y88888P 

#Scope
# Scan and Change
$GPO = Get-GPO -All
 
foreach ($Policy in $GPO) {

    $GPOID = $Policy.Id
    $GPODom = $Policy.DomainName
    $GPODisp = $Policy.DisplayName
    changeDrivePathDetails -GPI $GPOID -GPDom $GPODom
} 