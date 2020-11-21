
#Acceso a Datos abiertos MEF- Seguimiento de proyectos de inversión-Regional

library(tidyverse)
library(readxl)
library(xml2)
library(rvest)
library(RSelenium)
library(wdman)
library(robotstxt)

#library(httr)  #Para la función GET para API
#library(jsonlite) # Para leer el json

setwd("C:/Users/Jose Luis/Documents/GitHub/Inversión-Pública-MEF/Data")

#Diccionaro de datos de ejecución presupuestal para la API

DiccEPresup<-read_excel("Diccionario_CA_Gasto_1.xlsx")
DiccIngr<-read_excel("Diccionario_CA_Ingreso.xlsx")
names(DiccIngr)[1]<-"Variables"

#---- Descarga mediante API #----
#No funciona

MyAPIkey<-"u5P2d1X8t1cCmtH8H5cPnPZvfuYT3ESCMtgQsenu"

Urlbase<-"https://www.datosabiertos.gob.pe/dataset/ejecuci%C3%B3n-presupuestal-consulta-amigable-ministerio-de-econom%C3%ADa-y-finanzas-mef"

ApiMef<-get(Urlbase)

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

#Hacer clic en opción de R:Gobiernos Regionales
GobiernoRegional<-Browser$findElement(using = "css",
                                     value = "#ctl00_CPH1_RptData_ctl03_TD0") #Es Id
GobiernoRegional$clickElement()
Browser$screenshot(display=TRUE) # 

# Hacer clic en sector
Sector<-Browser$findElement(using = "css",
                                      value = "#ctl00_CPH1_BtnSector") #Es Id
Sector$clickElement()
Browser$screenshot(display=TRUE) # 

# Hacer clic en 99:GOBIERNOS REGIONALES
GR<-Browser$findElement(using = "css",
                            value = "#ctl00_CPH1_RptData_ctl02_TD0") #Es Id
GR$clickElement()
Browser$screenshot(display=TRUE) #

# Hacer clic en pliego
Pliego<-Browser$findElement(using = "css",
                        value = "#ctl00_CPH1_BtnPliego") #Es Id
Pliego$clickElement()
Browser$screenshot(display=TRUE) 

#Decirle que actúe sobre la página actual para rasparlo
Pagina_actual<-Browser$getPageSource()

#escrapeamos la información de todas las regiones
Pagina<-read_html(Pagina_actual[[1]]) # en el elemento 1 de la lista está la url de la página actual

EG_Regional<-Pagina%>%
  html_node(css = "#ctl00_CPH1_UpdatePanel1")%>%
  html_node(css = ".Data")%>%
  html_table(header = F)
#Cambiamos los nombres de las variables
names(EG_Regional)[2:10]<-c("Pliego","PIA","PIM","Certificación","CompAnual",
                          "AtenDeComprMensual","Devengado","Girado","Avance%")
EG_Regional<-EG_Regional[,-1]             #Nos quedamos con las variables que tienen información
EG_Regional$FechaDeConsulta<-Sys.Date() # Añadimos la fecha de consulta

#Guardamos la información
saveRDS(EG_Regional,file = "EG_GR.rds")
# Extraemos los proyectos de inversión pública de todas las regiones
#Para acceder a cada departamento

#ctl00_CPH1_RptData_ctl01_TD0
#ctl00_CPH1_RptData_ctl02_TD0
#ctl00_CPH1_RptData_ctl03_TD0
#ctl00_CPH1_RptData_ctl04_TD0 #Arequipa
#ctl00_CPH1_RptData_ctl05_TD0
#ctl00_CPH1_RptData_ctl26_TD0

#---- Hcer clic en Arequipa #----
#   Ejemplo
Arequipa<-Browser$findElement(using = "css",
                            value = "#ctl00_CPH1_RptData_ctl04_TD0") #Es Id
Arequipa$clickElement()
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

#rm(Proyectos)

#---- Bucle para todos #----
Regiones<-c("Amazonas","Ancash","Apurimac","Arequipa","Ayacucho","Cajamarca",
            "Cusco","Huancavelica","Huánuno","Ica","Junín","Libertad",
            "Lambayeque","Loreto","MadreDeDios","Moquegua","Pasco","Piura",
            "Puno","SanMartín","Tacna","Tumbes","Ucayalí","Lima","Callao",
            "LimaMetropolitana")

for(i in c(1:26)) {
  #count
  j<-str_pad(i,2,pad="0")
  print(j)
  Region<-Regiones[i]
  # Hacer clic en Regiones
  Region<-Browser$findElement("id", paste0("ctl00_CPH1_RptData_ctl",j,"_TD0")) #Es Id
  Region$clickElement()
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
  Proyectos$Region<-Regiones[i]        #Rellena con la región correspondiente
  #Ahora que guarde la información
  saveRDS(Proyectos,paste0("PP_",Regiones[i],".rds")) #Guardar
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
saveRDS(ProductoProyecto,"ProductoProyectoGR.rds")
#cerrar la sesión
Browser$close()
server$stop()
