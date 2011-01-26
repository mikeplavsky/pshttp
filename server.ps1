$http = New-Object System.Net.HttpListener

$http.Prefixes.Add( "http://spb9503:81/" )
$http.Start()

while (1) {

    "Listening...."

    $ctx = $http.GetContext()
    
    $res = "Gimme Powershell Please!"  
    $ctx.Request.RawUrl
    
    $query = $ctx.Request.RawUrl -replace "%20", " " -replace "%22", "'"
    
    if ( $query -match "^/\?cmd=(.*)" ) {
        
        $error.clear()
        
        $matches[1]
        $res = iex $matches[1] | Out-String
        
        if($error) {            
            $res = $error | Out-String            
        }
    }

    $buffer = [System.Text.Encoding]::UTF8.GetBytes($res)
    
    $ctx.Response.OutputStream.Write( $buffer, 0, $buffer.Length )
    $ctx.Response.OutputStream.Close()
    
    "Done"
    
}


