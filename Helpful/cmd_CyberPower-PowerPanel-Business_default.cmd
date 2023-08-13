@echo off
rem You can write your own commands by any *.cmd
rem *.cmd file supports windows shell command

rem Available environment variable 
rem %EVENT_STAGE% when an event occurred, there are two stage for invoking commands. 
rem When an event occurred, it enters OCCUR stage and invoking related commands.
rem When an event finished, it enters FINISH stage and invoking related commands.
rem %EVENT% represents the event identification, %EVENT_CONDITION% represents the condition identification.
rem  To understand the value definition of both environment variable, please check online help or user's manual.
rem %MODULE_NO% represents a UPS module number to help identify which module the event occur on. (PPB Local Only)


if "%EVENT_STAGE%"=="OCCUR" goto doEventOccurCommand
if "%EVENT_STAGE%"=="FINISH" goto doEventFinishCommand
goto end

:doEventOccurCommand
rem Write commands here. 
rem The commands will be ran when an event occurred. 
goto end

:doEventFinishCommand
rem Write commands here.
rem The commands will be ran when the occurred event finished.
rem Note: not all occurred event has FINISH stage.
goto end

:end
exit
