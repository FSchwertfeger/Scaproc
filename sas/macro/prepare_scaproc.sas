/* Beschreibung:  Aktiviert das Scaproc aus dem im -sysin übergebenen Namen           */

/* Testcode

1. Include
%include "h:/sas/init/cleanup.sas";
%include "h:/sas/init/init.sas";

2. Makro übersetzen

3. Makro ausführen
%prepare_proc;

*/

%macro prepare_scaproc(pfad);
  %let scriptname=%get_program;
  %put NOTE: scriptname: &scriptname.;

  proc scaproc;
    record "&pfad./&scriptname..scaproc.log" ATTR OPENTIMES EXPANDMACROS; 
  run;
%mend prepare_scaproc;
