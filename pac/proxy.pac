function FindProxyForURL(url, host) {
    if (isPlainHostName(host) 
      || isInNet(host, "PAC_NETWORK", "PAC_NETMASK")
      || dnsDomainIs(host, "desktopapp.smilebox.com")
      || dnsDomainIs(host, "waze.com")
      || dnsDomainIs(host, ".life360.com")
      || dnsDomainIs(host, ".zello.com")
      || dnsDomainIs(host, ".clients.google.com")
      || dnsDomainIs(host, "android-safebrowsing.google.com")
      || dnsDomainIs(host, ".audible.ca")
      || dnsDomainIs(host, ".line-apps.com")
      || dnsDomainIs(host, ".wikipedia.org")
      || dnsDomainIs(host, "inbox.google.com")
      || dnsDomainIs(host, ".googleusercontent.com")
      || dnsDomainIs(host, ".manageengine.com")
      || dnsDomainIs(host, ".whatsapp.net")
      || dnsDomainIs(host, "play.google.com")
      || dnsDomainIs(host, "sites.google.com")
      || dnsDomainIs(host, "yimg.com")
    ) {
      return "DIRECT";
    } else if (url.startsWith("wss:")
      || isInNet(host, "74.125.250.0", "255.255.255.0") // Google Meet IP range
      || isInNet(host, "13.107.64.0", "255.255.192.0")  // Skype and Teams IP range (next 3)
      || isInNet(host, "52.112.0.0", "255.252.0.0")     // teams
      || isInNet(host, "13.107.64.0", "255.255.192.0")  // teams
      || dnsDomainIs(host, ".zoom.us")			  // zoom
      || dnsDomainIs(host, ".cloudfront.net")	// zoom web site
      || dnsDomainIs(host, ".rapid7.com")
      || dnsDomainIs(host, ".dropbox.com")
      || dnsDomainIs(host, ".dropboxapi.com")
      || dnsDomainIs(host, ".perfectmemorials.com")
      || dnsDomainIs(host, ".googleusercontent.com")
      || dnsDomainIs(host, ".manageengine.com")
      || dnsDomainIs(host, ".smilebox.com")) {
      return "PROXY PAC_FQDN:3128"
    } else {
      return "PROXY PAC_FQDN:8080";
    }
}