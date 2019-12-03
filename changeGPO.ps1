
#GPO PANIC CHANGE
$GPO = Get-GPO -Name "AndrewDriveGPO"
$GPID = $GPO.Id
$GPDom = $GPO.DomainName

#Path should be consistent

function changeDrivePathDetails {
    Param($GPDomain, $GPID, $New_Path)
    #Changes path to a newly specified path
    if (Test-Path "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml") {
        $file = "\\$($GPDom)\SYSVOL\$($GPDom)\Policies\{$($GPID)}\User\Preferences\Drives\Drives.xml"
        [xml]$xml = Get-Content $file
        $path = $xml.Drives.Drive.Properties.GetAttribute("path")
        $path = "\\FILEDCBCLUSTER\ITNEU"
        $xml.Drives.Drive.Properties.SetAttribute("path", $path)
        $xml.Save($file)
    }
}#End changeDrivePathDetails

function pathCreator{
    Param($Path)
    #Returns new path based on the old Path

    #Analyse the current path
    $f,$strings = $Path.Split("\")
    
    $station = $strings[1].ToUpper()
    $folder = $strings[2]
    $newPath = "\\FILEDCBCLUSTER\"
    #Figuring out stations
    switch -Wildcard ($station){
        "FILEFRA*"{
            "Frankfurt"
            return $newPath+"FRA_"+$folder+"$"
        }
        "DCMUC*"{
            "Munich"
            return $newPath+"MUC_"+$folder+"$"
        }
        "FILEHAM*"{
            "Hamburg"
            return $newPath+"HAM_"+$folder+"$"
        }
        "DCHQ*"{
            "HQ"
            return $newPath+"HQ_"+$folder+"$"
        }
        "CDCNG*"{
            "Koeln"
            return $newPath+"CNG_"+$folder+"$"
        }
        "DCDUS*"{
            "Duesseledorf"
            return $newPath+"DUS_"+$folder+"$"
        }
        "DCBER*"{
            "Berlin"
            return $newPath+"BER_"+$folder+"$"
        }
        "FILEBRE*"{
            "Bremen"
            return $newPath+"BRE_"+$folder+"$"
        }
        "FILEHAJ*"{
            "Hannover"
            return $newPath+"HAJ_"+$folder+"$"
        }
        "DCEG*"{
            "DELETEME"
        }
        default{
            $station
            "Not suppose to happen"
        }
    }
    

}

#Paths to Test
# \\DCBER01\BER_Stationdrive
# \\filefra01\Stationdrive_FRA
# \\filefra01\company
# \\FILEDCBCLUSTER\ITNEU

pathCreator -Path "\\DCDUS01\sekretariat"