%include "&env_macro./count_nobs.sas";
%include "&env_macro./create_dir.sas";
%include "&env_macro./finish.sas";
%include "&env_macro./check_libname.sas";

%macro compare_table_init;
    %if not %check_libname(compare) %then %do;
        %create_dir(%sysfunc(pathname(work)), compare);
        libname compare spde "%sysfunc(pathname(work))/compare";* temp=yes;
    %end;
%mend compare_table_init;
%compare_table_init;

*libname pcr465 "E:\TS\Parallel_Prod_MGH\PCR465";
*libname prod465 "E:\TS\Parallel_Prod_MGH\PRod465";

*libname pcr390     "E:\TS\Parallel_Prod_MGH\pcr390" access = readonly;
*libname prod390    "E:\TS\Parallel_Prod_MGH\prod390"  access = readonly;

%*let w= where= (dt_ab=20240724  ) ;

%macro compare_tables(base=,
                      compare=,
                      drop=,
                      outname=,
                      id=);
    %let count = %sysfunc(countw(&id.));  /* Anzahl der Werte in der Liste */
    %let sql_condition =;
    %let id1 =;
   
    /* Schleife über alle Werte und Baue die SQL-Bedingungen */
    %do i = 1 %to &count.;
        %let current_id = %scan(&id., &i.);  /* Aktuellen Wert extrahieren */
        %if &i. eq 1 %then %do;
            %let id1 = &current_id.;
        %end;
        %else %do;
            %let sql_condition = &sql_condition. and;  
        %end;
        %let sql_condition = &sql_condition. t1.&current_id. = t2.&current_id.;  /* Bedingung für die aktuelle ID hinzufügen */
    %end;

    /* Ausgabe der finalen SQL-Bedingung */
    %put NOTE: sql_condition: &sql_condition.;                            
                      
    /* Gemeinsame Datensätze aus beiden Tabellen auswählen */
    proc sql;
        create table compare.&outname._common1 as
            select t1.*
            from &base. t1 inner join &compare t2 on &sql_condition.;
    quit;

    proc sql;
        create table compare.&outname._common2 as
            select t2.*
            from &compare. t2 inner join &base. t1 on &sql_condition.;
    quit;
                               
    proc compare base=compare.&outname._common1(drop=&drop.) 
              compare=compare.&outname._common2(drop=&drop.) 
                  out=compare.&outname. 
      noprint criterion=0.00001 method=absolute outbase outcompare outdiff outnoequal;
      id &id.;
    run;
    
    /* IDs, die in table1 existieren, aber in table2 fehlen */
    proc sql;
        create table compare.&outname._missing1 as
          select t1.*
          from &base. t1 left join &compare. t2 on &sql_condition.
          where t2.&id1. is null;
    quit;

    /* IDs, die in table1 existieren, aber in table2 fehlen */
    proc sql;
        create table compare.&outname._missing2 as
          select t2.*
          from &compare. t1 left join &base. t2 on &sql_condition.
          where t2.&id1. is null;
    quit;
%mend compare_tables;





