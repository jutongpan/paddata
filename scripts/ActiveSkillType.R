rm(list=ls())
library(data.table)
library(rvest)
library(DBI)
library(RSQLite)

if (Sys.info()[["sysname"]] == "Windows") {
  stop("This script cannot be run on Windows.")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
} else {
  setwd("//Users/yawenliang/Documents/paddata")
}

source("scripts/functions.R")

# Get active skill type list

url <- 'http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- readHtmlIgnoreSSL(url, device = "desktop")
# webpage <- read_html("raw/ActiveSkillType.html")
webnodes1 <- html_nodes(webpage, 'h3')
webnodes2 <- html_nodes(webpage, 'table')

ActiveSkillTable.ls <- as.list(html_text(webnodes1))
ActiveSkillTable.dt <- data.table(ActiveSkillTable.ls)
ActiveSkillContent.ls_ <- lapply(webnodes2, function(x) html_text(html_nodes(x, "tr td")))
ActiveSkillContent.ls_ <- ActiveSkillContent.ls_[4:(length(ActiveSkillContent.ls_ )-1)]


wide <- function(x){
  name_index <- seq(from = 1, to = length(x)-1, by = 2)
  description_index <- name_index+1
  name <- x[name_index]
  description <- x[description_index]
  data.table(ActiveSkillName = name, ActiveSkillDescription = description)
}
ActiveSkillContent.ls <- lapply(ActiveSkillContent.ls_, wide)


ActiveSkillType.ls <- list()
for (i in 1:length(ActiveSkillTable.ls)){
  ActiveSkillType.ls[[i]] <- ActiveSkillContent.ls[[i]][, ActiveSkillTable := ActiveSkillTable.ls[[i]] ]
}

ActiveSkillType.dt1 <- rbindlist(ActiveSkillType.ls)
ActiveSkillType.dt2 <- ActiveSkillType.dt1[, ActiveSkillType := strsplit(ActiveSkillTable, "；", fixed=TRUE)]
MaxComb <- max(sapply(ActiveSkillType.dt2$ActiveSkillType, length))
ActiveSkillType.dt3 <- ActiveSkillType.dt1[, paste0("ActiveSkillType", 1:MaxComb) := tstrsplit(ActiveSkillTable, "；", fixed=TRUE)]
ActiveSkillType.dt3[, c("ActiveSkillTable", "ActiveSkillType") := NULL]

ActiveSkillType.dt4 <- melt(ActiveSkillType.dt3, id.vars = c("ActiveSkillName", "ActiveSkillDescription"),
                           measure.vars = paste0("ActiveSkillType", 1:MaxComb), na.rm = TRUE)
ActiveSkillType.dt4 [, c("variable", "ActiveSkillDescription") := NULL]

ActiveSkillList.dt <- data.table(unique(ActiveSkillType.dt4$ActiveSkillName))
# fwrite(x = ActiveSkillList.dt, "db/ActiveSkillList.csv")

# Get ActiveSkillId
conn <- dbConnect(drv = RSQLite::SQLite(), "padmonster.sqlite3")
ActiveSkill <- dbReadTable(conn,"ActiveSkill")
ActiveSkill.dt <- data.table(ActiveSkill)
NameID <- ActiveSkill.dt[, .(ActiveSkillId, ActiveSkillName)]

setkey(ActiveSkillType.dt4, ActiveSkillName)
setkey(NameID, ActiveSkillName)
ActiveSkillType.dt <- merge(NameID, ActiveSkillType.dt4, all.x = TRUE)

ActiveSkillType.dt <- ActiveSkillType.dt[order(ActiveSkillId)]
setnames(ActiveSkillType.dt, "value", "ActiveSkillType")

setcolorder(ActiveSkillType.dt, c("ActiveSkillId", "ActiveSkillType"))
ActiveSkillType.dt<- ActiveSkillType.dt[ , ActiveSkillName := NULL]

## Ad-hoc fix for a bug on 戰友網
ActiveSkillType.dt[ActiveSkillType == "", ActiveSkillType := "解除無法消除寶珠狀態"]

# Write the data into database

dbExecute(conn, "DELETE FROM ActiveSkillType")
dbWriteTable(conn, "ActiveSkillType", ActiveSkillType.dt, append = T)
dbDisconnect(conn)
