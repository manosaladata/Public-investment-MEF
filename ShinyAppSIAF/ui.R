# Define UI for application 
#skin = "blue", theme = "slate",

shinyUI(
  dashboardPage(
    dashboardHeader(title = "Inversión pública"),
    #Barra lateral izquierda
    dashboardSidebar(
                     sidebarMenu(
                       menuItem("Dashboard",icon = icon("dashboard"),
                                dateRangeInput("date_Range_input","seleccione periodo:",
                                               start = "2010-01-01", #
                                               end =  Sys.Date(),
                                               format = "yyyy",startview = 'decade',
                                               separator = "a"),
                                selectInput("region","Región:",
                                            choices = c(unique(DataGR$G_Regional)),
                                            selected = c("Arequipa","Cusco"),
                                            multiple = TRUE),#selectize=TRUE
                                menuSubItem(icon = NULL,tabName = "dashboard",
                                            submitButton("Ejecutar"))),
                       menuItem("Data",icon = icon("table"),
                                menuSubItem("Data General",tabName = "dataG",icon = NULL))
                       )
                     ),
    #Cuerpo del Shiny
    dashboardBody(
      ##Este pedaso de CSS, cambia los colores de sidebar:
      use_theme(mytheme),
      tabItems(
        tabItem(
          tabName = "dashboard",
          tabsetPanel(
            tabPanel("Chart Bar",
                     # fluidRow(
                       # column(
                         # width = 12,#9
                         fluidRow(
                           valueBoxOutput("PIA_box"),
                           valueBoxOutput("PIM_box"),
                           valueBoxOutput("Deven_box"),
                           valueBoxOutput("Avan_box")
                         ),
                         fluidRow(
                           box(
                             width = 12,
                             plotOutput("boxplot1"))
                           )
                         # )
                       # )
                     ),
            tabPanel("Chart Line", plotlyOutput("Lineplot1")),
            tabPanel("Data Región", 
                     fluidRow(
                       box(
                         width = 12,
                         DT::DTOutput("DataRegion")))
                     )),
          # fluidRow(
          #   column(width = 8,
          #                     plotOutput("boxplot1")),
          #   column(width = 8,
          #          plotlyOutput("Lineplot1")),
          #   column(width = 8,
          #          dataTableOutput("DataRegion"),
          #          downloadButton("downloadData1", "Download")),
          #   # box(width = 8,
            #     title = "Evolucion de la inversión Pública",
            #     #color = "sky blue",ribbon = TRUE,title_side = "Top right",
            #     ),
            # box(width = 8,
            #     title = "Porcentaje de ejecución",
            #     #color = "blue",ribbon = TRUE,title_side = "Top right",
            #     
            #            ),
            # box(width = 16,
            #     title = "Data de la región",
            #     #color = "red",ribbon = TRUE,title_side = "Top right",
            #     )
            ),
        tabItem(
          tabName = "dataG",
          fluidRow(
            box(
              width = 12,
              DT::DTOutput("DataRegiones")
              # dataTableOutput("DataRegiones",width = "50%"),
              # downloadButton("downloadData2", "Download")
              )
            ))
        ))
  )
)
