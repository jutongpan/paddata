if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/JPan/Documents/repos/paddata")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
}

source(file = "scripts/downloadHTML.R", local = T)
source(file = "scripts/scraper.R", local = T)
source(file = "scripts/MonsterIcon.R", local = T)
source(file = "scripts/ActiveSkillType.R", local = T)
