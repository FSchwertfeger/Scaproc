proc scaproc; 
   record "C:\Projekte\Scaproc\log\parameter_standard.scaproc.log" /* ATTR OPENTIMES */ EXPANDMACROS; 
run;

data class;
  set sashelp.class;
run;

%macro my_macro;
  data cars;
    set sashelp.cars;
  run;
%mend my_macro;
%my_macro;

proc scaproc; 
   write; 
run;
