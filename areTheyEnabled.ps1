# TRCCB 09/06/23
Import-Module -Name ImportExcel

# Prompt for user SAM names separated by semicolons
$samNames = Read-Host -Prompt "Enter user SAM names separated by semicolons"

# Remove whitespace from the user input
$userList = ($samNames -split ';' | ForEach-Object { $_.Trim() }) -ne ''

# Initialize an empty array to store the results
$results = @()

# Loop through each SAM name
foreach ($samName in $userList) {
    # Check if the user exists
    $user = Get-ADUser -Filter "SamAccountName -eq '$samName'" -Properties DisplayName -ErrorAction SilentlyContinue
    
    if ($user) {
        # User found, check if disabled
        $isDisabled = $user.Enabled -eq $false
        $results += [PSCustomObject]@{
            'SAMname'     = $samName
            'DisplayName' = $user.DisplayName
            'Found'       = 'Yes'
            'Disabled'    = if ($isDisabled) { 'Yes' } else { 'No' }
        }
    } else {
        # User not found
        $results += [PSCustomObject]@{
            'SAMname'     = $samName
            'DisplayName' = 'N/A'
            'Found'       = 'No'
            'Disabled'    = 'N/A'
        }
    }
}

# Generate a unique filename based on the current timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$filename = "$PSScriptRoot\UserResults_$timestamp.xlsx"

# Export the results to a new Excel file
$results | Export-Excel -Path $filename -AutoSize

# Output the filename
Write-Host "Results exported to: $filename"

# Pause to wait for user acknowledgement
Write-Host "Press Enter to exit..."
$null = Read-Host
