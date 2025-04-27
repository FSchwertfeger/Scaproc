libname tmp "%sysfunc(pathname(work))";

data tmp.cars;
  set sashelp.cars;
run;