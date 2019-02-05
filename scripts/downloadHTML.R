setwd("C:/Users/Jutong/Documents/paddata")

id <- 1
while (id <= 5128) {
  tryCatch(
    {
      download.file(paste0("http://pad.skyozora.com/pets/", id), paste0("raw/", id, ".html"))
      if (id %% 100 == 0) Sys.sleep(30)
      if (id %% 10 == 0) Sys.sleep(3)
      id <- id + 1
    },
    error = function(e) {
      Sys.sleep(300)
    }
  )
}

## Download page of active skills by type
path <- "http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/"
download.file(path, "raw/ActiveSkillType.html")
