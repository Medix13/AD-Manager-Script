# Import Active Directory module
Import-Module ActiveDirectory

function Get-OUPath {
    param (
        [string]$OUName
    )
    return "OU=$OUName,DC=bbw,DC=lab"
}

function Create-OU {
    param(
        [Parameter(Mandatory=$true)][string]$OUName
    )
    try {
        New-ADOrganizationalUnit -Name $OUName -Path "DC=bbw,DC=lab"
        Write-Host "OU '$OUName' was successfully created."
    }
    catch {
        Write-Host "Error creating OU '$OUName'. Please check if it already exists." -ForegroundColor Red
    }
}

function Create-Group {
    param(
        [Parameter(Mandatory=$true)][string]$GroupName,
        [Parameter(Mandatory=$true)][string]$OUName
    )
    try {
        $ouPath = Get-OUPath -OUName $OUName
        New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope DomainLocal -Path $ouPath
        Write-Host "Group '$GroupName' was successfully created in OU '$OUName'."
    }
    catch {
        Write-Host "Error creating group '$GroupName'. Please check the OU and group name." -ForegroundColor Red
    }
}

function Create-User {
    param(
        [Parameter(Mandatory=$true)][string]$UserName,
        [Parameter(Mandatory=$true)][string]$OUName,
        [Parameter(Mandatory=$true)][securestring]$Password
    )
    try {
        $ouPath = Get-OUPath -OUName $OUName
        New-ADUser -Name $UserName -AccountPassword $Password -Path $ouPath -PassThru | Enable-ADAccount
        Write-Host "User '$UserName' was successfully created in OU '$OUName' and activated."
    }
    catch {
        Write-Host "Error creating user '$UserName'. Please check the inputs." -ForegroundColor Red
    }
}

function Delete-OU {
    param(
        [Parameter(Mandatory=$true)][string]$OUName
    )
    try {
        $ouPath = Get-OUPath -OUName $OUName
        Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false
        Write-Host "OU '$OUName' was successfully deleted."
    }
    catch {
        Write-Host "Error deleting OU '$OUName'. Please check if it exists." -ForegroundColor Red
    }
}

function Delete-Group {
    param(
        [Parameter(Mandatory=$true)][string]$GroupName
    )
    try {
        Remove-ADGroup -Identity $GroupName -Confirm:$false
        Write-Host "Group '$GroupName' was successfully deleted."
    }
    catch {
        Write-Host "Error deleting group '$GroupName'. Please check if the group exists." -ForegroundColor Red
    }
}

function Delete-User {
    param(
        [Parameter(Mandatory=$true)][string]$UserName
    )
    try {
        Remove-ADUser -Identity $UserName -Confirm:$false
        Write-Host "User '$UserName' was successfully deleted."
    }
    catch {
        Write-Host "Error deleting user '$UserName'. Please check if the user exists." -ForegroundColor Red
    }
}

# Main menu function
function Main-Menu {
    Write-Host "What would you like to do?"
    Write-Host "1. Create OU"
    Write-Host "2. Create Group"
    Write-Host "3. Create User"
    Write-Host "4. Delete OU"
    Write-Host "5. Delete Group"
    Write-Host "6. Delete User"
    
    $choice = Read-Host "Enter the number of your selection"
    
    switch ($choice) {
        1 {
            $OUName = Read-Host "Enter the name of the OU"
            Create-OU -OUName $OUName
        }
        2 {
            $GroupName = Read-Host "Enter the name of the group"
            $OUName = Read-Host "Enter the name of the OU where the group should be created"
            Create-Group -GroupName $GroupName -OUName $OUName
        }
        3 {
            $UserName = Read-Host "Enter the name of the user"
            $OUName = Read-Host "Enter the name of the OU where the user should be created"
            $Password = Read-Host -AsSecureString "Enter the password for the user"
            Create-User -UserName $UserName -OUName $OUName -Password $Password
        }
        4 {
            $OUName = Read-Host "Enter the name of the OU to delete"
            Delete-OU -OUName $OUName
        }
        5 {
            $GroupName = Read-Host "Enter the name of the group to delete"
            Delete-Group -GroupName $GroupName
        }
        6 {
            $UserName = Read-Host "Enter the name of the user to delete"
            Delete-User -UserName $UserName
        }
        default {
            Write-Host "Invalid selection!" -ForegroundColor Red
        }
    }
}

Main-Menu
