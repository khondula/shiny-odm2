#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
library(RPostgreSQL)
library(DT)
library(magrittr)
library(shiny)
library(shinydashboard)
library(dplyr)

# source('global.R')
variablenames <- dbGetQuery(db, "SELECT variablecode FROM odm2.variables")
sitenames <- dbGetQuery(db, "SELECT samplingfeaturecode 
                              FROM odm2.samplingfeatures 
                              WHERE samplingfeaturetypecv = 'site'")

ui <- dashboardPage(
  dashboardHeader(title = "Choptank database"),
  dashboardSidebar(
    tags$style(".skin-blue .sidebar a { color: #444; }"),
  #   sidebarMenu(
  #     menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
  #     menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  # ),
  checkboxGroupInput(inputId = "select_variable", label = "choose variable",
                 choices = variablenames$variablecode, selected = "methaneDissolved"),
  selectizeInput(inputId = "select_sites", label = "choose sites", multiple = TRUE,
                 choices = sitenames, selected = c("DB", "QB", "DK", "TB", "ND", "BB")),
  # checkboxGroupInput(inputId = "select_sites", label = "choose sites",
  #                choices = sitenames$samplingfeaturecode, selected = c("DB", "QB", "DK", "TB", "ND", "BB")),
  div(),
  dateRangeInput("dates", label = h3("Date range"), start = "2017-05-01")
  # box(title = "Download", status = "primary", solidHeader = TRUE,
  #     collapsible = TRUE,
  #     downloadButton("downloadData", "Save current data"))
  
  ),
  dashboardBody(
    # fluidRow(box(title = "Download", status = "primary", solidHeader = TRUE,
    #     collapsible = TRUE,
    #     downloadButton("downloadData", "Save current data"))),
    p("This is a simple interface to download data 
       from the choptank hydro connectivity database.
      Filter data by variable, sites, and date and
      download as a .csv file."),
    downloadButton("downloadData", "Save current data"),
    br(),br(),
    div(dataTableOutput("datatable1"), 
        style = "font-size:80%; font-family:arial; width:100%; height:50px")
      # dataTableOutput("datatable1"))
  )
)

server <- function(input, output) { 
  
  table1_data <- reactive({
    sql <- "SELECT 
              mrv.datavalue,
              mrv.valuedatetime,
              mrv.valuedatetimeutcoffset AS utc,
              sf.samplingfeaturecode,
              sf2.samplingfeaturecode AS siteID,
              v.variablecode,
              u.unitsname
            FROM 
              odm2.measurementresultvalues mrv
            INNER JOIN
              odm2.results r ON r.resultid = mrv.resultid
            INNER JOIN
              odm2.variables v ON v.variableid = r.variableid
            INNER JOIN
              odm2.units u ON u.unitsid = r.unitsid
            INNER JOIN 
              odm2.featureactions fa ON fa.featureactionid = r.featureactionid
            INNER JOIN 
              odm2.samplingfeatures sf ON sf.samplingfeatureid = fa.samplingfeatureid
            INNER JOIN
              odm2.relatedfeatures rf ON rf.samplingfeatureid = sf.samplingfeatureid
            INNER JOIN
              odm2.samplingfeatures sf2 ON  sf2.samplingfeatureid = rf.relatedfeatureid"
    
    
    sql <- sqlInterpolate(ANSI(), sql)
    # sql <- gsub("\n", "", sql)
    query_results <- dbGetQuery(db, sql)
    
    query_results 
  })

    output$datatable1 <- renderDataTable({ 
      table1_data() %>% 
        mutate(date = as.Date(valuedatetime)) %>%
        filter(siteid %in% input$select_sites, 
               variablecode %in% input$select_variable,
               date > input$dates[1], date < input$dates[2]
        )}, options = list(dom = 'pltif', pageLength = 10))
  
  # Downloadable csv of selected dataset
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("db_", gsub('[[:punct:] ]+','_', x = Sys.time()), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(as.data.frame(table1_data()), file, row.names = FALSE)
    }
  )
    
  }

shinyApp(ui, server)