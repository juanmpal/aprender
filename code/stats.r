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
library(data.table)
library(xtable)



#--------#
# Inputs #
#--------#


data <- "C:/research/aprender/data/"
base_list <- c("6grado","56anio")

#base <- read.csv(paste0(data,"analytical/base_6grado_2016.csv"))
#base <- read.csv(paste0(data,"analytical/base_56anio_2016.csv"))
#base <- base[,-1]



#---------------------------------------------------#
# 				1. Descriptive Statistics 			#
#---------------------------------------------------#

for (eachbase in base_list) {

 	base <- read.csv(paste0(data,"analytical/base_",eachbase,"_2016.csv"))
 	base <- base[,-1]

 	descr <- stat.desc(base[,c("privado","urbano","nbi",
		"class_size","women","edu_madre","trabaja","anios_jardin","repitio","apoyo",
		"buena_relacion","mpuntaje_std","lpuntaje_std")], basic=TRUE)
	descr <- descr[c("mean","std.dev"),]

	descr <- transpose(descr)

	N <- c(sum(unique(base["idschool"])), sum(unique(base["idclass"])), sum(base))

	descr[nrow(descr)+1,1] <- sum(unique(base["idschool"]))
	descr[nrow(descr)+1,1] <- sum(unique(base["idclass"]))
	descr[nrow(descr)+1,1] <- sum(base)

	assign(paste0("descr_",eachbase),descr)


}

descr <- merge(descr_6grado,descr_56anio, by="row.names")
descr <- arrange(descr,Row.names)
descr <- descr[,-1]
rownames(descr) <- c("Private School","Urban","NBI","Class size",
 				"Gender (women=1)","Mother's educ", "Occupied","Years of Kinder",
 				"Repeated grade","School support", "Good relation",
 				"Std Score Math", "Std Score Languaje","N schools","N classes",
 				"N students")
colnames(descr) <- c("Mean","SD","Mean","SD")


addtorow <- list()
addtorow$pos <- list(0,0)
addtorow$command <- c("& \\multicolumn{2}{c}{\\underline{6th grade}} & 
						\\multicolumn{2}{c}{\\underline{5th and 6th year}} \\\\",
						"& Mean & SD & Mean & SD \\\\")

descr <- xtable(descr)
align(descr) = "lcccc"

print(descr,
	add.to.row = addtorow,
	include.colnames = FALSE,
	file = "output/tables/descrmerge.tex")


	# stargazer(descr,
 # 		summary = FALSE,
 # 		summary.logical = FALSE,
 # 		align = TRUE,
 # 		digits = 2,
 # 		title = "Descriptive statistics",
 # 		notes = "Coefs usuales",
 # 		out = "output/tables/descrmerge.tex")



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




# g_density_m <- ggplot(base, aes(x=mpuntaje_std))+
# 				geom_density(color="darkblue", fill="lightblue")
# plot(g_density_m)

# g_density_l <- ggplot(base, aes(x=lpuntaje_std))+
# 				geom_density(color="red", fill="pink")
# plot(g_density_l)




# #-----------------------------------------------#
# # 				3. Regressions 					#
# #-----------------------------------------------#

# observables <- c("region","privado","urbano","nbi","class_size")

# peer_vars <- c("women","edu_madre", "edu_padre", "trabaja", "anios_jardin",
# 			   "repitio", "apoyo", "buena_relacion","auh")

# peer_avgs <- c("peer_women","peer_edu_madre","peer_edu_padre","peer_trabaja",
# 			   "peer_repitio","peer_apoyo","peer_buena_relacion","peer_auh")

# fe_model <- plm(mpuntaje_std ~ log(peers_score_m) + observables +
# 				!!!peer_vars + !!!peer_avgs,
# 				data = base,
# 				index = "idclass") 


