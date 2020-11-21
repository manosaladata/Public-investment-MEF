# Proyectos de inversión pública a nivel local
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

# Hacer clic en nivel de gobierno
NivelesGobierno<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_BtnTipoGobierno") #Es Id
NivelesGobierno$clickElement()
Browser$screenshot(display=TRUE) # si salío 

#Hacer clic en opción de M:Gobiernos Locales
GobiernoLocal<-Browser$findElement(using = "css",
                                      value = "#ctl00_CPH1_RptData_ctl02_TD0") #Es Id
GobiernoLocal$clickElement()
Browser$screenshot(display=TRUE) # 

# Hacer clic en Gobiernos locales/Mancomunidades
LocalesMancomun<-Browser$findElement(using = "css",
                            value = "#ctl00_CPH1_BtnSubTipoGobierno") #Es Id
LocalesMancomun$clickElement()
Browser$screenshot(display=TRUE) # 

# Hacer clic en M: Municipalidades
Municipalidades<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_RptData_ctl01_TD0") #Es Id
Municipalidades$clickElement()
Browser$screenshot(display=TRUE) #

# Hacer clic en Departamentos
Departamentos<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_BtnDepartamento") #Es Id
Departamentos$clickElement()
Browser$screenshot(display=TRUE) #

#Decirle que actúe sobre la página actual para rasparlo
Pagina_actual<-Browser$getPageSource()

#escrapeamos la información de todas las regiones
Pagina<-read_html(Pagina_actual[[1]]) # en el elemento 1 de la lista está la url de la página actual

EGDtosMuni<-Pagina%>%
  html_node(css = "#ctl00_CPH1_UpdatePanel1")%>% #ctl00_CPH1_UpdatePanel1
  html_node(css = ".Data")%>%
  html_table(header = F)

#Cambiamos los nombres de las variables
names(EGDtosMuni)[2:10]<-c("Departamento","PIA","PIM","Certificación","CompAnual",
                           "AtenDeComprMensual","Devengado","Girado","Avance%")
EGDtosMuni<-EGDtosMuni[,-1]             #Nos quedamos con las variables que tienen información1
EGDtosMuni$FechaDeConsulta<-Sys.Date() # Añadimos la fecha de consulta

#Guardamos la información
saveRDS(EGDtosMuni,file = "EG_DtosMunici.rds")
# Extraemos los proyectos de inversión pública de todos los sectores
#Para acceder a cada Departamento
EGDtosMuni$Departamento
  
#ID para acceso
#ctl00_CPH1_RptData_ctl01_TD0 # Amazonas
#ctl00_CPH1_RptData_ctl02_TD0 # Ancash
#ctl00_CPH1_RptData_ctl03_TD0 # Apurímac ...
#ctl00_CPH1_RptData_ctl25_TD0 #Ucayali

#---- Hcer clic en Amazonas #----
#   Ejemplo
Amazonas<-Browser$findElement(using = "css",
                         value = "#ctl00_CPH1_RptData_ctl01_TD0") #Es Id
Amazonas$clickElement()
Browser$screenshot(display=TRUE) 

# Hacer clic en Municipalidad
Municipalidad<-Browser$findElement(using = "css",
                                value = "#ctl00_CPH1_BtnMunicipalidad") #Es Id
Municipalidad$clickElement()
Browser$screenshot(display=TRUE)

#Raspamos información de municipalidades
#Nuevamente decirle que actúe sobre página actual
Pagina_actual<-Browser$getPageSource()

Pagina<-read_html(Pagina_actual[[1]])

EG_GL<-Pagina%>%
  html_node(css = "#ctl00_CPH1_UpdatePanel1")%>%
  html_node(css = ".Data")%>%
  html_table(header = F,fill=T)

#Cambiamos los nombres de las variables
names(EG_GL)[2:10]<-c("Municipalidad","PIA","PIM","Certificación","CompAnual",
                          "AtenDeComprMensual","Devengado","Girado","Avance%")
EG_GL<-EG_GL[,-1] #Nos quedamos con las variables que tienen información
#EG_GL<-EG_GL[!Proyectos$ProductoProyecto=="Ficha de Proyecto",] #Elemina las filas con ese patrón
EG_GL$Departamento<-Departamento[1]
EG_GL$FechaDeConsulta<-Sys.Date() #Añade la fecha de consulta

rm(EG_GL)

#---- Bucle para todos los gobiernos locales #----
Departamento<-EGDtosMuni[,1]%>%
  str_remove_all(pattern = "[:digit:]")%>%
  str_remove_all(pattern = "[:punct:]")%>%
  str_trim()

Departamento[1] #Indexamos los elementos

for(i in c(1:25)) {
  #count
  j<-str_pad(i,2,pad="0")
  print(j)
  NameGL<-Departamento[i]
  # Hacer clic en Departamentos para acceder a las municipalidades 
  DepartamentoGL<-Browser$findElement("id", paste0("ctl00_CPH1_RptData_ctl",j,"_TD0")) #Es Id
  DepartamentoGL$clickElement()
  Browser$screenshot(display=TRUE)
  # Hacer clic en Municipalidad
  Municipalidad<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_BtnMunicipalidad") #Es Id
  Municipalidad$clickElement()
  
  #Raspamos información de ejecución de gasto de las municipalidades
  #Decirle que actúe sobre página actual
  Pagina_actual<-Browser$getPageSource()
  #Leer la página
  EG_GLs<-read_html(Pagina_actual[[1]])%>%
    html_node(css = "#ctl00_CPH1_UpdatePanel1")%>%
    html_node(css = ".Data")%>%
    html_table(header = F,fill=T)
  
  #Cambiamos los nombres de las variables
  names(EG_GLs)[2:10]<-c("Municipalidad","PIA","PIM","Certificación","CompAnual",
                        "AtenDeComprMensual","Devengado","Girado","Avance%")
  EG_GLs<-EG_GLs[,-1] #Nos quedamos con las variables que tienen información
  EG_GLs$Departamento<-Departamento[i] #Llenar con el departamento correspondiente
  EG_GLs$FechaDeConsulta<-Sys.Date() #Añade la fecha de consulta
  
  #Ahora que guarde la información
  saveRDS(EG_GLs,paste0("EG_GL",Departamento[i],".rds")) #Guardar
  #Hacer clic al botón Regresar
  Retroceder<-Browser$findElement("id","ctl00_CPH1_RptHistory_ctl04_TD0")
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
