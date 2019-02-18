setwd("C:/Users/Jutong/Documents/paddata")

id.vt <- c(5129:5134, 5154)
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
