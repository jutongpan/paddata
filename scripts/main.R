rm(list=ls())

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/JPan/Documents/repos/paddata")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
}


readHtmlIgnoreSSL <- function(url, device) {

  if (device == "mobile") {
    user_agent <- "Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X)"
  } else {
    user_agent <- "R (3.5.2 x86_64-pc-linux-gnu x86_64 linux-gnu)"
  }

  read_html(
    httr::GET(
      url = url,
      httr::add_headers("user_agent" = user_agent),
      config = httr::config(ssl_verifypeer = F)
    )
  )

}

source(file = "scripts/downloadHTML.R", local = T)
source(file = "scripts/scraper.R", local = T)
source(file = "scripts/MonsterIcon.R", local = T)
source(file = "scripts/ActiveSkillType.R", local = T)
