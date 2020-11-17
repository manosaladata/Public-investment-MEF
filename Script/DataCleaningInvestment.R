# Limpieza de datos de inversión pública-Transparencia económica MEF
library(tidyverse)

setwd("C:/Users/Jose Luis/Documents/GitHub/Public-investment-MEF/Data")
#---- Gobiernos regionales #----
DataGRs<-read_rds("InversionPublicaGRs.rds")
# Creamos un vector de string para limpiar
#DataGRs$Pliego
Limpiar<-c("[[:digit:]]",": GOBIERNO REGIONAL DEL DEPARTAMENTO DE",
           ": GOBIERNO REGIONAL DE LA PROVINCIA CONSTITUCIONAL DEL",
           ": MUNICIPALIDAD")

Limpiar<-str_c(Limpiar,collapse = "|")

DataGRs<-DataGRs%>%
  mutate(Region=Pliego)

DataGRs$Region<-DataGRs$Region%>%
  str_remove_all(pattern = Limpiar)%>%
  str_trim()

# Reemplazamos las comas por nada, para convertir character a numérico de algunas columnas

DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) str_replace_all(x,pattern = ",",""))
sapply(DataGRs, class)
# Convertir chacarter a numérico
DataGRs$PIA
DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) round(as.numeric(x),2))
sapply(DataGRs, class)

# Convertimos los datos en millones de soles
DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) round(x/1000000,3))


