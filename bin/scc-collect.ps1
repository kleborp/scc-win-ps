# This script does the collection of data, it does not process anything
#
# Summary:
# - It logs when it started
# - It finds modules in the modules path
# - It runs each module and captures the output
# - It track how long each module takes to run
# - It logs when it finished
# 

$currentPath = $MyInvocation.MyCommand.Path | Split-Path
$sccModPath = $currentPath + "\modules"

# Import generic functions
Import-Module $sccModPath\include\sccFunctions.psm1

# Log start of collection run
Write-Output (sccTiming "scc-collect" "start of run")

# Loop over powershell scripts in modules folder and run them
foreach($module in Get-ChildItem -Path $sccmodPath -Filter "*.ps1") {

    # To do: The linux version splits out user and system modules
    # User modules are checksumed and get special lines added so scc can detect changes
    # See line 332 onwards in bin/scc-collect
    # Effectively this prevents updates to modules from appearing in the log book

    # Log that we are starting a module
    Write-Output (sccTiming $module "start module")

    # Measure how long it take to run the module, also capture output
    $moduleTiming = Measure-Command { $moduleOutput = Invoke-Expression $sccModPath\$module }
    # Write out the captured module output
    Write-Output $moduleOutput

    # Log that the module has finished running
    Write-Output (sccTiming $module "end module" $moduleTiming.TotalSeconds)
}

# Log end of collection run
Write-Output (sccTiming "scc-collect" "end of run")