#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

library(shiny)
library(shinydashboard)
library(RPostgreSQL)
library(DT)
library(magrittr)

# source('global.R')
variablenames <- dbGetQuery(db, "SELECT variablecode FROM odm2.variables")

ui <- dashboardPage(
  dashboardHeader(title = "ODM2 database"),
  dashboardSidebar(
    tags$style(".skin-blue .sidebar a { color: #444; }"),
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  ),
  selectizeInput(inputId = "select_variable", label = "choose variable",
                 choices = variablenames, selected = "methaneDissolved"),
  downloadButton("downloadData", "Download")
  
  ),
  dashboardBody(
    fluidRow(
     
      box(dataTableOutput("datatable1")))
  )
)

server <- function(input, output) { 
  
  table1_data <- reactive({
    sql <- "SELECT mrv.datavalue, mrv.valuedatetime, sf.samplingfeaturecode, r.featureactionid, v.variablecode, u.unitsname
  FROM odm2.measurementresultvalues mrv, odm2.results r, odm2.variables v, odm2.units u, odm2.samplingfeatures sf, odm2.featureactions fa
    WHERE r.variableid = v.variableid 
    AND r.featureactionid = fa.featureactionid
    AND fa.samplingfeatureid = sf.samplingfeatureid
    AND r.unitsid = u.unitsid
    AND mrv.resultid = r.resultid 
    AND variablecode = ?variablecode"
    
    sql <- sqlInterpolate(ANSI(), sql, variablecode = input$select_variable)
    # sql <- gsub("\n", "", sql)
    
    dbGetQuery(db, sql)
    
  })

    output$datatable1 <- renderDataTable({ table1_data() }, 
                                         options = list(dom = 'plt'))
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$select_variable, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(table1_data(), file, row.names = FALSE)
    }
  )

  
  }

shinyApp(ui, server)