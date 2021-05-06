

***Este do file
*1. Merge base alumnos con base directores
*2. Incorpora NBI
*3. Crea variables de interes y guarda las bases de cada grado/año con ellas


*1- Merge bases directores con bases de alumnos
* A partir de CUEANEXO
* También me quedo con la jurisdiccion


*2- Merge con nbi por departamento

set more off

*gl bases "D:\Matias\Cedlas\2018\APRENDER\2016\bases\stata"
gl bases "C:\Matias\CEDLAS\2018\APRENDER\2016\bases\stata"

loc base_1 = "$bases\originales\Cuestionario_del_Alumno_3_GRADO.dta"
loc base_2 = "$bases\originales\Cuestionario_del_Alumno_6_GRADO.dta"
loc base_3 = "$bases\originales\Cuestionario_del_Alumno_2-3_AÑO.dta"
loc base_4 = "$bases\originales\Cuestionario_del_Alumno_5-6_AÑO.dta"
loc base_5 = "$bases\originales\Cuestionario_del_Director_Primaria.dta"
loc base_6 = "$bases\originales\Cuestionario_del_Director_Secundaria.dta"

*** Preparo bases de directores para merge

* Primaria

use `base_5', clear

sort CUEANEXO

keep CUEANEXO jurisdiccion Dp1 Dp3a Dp3c Dp4a Dp4b Dp4c Dp4d Dp4e Dp4f Dp4g Dp4h Dp4i Dp6 Dp16* Dp18* Dp19* Dp20* Dp22* Dp36* Dp44* Dp48* Dp51* Dp52a1* Dp52b1*

tempfile dir5
	
save `dir5', replace

* Secundaria

use `base_6', clear

sort CUEANEXO

keep CUEANEXO jurisdiccion Dp1 Dp3a Dp3c Dp4a Dp4b Dp4c Dp4d Dp4e Dp4f Dp4g Dp4h Dp4i Dp6 Dp17* Dp19* Dp19* Dp20* Dp21* Dp23* Dp38* Dp46* Dp47* Dp51* Dp54* Dp55*

tempfile dir6
	
save `dir6', replace
	


* Merge bases de Alumnos de Primaria con base de Directores de Primaria

forvalues i = 1(1)2{

	use `base_`i'', clear
	
	
	if "`i'"=="1"  	loc a="3grado"
	if "`i'"=="2"  	loc a="6grado"
	
	sort CUEANEXO
	
	merge CUEANEXO using `dir5'
	
	drop if _merge==2
	
	drop _merge
	
	tempfile base`a'_dir
	
	save `base`a'_dir', replace
	
	
}


* Merge bases de Alumnos de Secundaria con base de Directores de Secundaria

forvalues i = 3(1)4{

	use `base_`i'', clear
	
	
	if "`i'"=="3"  	loc a="23anio"
	if "`i'"=="4"  	loc a="56anio"
	
	sort CUEANEXO
	
	merge CUEANEXO using `dir6'
	
	drop if _merge==2
	
	drop _merge
	
	tempfile base`a'_dir
	
	save `base`a'_dir', replace
	
	

}



*********************
*** Incorporo NBI promedio por departamento (jurisdiccion)
********************


use "C:\Matias\CEDLAS\2018\APRENDER\otros\nbi_dpto", clear
*use "D:\Matias\CEDLAS\2018\APRENDER\otros\nbi_dpto", clear

sort dpto

rename dpto cod_depto

tempfile nbi
	
save `nbi', replace


* Merge bases de Alumnos + Directores con NBI

forvalues i = 1(1)4{

	if "`i'"=="1"  	loc a="3grado"
	if "`i'"=="2"  	loc a="6grado"
	if "`i'"=="3"  	loc a="23anio"
	if "`i'"=="4"  	loc a="56anio"
	
	use `base`a'_dir', clear
	
	destring cod_depto, replace
	sort cod_depto
	
	merge cod_depto using `nbi'
	
	drop if _merge==2
	
	drop _merge
	
	capture drop suma_nbi
	
	tempfile base`a'_dir_nbi
	
	save `base`a'_dir_nbi', replace
	
		

}



*********************************************************************************************
*** CREACION DE VARIABLES
*********************************************************************************************

*base_1 = `base3grado_dir_nbi'
*base_2 = `base6grado_dir_nbi'
*base_3 = `base23anio_dir_nbi'
*base_4 = `base56anio_dir_nbi'


*************************
*** Cuestionario 3 GRADO
*************************

use `base3grado_dir_nbi', clear


*** Log de variable de puntajes (desempeño)

* Lengua
gen log_lpuntaje = log(lpuntaje)

* Matematica
gen log_mpuntaje = log(mpuntaje)

label define leng 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values ldesemp leng

label define mate 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values mdesemp mate


* Genero variables estandarizadas: Min:0; Max:880

* Lengua

gen lpuntaje_std = .
replace lpuntaje_std = lpuntaje / 880

* Matematica

gen mpuntaje_std = .
replace mpuntaje_std = mpuntaje / 880



*** Variables de interes disponibles (facotres asociados a desempeño)
*** Alumnos

* Sexo: Ap2

gen sexo = .
replace sexo = 0 if Ap2 ==1 /* =0, varon*/
replace sexo = 1 if Ap2 ==2

label define sexo 0"Hombre" 1"Mujer"
label values sexo sexo


* Jardin: Ap3

gen jardin = .
replace jardin = 1 if Ap3>0 & Ap3<4 /*si fue alguna vez*/
replace jardin = 0 if Ap3==4

label define jardin 0"No asistió jardín" 1"Asistió jardín"
label values jardin jardin

gen anios_jardin = .
replace anios_jardin = 0 if Ap3==4
replace anios_jardin = 1 if Ap3==3
replace anios_jardin = 2 if Ap3==2
replace anios_jardin = 3 if Ap3==1

label define anios_jardin 0"No asistió jardín" 1"Un año de jardín" 2"Dos años de jardín" 3"Tres años de jardín"
label values anios_jardin anios_jardin



* Repitencia: Ap4

gen repitio = .
replace repitio = 0 if Ap4==1
replace repitio = 1 if Ap4>1 & Ap4<5 /*si repitio alguna vez*/

label define repitio 0"Nunca repitió" 1"Repitió"
label values repitio repitio



* Relaciones: Ap9

gen buena_relacion = .
replace buena_relacion = 1 if Ap9==1 | Ap9==2
replace buena_relacion = 0 if Ap9==3 | Ap9==4

label define buena_relacion 0"No tiene buena relación" 1"Tiene buena relación"
label values buena_relacion buena_relacion

* Privado: sector

gen privado = .
replace privado = 1 if sector==2
replace privado = 0 if sector==1

label define privado 0"Sector Público" 1"Sector Privado"
label values privado privado


* Urbano: ambito

gen urbano = .
replace urbano = 1 if ambito==1
replace urbano = 0 if ambito==2

label define urbano 0"Rural" 1"Urbano"
label values urbano urbano

* NBI: 3 categ: Bajo (0-10); Medio(10-20); Alto(+20)

gen nbi = .
replace nbi = 1 if share_nbi>0 & share_nbi<=0.1
replace nbi = 2 if share_nbi>0.1 & share_nbi<=0.2
replace nbi = 3 if share_nbi>0.2

label define nbi 1"NBI Bajo" 2"NBI Medio" 3"NBI Alto"
label values nbi nbi



* Indice emotivo: iemotivol; iemotivom
* Indice Clima Escolar: iclimal; iclimam
* Vulnerabilidad: qvulneraa
* Categorias del indice socioeconomico estan disponibles para este cuestionario.


* Indicadores emotivos y de clima tienen problema con missing ==-1

loc reemp = "iemotivo iclima iemotivol iclimal iemotivom iclimam"

foreach var of local reemp{

	replace `var' = . if `var' ==-1

}

label define qvulneraa 1"Cuantil 1 Vulnerab." 2"Cuantil 2 Vulnerab." 3"Cuantil 3 Vulnerab." 4"Cuantil 4 Vulnerab."
label values qvulneraa qvulneraa



* Redondeo ponderadores

replace lpondera = round(lpondera)
replace mpondera = round(mpondera)


*** Variables de interes disponibles (facotres asociados a desempeño)
*** Director

* Sexo Director (Mujer=1)

gen sexo_dir = .
replace sexo_dir = 1 if Dp1==1
replace sexo_dir = 0 if Dp1==2

label define sexo_dir 0"Director Hombre" 1"Directora Mujer"
label values sexo_dir sexo_dir


* Antiguedad en el cargo/docente (Baja=hasta 5 años; Media=Hasta 10 años; Alta: +10 años)

gen antigue_cargo=.
replace antigue_cargo =1 if Dp3a>0 & Dp3a<=5
replace antigue_cargo =2 if Dp3a>5 & Dp3a<=10
replace antigue_cargo =3 if Dp3a>10 

label define antigue_cargo 1"Antiguedad Cargo Baja" 2"Antiguedad Cargo Media" 3"Antiguedad Cargo Alta"
label values antigue_cargo antigue_cargo


gen antigue_docente=.
replace antigue_docente =1 if Dp3c>0 & Dp3c<=5
replace antigue_docente =2 if Dp3c>5 & Dp3c<=10
replace antigue_docente =3 if Dp3c>10 

label define antigue_docente 1"Antiguedad Docente Baja" 2"Antiguedad Docente Media" 3"Antiguedad Docente Alta"
label values antigue_docente antigue_docente



* Dummmy titulo universitario

gen universitario = .
replace universitario = 1 if Dp4c==1 | Dp4e==1 | Dp4g==1 | Dp4i==1
replace universitario = 0 if Dp4a==1 | Dp4b==1 | Dp4d==1 | Dp4f==1 | Dp4h==1

label define universitario 0"Director Sin Título Univ." 1"Director Con Título Univ."
label values universitario universitario




* Dedicacion en horas semanales (Baja:hasta 24 hs semanales / Media: 25-29/ Alta:30+)

gen dedicacion = .
replace dedicacion =1 if Dp6==1 | Dp6==2
replace dedicacion =2 if Dp6==3
replace dedicacion =3 if Dp6==4

label define dedicacion 1"Dedicación Baja" 2"Dedicación Media" 3"Dedicación Alta"
label values dedicacion dedicacion




* Servicios con que cuenta la escuela. Bajo: 0,1,2 / Medio:3,5 /Alto:5,6

loc list = " Dp16a Dp16b Dp16c Dp16d Dp16e Dp16f" 

foreach var of loc list {

	replace `var' = . if `var'==-1
	
	replace `var' = 0 if `var'==2
	
}

egen aux = rowtotal(Dp16a Dp16b Dp16c Dp16d Dp16e Dp16f)

gen servicios = .
replace servicios = 1 if aux<=2
replace servicios = 2 if aux>2 & aux<=4
replace servicios = 3 if aux>5 & aux<=6

label define servicios 1"Servicios alumno Baja" 2"Servicios alumno Media" 3"Servicios alumno Alta"
label values servicios servicios



* Infraestructura escolar (edificio, aulas, biblioteca, mobiliario)
* =1 si reporta bueno/muy bueno/muy

gen edificio = .
replace edificio = 1 if  Dp19a==4 | Dp19a==5
replace edificio = 0 if  Dp19a==1 | Dp19a==2 | Dp19a==3

label define edificio 0"Edificio Inadecuado" 1"Edificio Adecuado"
label values edificio edificio



gen aulas = .
replace aulas = 1 if  Dp19b==4 | Dp19b==5
replace aulas = 0 if  Dp19b==1 | Dp19b==2 | Dp19b==3

label define aulas 0"Aulas Inadecuadas" 1"Aulas Adecuadas"
label values aulas aulas

gen biblioteca = .
replace biblioteca = 1 if  Dp19c==4 | Dp19c==5
replace biblioteca = 0 if  Dp19c==1 | Dp19c==2 | Dp19c==3

label define biblioteca 0"Biblioteca Inadecuada" 1"Biblioteca Adecuada"
label values biblioteca biblioteca


gen mobiliario = .
replace mobiliario = 1 if  Dp19d==4 | Dp19d==5
replace mobiliario = 0 if  Dp19d==1 | Dp19d==2 | Dp19d==3

label define mobiliario 0"Mobiliario Inadecuada" 1"Mobiliario Adecuada"
label values mobiliario mobiliario




* Bullying

gen bullying = .
replace bullying = 1 if Dp36d==1 | Dp36d==1
replace bullying = 0 if Dp36d==3

label define bullying 0"No sufrió Bullying" 1"Sufrió Bullying"
label values bullying bullying


* Disponibilidad de Computadoras suficiente

gen computadora = .
replace computadora = 1 if Dp44a1==1 & Dp44a2==1
replace computadora = 0 if Dp44a1==2 | Dp44a2==2

label define computadora 0"Computadoras Insuficientes" 1"Computadoras Suficientes"
label values computadora computadora


* Acceso a Internet en la escuela

gen internet = .
replace internet = 1 if Dp48==1 & Dp51==1
replace internet = 0 if Dp48==0 | Dp51==2 | Dp51==3 | Dp51==4 | Dp51==5

label define internet 0"Escuela Sin Internet" 1"Escuela Con Internet"
label values internet internet

* Capacitacion

gen capacitacion = .
replace capacitacion = 1 if Dp52a1==1 | Dp52b1==1
replace capacitacion = 0 if Dp52a1==2 | Dp52b1==2

label define capacitacion 0"No hubo Capacit. docente" 1"Hubo Capacit. Docente"
label values capacitacion capacitacion

* Dias en que se dictaron clases (Cuartiles de dias)

xtile cuart_dias_clase = Dp20 if Dp20>0, n(4)

label define cuart_dias_clase 1"Cuartil 1 Dias Clase" 2"Cuartil 2 Dias Clase" 3"Cuartil 3 Dias Clase" 4"Cuartil 4 Dias Clase"
label values cuart_dias_clase cuart_dias_clase

save "$bases\base_3grado_alum_dir.dta", replace



******************************************************************************************************************************************
*** CUESTIONARIO 6 Grado
**************************************************************

use `base6grado_dir_nbi', clear

*** Log de variable de puntajes (desempeño)

* Lengua
gen log_lpuntaje = log(lpuntaje)

* Matematica
gen log_mpuntaje = log(mpuntaje)

label define leng 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values ldesemp leng

label define mate 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values mdesemp mate

* Genero variables estandarizadas: Min:0; Max:880

* Lengua

gen lpuntaje_std = .
replace lpuntaje_std = lpuntaje / 880

* Matematica

gen mpuntaje_std = .
replace mpuntaje_std = mpuntaje / 880


*** Variables de interes disponibles (facotres asociados a desempeño)

* Sexo: Ap2

gen sexo = .
replace sexo = 0 if Ap2 ==1 /* =0, varon*/
replace sexo = 1 if Ap2 ==2

label define sexo 0"Hombre" 1"Mujer"
label values sexo sexo



* AUH: Ap5 . Mucha proporcion (45%) no sabe

gen auh = .
replace auh = 1 if Ap5==1
replace auh = 0 if Ap5==2

label define auh 0"Hogar no Recibe AUH" 1"Hogar Recibe AUH"
label values auh auh


* Nivel Educativo Padres: Ap7(madre); Ap8(padre). Las dejamos como estan, pero replace missing y "No se"

* 1=prii/pric; 2-seci; 3-secc; 4-supi/supc

gen edu_madre = .
replace edu_madre = 1 if Ap7==1
replace edu_madre = 2 if Ap7==2
replace edu_madre = 3 if Ap7==3
replace edu_madre = 4 if Ap7==4

label define edu_madre 1"Educ. Madre: hasta pric" 2"Educ. Madre: hasta seci" 3"Educ. Madre: hasta secc" 4"Educ. Madre: supi/supc"
label values edu_madre edu_madre


gen edu_padre = .
replace edu_padre = 1 if Ap8==1
replace edu_padre = 2 if Ap8==2
replace edu_padre = 3 if Ap8==3
replace edu_padre = 4 if Ap8==4

label define edu_padre 1"Educ. Padre: hasta pric" 2"Educ. Padre: hasta seci" 3"Educ. Padre: hasta secc" 4"Educ. Padre: supi/supc"
label values edu_padre edu_padre


* Trabaja: Ap10

gen trabaja = .
replace trabaja = 1 if Ap10==1
replace trabaja = 0 if Ap10==2

label define trabaja 0"No Trabaja" 1"Trabaja"
label values trabaja trabaja


* Jardin: Ap11

gen jardin = .
replace jardin = 1 if Ap11>0 & Ap11<4 /*si fue alguna vez*/
replace jardin = 0 if Ap11==4

label define jardin 0"No asistió jardín" 1"Asistió jardín"
label values jardin jardin

gen anios_jardin = .
replace anios_jardin = 0 if Ap11==4
replace anios_jardin = 1 if Ap11==3
replace anios_jardin = 2 if Ap11==2
replace anios_jardin = 3 if Ap11==1

label define anios_jardin 0"No asistió jardín" 1"Un año de jardín" 2"Dos años de jardín" 3"Tres años de jardín"
label values anios_jardin anios_jardin


* Repitencia: Ap12

gen repitio = .
replace repitio = 0 if Ap12==1
replace repitio = 1 if Ap12>1 & Ap12<5 /*si repitio alguna vez*/

label define repitio 0"Nunca repitió" 1"Repitió"
label values repitio repitio


* Faltas: Ap13. Las dejamos como estan, pero replace missing y "No se"

replace Ap13 = . if Ap13==-9 | Ap13==-1
rename Ap13 faltas

label define faltas 1"Menos de 8 veces" 2"8-17 veces" 3"18-24 veces" 4"Más de 24 veces"
label values faltas faltas


* Clases de Apoyo: Ap14

gen apoyo = .
replace apoyo = 1 if Ap14==1 | Ap14==2
replace apoyo = 0 if Ap14==3

label define apoyo 0"No tuvo clase apoyo" 1"Tuvo clase apoyo"
label values apoyo apoyo


* Relaciones: Ap23

gen buena_relacion = .
replace buena_relacion = 1 if Ap23==1 | Ap23==2
replace buena_relacion = 0 if Ap23==3 | Ap23==4

label define buena_relacion 0"No tiene buena relación" 1"Tiene buena relación"
label values buena_relacion buena_relacion

* Privado: sector

gen privado = .
replace privado = 1 if sector==2
replace privado = 0 if sector==1

label define privado 0"Sector Público" 1"Sector Privado"
label values privado privado


* Urbano: ambito

gen urbano = .
replace urbano = 1 if ambito==1
replace urbano = 0 if ambito==2

label define urbano 0"Rural" 1"Urbano"
label values urbano urbano


* NBI: 3 categ: Bajo (0-10); Medio(10-20); Alto(+20)

gen nbi = .
replace nbi = 1 if share_nbi>0 & share_nbi<=0.1
replace nbi = 2 if share_nbi>0.1 & share_nbi<=0.2
replace nbi = 3 if share_nbi>0.2

label define nbi 1"NBI Bajo" 2"NBI Medio" 3"NBI Alto"
label values nbi nbi



* Indice emotivo: iemotivol; iemotivom
* Indice Clima Escolar: iclimal; iclimam
* Vulnerabilidad: qvulneraa
* Socioeconomico : isocioal; isocioam


* Indicadores emotivos y de clima tienen problema con missing ==-1

loc reemp = " isocioa iemotivo iclima isocioal iemotivol iclimal isocioam iemotivom iclimam qvulneraa"

foreach var of local reemp{

	replace `var' = . if `var' ==-1

}


label define qvulneraa 1"Cuantil 1 Vulnerab." 2"Cuantil 2 Vulnerab." 3"Cuantil 3 Vulnerab." 4"Cuantil 4 Vulnerab."
label values qvulneraa qvulneraa

* Redondeo ponderadores

replace lpondera = round(lpondera)
replace mpondera = round(mpondera)

*** Variables de interes disponibles (facotres asociados a desempeño)
*** Director

* Sexo Director (Mujer=1)

gen sexo_dir = .
replace sexo_dir = 1 if Dp1==1
replace sexo_dir = 0 if Dp1==2

label define sexo_dir 0"Director Hombre" 1"Directora Mujer"
label values sexo_dir sexo_dir



* Antiguedad en el cargo/docente (Baja=hasta 5 años; Media=Hasta 10 años; Alta: +10 años)

gen antigue_cargo=.
replace antigue_cargo =1 if Dp3a>0 & Dp3a<=5
replace antigue_cargo =2 if Dp3a>5 & Dp3a<=10
replace antigue_cargo =3 if Dp3a>10

label define antigue_cargo 1"Antiguedad Cargo Baja" 2"Antiguedad Cargo Media" 3"Antiguedad Cargo Alta"
label values antigue_cargo antigue_cargo
 

gen antigue_docente=.
replace antigue_docente =1 if Dp3c>0 & Dp3c<=5
replace antigue_docente =2 if Dp3c>5 & Dp3c<=10
replace antigue_docente =3 if Dp3c>10 

label define antigue_docente 1"Antiguedad Docente Baja" 2"Antiguedad Docente Media" 3"Antiguedad Docente Alta"
label values antigue_docente antigue_docente


* Dummmy titulo universitario

gen universitario = .
replace universitario = 1 if Dp4c==1 | Dp4e==1 | Dp4g==1 | Dp4i==1
replace universitario = 0 if Dp4a==1 | Dp4b==1 | Dp4d==1 | Dp4f==1 | Dp4h==1

label define universitario 0"Director Sin Título Univ." 1"Director Con Título Univ."
label values universitario universitario




* Dedicacion en horas semanales (Baja:hasta 24 hs semanales / Media: 25-29/ Alta:30+)

gen dedicacion = .
replace dedicacion =1 if Dp6==1 | Dp6==2
replace dedicacion =2 if Dp6==3
replace dedicacion =3 if Dp6==4

label define dedicacion 1"Dedicación Baja" 2"Dedicación Media" 3"Dedicación Alta"
label values dedicacion dedicacion



* Servicios con que cuenta la escuela. Bajo: 0,1,2 / Medio:3,5 /Alto:5,6

loc list = " Dp16a Dp16b Dp16c Dp16d Dp16e Dp16f" 

foreach var of loc list {

	replace `var' = . if `var'==-1
	
	replace `var' = 0 if `var'==2
	
}

egen aux = rowtotal(Dp16a Dp16b Dp16c Dp16d Dp16e Dp16f)

gen servicios = .
replace servicios = 1 if aux<=2
replace servicios = 2 if aux>2 & aux<=4
replace servicios = 3 if aux>5 & aux<=6

label define servicios 1"Servicios alumno Baja" 2"Servicios alumno Media" 3"Servicios alumno Alta"
label values servicios servicios



* Infraestructura escolar (edificio, aulas, biblioteca, mobiliario)
* =1 si reporta bueno/muy bueno/muy

gen edificio = .
replace edificio = 1 if  Dp19a==4 | Dp19a==5
replace edificio = 0 if  Dp19a==1 | Dp19a==2 | Dp19a==3

label define edificio 0"Edificio Inadecuado" 1"Edificio Adecuado"
label values edificio edificio


gen aulas = .
replace aulas = 1 if  Dp19b==4 | Dp19b==5
replace aulas = 0 if  Dp19b==1 | Dp19b==2 | Dp19b==3

label define aulas 0"Aulas Inadecuadas" 1"Aulas Adecuadas"
label values aulas aulas



gen biblioteca = .
replace biblioteca = 1 if  Dp19c==4 | Dp19c==5
replace biblioteca = 0 if  Dp19c==1 | Dp19c==2 | Dp19c==3

label define biblioteca 0"Biblioteca Inadecuada" 1"Biblioteca Adecuada"
label values biblioteca biblioteca


gen mobiliario = .
replace mobiliario = 1 if  Dp19d==4 | Dp19d==5
replace mobiliario = 0 if  Dp19d==1 | Dp19d==2 | Dp19d==3

label define mobiliario 0"Mobiliario Inadecuada" 1"Mobiliario Adecuada"
label values mobiliario mobiliario

* Bullying

gen bullying = .
replace bullying = 1 if Dp36d==1 | Dp36d==1
replace bullying = 0 if Dp36d==3

label define bullying 0"No sufrió Bullying" 1"Sufrió Bullying"
label values bullying bullying


* Disponibilidad de Computadoras suficiente

gen computadora = .
replace computadora = 1 if Dp44a1==1 & Dp44a2==1
replace computadora = 0 if Dp44a1==2 | Dp44a2==2

label define computadora 0"Computadoras Insuficientes" 1"Computadoras Suficientes"
label values computadora computadora


* Acceso a Internet en la escuela

gen internet = .
replace internet = 1 if Dp48==1 & Dp51==1
replace internet = 0 if Dp48==0 | Dp51==2 | Dp51==3 | Dp51==4 | Dp51==5

label define internet 0"Escuela Sin Internet" 1"Escuela Con Internet"
label values internet internet


* Capacitacion

gen capacitacion = .
replace capacitacion = 1 if Dp52a1==1 | Dp52b1==1
replace capacitacion = 0 if Dp52a1==2 | Dp52b1==2

label define capacitacion 0"No hubo Capacit. docente" 1"Hubo Capacit. Docente"
label values capacitacion capacitacion


* Dias en que se dictaron clases (Cuartiles de dias)

xtile cuart_dias_clase = Dp20 if Dp20>0, n(4)

label define cuart_dias_clase 1"Cuartil 1 Dias Clase" 2"Cuartil 2 Dias Clase" 3"Cuartil 3 Dias Clase" 4"Cuartil 4 Dias Clase"
label values cuart_dias_clase cuart_dias_clase

save "$bases\base_6grado_alum_dir.dta", replace


*******************************************************************************************************
****  EDUCACION SECUNDARIA

**** 2-3 AÑO SECUNDARIA

*******************************************************************************************************	

use `base23anio_dir_nbi', clear


*** Log de variable de puntajes (desempeño)

* Lengua
gen log_lpuntaje = log(lpuntaje)

* Matematica
gen log_mpuntaje = log(mpuntaje)

label define leng 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values ldesemp leng

label define mate 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values mdesemp mate

* Genero variables estandarizadas: Min:0; Max:880

* Lengua

gen lpuntaje_std = .
replace lpuntaje_std = lpuntaje / 880

* Matematica

gen mpuntaje_std = .
replace mpuntaje_std = mpuntaje / 880


*** Variables de interes disponibles (facotres asociados a desempeño)

* Sexo: Ap2

gen sexo = .
replace sexo = 0 if Ap2 ==1 /* =0, varon*/
replace sexo = 1 if Ap2 ==2

label define sexo 0"Hombre" 1"Mujer"
label values sexo sexo


* Nacionalidad : Ap3a

gen argentina = .
replace argentina = 1 if Ap3a==1
replace argentina = 0 if Ap3a!=1 & Ap3a!=-1 & Ap3a!=-9

label define argentina 0"Extranjero" 1"No Extranjero"
label values argentina argentina


* Nacionalidad madre Ap3b

gen argentina_madre = .
replace argentina_madre = 1 if Ap3b==1
replace argentina_madre = 0 if Ap3b!=1 & Ap3b!=-1 & Ap3b!=-9

label define argentina_madre 0"Madre Extranjera" 1"Madre No Extranjera"
label values argentina_madre argentina_madre

* Nacionalidad padre: Ap3c

gen argentina_padre = .
replace argentina_padre = 1 if Ap3c==1
replace argentina_padre = 0 if Ap3c!=1 & Ap3c!=-1 & Ap3c!=-9

label define argentina_padre 0"Padre Extranjero" 1"Padre No Extranjero"
label values argentina_padre argentina_padre


* Nacionalidad padres (ambos argentinos)

gen arg_padres = .
replace arg_padres = 1 if argentina_madre==1 & argentina_padre==1
replace arg_padres = 0 if argentina_madre==0 | argentina_padre==0

label define arg_padres 0"Algún padre extranjero" 1"Ambos padres no extranjeros"
label values arg_padres arg_padres



* AUH: Ap8 . Mucha proporcion (34%) no sabe

gen auh = .
replace auh = 1 if Ap8==1
replace auh = 0 if Ap8==2

label define auh 0"Hogar no Recibe AUH" 1"Hogar Recibe AUH"
label values auh auh


* Nivel Educativo Padres: Ap6(madre); Ap7(padre). Las dejamos como estan, pero replace missing y "No se"
*1=prii 2=pric 3=seci 4=secc 5=supi/supc

gen edu_madre = .
replace edu_madre = 1 if Ap6==1
replace edu_madre = 2 if Ap6==2
replace edu_madre = 3 if Ap6==3
replace edu_madre = 4 if Ap6==4
replace edu_madre = 5 if Ap6==6

label define edu_madre 1"Educ. Madre: hasta prii" 2"hasta pric" 3"Educ. Madre: hasta seci" 4"Educ. Madre: hasta secc" 5"Educ. Madre: supi/supc"
label values edu_madre edu_madre



gen edu_padre = .
replace edu_padre = 1 if Ap7==1
replace edu_padre = 2 if Ap7==2
replace edu_padre = 3 if Ap7==3
replace edu_padre = 4 if Ap7==4
replace edu_padre = 5 if Ap7==6

label define edu_padre 1"Educ. Padre: hasta prii" 2"Educ. Padre: hasta pric" 3"Educ. Padre: hasta seci" 4"Educ. Padre: hasta secc" 5"Educ. Padre: supi/supc"
label values edu_padre edu_padre


* Trabaja: Ap11

gen trabaja = .
replace trabaja = 1 if Ap11==1
replace trabaja = 0 if Ap11==2

label define trabaja 0"No Trabaja" 1"Trabaja"
label values trabaja trabaja


* Hijos: Ap12

gen hijos = .
replace hijos = 1 if Ap12==1
replace hijos = 0 if Ap12==2

label define hijos 0"Sin Hijos" 1"Con Hijo/s"
label values hijos hijos


* Embarazada: Ap13

gen embarazada = .
replace embarazada = 1 if Ap13==1
replace embarazada = 0 if Ap13==2

label define embarazada 0"No Embarazada" 1"Embarazada"
label values embarazada embarazada


* Jardin: Ap14

gen jardin = .
replace jardin = 1 if Ap14>0 & Ap14<4 /*si fue alguna vez*/
replace jardin = 0 if Ap14==4

label define jardin 0"No asistió jardín" 1"Asistió jardín"
label values jardin jardin


gen anios_jardin = .
replace anios_jardin = 0 if Ap14==4
replace anios_jardin = 1 if Ap14==3
replace anios_jardin = 2 if Ap14==2
replace anios_jardin = 3 if Ap14==1

label define anios_jardin 0"No asistió jardín" 1"Un año de jardín" 2"Dos años de jardín" 3"Tres años de jardín"
label values anios_jardin anios_jardin



* Repitencia primaria: Ap15

gen repitio_prim = .
replace repitio_prim = 0 if Ap15==1
replace repitio_prim = 1 if Ap15>1 & Ap15<5 /*si repitio alguna vez*/

label define repitio_prim 0"Nunca repitió primaria" 1"Repitió primaria"
label values repitio_prim repitio_prim


* Repitencia secundaria: Ap16

gen repitio_sec = .
replace repitio_sec = 0 if Ap16==1
replace repitio_sec = 1 if Ap16>1 & Ap16<5 /*si repitio alguna vez*/

label define repitio_sec 0"Nunca repitió secundaria" 1"Repitió secundaria"
label values repitio_sec repitio_sec


* Faltas: Ap19. Las dejamos como estan, pero replace missing y "No se"

replace Ap19 = . if Ap19==-9 | Ap19==-1
rename Ap19 faltas

label define faltas 1"Menos de 8 veces" 2"8-17 veces" 3"18-24 veces" 4"Más de 24 veces"
label values faltas faltas


* Clases de Apoyo: Ap20

gen apoyo = .
replace apoyo = 1 if Ap20==1 | Ap20==2
replace apoyo = 0 if Ap20==3

label define apoyo 0"No tuvo clase apoyo" 1"Tuvo clase apoyo"
label values apoyo apoyo


* Relaciones: Ap32

gen buena_relacion = .
replace buena_relacion = 1 if Ap32==1 | Ap32==2
replace buena_relacion = 0 if Ap32==3 | Ap32==4

label define buena_relacion 0"No tiene buena relación" 1"Tiene buena relación"
label values buena_relacion buena_relacion

* Uso de computadora en el aula: Ap46a Las dejamos como estan, pero replace missing y "No se"

gen uso_pc_aula=.
replace uso_pc_aula = 1 if Ap46a==4
replace uso_pc_aula = 2 if Ap46a==3
replace uso_pc_aula = 3 if Ap46a==2
replace uso_pc_aula = 4 if Ap46a==1
 
label define uso_pc_aula 1"Al menos una vez por semana" 2"Algunas veces en el mes" 3" Algunas veces en el año" 4"Nunca"
label values uso_pc_aula uso_pc_aula



* Uso de computadora en el salon de informatica: Ap46b Las dejamos como estan, pero replace missing y "No se"

gen uso_pc_sala=.
replace uso_pc_sala = 1 if Ap46b==4
replace uso_pc_sala = 2 if Ap46b==3
replace uso_pc_sala = 3 if Ap46b==2
replace uso_pc_sala = 4 if Ap46b==1

label define uso_pc_sala 1"Al menos una vez por semana" 2"Algunas veces en el mes" 3" Algunas veces en el año" 4"Nunca"
label values uso_pc_sala uso_pc_sala



* Privado: sector

gen privado = .
replace privado = 1 if sector==2
replace privado = 0 if sector==1

label define privado 0"Sector Público" 1"Sector Privado"
label values privado privado

* Urbano: ambito

gen urbano = .
replace urbano = 1 if ambito==1
replace urbano = 0 if ambito==2

label define urbano 0"Rural" 1"Urbano"
label values urbano urbano

* NBI: 3 categ: Bajo (0-10); Medio(10-20); Alto(+20)

gen nbi = .
replace nbi = 1 if share_nbi>0 & share_nbi<=0.1
replace nbi = 2 if share_nbi>0.1 & share_nbi<=0.2
replace nbi = 3 if share_nbi>0.2

label define nbi 1"NBI Bajo" 2"NBI Medio" 3"NBI Alto"
label values nbi nbi


* Indice emotivo: iemotivol; iemotivom
* Indice Clima Escolar: iclimal; iclimam
* Vulnerabilidad: qvulneraa
* Socioeconomico : isocioal; isocioam



* Indicadores emotivos y de clima tienen problema con missing ==-1

loc reemp = " isocioa iemotivo iclima isocioal iemotivol iclimal isocioam iemotivom iclimam qvulneraa"

foreach var of local reemp{

	replace `var' = . if `var' ==-1

}

* Redondeo ponderadores

replace lpondera = round(lpondera)
replace mpondera = round(mpondera)


*** Variables de interes disponibles (facotres asociados a desempeño)
*** Director

* Sexo Director (Mujer=1)

gen sexo_dir = .
replace sexo_dir = 1 if Dp1==1
replace sexo_dir = 0 if Dp1==2

label define sexo_dir 0"Director Hombre" 1"Directora Mujer"
label values sexo_dir sexo_dir

* Antiguedad en el cargo/docente (Baja=hasta 5 años; Media=Hasta 10 años; Alta: +10 años)

gen antigue_cargo=.
replace antigue_cargo =1 if Dp3a>0 & Dp3a<=5
replace antigue_cargo =2 if Dp3a>5 & Dp3a<=10
replace antigue_cargo =3 if Dp3a>10 

label define antigue_cargo 1"Antiguedad Cargo Baja" 2"Antiguedad Cargo Media" 3"Antiguedad Cargo Alta"
label values antigue_cargo antigue_cargo

gen antigue_docente=.
replace antigue_docente =1 if Dp3c>0 & Dp3c<=5
replace antigue_docente =2 if Dp3c>5 & Dp3c<=10
replace antigue_docente =3 if Dp3c>10 

label define antigue_docente 1"Antiguedad Docente Baja" 2"Antiguedad Docente Media" 3"Antiguedad Docente Alta"
label values antigue_docente antigue_docente

* Dummmy titulo universitario

gen universitario = .
replace universitario = 1 if Dp4c==1 | Dp4e==1 | Dp4g==1 | Dp4i==1
replace universitario = 0 if Dp4a==1 | Dp4b==1 | Dp4d==1 | Dp4f==1 | Dp4h==1

label define universitario 0"Director Sin Título Univ." 1"Director Con Título Univ."
label values universitario universitario


* Dedicacion en horas semanales (Baja:hasta 24 hs semanales / Media: 25-29/ Alta:30+)

gen dedicacion = .
replace dedicacion =1 if Dp6==1 | Dp6==2
replace dedicacion =2 if Dp6==3
replace dedicacion =3 if Dp6==4

label define dedicacion 1"Dedicación Baja" 2"Dedicación Media" 3"Dedicación Alta"
label values dedicacion dedicacion


* Servicios con que cuenta la escuela. Bajo: 0,1,2 / Medio:3,5 /Alto:5,6

loc list = " Dp17a Dp17b Dp17c Dp17d Dp17e Dp17f" 

foreach var of loc list {

	replace `var' = . if `var'==-1
	
	replace `var' = 0 if `var'==2
	
}

egen aux = rowtotal(Dp17a Dp17b Dp17c Dp17d Dp17e Dp17f)

gen servicios = .
replace servicios = 1 if aux<=2
replace servicios = 2 if aux>2 & aux<=4
replace servicios = 3 if aux>5 & aux<=6

label define servicios 1"Servicios alumno Baja" 2"Servicios alumno Media" 3"Servicios alumno Alta"
label values servicios servicios



* Infraestructura escolar (edificio, aulas, biblioteca, mobiliario)
* =1 si reporta bueno/muy bueno/muy

gen edificio = .
replace edificio = 1 if  Dp20a==4 | Dp20a==5
replace edificio = 0 if  Dp20a==1 | Dp20a==2 | Dp20a==3

label define edificio 0"Edificio Inadecuado" 1"Edificio Adecuado"
label values edificio edificio

gen aulas = .
replace aulas = 1 if  Dp20b==4 | Dp20b==5
replace aulas = 0 if  Dp20b==1 | Dp20b==2 | Dp20b==3

label define aulas 0"Aulas Inadecuadas" 1"Aulas Adecuadas"
label values aulas aulas

gen biblioteca = .
replace biblioteca = 1 if  Dp20c==4 | Dp20c==5
replace biblioteca = 0 if  Dp20c==1 | Dp20c==2 | Dp20c==3

label define biblioteca 0"Biblioteca Inadecuada" 1"Biblioteca Adecuada"
label values biblioteca biblioteca

gen mobiliario = .
replace mobiliario = 1 if  Dp20d==4 | Dp20d==5
replace mobiliario = 0 if  Dp20d==1 | Dp20d==2 | Dp20d==3

label define mobiliario 0"Mobiliario Inadecuada" 1"Mobiliario Adecuada"
label values mobiliario mobiliario



* Bullying

gen bullying = .
replace bullying = 1 if Dp38d==1 | Dp38d==1
replace bullying = 0 if Dp38d==3

label define bullying 0"No sufrió Bullying" 1"Sufrió Bullying"
label values bullying bullying

* Disponibilidad de Computadoras suficiente

gen computadora = .
replace computadora = 1 if Dp47a1==1 & Dp47a2==1
replace computadora = 0 if Dp47a1==2 | Dp47a2==2

label define computadora 0"Computadoras Insuficientes" 1"Computadoras Suficientes"
label values computadora computadora


* Acceso a Internet en la escuela

gen internet = .
replace internet = 1 if Dp51==1 & Dp54==1
replace internet = 0 if Dp51==0 | Dp54==2 | Dp54==3 | Dp54==4 | Dp54==5

label define internet 0"Escuela Sin Internet" 1"Escuela Con Internet"
label values internet internet

* Capacitacion

gen capacitacion = .
replace capacitacion = 1 if Dp55a1==1 | Dp55b1==1
replace capacitacion = 0 if Dp55a1==2 | Dp55b1==2

label define capacitacion 0"No hubo Capacit. docente" 1"Hubo Capacit. Docente"
label values capacitacion capacitacion

* Dias en que se dictaron clases (Cuartiles de dias)

xtile cuart_dias_clase = Dp21 if Dp21>0, n(4)

label define cuart_dias_clase 1"Cuartil 1 Dias Clase" 2"Cuartil 2 Dias Clase" 3"Cuartil 3 Dias Clase" 4"Cuartil 4 Dias Clase"
label values cuart_dias_clase cuart_dias_clase


* Conectar Igualdad (dummy si mas del 50% de la escuela recibio)

gen conectar_igualdad = .
replace conectar_igualdad = 1 if Dp46a==3 | Dp46a==4
replace conectar_igualdad = 0 if Dp46a==1 | Dp46a==2

label define conectar_igualdad 0"Conect Igualdad: -50% alumnos" 1"Conect Igualdad: +50% alumnos"
label values conectar_igualdad conectar_igualdad

save "$bases\base_23anio_alum_dir.dta", replace



*******************************************************************************************************	

**** 5-6 AÑO SECUNDARIA

*******************************************************************************************************	

use `base56anio_dir_nbi', clear

*** Log de variable de puntajes (desempeño)

* Lengua
gen log_lpuntaje = log(lpuntaje)

* Matematica
gen log_mpuntaje = log(mpuntaje)

* Ciencias Sociales
gen log_cspuntaje = log(cspuntaje)

* Ciencias Naturales
gen log_cnpuntaje = log(cnpuntaje)


label define leng 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values ldesemp leng

label define mate 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values mdesemp mate

label define nat 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values cndesemp nat

label define soc 1"Por debajo de nivel basico" 2"Nivel Basico" 3"Nivel Satisfactorio" 4"Nivel Avanzado"
label values csdesemp soc

* Genero variables estandarizadas: Min:0; Max:880

* Lengua

gen lpuntaje_std = .
replace lpuntaje_std = lpuntaje / 880

* Matematica

gen mpuntaje_std = .
replace mpuntaje_std = mpuntaje / 880

* Ciencias Naturales

gen cnpuntaje_std = .
replace cnpuntaje_std = cnpuntaje / 880


* Ciencias Sociales

gen cspuntaje_std = .
replace cspuntaje_std = cspuntaje / 880


*** Variables de interes disponibles (facotres asociados a desempeño)

* Sexo: Ap2

gen sexo = .
replace sexo = 0 if Ap2 ==1 /* =0, varon*/
replace sexo = 1 if Ap2 ==2

label define sexo 0"Hombre" 1"Mujer"
label values sexo sexo

* Nacionalidad : Ap3a

gen argentina = .
replace argentina = 1 if Ap3a==1
replace argentina = 0 if Ap3a!=1 & Ap3a!=-1 & Ap3a!=-9

label define argentina 0"Extranjero" 1"No Extranjero"
label values argentina argentina


* Nacionalidad madre Ap3b

gen argentina_madre = .
replace argentina_madre = 1 if Ap3b==1
replace argentina_madre = 0 if Ap3b!=1 & Ap3b!=-1 & Ap3b!=-9

label define argentina_madre 0"Madre Extranjera" 1"Madre No Extranjera"
label values argentina_madre argentina_madre

* Nacionalidad padre: Ap3c

gen argentina_padre = .
replace argentina_padre = 1 if Ap3c==1
replace argentina_padre = 0 if Ap3c!=1 & Ap3c!=-1 & Ap3c!=-9

label define argentina_padre 0"Padre Extranjero" 1"Padre No Extranjero"
label values argentina_padre argentina_padre


* Nacionalidad padres (ambos argentinos)

gen arg_padres = .
replace arg_padres = 1 if argentina_madre==1 & argentina_padre==1
replace arg_padres = 0 if argentina_madre==0 & argentina_padre==0

label define arg_padres 0"Algún padre extranjero" 1"Ambos padres no extranjeros"
label values arg_padres arg_padres



* AUH: Ap6 . Mucha proporcion (17%) no sabe

gen auh = .
replace auh = 1 if Ap6==1
replace auh = 0 if Ap6==2

label define auh 0"Hogar no Recibe AUH" 1"Hogar Recibe AUH"
label values auh auh

* Nivel Educativo Padres: Ap7(madre); Ap8(padre). Las dejamos como estan, pero replace missing y "No se"
*1=prii 2=pric 3=seci 4=secc 5=supi/supc

gen edu_madre = .
replace edu_madre = 1 if Ap7==1
replace edu_madre = 2 if Ap7==2
replace edu_madre = 3 if Ap7==3
replace edu_madre = 4 if Ap7==4
replace edu_madre = 5 if Ap7==6

label define edu_madre 1"Educ. Madre: hasta prii" 2"hasta pric" 3"Educ. Madre: hasta seci" 4"Educ. Madre: hasta secc" 5"Educ. Madre: supi/supc"
label values edu_madre edu_madre

gen edu_padre = .
replace edu_padre = 1 if Ap8==1
replace edu_padre = 2 if Ap8==2
replace edu_padre = 3 if Ap8==3
replace edu_padre = 4 if Ap8==4
replace edu_padre = 5 if Ap8==6

label define edu_padre 1"Educ. Padre: hasta prii" 2"Educ. Padre: hasta pric" 3"Educ. Padre: hasta seci" 4"Educ. Padre: hasta secc" 5"Educ. Padre: supi/supc"
label values edu_padre edu_padre


* Trabaja: Ap11

gen trabaja = .
replace trabaja = 1 if Ap11==1
replace trabaja = 0 if Ap11==2

label define trabaja 0"No Trabaja" 1"Trabaja"
label values trabaja trabaja


* Hijos: Ap12

gen hijos = .
replace hijos = 1 if Ap12==1
replace hijos = 0 if Ap12==2

label define hijos 0"Sin Hijos" 1"Con Hijo/s"
label values hijos hijos


* Embarazada: Ap13

gen embarazada = .
replace embarazada = 1 if Ap13==1
replace embarazada = 0 if Ap13==2

label define embarazada 0"No Embarazada" 1"Embarazada"
label values embarazada embarazada

* Jardin: Ap14

gen jardin = .
replace jardin = 1 if Ap14>0 & Ap14<4 /*si fue alguna vez*/
replace jardin = 0 if Ap14==4

label define jardin 0"No asistió jardín" 1"Asistió jardín"
label values jardin jardin


gen anios_jardin = .
replace anios_jardin = 0 if Ap14==4
replace anios_jardin = 1 if Ap14==3
replace anios_jardin = 2 if Ap14==2
replace anios_jardin = 3 if Ap14==1

label define anios_jardin 0"No asistió jardín" 1"Un año de jardín" 2"Dos años de jardín" 3"Tres años de jardín"
label values anios_jardin anios_jardin


* Repitencia primaria: Ap15

gen repitio_prim = .
replace repitio_prim = 0 if Ap15==1
replace repitio_prim = 1 if Ap15>1 & Ap15<5 /*si repitio alguna vez*/

label define repitio_prim 0"Nunca repitió primaria" 1"Repitió primaria"
label values repitio_prim repitio_prim

* Repitencia secundaria: Ap16

gen repitio_sec = .
replace repitio_sec = 0 if Ap16==1
replace repitio_sec = 1 if Ap16>1 & Ap16<5 /*si repitio alguna vez*/

label define repitio_sec 0"Nunca repitió secundaria" 1"Repitió secundaria"
label values repitio_sec repitio_sec


* Faltas: Ap19. Las dejamos como estan, pero replace missing y "No se"

replace Ap19 = . if Ap19==-9 | Ap19==-1
rename Ap19 faltas

label define faltas 1"Menos de 8 veces" 2"8-17 veces" 3"18-24 veces" 4"Más de 24 veces"
label values faltas faltas


* Clases de Apoyo: Ap20

gen apoyo = .
replace apoyo = 1 if Ap20==1 | Ap20==2
replace apoyo = 0 if Ap20==3

label define apoyo 0"No tuvo clase apoyo" 1"Tuvo clase apoyo"
label values apoyo apoyo


* Relaciones: Ap35

gen buena_relacion = .
replace buena_relacion = 1 if Ap35==1 | Ap35==2
replace buena_relacion = 0 if Ap35==3 | Ap35==4

label define buena_relacion 0"No tiene buena relación" 1"Tiene buena relación"
label values buena_relacion buena_relacion

* Uso de computadora en el aula: Ap46a Las dejamos como estan, pero replace missing y "No se"

gen uso_pc_aula=.
replace uso_pc_aula = 1 if Ap47a==4
replace uso_pc_aula = 2 if Ap47a==3
replace uso_pc_aula = 3 if Ap47a==2
replace uso_pc_aula = 4 if Ap47a==1

label define uso_pc_aula 1"Al menos una vez por semana" 2"Algunas veces en el mes" 3" Algunas veces en el año" 4"Nunca"
label values uso_pc_aula uso_pc_aula



* Uso de computadora en el salon de informatica: Ap46b Las dejamos como estan, pero replace missing y "No se"

gen uso_pc_sala=.
replace uso_pc_sala = 1 if Ap47b==4
replace uso_pc_sala = 2 if Ap47b==3
replace uso_pc_sala = 3 if Ap47b==2
replace uso_pc_sala = 4 if Ap47b==1

label define uso_pc_sala 1"Al menos una vez por semana" 2"Algunas veces en el mes" 3" Algunas veces en el año" 4"Nunca"
label values uso_pc_sala uso_pc_sala


* Docencia: te gustaria ser docente?: No disponible en la base de datos

* Privado: sector

gen privado = .
replace privado = 1 if sector==2
replace privado = 0 if sector==1

label define privado 0"Sector Público" 1"Sector Privado"
label values privado privado


* Urbano: ambito

gen urbano = .
replace urbano = 1 if ambito==1
replace urbano = 0 if ambito==2

label define urbano 0"Rural" 1"Urbano"
label values urbano urbano

* NBI: 3 categ: Bajo (0-10); Medio(10-20); Alto(+20)

gen nbi = .
replace nbi = 1 if share_nbi>0 & share_nbi<=0.1
replace nbi = 2 if share_nbi>0.1 & share_nbi<=0.2
replace nbi = 3 if share_nbi>0.2

label define nbi 1"NBI Bajo" 2"NBI Medio" 3"NBI Alto"
label values nbi nbi



* Indice emotivo: iemotivol; iemotivom
* Indice Clima Escolar: iclimal; iclimam
* Vulnerabilidad: qvulneraa
* Socioeconomico : isocioal; isocioam


* Indicadores emotivos y de clima tienen problema con missing ==-1

loc reemp = " isocioa iemotivo iclima isocioal iemotivol iclimal isocioam iemotivom iclimam qvulneraa isocioacn iemotivocn iclimacn isocioacs iemotivocs iemotivocs iclimacs"

foreach var of local reemp{

	replace `var' = . if `var' ==-1

}

* Redondeo ponderadores

replace lpondera = round(lpondera)
replace mpondera = round(mpondera)
replace cnpondera = round(cnpondera)
replace cspondera = round(cspondera)


*** Variables de interes disponibles (facotres asociados a desempeño)
*** Director

* Sexo Director (Mujer=1)

gen sexo_dir = .
replace sexo_dir = 1 if Dp1==1
replace sexo_dir = 0 if Dp1==2

label define sexo_dir 0"Director Hombre" 1"Directora Mujer"
label values sexo_dir sexo_dir

* Antiguedad en el cargo/docente (Baja=hasta 5 años; Media=Hasta 10 años; Alta: +10 años)

gen antigue_cargo=.
replace antigue_cargo =1 if Dp3a>0 & Dp3a<=5
replace antigue_cargo =2 if Dp3a>5 & Dp3a<=10
replace antigue_cargo =3 if Dp3a>10 

label define antigue_cargo 1"Antiguedad Cargo Baja" 2"Antiguedad Cargo Media" 3"Antiguedad Cargo Alta"
label values antigue_cargo antigue_cargo

gen antigue_docente=.
replace antigue_docente =1 if Dp3c>0 & Dp3c<=5
replace antigue_docente =2 if Dp3c>5 & Dp3c<=10
replace antigue_docente =3 if Dp3c>10 

label define antigue_docente 1"Antiguedad Docente Baja" 2"Antiguedad Docente Media" 3"Antiguedad Docente Alta"
label values antigue_docente antigue_docente

* Dummmy titulo universitario

gen universitario = .
replace universitario = 1 if Dp4c==1 | Dp4e==1 | Dp4g==1 | Dp4i==1
replace universitario = 0 if Dp4a==1 | Dp4b==1 | Dp4d==1 | Dp4f==1 | Dp4h==1

label define universitario 0"Director Sin Título Univ." 1"Director Con Título Univ."
label values universitario universitario


* Dedicacion en horas semanales (Baja:hasta 24 hs semanales / Media: 25-29/ Alta:30+)

gen dedicacion = .
replace dedicacion =1 if Dp6==1 | Dp6==2
replace dedicacion =2 if Dp6==3
replace dedicacion =3 if Dp6==4

label define dedicacion 1"Dedicación Baja" 2"Dedicación Media" 3"Dedicación Alta"
label values dedicacion dedicacion


* Servicios con que cuenta la escuela. Bajo: 0,1,2 / Medio:3,5 /Alto:5,6

loc list = " Dp17a Dp17b Dp17c Dp17d Dp17e Dp17f" 

foreach var of loc list {

	replace `var' = . if `var'==-1
	
	replace `var' = 0 if `var'==2
	
}

egen aux = rowtotal(Dp17a Dp17b Dp17c Dp17d Dp17e Dp17f)

gen servicios = .
replace servicios = 1 if aux<=2
replace servicios = 2 if aux>2 & aux<=4
replace servicios = 3 if aux>5 & aux<=6

label define servicios 1"Servicios alumno Baja" 2"Servicios alumno Media" 3"Servicios alumno Alta"
label values servicios servicios


* Infraestructura escolar (edificio, aulas, biblioteca, mobiliario)
* =1 si reporta bueno/muy bueno/muy

gen edificio = .
replace edificio = 1 if  Dp20a==4 | Dp20a==5
replace edificio = 0 if  Dp20a==1 | Dp20a==2 | Dp20a==3

label define edificio 0"Edificio Inadecuado" 1"Edificio Adecuado"
label values edificio edificio


gen aulas = .
replace aulas = 1 if  Dp20b==4 | Dp20b==5
replace aulas = 0 if  Dp20b==1 | Dp20b==2 | Dp20b==3

label define aulas 0"Aulas Inadecuadas" 1"Aulas Adecuadas"
label values aulas aulas


gen biblioteca = .
replace biblioteca = 1 if  Dp20c==4 | Dp20c==5
replace biblioteca = 0 if  Dp20c==1 | Dp20c==2 | Dp20c==3

label define biblioteca 0"Biblioteca Inadecuada" 1"Biblioteca Adecuada"
label values biblioteca biblioteca

gen mobiliario = .
replace mobiliario = 1 if  Dp20d==4 | Dp20d==5
replace mobiliario = 0 if  Dp20d==1 | Dp20d==2 | Dp20d==3

label define mobiliario 0"Mobiliario Inadecuada" 1"Mobiliario Adecuada"
label values mobiliario mobiliario


* Bullying

gen bullying = .
replace bullying = 1 if Dp38d==1 | Dp38d==1
replace bullying = 0 if Dp38d==3

label define bullying 0"No sufrió Bullying" 1"Sufrió Bullying"
label values bullying bullying

* Disponibilidad de Computadoras suficiente

gen computadora = .
replace computadora = 1 if Dp47a1==1 & Dp47a2==1
replace computadora = 0 if Dp47a1==2 | Dp47a2==2

label define computadora 0"Computadoras Insuficientes" 1"Computadoras Suficientes"
label values computadora computadora

* Acceso a Internet en la escuela

gen internet = .
replace internet = 1 if Dp51==1 & Dp54==1
replace internet = 0 if Dp51==0 | Dp54==2 | Dp54==3 | Dp54==4 | Dp54==5

label define internet 0"Escuela Sin Internet" 1"Escuela Con Internet"
label values internet internet

* Capacitacion

gen capacitacion = .
replace capacitacion = 1 if Dp55a1==1 | Dp55b1==1
replace capacitacion = 0 if Dp55a1==2 | Dp55b1==2

label define capacitacion 0"No hubo Capacit. docente" 1"Hubo Capacit. Docente"
label values capacitacion capacitacion

* Dias en que se dictaron clases (Cuartiles de dias)

xtile cuart_dias_clase = Dp21 if Dp21>0, n(4)

label define cuart_dias_clase 1"Cuartil 1 Dias Clase" 2"Cuartil 2 Dias Clase" 3"Cuartil 3 Dias Clase" 4"Cuartil 4 Dias Clase"
label values cuart_dias_clase cuart_dias_clase


* Conectar Igualdad (dummy si mas del 50% de la escuela recibio)

gen conectar_igualdad = .
replace conectar_igualdad = 1 if Dp46a==3 | Dp46a==4
replace conectar_igualdad = 0 if Dp46a==1 | Dp46a==2

label define conectar_igualdad 0"Conect Igualdad: -50% alumnos" 1"Conect Igualdad: +50% alumnos"
label values conectar_igualdad conectar_igualdad



save "$bases\base_56anio_alum_dir.dta", replace

