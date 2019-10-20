library(data.table)
library(rvest)
library(stringr)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/JPan/Documents/repos/paddata")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
}

source("scripts/functions.R")

extractMonIdsToScrape <- function(link) {
  webpage <- readHtmlIgnoreSSL(link, device = "desktop")
  hrefs <- html_nodes(webpage, "a") %>% html_attr("href")
  hrefs_pets <- str_match(string = hrefs, pattern = "^pets/([0-9]{3,4})$")[,2]
  vt_id <- as.integer(hrefs_pets[!is.na(hrefs_pets)])
  vt_id
}

vt_link <- c(
  "http://pad.skyozora.com/",
  "https://pad.skyozora.com/news/（10/18實裝）部份寵物追加進化形態＆能力調整！"
)

id.vt <- unique(unlist(sapply(vt_link, extractMonIdsToScrape), use.names = F))

index <- 1
while (index <= length(id.vt)) {
  tryCatch(
    {
      writeLines(
        text = RCurl::getURL(
          url = paste0("https://pad.skyozora.com/pets/", id.vt[index]),
          ssl.verifypeer = FALSE
        ),
        con = paste0("raw/", id.vt[index], ".html")
      )
      cat(id.vt[index], "\n")
      if (index %% 100 == 0) Sys.sleep(30)
      if (index %% 10 == 0) Sys.sleep(3)
      index <- index + 1
    },
    error = function(e) {
      Sys.sleep(300)
    }
  )
}

## Download page of active skills by type
# path <- "http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/"
# download.file(path, "raw/ActiveSkillType.html")
