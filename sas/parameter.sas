proc scaproc; 
   record "c:\temp\scaproc_5.log" ATTR OPENTIMES EXPANDMACROS; 
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
