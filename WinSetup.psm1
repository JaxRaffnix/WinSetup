# load helper functions
$helperFiles = Get-ChildItem -Path "$PSScriptRoot\Helpers" -Filter '*.ps1'
foreach ($file in $helperFiles) {
    . $file.FullName
}

# Load all function scripts and expose them via Export-ModuleMember
$functionFiles = Get-ChildItem -Path "$PSScriptRoot/src" -Filter *.ps1

foreach ($file in $functionFiles) {
    . $file.FullName
}
