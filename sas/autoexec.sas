%include "C:\Projekte\Scaproc/sas/init/cleanup.sas";
%include "C:\Projekte\Scaproc/sas/init/init.sas";

%macro reset;
  %include "C:\Projekte\Scaproc/sas/init/cleanup.sas";
  %include "C:\Projekte\Scaproc/sas/init/init.sas";  
  
  options noerrorabend;
%mend reset;

* nur zuweisen wenn Pfad vorhanden ist;
%macro assign_libname(libname, pfad, engine=, options=access=readonly);
  %if %sysfunc(fileexist(&pfad.)) %then %do;
    libname &libname &engine. "&pfad." &options.;
  %end;
%mend assign_libname;

%macro libnames;

  * Ordner ZLM;
  %assign_libname(dwh139,   &sas_data./zlm/zlm001);
  %assign_libname(anl139,   &sas_data./zlm/zlm002);
  %assign_libname(anl139m,  &sas_data./zlm/zlm002m);
%mend libnames;

%macro zlms;
  %global sas_data sas_input sas_program sas_output;
  %reset;

  %let sas_data=C:\Projekte\DZ HYP\ZLMS\daten;
  %let sas_input=C:\Projekte\DZ HYP\ZLMS\daten;
  %let sas_program=C:\Projekte\DZ HYP\ZLMS/programm;
  %let sas_output=C:\Projekte\DZ HYP\ZLMS\daten;

  %libnames;
%mend zlms;

options noerrorabend;

%put NOTE: Makro %nrstr(%reset;) für Cleanup und Init;
%put NOTE: Makro %nrstr(%zlms;) für lokalen ZLMS Test in h:/zlms;

