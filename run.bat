rem Setzen der notwendigen Umgebungsvariablen

setlocal enabledelayedexpansion

set MYROOT=C:\Projekte\Scaproc
cd "%MYROOT%"

set SASSTART="C:\Program Files\SASHome\x86\SASFoundation\9.4\SAS.EXE"
set SASCONFIG=-config "C:\Program Files\SASHome\x86\SASFoundation\9.4\SASV9.CFG"
rem set initstmt=-initstmt "%%inc 'c:/projekte/scaproc/sas/macro/get_program.sas'; %%inc 'c:/projekte/scaproc/sas/macro/prepare_scaproc.sas'; %%prepare_scaproc(c:/projekte/scaproc/log); run;"
set initstmt=-initstmt "proc scaproc; record 'c:/projekte/scaproc/log/%SASPGM%.scaproc.log' ATTR OPENTIMES EXPANDMACROS; run;"





del log\pcrbatch_scaproc.log
set "opt_robocopy=/mir /r:2 /w:30 /tee /np /log+:log/pcrbatch_scaproc.log"

set log="C:\Projekte\scaproc\log"
set lst="C:\Projekte\scaproc\log"

set SASAUTO=-AUTOEXEC "sas\autoexec.sas"
set saslog=-log %log% -print %lst%
 
 

set SASPGM=program_1
set SASSYSIN=-sysin "example\%SASPGM%.sas"

%SASSTART%  -work C:\Temp %SASAUTO% %SASCONFIG% %SASSYSIN% %saslog% %initstmt%


pause