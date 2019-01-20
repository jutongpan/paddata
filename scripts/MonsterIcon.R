rm(list=ls())
library(data.table)
library(DBI)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else {
  setwd("//Users/yawenliang/Documents/paddata")
}

conn <- dbConnect(drv = RSQLite::SQLite(), "padmonster.sqlite3")
Monster.dt <- setDT(dbReadTable(conn, "Monster"))
MonsterIcon.dt <- Monster.dt[ , c("MonsterId", "MonsterIconDownload")]
for (i in 1:nrow(MonsterIcon.dt)){
  if (file.exists(paste0("img/MonsterIcon/", MonsterIcon.dt[i, MonsterId], ".png")) == FALSE) {
      download.file(MonsterIcon.dt$MonsterIconDownload[i],
                    paste0("img/MonsterIcon/", MonsterIcon.dt[i, MonsterId], ".png"),
                    mode = "wb")
  }
}
