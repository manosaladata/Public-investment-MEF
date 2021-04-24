
ui <- dashboardPage(
    dashboardHeader(title = "Inversión pública",color = "blue",inverted = TRUE),
    dashboardSidebar(side = "left", size = "thin", color = "teal",
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard",icon = icon("dashboard")),
            menuItem("Data", tabName = "data",icon = icon("table")))),
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
                                choices = c(unique(DataGR$G_Regional)))),
                    box(width = 3,color = "sky blue",ribbon = TRUE,
                        submitButton("Ejecutar"))),
                fluidRow(
                    box(width = 8,
                            title = "Graph 1",
                            color = "green",ribbon = TRUE,title_side = "Top right",
                            column(width = 8,
                                   plotOutput("boxplot1"))),
                    box(width = 8,
                            title = "Graph 2",
                            color = "red",ribbon = TRUE,title_side = "Top right",
                            column(width = 8,
                                   plotlyOutput("dotplot1"))))),
            tabItem(
                tabName = "data",
                fluidRow(
                    dataTableOutput("DataRegion"),
                    downloadButton("downloadData", "Download"))))
        )
)

