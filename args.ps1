# param([Parameter(mandatory=$true)]
#     [string]$Station,
#     [switch]$Reverse

#     )

# #Test args
# if($station -eq ''){
#     write-host "No Station Provided `n Stop"
#     break
# }



# #Flags
# $MucGO  = $false	
# $HamGO = $false	
# $HqGO = $false	
# $BreGO = $false	
# $CgnGO = $false	
# $BerGO = $false	
# $HajGO = $false	
# $FraGO = $false	
# $AllGO = $false	

# switch ($Station) {
#     "MUC" { $MucGO= $true}
#     "HAM" { $HamGO= $true}
#     "HQ"  { $HqGO= $true}
#     "BRE" { $BreGO= $true}
#     "CGN" { $CgnGO= $true}
#     "BER" { $BerGO= $true}
#     "HAJ" { $HajGO= $true}
#     "FRA" { $FraGO= $true}
#     "ALL" { $MucGO=$HamGO=$HqGO=$BreGO=$CgnGO=$BerGO=$HajGO=$FraGO = $true}
#     Default { return "Station Not Recognised" }
# }

# $Reverse

# Get-Mailbox -ResultSize 5000 | where {$_.EmailADdresses -like "ber*"} | Select DisplayName, RecipientTypeEmailAddresses | Out-File ber.txt
# Get-Recipient -ResultSize 5000 | where {$_.EmailADdresses -like "*ber*"} | Select DisplayName, EmailAddresses | Out-File ber.txt


