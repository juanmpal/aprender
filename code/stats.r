#-----------------------------
#This script:
# 1)Descr stats 
# 2)Tables
# 3)Regressions
#-----------------------------

library(tidyverse)
library(tidyselect)
library(here)
library(haven) #read dta
library(plm) #panel data models
library(stargazer) #output to latex
library(janitor) #examining and cleaning data
library(pastecs) #descriptive statistics



#--------#
# Inputs #
#--------#


data <- "C:/research/aprender/data/"

base <- read.csv(paste0(data,"analytical/base_6grado_2016.csv"))
base <- base[,-1]



#---------------------------------------------------#
# 				1. Descriptive Statistics 			#
#---------------------------------------------------#



#one way to do it
descr <- stargazer(base[,-(1:4)], 
			summary.stat = c("mean","sd"),
			summary.logical = FALSE,
			align = TRUE,
			digits = 2,
			title = "Descriptive statistics",
			notes = "Coefs usuales",
			out = "output/tables/descr.tex")

# #equivalent
# descr2 <- stat.desc(base[,-(1:5)], basic=TRUE)
# descr2 <- descr2[c("mean","std.dev"),]

# descr2_table <- stargazer(descr2,
# 					summary = FALSE,
# 					summary.logical = FALSE,
# 					align = TRUE,
# 					digits = 2,
# 					flip = TRUE,
# 					title = "Descriptive statistics",
# 					notes = "Coefs usuales",
# 					out = "output/tables/descr2.tex")

# #equivalent
# descr3 <- base %>%
# 	summarise_at(-(1:5), funs(mean,sd), na.rm = TRUE) %>%
# 	pivot_longer(
# 		everything(),
# 		names_to = c("variable","stat"),
# 		names_sep = "_(?=[^_]+$)",
# 		values_to = "value") %>% 
#  	pivot_wider(
#  		id_cols = "variable",
#  		names_from = "stat",
#  		values_from = "value")


#-----------------------------------------------#
# 				2. Graphs	 					#
#-----------------------------------------------#




g_density_m <- ggplot(base, aes(x=mpuntaje_std))+
				geom_density(color="darkblue", fill="lightblue")
plot(g_density_m)

g_density_l <- ggplot(base, aes(x=lpuntaje_std))+
				geom_density(color="red", fill="pink")
plot(g_density_l)




#-----------------------------------------------#
# 				3. Regressions 					#
#-----------------------------------------------#

observables <- c("region","privado","urbano","nbi","class_size")

peer_vars <- c("women","edu_madre", "edu_padre", "trabaja", "anios_jardin",
			   "repitio", "apoyo", "buena_relacion","auh")

peer_avgs <- c("peer_women","peer_edu_madre","peer_edu_padre","peer_trabaja",
			   "peer_repitio","peer_apoyo","peer_buena_relacion","peer_auh")

fe_model <- plm(mpuntaje_std ~ log(peers_score_m) + observables +
				!!!peer_vars + !!!peer_avgs,
				data = base,
				index = "idclass") 


