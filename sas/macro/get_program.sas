/*
Ermittelt das ausgeführte Programm (ohne Extension)

Testcode:
1. Makro übersetzen

2. Ausf hren
%put %get_program;

*/

%macro get_program;
   %local programm programm_gross index result;

   %let programm = %sysfunc(getoption(sysin));
   %let programm = %scan(&programm., -1, "\");
   %if "&programm." eq "" %then %do;
     %let programm = %scan(&programm., -1, "/");
   %end;

   %if %SYMEXIST(_SASPROGRAMFILE) and "&programm." eq "" %then %do;
     %let programm = %sysfunc(compress(&_SASPROGRAMFILE, "'"));
     %let programm = %quote(%scan(&programm., -1, "\"));
     %if "&programm." eq "" %then %do;
       %let programm = %quote(%scan(&programm., -1, "/"));
     %end;
   %end;

   %if "&programm." eq "" %then %do;
     %let programm = %sysget(SAS_EXECFILENAME);
   %end;

   %let result = &programm.;
   %let programm_gross = %upcase(&programm.);
   %let index = %index(&programm_gross., .SAS);
   %if &index. gt 0 %then %do;
     %let result = %substr(&programm., 1, &index. - 1);
   %end;
   &result.
%mend get_program;
