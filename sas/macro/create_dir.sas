%macro create_dir(base, dir);
  data _null_;
    rc = dcreate("&dir.", "&base.");
  run;
%mend create_dir;
%*create_dir(e:/temp, frank);
