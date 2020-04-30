******************************
* Estimation of peer effects *
******************************

set more off
clear all

cd "C:\Users\juanc\Google Drive\research\aprender"

local data = "C:\research\aprender\data\"


local base_list = "6grado 56anio"


foreach eachbase of local base_list {


	use "`data'/raw/base_`eachbase'_alum_dir_2016", clear

	if "`eachbase'" != "6grado" {

		gen repitio = .
		replace repitio = 0 if repitio_prim == 0 & repitio_sec == 0
		replace repitio = 1 if repitio_prim == 1 | repitio_sec == 1

		drop repitio_prim repitio_sec

	}


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


	*IDs
	encode CUEANEXO, gen(idschool)
	encode seccion, gen(idclass)

	bysort idclass: gen idstudent = _n

	rename region region2
	encode cod_provincia, gen(region)

	order idschool idclass idstudent region
	sort  idschool idclass idstudent


	*Keep schools with more than one class
	gen aux_classes = 1 if idstudent == 1
	bysort idschool: egen totclasses = sum(aux_classes)
	keep if totclasses > 1 & totclasses != .


	*Ordered class per school
	bysort idschool: gen idclass2 = sum(aux_classes)

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
	local varlist = "women edu_madre edu_padre trabaja anios_jardin repitio apoyo"
	local varlist = "`varlist' buena_relacion auh"

	foreach var of local varlist {
		bysort idclass: egen peer_`var' = sum(`var')
		replace peer_`var' = (peer_`var' - `var') / (class_size-1)
	}



	*Keep varlist of interest
	keep idschool idclass idclass2 idstudent region privado urbano nbi  ///
		 mpuntaje_std log_mpuntaje lpuntaje_std log_lpuntaje   			///	
	 	 class_size women edu_madre edu_padre trabaja anios_jardin  	///
	 	 repitio apoyo buena_relacion auh            					///
	 	 peers_score_l lpeers_score_l peers_score_m lpeers_score_m peer_*

	order idschool idclass idclass2 idstudent region privado urbano nbi  ///
		  mpuntaje_std log_mpuntaje lpuntaje_std log_lpuntaje   		 ///	
	 	  class_size women edu_madre edu_padre trabaja anios_jardin  	 ///
	 	  repitio apoyo buena_relacion auh            					 ///
	 	  peers_score_l lpeers_score_l peers_score_m lpeers_score_m peer_*



	save "`data'/analytical/base_`eachbase'_2016.dta", replace


}

