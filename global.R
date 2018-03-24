library(RPostgreSQL)
library(DT)
library(magrittr)

password = scan(".pgpass", what = "")
db <- dbConnect(PostgreSQL(), 
                host = "sesync-postgis01.research.sesync.org",
                dbname = "choptank", 
                user = "palmergroup",
                password = password)
