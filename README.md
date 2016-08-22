# Project Summary
scc-win-ps is a System Configuration Collector implementation written in PowerShell. For more information on System Configuration Collector project, please see: http://sysconfcollect.sourceforge.net/

The current scc-win collector that is part of the or original project was written in Perl and requires a Perl interpreter to be installed on the Windows system. The aim of this project is to write a set of scripts in PowerShell that will be compatible with scc-srv and provide the same, if not more details than the original scc-win implementation without any external dependencies.

Currently the project is in a phase where it's being ported without too many changes straight from the Perl scripts and it currently incomplete.

# Project Structure
Project Structure:
- bin\ - Folder that will hold all scripts and dependencies
- bin\scc-log.ps1 - Incomplete port of scc-log.pl, invokes the collector and tries to validate the output
- bin\scc-collector.ps1 - Nearly complete port of scc-collector.pl, invokes all modules and keeps track of module timings and statistics
- bin\modules\*.ps1 - Port of the scc_modules\*.pl, not all modules ported yet but the ones that have been should be complete and nearly identical in output to the original scripts
- data\ - Folder where output will be saved
- tmp\ - Folder where temporary data may be written during collection
