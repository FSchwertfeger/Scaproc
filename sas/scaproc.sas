/*

Reading and analyzing PROC SCAPROC

* Activate log in program;
proc scaproc;
   record 'e:\temp\scaproc.log' ATTR OPENTIMES EXPANDMACROS; 
run;

* Deactivate SCAPROC;
proc scaproc;
   write;
run;

*/

%include "C:\Projekte\Scaproc/sas/init/cleanup.sas";
%include "C:\Projekte\Scaproc/sas/init/init.sas";

options noerrorabend;

%include "&env_macro./count_nobs.sas";
%include "&env_macro./list_files.sas";

/*
The SCAN function of SAS cannot handle quoted strings. 
Here is an attempt to work around the problem.
*/
proc fcmp outlib=work.userfuncs.scanner;
   function scanner(string$, n, seperator$)$;
     length result $1024;
     result = "";
     instring = 0;
     counter = 1;
     von = 0;
     bis = 0;
     do i = 1 to length(string);
       tmp = substr(string, i, 1);
       if counter = n and tmp ^= separator and tmp ^= '"' and tmp ^= '"' then do;
         if von = 0 then von = i;
         bis = i;
         *result = cats(result, tmp);
       end;
       if tmp = seperator and instring = 0 then do;
         if counter = n and von > 0 and bis > 0 then do;
           result = substr(string, von, bis - von + 1);
         end;
         von = 0;
         bis = 0;
         counter = counter + 1;
       end;
       if tmp = '"' or tmp = "'" then do;
         if instring = 0 then instring = 1;
         else instring = 0;
       end;
     end;
     return(result);
   endfunc;
run;

options cmplib=work.userfuncs;

%macro import_scaproc(scaproc);
   * Import protocol;
   filename scafile "&scaproc";
   data scaproc_1;
     infile scafile lrecl=1000 length=linelength end=eof;
     input scaline $varying1000. linelength;
     length scaproc $255.;
     scaproc = "&scaproc.";
   run;

   data scaproc;
     length word1 word2 word3 word4 word5 word6 word7 $200. source $1000.;
     retain step 0;
     retain source '';
     set scaproc_1;
     line = _n_;
     word1 = scanner(scaline,1,' ');
     word2 = scanner(scaline,2,' ');
     word3 = scanner(scaline,3,' ');
     word4 = scanner(scaline,4,' ');
     word5 = scanner(scaline,5,' ');
     word6 = scanner(scaline,6,' ');
     word7 = scanner(scaline,7,' ');
     if word2='JOBSPLIT:' and word3='TASKSTARTTIME' then step+1;
     if word1^='/*' and word2^='JOBSPLIT:' then do;
       contain_source = 1;
       source = scaline;
     end;
   run;

   data step_1;
     length sources $1000;
     do until(last.step);
       set scaproc;
       where contain_source=1;
       by step;
       sources = catx(" ", sources, source);
     end;
   run;

   data taskstarttime;
     set scaproc;
     where word3='TASKSTARTTIME';
     taskstarttime = word4;
     keep step taskstarttime line;
   run;

   proc sort nodupkey;
     by step;
   run;

   proc sql;
     create table step as
       select step_1.step,
         taskstarttime.taskstarttime,
         taskstarttime.line,
         step_1.sources
       from step_1 left join taskstarttime on step_1.step = taskstarttime.step;
   quit;

   proc sql;
     create table libname_1 as
       select scaproc.*
       from scaproc
       where step in (select step from step)
         and word3='LIBNAME';
   quit;

   data libname_2;
     length libname engine $12. path $256.;
     set libname_1;
     libname = word4;
     if upcase(word5) = 'V9' or upcase(word5) = 'SPDE' then do;
       engine = upcase(word5);
       path = word6;
     end;
     else do;
       path = word5;
     end;
   run;

   proc sql;
     create table libname as
       select distinct step, libname, engine, path, line
       from libname_2
       where substr(libname, 1, 1) ^= '#';
   quit;

   data inout_1;
     set scaproc;
     where word3='DATASET';
     libname = scan(word6, 1, '.');
     inout = word4;
     table = substr(word6, length(libname) + 2);
     table = scan(word6, 2, '.');
   run;

   data inout;
     retain step libname table inout line;
     set inout_1;
     where substr(libname, 1, 1) ^= '#';
     keep step libname table inout line;
   run;

   data file_1;
     set scaproc;
     where word3='FILE';
     file = word5;
     inout = word4;
   run;

   data file;
     retain step file inout;
     set file_1;
     where substr(file, 1, 1) ^= '#';
     keep step file inout;
  run;

   data attr_1;
     set scaproc;
     length type libname $12 attr table $30;
     where word3='ATTR';
     libname = scan(word4, 1, '.');
     table = scan(word4, 2, '.');
     inout = word5;
     attr = scan(word6, 2, ':');
     type = scan(word7, 2, ':');
   run;

   data attr;
     retain step libname table attr inout type;
     set attr_1;
     where substr(libname, 1, 1) ^= '#';
     keep step libname table attr inout type;
   run;
%mend import_scaproc;


* Imports the Scaprocs of a folder, the programs come from scaproc.program.program;
%macro import_directory(path);
  %list_files(program1,&path.);

  data program;
    set program1;
    length program $255.;
    if prxmatch('/^.*\.scaproc\.log\s*$/i', file);
    program = substr(file,1,length(file)-12);
    position = findc(program, '\/', -LENGTH(program), 'b');
    program = substr(program,position+1);
    drop position;
  run;

   proc datasets lib=work nolist nowarn;
     delete pm_attr;
     delete pm_inout;
     delete pm_libname;
     delete pm_step;
     delete pm_file;
   quit;

   %let nobs = %count_nobs(program);
   %do i=1 %to &nobs.;
     data _null_;
       set program(firstobs=&i. obs=&i.);
       length logfile $255.;
       logfile = strip(program) || '.scaproc.log';
       call symputx('program', program);
       call symputx('logfile', logfile);
     run;
     %put NOTE: program: &program.;
     %put NOTE: logfile: &logfile.;

     %put NOTE: Importiere: &logfile.;

     %import_scaproc(&path.\&logfile.);

     data attr;
       set attr;
       length program $255;
       program = "&program.";
     run;
     proc append base=pm_attr data=attr force;
     run;

     data inout;
       set inout;
       length program $255;
       program = "&program.";
     run;
     proc append base=pm_inout data=inout force;
     run;

     data libname;
       set libname;
       length program $255;
       program = "&program.";
     run;
     proc append base=pm_libname data=libname force;
     run;

     data step;
       set step;
       length program $255;
       program = "&program.";
     run;
     proc append base=pm_step data=step force;
     run;

     data file;
       set file;
       length program $255;
       program = "&program.";
     run;
     proc append base=pm_file data=file force;
     run;
   %end;
%mend import_directory;
%import_directory(C:\Projekte\Scaproc\log);


* Code for an evaluation table;
proc sql;
   create table scaproc.pm_read_write_table as
     select distinct pm_inout.program, pm_inout.step, pm_inout.libname, pm_inout.table, pm_inout.inout
     from pm_inout left join program on pm_inout.program=program.program
     where pm_inout.libname not in ('WORK' 'WORKS' 'SCAPROC' 'LOGCHECK' 'LIBRARY' 'SASUSER')
     order by pm_inout.program, pm_inout.libname, pm_inout.table, pm_inout.inout; 
quit;

data scaproc.pm_file;
  set pm_file;
run;

proc datasets library=work nolist;
  copy out=scaproc;
  select pm_file pm_inout pm_libname pm_step;
run;