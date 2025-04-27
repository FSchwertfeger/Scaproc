* GP Anzahl der Obs in Tabelle abfragen; 
%macro count_nobs(table);
    %local dsid nobs;
    %let dsid=%sysfunc(open(&table.));
    %if (&dsid.) %then %do;
        %let nobs=%sysfunc(attrn(&dsid., nlobs));
        %let dsid=%sysfunc(close(&dsid.));
    %end;
    %else %do;
        %let nobs=-1;
    %end;
    %put NOTE: nobs: &nobs.;

    &nobs.
%mend count_nobs;

%*put NOTE: S�tze in Tabelle sashelp.class: %count_nobs(sashelp.class);
%*put S�tze in Tabelle sashelp.shoes: %count_nobs(sashelp.shoes);

