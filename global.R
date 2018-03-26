library(RPostgreSQL)
library(DT)
library(magrittr)
library(shiny)
library(shinydashboard)
library(dplyr)

password = scan(".pgpass", what = "")
db <- dbConnect(PostgreSQL(), 
                host = "sesync-postgis01.research.sesync.org",
                dbname = "choptank", 
                user = "palmergroup",
                password = password)
