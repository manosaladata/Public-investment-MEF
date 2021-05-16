#
# Observatorio de Inversión Pública-SIAF-MEF
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinyWidgets) #numericRangeInput()
#library(shinydashboard)
library(semantic.dashboard)
library(plotly)
library(DT)
#library(lubridate)
library(tidyverse)

#iconos:https://fontawesome.com/icons?d=listing&p=8&m=free

#Esta primera parte es limpieza de datos
DataGR <- readRDS("Data/InversionTotalDepa.rds")
DataGR[,c(2:8)] <- sapply(DataGR[,c(2:8)], function(x) str_remove_all(x,pattern = ","))
DataGR[,c(2:8)] <- sapply(DataGR[,c(2:8)], function(x) round(as.numeric(x)/1000000,3)) #Convertir en millones de soles
DataGR <- DataGR%>%
  separate(col = 1,into = c("Codigo_Pliego","G_Regional"),sep = ": ")

DataGR[,2] <- sapply(DataGR[,2],function(x) str_to_title(x,locale = "sp")) #en
DataGR[,2] <- sapply(DataGR[,2],function(x) str_replace_all(x,pattern = "Provincia Constitucional Del Callao",
                                                            replacement = "Callao"))
#DataGR[,2] <- sapply(DataGR[,2],function(x) factor(x,
#                                                   levels =unique(DataGR$G_Regional)))

DataGR[,2] <- sapply(DataGR[,2],function(x) as.character(x))


