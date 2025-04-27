/* Beschreibung:  Ermittelt die Dateien eines Verzeichnisses, das Ergebnis wird in eine        */
/*                Tabelle geschrieben. */

%macro list_files(ausgabetabelle,dir);
    %local filrf rc did memcnt name i;

    data &ausgabetabelle.;
        length file $300.;
        stop;
    run;

    %let rc=%sysfunc(filename(filrf,&dir.));
    %let did=%sysfunc(dopen(&filrf.));

    %if &did. eq 0 %then %do;
        %put Directory &dir. cannot be open or does not exist;
        %return;
    %end;

    %do i=1 %to %sysfunc(dnum(&did.));
        %let name=%qsysfunc(dread(&did.,&i.));
        %if &name. ne %then %do;
            %put NOTE: Datei: &dir.\&name.;
            data &ausgabetabelle._append;
                length file $300.;
                file="&dir./&name.";
            run;

            %if %sysfunc(exist(&ausgabetabelle.)) %then %do;
                data &ausgabetabelle.;
                    set &ausgabetabelle. &ausgabetabelle._append;
                run;
            %end;
            %else %do;
                data &ausgabetabelle.;
                    set &ausgabetabelle._append;
                run;
            %end;
        %end;
    %end;
    %let rc=%sysfunc(dclose(&did.));
    %let rc=%sysfunc(filename(filrf));
%mend list_files;
%*list_files(files,e:\frank\log);
