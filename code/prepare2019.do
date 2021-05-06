set more off
clear all

/*=================
 	Prepare 2019
===================

*This do file

1- Merges student with director base
2- Generates variables of interest

====================================*/

*Directory structure

cd "C:\Users\juanc\Google Drive\research\aprender"

loc data = "C:\research\aprender\data\"
loc base_dir = "`data'/raw/base_56anio_dir_2019.dta"
loc base_stu = "`data'/raw/base_56anio_alum_2019.dta"







/*=======================================
	1) Merge Student with Director Base
========================================*/





*Prepare director base

use `base_dir', clear

sort ID1

tempfile dir_temp

save `dir_temp', replace


*Merge it with student base

use `base_stu'

sort ID1

merge ID1 using `dir_temp'

drop if _merge == 2

drop _merge



destring ap* ldesemp mdesemp, replace
destring TEM TEL, replace dpcomma



/*=======================================
		2) Variable Creation
========================================*/
/*

2.1) Test Scores
2.2) Identifiers
2.3) Socioeconomic variables

*/

/*====================
	2.1) Test Scores
======================*/

gen lpuntaje = TEL
gen mpuntaje = TEM

*(Log) Test Scores

* Lengua
gen log_lpuntaje = log(lpuntaje)

* Matematica
gen log_mpuntaje = log(mpuntaje)


label define leng 1"Por debajo de nivel basico" 2"Nivel Basico" ///
	3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values ldesemp leng

label define mate 1"Por debajo de nivel basico" 2"Nivel Basico" ///
	3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values mdesemp mate




*Standardized Test Scores

* Lengua
gen lpuntaje_std = .
replace lpuntaje_std = lpuntaje / 880

* Matematica
gen mpuntaje_std = .
replace mpuntaje_std = mpuntaje / 880





/*================================
		2.2) Identifiers
==================================*/



gen idschool = ID1
*encode ID1, gen(idschool)
encode claveseccion, gen(idclass)

bysort idclass: gen idstudent = _n

gen region = cod_provincia
*encode cod_provincia, gen(region)

order idschool idclass idstudent region
sort  idschool idclass idstudent




/*================================
	2.3) Socioeconomic variables
==================================*/



*private (vs public school)
gen 	private = .
replace private = 0 if sector == 1
replace private = 1 if sector == 2

*urban (vs rural school)
gen 	urban = .
replace urban = 0 if ambito == 1
replace urban = 1 if ambito == 2


*dummy women
gen 	women = 0 if ap2 == 1
replace women = 1 if ap2 == 2


*foreign
*0=Argentina, 1=Any other country
gen 	foreign = .
replace foreign = 0 if ap03 == 1
replace foreign = 1 if ap03 > 1 & ap03 != .

label define foreign 0 "Argentine" "Foreign"
label values foreign foreign


*child: if has any child
gen 	child = .
replace child = 0 if ap09 == 2
replace child = 1 if ap09 == 1


*internet: if has internet connection at home
gen 	internet = .
replace internet = 0 if ap11_08 == 2
replace internet = 1 if ap11_08 == 1


*internet_phone: if can access internet through internet_phone
gen 	  internet_phone = .
replace   internet_phone = 0 if ap13 == 2
replace   internet_phone = 1 if ap13 == 1
label var internet_phone "If can access internet via phone"


*educ_mother: mother's education level
	*1=prii 2=pric 3=seci 4=secc 5=supi/supc	
gen 		 educ_mother = .
replace 	 educ_mother = 1 if ap16 == 1 	
replace 	 educ_mother = 2 if ap16 == 2
replace 	 educ_mother = 3 if ap16 == 3
replace 	 educ_mother = 4 if ap16 == 4
replace 	 educ_mother = 5 if ap16 == 5 | ap16 == 6 | ap16 == 7
label define educ_mother  	1"Primary Incomplete" 	///
							2"Primary Complete" 	///
							3"Secondary Incomplete" ///
							4"Secondary Complete" 	///
							5"Superior (Complete or incomplete)"
label values educ_mother educ_mother



*educ_father: father's education level
	*1=prii 2=pric 3=seci 4=secc 5=supi/supc	
gen 		 educ_father = .
replace 	 educ_father = 1 if ap17 == 1 	
replace 	 educ_father = 2 if ap17 == 2
replace 	 educ_father = 3 if ap17 == 3
replace 	 educ_father = 4 if ap17 == 4
replace 	 educ_father = 5 if ap17 == 5 | ap17 == 6 | ap17 == 7
label define educ_father  	1"Primary Incomplete" 	///
							2"Primary Complete" 	///
							3"Secondary Incomplete" ///
							4"Secondary Complete" 	///
							5"Superior (Complete or incomplete)"
label values educ_father educ_father



*work: if works outside home
gen 	work = .
replace work = 0 if ap21 == 1
replace work = 1 if ap21 > 1 & ap21 != .



*kinder: if went to kindergarden
gen 	kinder = .
replace kinder = 0 if ap24 == 4
replace kinder = 1 if ap24 >= 1 & ap24 <= 3


*repeated: dummy for any level
gen 	repeated = .
replace repeated = 0 if repitencia_dicotomica == 2
replace repeated = 1 if repitencia_dicotomica == 1


save "`data'/analyitical/base_56anio_2019.dta", replace



