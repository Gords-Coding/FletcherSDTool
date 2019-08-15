#########################################################################
#                        Load Main Panel                                #
#########################################################################
 
# return the directory of source files
$Script:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
 
# function to load the xaml
function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
 
 
$XamlMainWindow = LoadXaml($pathPanel+"\MainWindow.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)
 
#########################################################################
#                        Show Dialog                                    #
#########################################################################

#$reader=(New-Object System.Xml.XmlNodeReader $xaml)
#try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
#catch{Write-Host "Unable to load Windows.Markup.XamlReader."; exit}

$XamlMainWindow.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
$fdate=Get-Date -Format o | foreach {$_ -replace ":", "."}

$fpath = "c:\Windows\Temp\Failed"+ $fdate +".txt"
$spath = "c:\Windows\Temp\Sucess"+ $fdate +".txt"
$ServerNamePath= "c:\Windows\Temp\ServerName"+$fdate +".txt"
$BiosPath= "c:\Windows\Temp\Bios"+$fdate +".txt"

$button.add_Click({

$strname=$txtserver.Text 
$strname| Out-File $ServerNamePath

$sname = get-content $ServerNamePath

$sname = get-content $ServerNamePath | foreach {
    Write-Verbose "Testing $_"
    $test = Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue
    if($test) { 
        $status = 'OK'
        $address = $test.IPV4Address
        $getUsername = Get-CimInstance –ComputerName $_ –ClassName Win32_ComputerSystem
        $Username = $getUsername.Username

    } else { 
        $status = 'Failed'
        $address = ""
    }
    [PSCustomObject]@{
        ServerName = $_
        IPAddress = $address
        ‘Ping Status’ = $status
        'Username' = $username
    }
}

$sname | Out-GridView -Title "Ping Status"

})

$softwarebutton.add_Click({

$strname=$assetno.Text 

$test = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
if($test) { 
        $software.Text = $test.DisplayName
        $software.Text = $software.Text -replace "  ", "`r`n"
    } else { 
        $software.Text = "Failed"
    }

})


$Form.ShowDialog() | Out-Null