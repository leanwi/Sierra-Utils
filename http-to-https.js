// Best to do this at webservice engine level (eg in .htaccess) 
// but if that's not an option, this should work.

if (window.location.protocol != 'https:') {
  const stagingHTTP  = ':2082';   // Default http port for staging 
  const stagingHTTPS = ':444';    // Default https port for staging

  var newLocation;                

  newLocation = location.href.replace('http://', 'https://');   // Update location with "https" and load our var
  newLocation = sslUrl.replace(stagingHTTP, stagingHTTPS);      // If in staging we'll need to expressly swap out ports
  window.location = newLocation;                                // 
}
