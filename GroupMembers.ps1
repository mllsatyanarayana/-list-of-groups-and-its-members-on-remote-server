# Define output CSV file path
$outputFile = "GroupMembers.csv"

# Define the name of the remote server
$remoteServer = "REMOTE_SERVER_NAME"

# Initialize an empty array to store group information
$groupData = @()

# Get the computer name of the remote server
$computerName = Invoke-Command -ComputerName $remoteServer -ScriptBlock { $env:COMPUTERNAME }

# Get all local groups on the remote server
$groups = Invoke-Command -ComputerName $remoteServer -ScriptBlock { Get-LocalGroup }

# Iterate through each local group
foreach ($group in $groups) {
    # Retrieve group members
    $members = Invoke-Command -ComputerName $remoteServer -ScriptBlock {
        param($groupName)
        Get-LocalGroupMember -Group $groupName
    } -ArgumentList $group.Name

    # Iterate through each member of the group
    foreach ($member in $members) {
        # Add group and member information to the array
        $groupData += [PSCustomObject]@{
            "Computer Name" = $computerName
            "Group Name" = $group.Name
            "Member Name" = $member.Name
            "Member Type" = $member.ObjectClass
        }
    }
}

# Export the group data to a CSV file
$groupData | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Group members exported to $outputFile"
