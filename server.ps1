$location = gl

filter log () {
    Push-Location $location
    "$(Get-Date)`t$_" | Out-File log.txt -Append     
    Pop-Location
}

$http = New-Object System.Net.HttpListener
$http.Prefixes.Add( "http://$($env:computername):$($args[0])/" )

$error.clear()        
$http.Start()


if($error) {
    $error | log
    return 
}

while (1) {

    "Listening...." | log
    
    
    $ctx = $http.GetContext()
    
    
    $ctx.Request.RawUrl | log
    $ctx.Request.RemoteEndPoint.Address | log
    
    
    $res = "Gimme Powershell Please!"  
    $query = $ctx.Request.QueryString
    
    if ( $query[ "cmd" ] ) {
        
        $error.clear()        
        $query[ "cmd" ] | log
        
        $t = measure-command {$res = iex $query[ "cmd" ] | Out-String}
        "time to run: $t" | log
        
        if($error) {            
            $res = $error | Out-String            
        }
    }
    
    $func = $query['callback']   
    
    if ( !($args[1] -eq 'text' ) ) {
    
        $res = $res -replace "\\", "\\" -replace "\r\n", "\n" -replace "'", '"'   
        $res = "$func('" + $res + "');"    
        $ctx.Response.Headers[ "Content-Type" ] = "text/javascript";
        
    }
    
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($res)
    
    $ctx.Response.OutputStream.Write( $buffer, 0, $buffer.Length )
    $ctx.Response.OutputStream.Close()
    
    "Done" | log
  
}