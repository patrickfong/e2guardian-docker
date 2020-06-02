function FindProxyForURL(url, host) {
    if (isPlainHostName(host) 
      || isInNet(host, "PAC_NETWORK", "PAC_NETMASK" ) 
      || isInNet(host, "74.125.250.0", "255.255.255.0") // Google Meet IP range
      || isInNet(host, "13.107.64.0", "255.255.192.0") // Skype and Teams IP range (next 3)
      || isInNet(host, "52.112.0.0", "255.252.0.0")  
      || isInNet(host, "52.120.0.0", "255.252.0.0") 
      || dnsDomainIs(host, ".prodigygame.com")
      || dnsDomainIs(host, ".zoom.us")) {
      return "DIRECT";
    } else {
      return "PROXY PAC_FQDN:8080";
    }
}