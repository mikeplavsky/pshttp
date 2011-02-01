$http = New-Object System.Net.HttpListener

if ( !$args.Length ) {
    "Please, specify url the service will be listening to."
    return
}

$error.Clear()

$http.Prefixes.Add( $args[0] )
$http.Start()

if ($error) { return }

while (1) {

    "Listening...."

    $ctx = $http.GetContext()
    
    $res = "Gimme Powershell Please!"  
    $ctx.Request.RawUrl
    
    $query = $ctx.Request.RawUrl -replace "%20", " " -replace "%22", "'"
    
    if ( $query -match "^/\?cmd=(.*)" ) {
    
        $error.clear()
        
        $matches[1]        
        $job = Start-Job {iex "$args" | Out-String} -ArgumentList $matches[1]
        
        while ( $job.State -eq "Running" -or $job.State -eq "NotStarted") {
            Wait-Job $job -Timeout 1            
        }
        
        if ( $job.State -eq "Blocked" ) {
            $res = "Command requires additional parameters, please, check it out"
        }
        else {
            "Receiving Job"
            $res = Receive-Job $job
        }
        
        if($error) {            
            $res = $error | Out-String            
        }

        "Stopping Job"    
        
        $job.StopJob()
        Get-Job | Remove-Job -Force
        
        "Done"
        
    }

    $buffer = [System.Text.Encoding]::UTF8.GetBytes($res)
    
    $ctx.Response.OutputStream.Write( $buffer, 0, $buffer.Length )
    $ctx.Response.OutputStream.Close()
    
    "Done"
    
}


