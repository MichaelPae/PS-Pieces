# Send-WakeOnLanToMacAddress.ps1
param( $Mac ) 


function Send-WakeOnLAN {
<#
.SYNOPSIS
	Sendet ein Wake-On-LAN-Paket per Broadcast
.DESCRIPTION
	Mit dem Cmdlet Send-WakeOnLAN wird ein Wake-On-LAN-Paket ein Wake-On-LAN-Paket
        fuer einen Rechner per Broadcast gesendet.
.PARAMETER Mac
	Mac-Adresse des Ziel-Rechners 
.EXAMPLE
	Send-WakeOnLAN -Mac 74:D4:35:B2:D3:5F
.NOTES
    
.LINK
#>
    param(
    [String]$Mac='74:D4:35:B2:D3:5F' # Mac-Adresse der Netzwerk-Karte, Default: meine Karte
    )

    # Syntax der MAC-Adresse pruefen 
    if (!($Mac -like "*:*:*:*:*:*") -or ($Mac -like "*-*-*-*-*-*")){ 
        write-error "Falsches Format der Mac-Adresse" 
        break 
    } 

    $packet = ConvertTo-MagicPacket -Mac $Mac
    #write-output $packet
     
    # .NET Framework User Datagram Protocol
    $UDPclient = new-Object System.Net.Sockets.UdpClient 
    $UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000) 
    $UDPclient.Send($packet, $packet.Length) | out-null

    Write-Output ("Magic-Packet an Mac-Adresse versandt: " + $Mac)
    Start-Sleep -s 2
}


function ConvertTo-MagicPacket {
<#
.SYNOPSIS
	Konvertiert einen String in ein Wake-On-Lan Magic-Packet.
.DESCRIPTION
	Mit dem Cmdlet wird ein String in ein Wake-On-Lan Magic-Packet konvertiert.
.PARAMETER Mac
	Mac-Adresse des Ziel-Rechners 
.EXAMPLE
	ConvertTo-MagicPacket -Mac 00:22:19:0F:E0:82
.NOTES
    Idee: Pedro Castro, 2012-07-30; https://gallery.technet.microsoft.com/scriptcenter/Wake-On-Lan-815424c4
.LINK 
#>
    param([String]$Mac) # Mac-Adresse einer Netzwerk-Karte
 
    # Magic-Packet zusammenstellen (s. http://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet )
    $string=@($Mac.split(":""-") | foreach {$_.insert(0,"0x")}) 
    $target = [byte[]]($string[0], $string[1], $string[2], $string[3], $string[4], $string[5]) 
    # The magic packet is a broadcast frame containing anywhere within its payload 6 bytes of all 255 (FF FF FF FF FF FF in hexadecimal) 
    $packet = [byte[]](,0xFF * 102) 
    # followed by sixteen repetitions of the target computer's 48-bit MAC address, for a total of 102 bytes. 
    6..101 |% { $packet[$_] = $target[($_%6)]} 

    return $packet
}


# Startpunkt
if (-not$Mac) {
    Send-WakeOnLAN
    }
else {
    Send-WakeOnLAN -Mac $Mac
}