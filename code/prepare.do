******************************
* Estimation of peer effects *
******************************

set more off
clear all

cd "C:\Users\juanc\Google Drive\research\aprender"

local data = "C:\research\aprender\data\"


use "`data'/raw/base_6grado_alum_dir_2016", clear

*dummy women
gen 	women = 0 if Ap2 == 1
replace women = 1 if Ap2 == 2

**Women per class
*Reference variables
*CUEANEXO: school id
*seccion: class id
bysort CUEANEXO seccion: egen totwomen = sum(women)
gen ltotwomen = log(totwomen)
keep if women != .


encode CUEANEXO, gen(idschool)
encode seccion, gen(idclass)

bysort idclass: gen idstudent = _n

order idschool idclass idstudent
sort  idschool idclass idstudent


*Keep schools with more than one class
gen aux_classes = 1 if idstudent == 1
bysort idschool: egen totclasses = sum(aux_classes)

keep if totclasses > 1 & totclasses != .

*Class size
bysort idclass: egen class_size = max(idstudent)

*Average score of peers
bysort idclass: egen peers_score_m = sum(mpuntaje_std)
replace peers_score_m = (peers_score_m - mpuntaje_std) / (class_size-1)
gen lpeers_score_m = log(peers_score_m)

bysort idclass: egen peers_score_l = sum(lpuntaje_std)
replace peers_score_l = (peers_score_l - lpuntaje_std) / (class_size-1)
gen lpeers_score_l = log(peers_score_l)

*Average characteristics of peers
local varlist = "edu_madre edu_padre trabaja anios_jardin repitio apoyo buena_relacion"

foreach var of local varlist {
	bysort idclass: egen peer_`var' = sum(`var')
	replace peer_`var' = (peer_`var' - `var') / (class_size-1)
}

keep idschool idclass idstudent mpuntaje_std log_mpuntaje lpuntaje_std log_lpuntaje ///
 	 ltotwomen sexo class_size auh edu_madre edu_padre trabaja anios_jardin repitio ///
 	 apoyo buena_relacion privado urbano nbi peers_score_l lpeers_score_l           ///
 	 peers_score_m lpeers_score_m peer_*

order idschool idclass idstudent mpuntaje_std log_mpuntaje lpuntaje_std log_lpuntaje ///
	  ltotwomen sexo class_size auh edu_madre edu_padre trabaja anios_jardin repitio ///
	  apoyo buena_relacion privado urbano nbi peers_score_l lpeers_score_l           ///
	  peers_score_m lpeers_score_m peer_*


save "`data'/analytical/base_6grado_2016.dta", replace
