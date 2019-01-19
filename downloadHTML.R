ids <- 5001:5022
for (id in ids) {
  download.file(paste0("http://pad.skyozora.com/pets/", id), paste0("HTMLs/", id, ".html"))
}

## For full download only
for (id in 1:5074) {
  download.file(paste0("http://pad.skyozora.com/pets/", id), paste0("HTMLs/", id, ".html"))
  if (id %% 100 == 0) Sys.sleep(30)
  if (id %% 10 == 0) Sys.sleep(3)
}