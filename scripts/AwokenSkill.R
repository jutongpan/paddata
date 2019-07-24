rm(list=ls())
library(data.table)
library(rvest)
library(DBI)
library(RSQLite)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/jpan/Documents/repos/paddata")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
} else {
  setwd("//Users/yawenliang/Documents/paddata")
}

## 1. Scrape awoken skill data

url <- 'http://pad.skyozora.com/skill/%E8%A6%BA%E9%86%92%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '.tooltip')

AwokenSkillName <- sapply(webnodes, function(x) xml_attr(x, "title"))
AwokenSkillIconDownload <- sapply(webnodes, function(x) xml_attr(xml_child(x), "src"))

AwokenSkill.dt <- data.table(
  AwokenSkillName = AwokenSkillName,
  AwokenSkillIconDownload = AwokenSkillIconDownload
)
AwokenSkill.dt <- AwokenSkill.dt[-1, ]
AwokenSkill.dt[ , AwokenSkillId := .I]

## 2. Write the data into database
conn <- dbConnect(drv = RSQLite::SQLite(), "padmonster.sqlite3")
dbExecute(conn, "DELETE FROM AwokenSkill")
dbWriteTable(conn, "AwokenSkill", AwokenSkill.dt, append = TRUE)
dbDisconnect(conn)

## 3. Download Awoken Skill icons 
for (i in 1:nrow(AwokenSkill.dt)) {
  if (file.exists(paste0("img/AwokenSkill/", i, ".png")) == FALSE) {
    download.file(
      AwokenSkill.dt$AwokenSkillIconDownload[i],
      paste0("img/AwokenSkill/", AwokenSkill.dt[i, AwokenSkillId], ".png")
    )
  }
}
