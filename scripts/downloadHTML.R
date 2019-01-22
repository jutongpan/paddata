setwd("C:/Users/Jutong/Documents/paddata")

ids <- 5001:5022
for (id in ids) {
  download.file(paste0("http://pad.skyozora.com/pets/", id), paste0("raw/", id, ".html"))
}

## For full download only
for (id in 1:5074) {
  download.file(paste0("http://pad.skyozora.com/pets/", id), paste0("raw/", id, ".html"))
  if (id %% 100 == 0) Sys.sleep(30)
  if (id %% 10 == 0) Sys.sleep(3)
}

## Download page of active skills by type
path <- "http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/"
download.file(path, "raw/ActiveSkillType.html")
