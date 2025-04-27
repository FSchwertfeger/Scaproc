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

%let program=DT_ERL_BCA_BCASTAT_10;
%*let program=Finanzprojekt_gemeinsam_bCA_CML_V1;
%*let program=Master_Tab_V17_4;

proc sql;
  create table pm_read_write_table as  
    select strip(program) !! '.sas' as program, 
      libname, 
      table,
      max(case when inout='INPUT' then 1 else 0 end) as inout_input,
      max(case when inout='OUTPUT' then 1 else 0 end) as inout_output,
      max(case when inout='UPDATE' then 1 else 0 end) as inout_update
    from scaproc.pm_read_write_table
    where program = "&program."
    group by program, libname, table;
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

/* Header schreiben */
data _null_;
    file dotfile;
    put 'digraph dataflow {';
    put '    rankdir=LR;';
    put '    node [shape=box];';
run;

/* === Tabelle: Duplikate entfernen === */
proc sql;
    create table rw_edges as
    select distinct
        upcase(strip(program)) as program,
        upcase(strip(libname)) as libname,
        upcase(strip(table)) as table,
        inout_input,
        inout_output,
        inout_update
    from &table_input;
quit;

/* === Datei: Duplikate entfernen === */
proc sql;
    create table file_edges as
    select distinct
        upcase(strip(program)) as program,
        tranwrd(strip(file), '\', '/') as file,
        upcase(strip(inout)) as inout
    from &file_input;
quit;

/* === Kanten aus Tabellen schreiben === */
data _null_;
    set rw_edges;
    file dotfile mod;

    program = strip(program);
    lib = strip(libname);
    table = strip(table);

    if inout_input = 1 and inout_output = 0 and inout_update = 0 then
        put '    "' lib +(-1) '.' table +(-1) '" -> "' program +(-1) '";';
    else if inout_input = 0 and inout_output = 1 and inout_update = 0 then
        put '    "' program +(-1) '" -> "' lib +(-1) '.' table +(-1) '";';
    else do;
        /* put '    "' lib +(-1) '.' table +(-1) '" <-> "' program +(-1) '" [style=dashed, label="UPDATE"];'; */
        put '    "' program +(-1) '" -> "' lib +(-1) '.' table +(-1) '" [style=dashed, label="UPDATE"];'; 
    end;
run;

/* === Kanten aus Dateien schreiben === */
data _null_;
    set file_edges;
    file dotfile mod;

    select (inout);
        when ('INPUT')
            put '    "' file +(-1) '" -> "' program +(-1) '";';
        when ('OUTPUT')
            put '    "' program +(-1) '" -> "' file +(-1) '";';
        otherwise;
    end;
run;

/* === Tabellen als Ellipsen darstellen === */
proc sql noprint;
    create table distinct_tables as
    select distinct cats(libname, '.', table) as tablename
    from rw_edges;
quit;

data _null_;
    set distinct_tables;
    file dotfile mod;
    put '    "' tablename +(-1) '" [shape=ellipse];';
run;

/* === Dateien als Notizsymbole darstellen === */
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

/* Footer */
data _null_;
    file dotfile mod;
    put '}';
run;

* Only for display manager; 
%finish;
