#This script:
#Datawrangling

library(here)
library(tidyverse)
library(haven)
library(ggplot2)
library(openxlsx)

base_56anio_alum_dir_2016 <- read_dta("C:/research/aprender/data/raw/base_6grado_alum_dir_2016.dta")
#base_56anio_alum_dir_2016 <- read_dta("raw/base_56anio_alum_dir_2016.dta")
#base_56anio_alum_dir_2017 <- read_dta(here("data","raw","base_56anio_alum_dir_2017.dta"))



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



