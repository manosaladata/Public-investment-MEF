# Limpieza de datos de inversión pública-Transparencia económica MEF
rm(list = ls())
cat("\014")

library(tidyverse)

setwd("C:/Users/Jose Luis/Documents/GitHub/Public-investment-MEF/Data")

#---- Gobierno nacional #----
DataGNs<-read_rds("EG_GN.rds")
sapply(DataGNs, class)          #vemos la estructura de los datos
#Duplicamos los datos de una variable, y luego limpiamos (Tambien con mutate se puede crear)
DataGNs$Sectores<-DataGNs$Sector
DataGNs$Sectores<-DataGNs$Sectores%>%
  str_remove_all(pattern ="[:digit:]" )%>%
  str_remove_all(pattern = "[:punct:]")%>%
  str_trim() #Limpiamos

#Convertimos en formato título 
DataGNs$Sectores<-DataGNs$Sectores%>%
  str_to_title(locale = "sp")

#Eliminamos las comas, también podría ser reemplazado por nada
DataGNs[,c(2:8)]<-sapply(DataGNs[,c(2:8)],function(x) str_remove_all(x,pattern =","))
#Convertir character a numérico
DataGNs[,c(2:8)]<-sapply(DataGNs[,c(2:8)],function(x) round(as.numeric(x),2))
#Convertimos en millones 
DataGNs[,c(2:8)]<-sapply(DataGNs[,c(2:8)],function(x) round(x/1000000,2))
#Guardamos las data limpia
saveRDS(DataGNs,file = "EG_GN.rds")

#Cargamos los proyectos del gobierno nacional y limpiamos

DataProyectoGN<-read_rds("ProductoProyectoGN.rds")
#Creamos una variable con los datos de los proyectos
names(DataProyectoGN)
DataProyectoGN$Proyecto<-DataProyectoGN$ProductoProyecto
#Limpiar los números de la variable proyecto y convertir en formato oración
DataProyectoGN$Proyecto<-DataProyectoGN$Proyecto%>%
  str_remove_all(pattern = "[:digit:]")%>%
  str_remove_all(pattern = "[:punct:]")%>%
  str_trim()%>%
  str_to_sentence(locale = "sp") #español

#Convertimos a formato título la variable sector
DataProyectoGN$Sector<-DataProyectoGN$Sector%>%
  str_to_title(locale = "sp")

# Eliminamos las comas, y luego convertirlo en numérico
DataProyectoGN[,c(2:8)]<-sapply(DataProyectoGN[,c(2:8)],function(x) str_remove_all(x,pattern =","))
#Convertir character a numérico
DataProyectoGN[,c(2:8)]<-sapply(DataProyectoGN[,c(2:8)],function(x) round(as.numeric(x),2))
#Convertimos en millones 
DataProyectoGN[,c(2:8)]<-sapply(DataProyectoGN[,c(2:8)],function(x) round(x/1000000,2))

#Guardamos la data limpia de proyectos de GN
saveRDS(DataProyectoGN,file = "DataProyectosGN.rds")

#---- Gobiernos regionales #----

DataGRs<-read_rds("EG_GR.rds")
# Creamos una variable con los datos de pliego, para extraer región
DataGRs$'Gobierno Regional'<-DataGRs$Pliego

Limpiar<-c("[[:digit:]]",": GOBIERNO REGIONAL DEL DEPARTAMENTO DE",
           ": GOBIERNO REGIONAL DE LA PROVINCIA CONSTITUCIONAL DEL",
           ": MUNICIPALIDAD")

Limpiar<-str_c(Limpiar,collapse = "|")

#DataGRs<-DataGRs%>%
 # mutate(Region=Pliego)

DataGRs$`Gobierno Regional`<-DataGRs$`Gobierno Regional`%>%
  str_remove_all(pattern = Limpiar)%>%
  str_trim()%>%
  str_to_title(locale = "sp")

# Eliminamos las comas, para convertir character a numérico de algunas columnas

DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) str_remove_all(x,pattern = ","))
sapply(DataGRs, class)
# Convertir chacarter a numérico
DataGRs$PIA
DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) round(as.numeric(x),2))
sapply(DataGRs, class)

# Convertimos los datos en millones de soles
DataGRs[,c(2:8)] <- sapply(DataGRs[,c(2:8)],function(x) round(x/1000000,2))

# Proyectos de gobiernos regionales
DataProyectosGR<-read_rds(file = "ProyectosGR.rds")

#creamos la variable Proyectos a partir producto/proyecto
DataProyectosGR$Proyecto<-DataProyectosGR$ProductoProyecto

#Limpiamos la variable proyectos
DataProyectosGR$Proyecto<-DataProyectosGR$Proyecto%>%
  str_remove_all(pattern = "[:digit:]")%>%
  str_remove_all(pattern = ":")%>%
  str_trim()%>%
  str_to_sentence()

#Eliminamos las comas, para convertir a numérico los datos
DataProyectosGR[,c(2:8)]<-sapply(DataProyectosGR[,c(2:8)],function(x) str_remove_all(x,","))
#Convertimos a numérico los datos
DataProyectosGR[,c(2:8)]<-sapply(DataProyectosGR[,c(2:8)],function(x) round(as.numeric(x),2))
#Coonvertimos en millones
DataProyectosGR[,c(2:8)]<-sapply(DataProyectosGR[,c(2:8)], function(x) round(x/1000000,2))

#Guardamos las información limpia
saveRDS(DataProyectosGR,file ="DataProyectosGR.rds")
#---- Gobiernos locales #----


