# Define UI for application 
#skin = "blue", theme = "slate",

shinyUI(
    dashboardPage(
    dashboardHeader(title = "Inversión pública",color = "blue",inverted = TRUE),
    #Barra lateral izquierda
    dashboardSidebar(side = "left", size = "thin", color = "teal",
                     sidebarMenu(
                         menuItem("Dashboard", tabName = "dashboard",icon = icon("dashboard")),
                         menuItem("Data", tabName = "data",icon = icon("table")))),
    #Cuerpo del Shiny
    dashboardBody(
        tabItems(
            #selected = 1,
            tabItem(
                tabName = "dashboard",
                fluidRow(
                    box(width = 4,color = "sky blue",ribbon = TRUE,
                        numericRangeInput("numeric_Range_input","seleccione rango de año:",
                                          value = c(2010:2020), 
                                          separator = "a")),
                    box(width = 3,color = "sky blue",ribbon = TRUE,
                        selectInput("region","Región:",
                                    choices = c(unique(DataGR$G_Regional)),
                                    multiple = TRUE)),
                    box(width = 3,color = "sky blue",ribbon = TRUE,
                        submitButton("Ejecutar"))),
                fluidRow(
                    box(width = 8,
                        title = "Evolucion de la inversión Pública",
                        color = "sky blue",ribbon = TRUE,title_side = "Top right",
                        column(width = 8,
                               plotOutput("boxplot1"))),
                    box(width = 8,
                        title = "Porcentaje de ejecución",
                        color = "blue",ribbon = TRUE,title_side = "Top right",
                        column(width = 8,
                               plotlyOutput("Lineplot1"))),
                    box(width = 16,
                        title = "Data de la región",
                        color = "red",ribbon = TRUE,title_side = "Top right",
                        column(width = 8,
                               dataTableOutput("DataRegion"),
                               downloadButton("downloadData1", "Download"))))),
            tabItem(
                tabName = "data",
                fluidRow(
                    dataTableOutput("DataRegiones"),
                    downloadButton("downloadData2", "Download"))))
        )
    )
)