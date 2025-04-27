OPTIONS ERRORS=1 LINESIZE=132 PAGESIZE=60 COMPRESS=YES REUSE=YES;        
OPTIONS FMTSEARCH=(KON001 KON002 KON003 KON005 KON006 KON802 CISLIB IDVLIB CLIENT);  
OPTIONS FULLSTIMER;                                                                  

options msglevel=i source source2 mlogic mprint symbolgen errorabend noxwait; 

%global env_program env_macro env_log env_logarchiv;

%let env_program=C:\Projekte\Scaproc\sas;
%let env_macro=C:\Projekte\Scaproc\sas\macro;
%let env_log=C:\Projekte\Scaproc\log;
%let env_logarchiv=C:\Projekte\Scaproc\log\archiv;

%include "&env_macro./create_dir.sas";

%create_dir(%sysfunc(pathname(work)), works);
libname works spde "%sysfunc(pathname(work))/works";* temp=yes;

libname scaproc "C:\Projekte\Scaproc\libname_scaproc";
