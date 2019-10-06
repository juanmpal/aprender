#This script:
#Transforms data into r format

rm(list=ls())


library(tidyverse)
library(haven)
library(ggplot2)
library(openxlsx)
library(readxl)

wd <- "C:/Users/juanc/Google Drive/research/aprender"

setwd(wd)

base_3grado_alum_dir <- read_dta("data/raw/base_3grado_alum_dir.dta")




