*nur löschen wenn vorhanden, spart eine Warnung; 
%macro delete_libname(lib);
   %if %sysfunc(libref(&lib.)) eq 0 %then %do;
     libname &lib. clear;
   %end;
%mend delete_libname;

%macro cleanup;
   *Libnames entfernen;
   proc sql;
     create table libnames as
       select distinct libname from dictionary.libnames where libname not in ('WORK' 'WORKS' 'TASKWORK' 'TSKWORKS' 'SASUSER' 'MAPS' 'MAPSGFK' 'MAPSSAS' 'SASUSER' 'SASHELP');
   run;

   %let nobs=;
   proc sql noprint;
     select count(1) into: nobs
     from libnames;
   quit;

   %do i=1 %to &nobs.;
     data _null_;
       set libnames (firstobs=&i. obs=&i.);
       call symputx('libname', libname);
     run;

     libname &libname. clear;
   %end;

   *Cleanup: WORK und WORKS platt machen;
   proc datasets lib=work kill nolist;
   quit;

   %if %sysfunc(libref(works)) eq 0 %then %do;
     proc datasets lib=works kill nolist;
     quit;
   %end;

   %if %sysfunc(libref(compare)) eq 0 %then %do;
     proc datasets lib=compare kill nolist;
     quit;
   %end;

   *Globale Macrovariable platten;
   data _null_;
     length cmd $200;
     set sashelp.vmacro;
     where scope='GLOBAL' and offset=0 and (name not in ('SYSDB' '_SASPROGRAMFILE' 'SYSDBMSG' 'SYSDBRC' 'SYSSTREAMINGLOG')) and (name not contains 'SYS_SQL_');
     cmd='%nrstr(%symdel ' || trim(name) || ' / nowarn );';
     call execute(cmd);
   run;

   *Macros löschen, auskommentiert weil es gerne mal schief geht;
   /*proc catalog c=work.sasmacr kill force;
   run;*/

   %delete_libname(taskwork);
   %delete_libname(tskworks);
%mend cleanup;
%cleanup;


