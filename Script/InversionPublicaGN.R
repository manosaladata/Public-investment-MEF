#Proyectos de inversión pública - gobiernos nacionales

library(tidyverse)
library(readxl)
library(xml2)
library(rvest)
library(RSelenium)
library(wdman)
library(robotstxt)

#Nuestro directorio

setwd("C:/Users/Jose Luis/Documents/GitHub/Public-investment-MEF/Data")
#---- Rselenium y rvest #----

#URL DE CONSULTA AMIGABLE -TRANSFERENCIA ECONÓMICA -PERÚ
URLm<-"https://apps5.mineco.gob.pe/transparencia/mensual/default.aspx?y="   # Actualización mensual
#URLd<-"https://apps5.mineco.gob.pe/transparencia/navegador/default.aspx?y=" #Actualización diaria

# Para seguimiento de proyectos de inversión:
#https://www.gob.pe/802-seguimiento-de-la-ejecucion-presupuestal-consulta-amigable
#"https://apps5.mineco.gob.pe/bingos/seguimiento_pi/Navegador/default.aspx?y="

#paths_allowed(paths = c(URL)) # debió decir TRUE

options(encoding = "utf-8") # Le asignamos el encoding

#Abrimos una sesion en la web
# Ejecutamos el servidor phantomjs -creamos un navegador fantasma

server<-phantomjs(port=5012L)
#Abrimos el navegador
Browser <- remoteDriver(browserName = "phantomjs", port=5012L)
Browser$open()

#Navegar la página web que guardamos indicandole los años y tipo de información
# Años
Years<-c(2010:2020)
Years[11]
#Tipo de informacíon
TipoInfo<-c("ActProy","Actividad","Proyecto") #Actividades/Proyectos, sólo actividades, sólo proyectos
TipoInfo[3]
#Navegamos
Browser$navigate(paste0(URLm,Years[11],"&ap=",TipoInfo[3]))
Browser$screenshot(display=TRUE)

#Ubicamos el frame donde están los botones
frame0<-Browser$findElement(value='//*[@id="frame0"]')
#Activamos el Frame
Browser$switchToFrame(frame0)

# Hacer clic en niveles de gobierno
NivelesGobierno<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_BtnTipoGobierno") #Es Id
NivelesGobierno$clickElement()
Browser$screenshot(display=TRUE) # si salío 

#Hacer clic en opción de E:Gobierno Nacional
GobiernoNacional<-Browser$findElement(using = "css",
                                      value = "#ctl00_CPH1_RptData_ctl01_TD0") #Es Id
GobiernoNacional$clickElement()
Browser$screenshot(display=TRUE) # 

# Hacer clic en sector
Sector<-Browser$findElement(using = "css",
                            value = "#ctl00_CPH1_BtnSector") #Es Id
Sector$clickElement()
Browser$screenshot(display=TRUE) # 

#Decirle que actúe sobre la página actual para rasparlo
Pagina_actual<-Browser$getPageSource()

#escrapeamos la información de todas las regiones
Pagina<-read_html(Pagina_actual[[1]]) # en el elemento 1 de la lista está la url de la página actual

EGNacional<-Pagina%>%
  html_node(css = "#ctl00_CPH1_UpdatePanel1")%>% #ctl00_CPH1_UpdatePanel1
  html_node(css = ".Data")%>%
  html_table(header = F)

#Cambiamos los nombres de las variables
names(EGNacional)[2:10]<-c("Sector","PIA","PIM","Certificación","CompAnual",
                          "AtenDeComprMensual","Devengado","Girado","Avance%")
EGNacional<-EGNacional[,-1]             #Nos quedamos con las variables que tienen información1
EGNacional$FechaDeConsulta<-Sys.Date() # Añadimos la fecha de consulta

#Guardamos la información
saveRDS(EGNacional,file = "EG_GN.rds")
# Extraemos los proyectos de inversión pública de todos los sectores
#Para acceder a cada Sector
EGNacional$Sector

#ID para acceso
#ctl00_CPH1_RptData_ctl01_TD0 #PCM
#ctl00_CPH1_RptData_ctl02_TD0 #Cultura
#ctl00_CPH1_RptData_ctl03_TD0 #PJ ...
#ctl00_CPH1_RptData_ctl26_TD0 #Desarrollo e inclusión social

#---- Hcer clic en PRESIDENCIA CONSEJO MINISTROS #----
#   Ejemplo
PCM<-Browser$findElement(using = "css",
                              value = "#ctl00_CPH1_RptData_ctl01_TD0") #Es Id
PCM$clickElement()
Browser$screenshot(display=TRUE) 

# Hacer clic en Producto/Proyecto
ProdProyec<-Browser$findElement(using = "css",
                                value = "#ctl00_CPH1_BtnProdProy") #Es Id
ProdProyec$clickElement()
Browser$screenshot(display=TRUE)

#Raspamos información de Proyectos
#Nuevamente decirle que actúe sobre página actual
Pagina_actual<-Browser$getPageSource()

Pagina<-read_html(Pagina_actual[[1]])

Proyectos<-Pagina%>%
  html_node(css = "#ctl00_CPH1_UpdatePanel1")%>%
  html_node(css = ".Data")%>%
  html_table(header = F,fill=T)

#Cambiamos los nombres de las variables
names(Proyectos)[2:10]<-c("ProductoProyecto","PIA","PIM","Certificación","CompAnual",
                          "AtenDeComprMensual","Devengado","Girado","Avance%")
Proyectos<-Proyectos[,-1] #Nos quedamos con las variables que tienen información
Proyectos<-Proyectos[!Proyectos$ProductoProyecto=="Ficha de Proyecto",] #Elemina las filas con ese patrón
Proyectos$FechaDeConsulta<-Sys.Date() #Añade la fecha de consulta

rm(Proyectos)

#---- Bucle para todos los sectores #----

Sectores<-EGNacional[,1]%>%
  str_remove_all(pattern = "[:digit:]")%>%
  str_remove_all(pattern = "[:punct:]")%>%
  str_trim()

Sectores[1] #Indexamos los elementos

for(i in c(1:26)) {
  #count
  j<-str_pad(i,2,pad="0")
  print(j)
  NameSector<-Sectores[i]
  # Hacer clic en los sectores del GN
  SectoresGN<-Browser$findElement("id", paste0("ctl00_CPH1_RptData_ctl",j,"_TD0")) #Es Id
  SectoresGN$clickElement()
  #Browser$screenshot(display=TRUE)
  # Hacer clic en Producto/Proyecto
  ProdProyec<-Browser$findElement(using = "css",value = "#ctl00_CPH1_BtnProdProy") #Es Id
  ProdProyec$clickElement()
  
  #Raspamos información de Proyectos
  #Decirle que actúe sobre página actual
  Pagina_actual<-Browser$getPageSource()
  #Leer la página
  Proyectos<-read_html(Pagina_actual[[1]])%>%
    html_node(css = "#ctl00_CPH1_UpdatePanel1")%>%
    html_node(css = ".Data")%>%
    html_table(header = F,fill=T)
  
  #Cambiamos los nombres de las variables
  names(Proyectos)[2:10]<-c("ProductoProyecto","PIA","PIM","Certificación","CompAnual",
                            "AtenDeComprMensual","Devengado","Girado","Avance%")
  Proyectos<-Proyectos[,-1]             #Nos quedamos con las variables que tienen información
  Proyectos<-Proyectos[!Proyectos$ProductoProyecto=="Ficha de Proyecto",] #Elemina las filas con ese patrón
  Proyectos$FechaDeConsulta<-Sys.Date() #Añade la fecha de consulta
  Proyectos$Sector<-Sectores[i]        #Rellena el sector correspondiente
  #Ahora que guarde la información
  saveRDS(Proyectos,paste0("PP_",Sectores[i],".rds")) #Guardar
  #Hacer clic al botón Regresar
  Retroceder<-Browser$findElement("id","ctl00_CPH1_RptHistory_ctl03_TD0")
  Retroceder$clickElement()
  #Que descance un rato
  Sys.sleep(4)
}

#Juntar toda la base de dados

list.files() # vemos todos los archivos de nuestra carpeta 
Ficheros <- list.files(pattern = "^PP_") # Extrae solo los que inician con determinado caracter
ProductoProyecto<-read_rds(Ficheros[1])

for (i in 2:26) {
  ProductoProyecto<-rbind(ProductoProyecto,read_rds(Ficheros[i]))  
}
#Guardamos
saveRDS(ProductoProyecto,"ProductoProyectoGN.rds")
#cerrar la sesión
Browser$close()
server$stop()