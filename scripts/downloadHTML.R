library(data.table)
library(rvest)
library(stringr)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/JPan/Documents/repo/paddata")
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
  "http://pad.skyozora.com/news/%EF%BC%8807/12%E5%AF%A6%E8%A3%9D%EF%BC%89%E9%83%A8%E4%BB%BD%E5%AF%B5%E7%89%A9%E7%A9%B6%E6%A5%B5%E9%80%B2%E5%8C%96%EF%BC%86%E8%83%BD%E5%8A%9B%E8%AA%BF%E6%95%B4%EF%BC%81"
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
