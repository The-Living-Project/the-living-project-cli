[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PassthroughArgs
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$cliPath = Join-Path $scriptRoot "bin\living-project.js"

node $cliPath init @PassthroughArgs
exit $LASTEXITCODE
