**********************
* OVERVIEW
*   All raw data are stored in /data
*   All tables are outputted to /output/tables
*   All figures are outputted to /output/figures
* 
* SOFTWARE REQUIREMENTS
*   Analyses run on Windows using Stata version 15 and R-3.6.0
*
* TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
*   /processed
*   /output
**********************

* User must define two global macros in order to run the analysis:
* (1) "aprender" points to the project folder
* (2) "RSCRIPT_PATH" points to the folder containing the executables for R-3.6.0 (or newer)
* global aprender "C:/Users/jdoe/aprender"
* global RSCRIPT_PATH "C:/Program Files/R/R-3.6.0/bin/x64"

* To disable the R portion of the analysis, set the following flag to 1
global DisableR = 1

* Confirm that the globals for the project root directory and the R executable have been defined
assert !missing("$aprender")
if "$DisableR"!="1" assert !missing("$RSCRIPT_PATH")

* Initialize log and record system parameters
clear 
set more off
cap mkdir "$aprender/code/logs"
cap log close
local datetime : di %tcCCYY.NN.DD!_HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$aprender/code/logs/log_`datetime'.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"

* All required Stata packages are available in the /libraries/stata folder
adopath ++ "$aprender/code/libraries/stata"
mata: mata mlib index

* R packages can be installed manually (see README) or installed automatically by uncommenting the following line
* if "$DisableR"!="1" rscript using "$aprender/code/programs/_install_R_packages.R"

* Stata programs and R code are stored in /programs
adopath ++ "$aprender/code/programs"

* Stata and R version control
version 15
if "$DisableR"!="1" rscript using "$aprender/code/programs/_confirm_verison.R"

* Create directories for output files
cap mkdir "$aprender/data/analytical"
cap mkdir "$aprender/output"
cap mkdir "$aprender/output/figures"
cap mkdir "$aprender/output/intermediate"
cap mkdir "$aprender/output/tables"

* Run project analysis
do "$aprender/code/prepare.do"
do "$aprender/code/stats.do"
*do "$aprender/code/1_process_raw_data.do"
*do "$aprender/code/2_clean_data.do"
*do "$aprender/code/3_regressions.do"
*do "$aprender/code/4_make_tables_figures.do"

* End log
di "End date and time: $S_DATE $S_TIME"
log close

** EOF
