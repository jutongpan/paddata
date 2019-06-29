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
  "http://pad.skyozora.com/news/%EF%BC%8806/28%E5%AF%A6%E8%A3%9D%EF%BC%89%E9%83%A8%E4%BB%BD%E5%90%88%E4%BD%9C%E8%A7%92%E8%89%B2PowerUp%EF%BC%88%E4%B8%BB%E5%8B%95%E6%8A%80%EF%BC%86%E9%9A%8A%E9%95%B7%E6%8A%80%EF%BC%89",
  "http://pad.skyozora.com/news/%EF%BC%8806/28%E5%AF%A6%E8%A3%9D%EF%BC%89%E9%83%A8%E4%BB%BD%E5%90%88%E4%BD%9C%E8%A7%92%E8%89%B2PowerUp%EF%BC%88%E6%95%B8%E5%80%BC%EF%BC%86%E8%B6%85%E8%A6%BA%E9%86%92%EF%BC%89",
  "http://pad.skyozora.com/news/%EF%BC%8806/28%E5%AF%A6%E8%A3%9D%EF%BC%89%E9%83%A8%E4%BB%BD%E5%90%88%E4%BD%9C%E8%A7%92%E8%89%B2PowerUp%EF%BC%88%E8%A6%BA%E9%86%92%E6%8A%80%EF%BC%89"
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
