#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "ODM2 database"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  ),
  selectizeInput(inputId = "select_variable", label = "choose variable",
                 choices = variablenames)),
  dashboardBody(
    fluidRow(
      box(dataTableOutput("table1")))
  )
)

server <- function(input, output) { 
  
  output$table1 <- renderDataTable({
    sql <- "SELECT mrv.datavalue, mrv.valuedatetime, sf.samplingfeaturecode, r.featureactionid, v.variablecode, u.unitsname
  FROM odm2.measurementresultvalues mrv, odm2.results r, odm2.variables v, odm2.units u, odm2.samplingfeatures sf, odm2.featureactions fa
    WHERE r.variableid = v.variableid 
    AND r.featureactionid = fa.featureactionid
    AND fa.samplingfeatureid = sf.samplingfeatureid
    AND r.unitsid = u.unitsid
    AND mrv.resultid = r.resultid 
    AND r.sampledmediumcv = 'soil'
    AND v.variablenamecv = ?variablenamecv"
    
    sql <- sqlInterpolate(ANSI(), sql, variablenamecv = input$select_variable)
    # sql <- gsub("\n", "", sql)
    
    dbGetQuery(db, sql)
    
  })

  
  }

shinyApp(ui, server)