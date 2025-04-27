%include "E:/TS/Parallel_prod_Frank/sas/init/cleanup.sas";
%include "E:/TS/Parallel_prod_Frank/sas/init/init.sas";

options noerrorabend;

%include "&env_macro./prepare_log.sas";
%prepare_log;

%include "&env_macro./finish.sas";

*libname scaproc "/apps/daten/scaproc";

/* === Konfiguration: Hier kannst du die Eingabetabelle ändern === */
%let table_input = work.pm_read_write_table;
%let file_input  = work.pm_file;

%let program=Master_Tab_V9_Frank;

proc sql;
  create table pm_read_write_table as  
    select strip(program) !! '.sas' as program, 
      libname, 
      max(case when inout='INPUT' then 1 else 0 end) as inout_input,
      max(case when inout='OUTPUT' then 1 else 0 end) as inout_output,
      max(case when inout='UPDATE' then 1 else 0 end) as inout_update
    from scaproc.pm_read_write_table
    where program = "&program."
    group by program, libname;
quit;

data pm_file;
  set scaproc.pm_file;
  where program = "&program."
    and lowcase(file) not like '%.sas'
    and lowcase(file) not like lowcase("%.scaproc.log");
  ends = substr(lowcase(file), length(file) - length("&program.") - 3);
  if ends ^= lowcase("&program..log") and ends ^= lowcase("&program..lst");
  program = strip(program) !! '.sas';
run;

/* === Konfiguration === */
%*let table_input = scaproc.pm_read_write_table;
%*let file_input  = scaproc.pm_file;

*filename dotfile "/apps/daten/dataflow.dot";
filename dotfile "c:/temp/dataflow.dot";

/* === DOT-Header === */
data _null_;
    file dotfile;
    put 'digraph dataflow {';
    put '    rankdir=LR;';
    put '    node [shape=box];';
run;

/* === Duplikate entfernen aus pm_read_write_table === */
/* Nur Libname-Ebene, keine einzelnen Tabellen */
proc sql;
    create table rw_edges as
    select distinct
        upcase(strip(program))       as program,
        upcase(strip(libname))       as libname,
        inout_input,
        inout_output,
        inout_update
    from &table_input;
quit;

/* === Duplikate entfernen aus pm_file (ohne .sas-Dateien) === */
proc sql;
    create table file_edges as
    select distinct
        upcase(strip(program))       as program,
        tranwrd(strip(file), '\', '/') as file,
        upcase(strip(inout))         as inout
    from &file_input
    where lowcase(file) not like '%.sas';
quit;

/* === Kanten aus Libnames erzeugen === */
data _null_;
    set rw_edges;
    file dotfile mod;

    program = strip(program);
    lib     = strip(libname);

    if inout_input = 1 then
        put '    "' lib +(-1) '" -> "' program +(-1) '";';

    if inout_output = 1 then
        put '    "' program +(-1) '" -> "' lib +(-1) '";';

    if inout_update = 1 then do;
        put '    "' lib +(-1) '" -> "' program +(-1) '" [style=dashed, label="UPDATE"];';
        put '    "' program +(-1) '" -> "' lib +(-1) '" [style=dashed, label="UPDATE"];';
    end;
run;

/* === Kanten aus externen Dateien === */
data _null_;
    set file_edges;
    file dotfile mod;

    program = strip(program);
    file    = strip(file);

    select (inout);
        when ('INPUT')
            put '    "' file +(-1) '" -> "' program +(-1) '";';
        when ('OUTPUT')
            put '    "' program +(-1) '" -> "' file +(-1) '";';
        otherwise;
    end;
run;

/* === Libnames als Ellipsen darstellen === */
proc sql noprint;
    create table distinct_libnames as
    select distinct libname
    from rw_edges;
quit;

data _null_;
    set distinct_libnames;
    file dotfile mod;
    put '    "' libname +(-1) '" [shape=ellipse];';
run;

/* === Dateien als Notizsymbol darstellen === */
proc sql noprint;
    create table distinct_files as
    select distinct file
    from file_edges;
quit;

data _null_;
    set distinct_files;
    file dotfile mod;
    put '    "' file +(-1) '" [shape=note];';
run;

/* === DOT-Footer === */
data _null_;
    file dotfile mod;
    put '}';
run;

* Only for display manager; 
%finish;
