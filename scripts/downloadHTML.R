library(data.table)
library(rvest)
library(stringr)

setwd("C:/Users/Jutong/Documents/paddata")

extractMonIdsToScrape <- function(link) {
  webpage <- read_html(link)
  hrefs <- html_nodes(webpage, "a") %>% html_attr("href")
  hrefs_pets <- str_match(string = hrefs, pattern = "^pets/([0-9]{3,4})$")[,2]
  vt_id <- as.integer(hrefs_pets[!is.na(hrefs_pets)])
  vt_id
}

vt_link <- c(
  "http://pad.skyozora.com/",
  "http://pad.skyozora.com/news/%EF%BC%8806/07%E5%AF%A6%E8%A3%9D%EF%BC%89%E9%83%A8%E4%BB%BD%E5%90%88%E4%BD%9C%E8%A7%92%E8%89%B2%E8%BF%BD%E5%8A%A0%E9%80%B2%E5%8C%96%E5%BD%A2%E6%85%8B%EF%BC%86PowerUp%EF%BC%81"
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
path <- "http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/"
download.file(path, "raw/ActiveSkillType.html")
