function FindProxyForURL(url, host) {
    if (isPlainHostName(host) || isInNet(host, "PAC_NETWORK", "PAC_NETMASK" ) || shExpMatch(url, "*multiplayer-?.prodigygame.com/*")) {
      return "DIRECT";
    } else {
      return "PROXY PAC_FQDN:8080";
    }
}