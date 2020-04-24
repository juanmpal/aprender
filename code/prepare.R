#This script:
#Datawrangling

library(tidyverse)
library(tidyselect)
library(haven)
library(here)
library(janitor) #examining and cleaning data

data <- "C:/research/aprender/data/"

base_raw <- read_dta(paste0(data,"raw/base_6grado_alum_dir_2016.dta"))


#Dummy women
base <- base_raw %>%
	mutate(women = case_when(Ap2 == 1 ~ 0,
	                         Ap2 == 2 ~ 1))

##Women per class
#Reference variables:
  #CUEANEXO: school id
  #seccion: class id
base <- base %>%
  group_by(CUEANEXO,seccion) %>%
  mutate(totwomen=sum(women, na.rm=TRUE)) %>%
  mutate(ltotwomen=log(totwomen))
base <- base[!is.na(base$women),]


#school, class and student id  
base <- base %>%
  mutate(idschool = as_factor(CUEANEXO))
base$idschool <- as.numeric(base$idschool)

base <- base %>%
  mutate(idclass = as_factor(seccion))
base$idclass <- as.numeric(base$idclass)

base <- base %>%
 group_by(idclass) %>%
 mutate(idstudent = row_number())

#Province code to numeric
base <- base %>%
  mutate(region = as_factor(cod_provincia))
base$region <- as.numeric(base$region)

#Sorting
base <- base %>%
  arrange(idschool,idclass,idstudent) %>%
  select(idschool,idclass,idstudent,region,everything())

#Keep schools with more than one class
base <- base %>%
  mutate(aux_classes = case_when(idstudent == 1 ~ 1)) %>%
  group_by(idschool) %>%
  mutate(totclasses = sum(aux_classes, na.rm=TRUE))
base <- base[(base$totclasses>1 & !is.na(base$totclasses)),]

#Class size
base <- base %>%
  group_by(idclass) %>%
  mutate(class_size = max(idstudent))

#Average score of peers
base <- base %>%
  group_by(idclass) %>%
  mutate(peers_score_m = sum(mpuntaje_std)) %>%
  mutate(peers_score_m = (peers_score_m - mpuntaje_std)/(class_size - 1)) %>%
  mutate(peers_score_l = sum(lpuntaje_std)) %>%
  mutate(peers_score_l = (peers_score_l - lpuntaje_std)/(class_size - 1))



#----------------------------------#
# Average characteristics of peers #
#----------------------------------#

peer_vars <- c("women","edu_madre", "edu_padre", "trabaja", "anios_jardin",
			   "repitio", "apoyo", "buena_relacion","auh")

#Keep variables of interest
base <- base %>%
	select(idschool,idclass,idstudent,region,privado,urbano,nbi,class_size,
		   mpuntaje_std, lpuntaje_std, peers_score_m,peers_score_l,
		   !!!peer_vars)


#Function that generates peer average of var (not including own value)
peer_var_gen <- function(data, group_var, peer_var_list) {

	group_var <- enquo(group_var)
	data <- data %>%
		group_by(!!group_var)
	
	for (var in peer_var_list) {
		peer_var <- paste0("peer_",var)
		peer_var <- sym(peer_var)
		var <- sym(var)
		data <- data %>%
 			mutate(!!peer_var := sum(!!var, na.rm=TRUE)) %>%
 			mutate(!!peer_var := (!!peer_var - !!var)/(class_size-1))
 	}

 	data <- data %>%
 		ungroup()

}	

system.time(
base <- peer_var_gen(base, idclass, peer_vars)
)

write.csv(base,paste0(data,"analytical/base_6grado_2016.csv"))

