param([Parameter(mandatory = $true)]
    [string]$Station,
    [switch]$Restore, #Should restore the files and delete the drives.xml
    [switch] $ForceNewRestorePoint, #Will delete the orig files and replace them with new copies. 
    [switch] $Live #Will only pipe or show on screen the expected changes unless Live is triggered then it will actually perform actions

)

#Test args
if ($station -eq '') {
    write-host "No Station Provided `n Stop"
    break
}

#Live warning
if($Live){
    Write-Host 'Warning: This will make changes to GPO policies. Do you wish to continue?' -ForegroundColor Red
   $Ans=Read-Host -Prompt 'y or n'
   if(-Not ($Ans -eq 'y')){
       Write-Host 'Answer not y, breaking' -ForegroundColor Yellow
    break
   }
}

#Flag Collection
#Statations
$MucGO = $false	
$HamGO = $false	
$HqGO = $false	
$BreGO = $false	
$CgnGO = $false	
$BerGO = $false	
$HajGO = $false	
$FraGO = $false	



switch ($Station) {
    "MUC" { $MucGO = $true }
    "HAM" { $HamGO = $true }
    "HQ" { $HqGO = $true }
    "BRE" { $BreGO = $true }
    "CGN" { $CgnGO = $true }
    "BER" { $BerGO = $true }
    "HAJ" { $HajGO = $true }
    "FRA" { $FraGO = $true }
    "ALL" { $MucGO = $HamGO = $HqGO = $BreGO = $CgnGO = $BerGO = $HajGO = $FraGO = $true }
    Default { return "Station Not Recognised" }
}

function driveMapPaths {
    Param($FilePath, [switch]$RestoreMode)
    #OK Drivemaps contain more than one map... some my suggest obviously
    $FilePath
    [xml]$xml = Get-Content $FilePath
    foreach ( $drivemap in $xml.Drives.Drive ) {
        if ($RestoreMode) {
            #Split path mode
            'enter restore mode'
            $path = $drivemap.Properties.GetAttribute("path")
            #Won't work with all properly
            if($path -match $Station ){
                $file = Split-Path $FilePath
                restore -Path $file
                return $true
            }
            Write-Host "Failed Station Check `nPlease check" -ForegroundColor Yellow

        }
        else {
            $path = $drivemap.Properties.GetAttribute("path")
            Write-Output "OLD path: "$path
            $newMapPath = pathCreator -Path $path
            Write-Output "New path: "$newMapPath
            Write-Output "*************************`n"
            if ($Live) {
                $xml.Drives.Drive.Properties.SetAttribute("path", $newMapPath)
                $xml.Save($file)
            }
        }
        
        
    }
}

#Path should be consistent
function changeDrivePathDetails {
    Param($GPDom, $GPID, $DisplayName)
    #This is the main function loop
    
    #Changes path to a newly specified path
    if (Test-Path "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml") {
        #$file = "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml"
        $DrivePath = "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\"
        $file = $DrivePath + "Drives.xml"
        Write-Output 'Policy Name: '$DisplayName
            
        if ($Restore) {
            #Test path to See if Segment exists then 
            
            driveMapPaths -FilePath $file -RestoreMode
        }
        else {
            #Write the Restore point
            #Write Restore Points for all now
            if (-Not (Test-Path $file".orig")) {
                Write-Output "Restore Point Created"
                Write-Output $file".orig"
                if($Live){
                   Copy-Item -Path $file -Destination $file".orig"  
                }
                 
            }
            else {
                Write-Output "Restore Point Found"
                Write-Output $file".orig"
            }

            driveMapPaths -FilePath $file
        
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
    #Checks a segment of text to see if matches a stations
    #Returns blank if matches a station code otherwise returns original string
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
    #Gets filename and splits it passes it through Segement and returns the cleaned file name
    #EG HAM_file or file_HAM becomes file
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
            
            if ($FraGO) {
                return $newPath + "FRA_" + $folder + "$" 
            }
            else {
                return $path
            }
            
        }
        "DCMUC*" {
            if ($MUCGO) {
                return $newPath + "MUC_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "FILEHAM*" {
            if ($HamGO) {
                return $newPath + "HAM_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "DCHQ*" {
            if ($HqGO) {
                return $newPath + "HQ_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "DCCGN*" {
            if ($CgnGO) {
                return $newPath + "CGN_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "DCDUS*" {
            if ($DusGO) {
                return $newPath + "DUS_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "DCBER*" {
            if ($BerGO) {
                return $newPath + "BER_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "FILEBRE*" {
            if ($BreGO) {
                return $newPath + "BRE_" + $folder + "$" 
            }
            else {
                return $path
            }
        }
        "FILEHAJ*" {
            if ($HajGO) {
                return $newPath + "HAJ_" + $folder + "$" 
            }
            else {
                return $path
            }
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

function restore {
    #Restores the backup files to thier original State. 
    #It is error Handled and built in a round a bout method to problems
    Param([string]$Path)
    $Backup = $Path + "Drives.xml.orig"
    $XMLFile = $Path + "Drives.xml"
    $BackupOfTheBackup = $Path + "Drives.x"
    if (Test-Path $Backup) {
        "I will now remove"
        #Delete XML!
        try {
            #A bit much here but it should fail if it can't rename the back up meaning it doesn't exist
            #This is done so to avoid deletion of Drives.xml beofre the seeing if the rename is there as the over the network this can be slow to Test-Path accuratly.
            #Thus should avoid false postives. 
            Rename-Item $Backup -NewName "Drives.x"
            
        }
        catch {
            Write-Output "Failed to Find Restore Point"
            Write-Output | Get-Item $Path*
            Write-Host "Restore Unsucessful" -ForegroundColor Red
        }
        try {
            Remove-Item $XMLFile
        }
        catch {
            Write-Output "Failed to Remove Drive Folder: $XMLFile"
            Write-Host "Restore Unsucessful" -ForegroundColor Red
        }
        try {
            Rename-Item  $BackupOfTheBackup -NewName "Drives.xml"
            Write-Host "Restore Successful" -ForegroundColor Green
        }
        catch {
            Write-Output "Failed to Rename and Restore backup : $BackupOfTheBackup "
            Write-Host "Restore Unsucessful" -ForegroundColor Red
        }
       
    }
    else {
        Write-Host "No Restore Point Available" -ForegroundColor Red
        Write-Output "No Restore Point Available"

    }

}


#  .d8888.  .o88b.  .d88b.  d8888b. d88888b 
#  88'  YP d8P  Y8 .8P  Y8. 88  `8D 88'     
#  `8bo.   8P      88    88 88oodD' 88ooooo 
#    `Y8b. 8b      88    88 88~~~   88~~~~~ 
#  db   8D Y8b  d8 `8b  d8' 88      88.     
#  `8888Y'  `Y88P'  `Y88P'  88      Y88888P 

#Scope
#Here you can define your scope
# Scan and Change
# $GPO = Get-GPO -All
$GPO = Get-GPO -Name AndrewDriveGPO

 
foreach ($Policy in $GPO) {

    $GPOID = $Policy.Id
    $GPODom = $Policy.DomainName
    $GPODisp = $Policy.DisplayName
    
    changeDrivePathDetails -GPI $GPOID -GPDom $GPODom -DisplayName $GPODisp
} 

# restore -Path "\\intern.ahs-de.com\SYSVOL\intern.ahs-de.com\Policies\{a6fc2730-929a-45eb-bd36-158133e746d6}\User\Preferences\Drives\"
# # Get-Item -Path "\\intern.ahs-de.com\SYSVOL\intern.ahs-de.com\Policies\{a6fc2730-929a-45eb-bd36-158133e746d6}\User\Preferences\Drives\*"