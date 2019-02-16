rm(list=ls())
library(data.table)
library(rvest)
library(DBI)
library(RSQLite)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else {
  setwd("//Users/yawenliang/Documents/paddata")
}

## 1. Scrape awoken skill data

url <- 'http://pad.skyozora.com/skill/%E8%A6%BA%E9%86%92%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '.tooltip')

AwokenSkillName <- sapply(webnodes, function(x) xml_attr(x, "title"))
AwokenSkillIconDownload <- sapply(webnodes, function(x) xml_attr(xml_child(x), "src"))

AwokenSkillName.dt <- data.table(AwokenSkillName)
AwokenSkillIconDownload.dt <- data.table(AwokenSkillIconDownload)

AwokenSkill.dt <- cbind(AwokenSkillName.dt, AwokenSkillIconDownload.dt)
AwokenSkill.dt <- AwokenSkill.dt[-1,]
AwokenSkill.dt[ , AwokenSkillId := 1:nrow(AwokenSkill.dt)]

# for(i in 1:length(AwokenSkill.dt$AwokenSkillIconDownload)){
# download.file(paste0(AwokenSkill.dt$AwokenSkillIconDownload[i]),
#               paste0("app/img/AwokenSkill/", AwokenSkill.dt[i,AwokenSkillId], ".png"))
# }


## 2. Write the data into database
conn <- dbConnect(drv = RSQLite::SQLite(), "padmonster.sqlite3")
dbExecute(conn, "DELETE FROM AwokenSkill")
dbWriteTable(conn, "AwokenSkill", AwokenSkill.dt, append = TRUE)
dbDisconnect(conn)
