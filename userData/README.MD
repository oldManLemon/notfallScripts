# Change Shared User Paths(Drive Maps GPO Changer)
## Introduction
In order to control our shared folders to various stations we have a range of GPO policies that map drive paths and letters to local users based on Group memberships or individual user. 
This script was designed as the panic script for when these servers may fall over. This script will run through all the GPO's and where appropriate take action to change the drive path to central server. Currently there is a debate whether we switch back after directing all the traffic to the central server. 

## Usage
Currently running it with correct permissions will be enough change the drive folders. 
1. Open Powershell and `cd` to the script location. 
2. Run the script `.\changeGPO.ps1`
3. CAUTION, CURRENTLY THERE IS NO REVERSE!!!!!
4. ACHTUNG, KEINE RÜCKGÄNGIG MÖGLICH!

## Features
There are some cleanup features included.  Christian requested that all new paths should include `HAJ_OrnderName` or `DUS_OrnderName` for example. Some folders seem to already be following this convention or have attempted to follow this convention by placing the name at the end `OrdnerName_DUS` for example. 
The script will clean the folders names and standardise them to be the same.
### Name Scrubber
Assume the 3 variables on the folder names below and that they are all from FRA's server

    FRA_tiger
    tiger_FRA
    tiger
The script will output:

    FRA_tiger
    FRA_tiger
    FRA_tiger

## Output File
The current actions that will be taken by the script are available to be seen from the attached the TXT file. 

Quick examples:

    OLD path: 
    \\filehaj01\Stationdrive_HAJ
    New path: 
    Hannover
    \\FILEDCBCLUSTER\HAJ_Stationdrive$
    *************************
    
    OLD path: 
    \\filehaj01\company
    New path: 
    Hannover
    \\FILEDCBCLUSTER\HAJ_company$
    *************************
    
    
    OLD path: 
    \\FILEHAJ01\USERSHARE$\%USERNAME%\Documents
    New path: 
    Hannover
    \\FILEDCBCLUSTER\HAJ_USERSHARE$\%USERNAME%\Documents$
    *************************
    
    OLD path: 
    \\DCMUC02\MUC_GGR
    New path: 
    Munich
    \\FILEDCBCLUSTER\MUC_GGR$
    
    OLD path: 
    \\filedcbcluster\Global$
    New path: 
    \\filedcbcluster\Global$
    *************************

# Possible TODO's
- Reverse Script
- Station Selection(Run only against a chosen station)
- ~~Better~~ German Translation(Ich suche Freiwillige)
