function FindProxyForURL(url, host) {
    if (isPlainHostName(host) 
      || isInNet(host, "PAC_NETWORK", "PAC_NETMASK" ) 
      || dnsDomainIs(host, ".prodigygame.com")
      || dnsDomainIs(host, ".zoom.us")) {
      return "DIRECT";
    } else {
      return "PROXY PAC_FQDN:8080";
    }
}