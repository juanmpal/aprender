******************************
* Estimation of peer effects *
******************************

set more off
clear all

cd "C:\Users\juanc\Google Drive\research\aprender"

local data = "C:\research\aprender\data"

use "`data'/analytical/base_6grado_2016.dta", clear


*FE reg
* y_i = a + b1 \bar{Y}_{-i} + b2 x_i + b3 \bar{x}_{-i} + e_i
areg log_lpuntaje lpeers_score_l peer_* class_size 					///
				  women edu_madre edu_padre trabaja anios_jardin 	///
				  repitio apoyo buena_relacion auh 					///
				  privado urbano nbi,  								///
				  abs(idschool) vce(cluster idclass)

areg log_mpuntaje lpeers_score_m peer_* class_size 					///
				  women edu_madre edu_padre trabaja anios_jardin 	///
				  repitio apoyo buena_relacion auh 					///
				  privado urbano nbi,  								///
				  abs(idschool) vce(cluster idclass)



xtset idschool

xtreg 			  mpuntaje_std peers_score_m peer_* class_size 		///
				  women edu_madre edu_padre trabaja anios_jardin 	///
				  repitio apoyo buena_relacion auh 					///
				  privado urbano nbi,  								///
				  mle

areg mpuntaje_std peers_score_m peer_* class_size 					///
				  women edu_madre edu_padre trabaja anios_jardin 	///
				  repitio apoyo buena_relacion auh 					///
				  privado urbano nbi,  								///
				  abs(idschool) vce(cluster idclass)
