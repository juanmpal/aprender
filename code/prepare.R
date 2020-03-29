#This script:
#Datawrangling

library(tidyverse)
library(tidyselect)
library(haven)
library(here)

data <- "C:/research/aprender/data/"

base_56anio_alum_dir_2016 <- read_dta(paste0(data,"raw/base_6grado_alum_dir_2016.dta"))


#Dummy women
base <- base_56anio_alum_dir_2016 %>%
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

#Sorting
base <- base %>%
  arrange(idschool,idclass,idstudent) %>%
  select(idschool,idclass,idstudent,everything())

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

#Average characteristics of peers
peer_vars <- c("edu_madre", "edu_padre", "trabaja", "anios_jardin", "repitio", "apoyo", "buena_relacion")

grouped_base <- base %>%
	select(idschool,idclass,idstudent,class_size,!!!peer_vars)

 for (var in peer_vars){
 	peer_var <- paste0("peer_",var)
 	grouped_base <- grouped_base %>%
 	mutate(!!sym(peer_var) := sum(!!sym(var), na.rm=TRUE)) %>%
 	mutate(!!sym(peer_var) := (!!sym(peer_var) - !!sym(var))/(class_size-1))
 }

peer_vars_avg <- c("peer_edu_madre", "peer_edu_padre", "peer_trabaja", "peer_anios_jardin", "peer_repitio",
					"peer_apoyo", "peer_buena_relacion")

grouped_base <- grouped_base %>%
	ungroup()

write.csv(grouped_base,paste0(data,"analytical/base_6grado_2016"))

