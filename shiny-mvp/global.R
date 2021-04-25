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
# DataGR <- readRDS("ShinyInversionPublica/Data/InversionTotalDepa.rds")
# DataGR <- readRDS("D:/ABCN/Github/Public-investment-MEF/ShinyInversionPublica/Data/InversionTotalDepa.rds")

DataGR[,c(2:8)] <- sapply(DataGR[,c(2:8)], function(x) str_remove_all(x,pattern = ","))
DataGR[,c(2:8)] <- sapply(DataGR[,c(2:8)], function(x) round(as.numeric(x)/1000000,3)) #Convertir en millones de soles
DataGR <- DataGR%>%
    separate(col = 1,into = c("Codigo_Pliego","G_Regional"),sep = ": ")

DataGR[,2] <- sapply(DataGR[,2],function(x) str_to_title(x,locale = "sp")) #en
DataGR[,2] <- sapply(DataGR[,2],function(x) str_replace_all(x,pattern = "Provincia Constitucional Del Callao",
                                                            replacement = "Callao"))
DataGR[,2] <- sapply(DataGR[,2],function(x) as.character(x))
# DataGR$G_Regional <- as.factor(DataGR$G_Regional,)
DataGR$G_Regional <- factor(DataGR$G_Regional,levels = unique(DataGR$G_Regional))
# DataGR$G_Regional
# ?factor
# names(DataGR)
#DataGR[,11] <- sapply(DataGR[,11],function(x) as.numeric(x))

#sapply(DataGR, class)
#table(DataGR$G_Regional)
#?icon()
# Define UI for application 
#skin = "blue", ó theme = "slate",
