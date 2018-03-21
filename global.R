library(RPostgreSQL)
library(DT)
library(magrittr)

db <- dbConnect(PostgreSQL(), 
                host = "sesync-postgis01.research.sesync.org",
                dbname = "choptank", 
                user = "palmergroup",
                password = password)

variablenames <- dbGetQuery(db, "SELECT variablenamecv FROM odm2.variables")
