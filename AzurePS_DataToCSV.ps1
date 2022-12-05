# Login with Azure account
Connect-AzAccount

# Get all resource groups
$rgs = Get-AzResourceGroup

# Get all VMs
$vms = Get-AzVM

foreach ($vm in $vms) {
   # Set separate variables for VM IP address
   $networkProfile = $vm.NetworkProfile.NetworkInterfaces.id.Split("/") | Select -Last 1 # Get output containing full network profile path, split and then obtain last part of output
   $IPAddr = (Get-AzNetworkInterface -Name $networkProfile).IpConfigurations.PrivateIpAddress # Get Private IP address from NIC stored in variable above

   # Set separate loop to get VM Power State
   foreach ($rg in $rgs) {
    $vmstatus = Get-AzVM -ResourceGroupName $rg.ResourceGroupName -status
    $vmpower = $vmstatus.PowerState
    
    # Get tags of VMs based off resource group
    $tags = Get-AzResource -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name
    $vmTags = $tags.Tags.Keys + $tags.Tags.Values
   }

   # Assign required outputs to values
   $output=[pscustomobject]@{
       'VM Id' = $vm.VmId
       'VM IP' = $IPAddr
       'VM Name' = $vm.Name
       'VM Size' = $vm.HardwareProfile.VmSize
       'VM OS' = $vm.StorageProfile.OsDisk.OsType
       'VM Power State' = $vmpower
       'VM Tags' = ($vmTags -join ';')
   }
   # Output info to console
   $output
   # Output info to csv
   $output | Export-Csv "C:\Users\Nate\Documents\PowerShell Projects\Azure PowerShell\ExportedData.csv" -Append
}
