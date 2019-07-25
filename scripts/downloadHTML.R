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

options(HTTPUserAgent = "R (3.5.2 x86_64-pc-linux-gnu x86_64 linux-gnu)")

extractMonIdsToScrape <- function(link) {
  webpage <- read_html(link)
  hrefs <- html_nodes(webpage, "a") %>% html_attr("href")
  hrefs_pets <- str_match(string = hrefs, pattern = "^pets/([0-9]{3,4})$")[,2]
  vt_id <- as.integer(hrefs_pets[!is.na(hrefs_pets)])
  vt_id
}

vt_link <- c(
  "http://pad.skyozora.com/",
  "http://pad.skyozora.com/news/Ver.17.3-%E6%9B%B4%E6%96%B0%E6%83%85%E5%A0%B1"
)

id.vt <- unique(unlist(sapply(vt_link, extractMonIdsToScrape), use.names = F))

index <- 1
while (index <= length(id.vt)) {
  tryCatch(
    {
      download.file(paste0("http://pad.skyozora.com/pets/", id.vt[index]), paste0("raw/", id.vt[index], ".html"))
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
