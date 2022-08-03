#
# Observatorio de Inversión Pública-SIAF-MEF
#
#
#
library(shiny)
#library(shinyWidgets) #numericRangeInput()
library(shinydashboard)
#library(semantic.dashboard)
library(plotly)
library(DT)
library(lubridate)
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

#DataGR[,2] <- sapply(DataGR[,2],function(x) as.character(x))
DataGR <- DataGR%>%
  mutate(Year=as.Date(paste0(Year,"-01-01", sep = "",format='%Y-%b-%d')))

DataGR <- DataGR%>%
  select(-c(1))%>%
  select(10,everything())
#sapply(DataGR, class)

#Cargamos la data del porta de datos abiertos del MEF
# DataInversion <- read.csv(file = "ShinyAppSIAF/Data/DETALLE_INVERSIONES.csv")
# names(DataInversion)
# unique(DataInversion$PRIOR_GN)
# table(DataInversion$PRIOR_GN)
# unique(DataInversion$PRIOR_GR)
# table(DataInversion$PRIOR_GR)
# unique(DataInversion$PRIOR_GL)
# table(DataInversion$PRIOR_GL)

#---- Personalizamos nuestro sidebar #----

library(fresh)
# Create the theme
mytheme <- create_theme(
  adminlte_sidebar(
    width = "250px",
    dark_bg = "#D8DEE9",
    dark_hover_bg = "#81A1C1",
    dark_color = "#001F3F",
    dark_submenu_bg = "#4682B4", #81A1C1
    dark_submenu_color="#001F3F"
    #dark_submenu_hover_color = "#81A1C1",
    #light_bg="#000000"
  )
)
##---- Personalizar los valueBox #----

valueBox2 <- function (value, subtitle, icon = NULL, 
                       backgroundColor = "#7cb5ec", 
                       textColor = "#FFF", width = 3, 
                       href = NULL)
  {
  
  boxContent <- div(
    class = paste0("small-box"),
    style = paste0("background-color: ", backgroundColor, "; color: ", textColor, ";"),
    div(
      class = "inner",
      h3(value),
      p(subtitle)
    ),
    if (!is.null(icon)) {
      div(class = "icon-large", icon)
    }
  )
  if (!is.null(href)) {
    boxContent <- a(href = href, boxContent)
  }
  div(
    class = if (!is.null(width)) paste0("col-sm-", width),
    boxContent
  )
}