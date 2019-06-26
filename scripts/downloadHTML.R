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

extractMonIdsToScrape <- function(link) {
  webpage <- read_html(link)
  hrefs <- html_nodes(webpage, "a") %>% html_attr("href")
  hrefs_pets <- str_match(string = hrefs, pattern = "^pets/([0-9]{3,4})$")[,2]
  vt_id <- as.integer(hrefs_pets[!is.na(hrefs_pets)])
  vt_id
}

vt_link <- c(
  "http://pad.skyozora.com/",
  "http://pad.skyozora.com/news/%E6%96%B0%E9%99%8D%E8%87%A8%E5%9C%B0%E4%B8%8B%E5%9F%8E%E3%80%8C%E3%82%A8%E3%83%AA%E3%82%B9%E9%99%8D%E8%87%A8%EF%BC%81%E3%80%90%E5%85%A8%E5%B1%9E%E6%80%A7%E5%BF%85%E9%A0%88%E3%80%91%E3%80%8D%E7%99%BB%E5%A0%B4!!"
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
