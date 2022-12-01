# Login with Azure account
Connect-AzAccount

# Get all subscriptions in tenant
$azSubs = Get-AzSubscription

# Create loop for each subscription in tenant
foreach ($azsub in $azSubs) {
    Select-AzSubscription -SubscriptionId $azsub.Id
    $vms = Get-AzVM
    # Separate variable for VM power status
    $vmPower = Get-AzVM -Status
    # Separate variables for retrieving VM network adapter and IP address
    $vmNIC = $vms.NetworkProfile.NetworkInterfaces.id
    $vmIP = (Get-AzNetworkInterface -Name $vmNIC).IpConfigurations.PrivateIpAddress
    # Create loop for each vm and write out each required detail
    foreach ($vm in $vms) {
     $output=[pscustomobject]@{
        'VMId' = $vm.VmId
        'VMName' = $vm.Name
        'VMSize' = $vm.HardwareProfile.VmSize
        'VMOSType' = $vm.StorageProfile.OsDisk.OsType
        'VMPowerState' = $vmPower.PowerState
        'VMIPAddress' = $vmIP }
    }
    # Output info to csv
    $output | Export-Csv "c:\coding\Task 2\ExportedData.csv" -Append -Force
}