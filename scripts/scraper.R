library(rvest)
library(pbapply)
library(data.table)
library(DBI)
library(RSQLite)
library(stringr)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/paddata")
} else if (Sys.info()[["nodename"]] == "MU-JPAN") {
  setwd("C:/Users/jpan/Documents/repos/paddata")
} else if (Sys.info()[["nodename"]] == "jpan-personal") {
  setwd("/home/jpan/paddata")
}

updateMode <- TRUE
if (!exists("id.vt")) updateMode <- FALSE

con <- dbConnect(SQLite(), "padmonster.sqlite3")
for (table in dbListTables(con)) {
  assign(paste0(table, ".dt"), setDT(dbReadTable(con, table)))
}
dbDisconnect(con)

rmSpacesBreaks <- function(text.vt) {
  trimws(gsub(x = text.vt, pattern = "\\\n|\\\t", replacement = ""))
}

ifEmptythenNA <- function(x) {
  if (length(x)==0) {
    is.na(x) <- T
  }
  x
}


readMonsterPage <- function(MonsterId) {
  webpage <- tryCatch(
      read_html(paste0("raw/", MonsterId, ".html")),
      error = function(e) NA
    )
  if (is.na(webpage)) return(NA)
  if (length(webpage %>% html_nodes("table tr td table tr td h3") %>% html_text()) == 0) {
    webpage <- NA
  }
  webpage
}

if (!updateMode) {
  filenames <- list.files("raw/", pattern = "^[0-9]+.html$")
  id.vt <- 1:max(as.integer(gsub(x = filenames, pattern = ".html", replacement = "")))
}
webpage.ls <- lapply(id.vt, readMonsterPage)
names(webpage.ls) <- id.vt
webpage.ls[is.na(webpage.ls)] <- NULL


parseMonData <- function(webpage) {

  MonsterId <- webpage %>% html_nodes("table tr td table tr td h3") %>% html_text() %>%
    sub(pattern = "No\\.([0-9]+) - .*", replacement = "\\1") %>% as.integer()

  JpName <- webpage %>% html_nodes("table tr td table tr td h3") %>% html_text() %>%
    sub(pattern = ".* - (.*)", replacement = "\\1")

  CnName <- webpage %>% html_nodes("table tr td table tr td h2") %>% html_text()

  Rarity <- stringr::str_count(
    string = webpage %>% html_nodes("table+ table table td+ td") %>% html_text(),
    pattern = "★"
  )

  titles <- webpage %>% html_nodes("table tr td a") %>% html_attr("title")

  MainAtt <- titles %>%
    grep(pattern = "主屬性:(.)", value = T) %>%
    sub(pattern = "主屬性:(.)", replacement = "\\1")

  SubAtt <- titles %>%
    grep(pattern = "副屬性:(.)", value = T) %>%
    sub(pattern = "副屬性:(.)", replacement = "\\1")
  SubAtt <- ifEmptythenNA(SubAtt)

  alltypes <- Type.dt$TypeName

  Type <- titles %>%
    grep(pattern = paste(paste0("^", alltypes, "$"), collapse = "|"), value = T)

  stats <- webpage %>%
    html_nodes("table tr td table tr td") %>%
    html_text() %>% grep(pattern = "LV\\.", value = T)

  stats_lvmax <- stats[3]

  lvmax <- sub(x = stats_lvmax, pattern = ".*LV.([0-9]+).*", replacement = "\\1") %>% as.integer()
  hp_lvmax <- sub(x = stats_lvmax, pattern = ".*HP: ([0-9]+).*", replacement = "\\1") %>% as.integer()
  atk_lvmax <- sub(x = stats_lvmax, pattern = ".*攻擊力: ([0-9]+).*", replacement = "\\1") %>% as.integer()
  rcv_lvmax <- sub(x = stats_lvmax, pattern = ".*回復力: (\\-*[0-9]+).*", replacement = "\\1") %>% as.integer()

  hp_lv110 <- NA_integer_
  atk_lv110 <- NA_integer_
  rcv_lv110 <- NA_integer_

  if (length(stats)>7) {
    stats_lv110 <- stats[5]
    hp_lv110 <- sub(x = stats_lv110, pattern = ".*HP: ([0-9]+).*", replacement = "\\1") %>% as.integer()
    atk_lv110 <- sub(x = stats_lv110, pattern = ".*攻擊力: ([0-9]+).*", replacement = "\\1") %>% as.integer()
    rcv_lv110 <- sub(x = stats_lv110, pattern = ".*回復力: ([0-9]+).*", replacement = "\\1") %>% as.integer()
  }

  nodes <- webpage %>% html_nodes("table tr td")

  texts <- rmSpacesBreaks(nodes %>% html_text())

  ActiveSkillName <- sub(
    x = texts[grepl(x = texts, pattern = "^主動技能 -")],
    pattern = "主動技能 - (.*)",
    replacement = "\\1"
  )
  MaxCd <- texts[which(texts=="初始冷卻")+1] %>% str_extract(pattern = "[0-9]+") %>% as.integer()
  MinCd <- texts[which(texts=="最小冷卻")+1] %>% str_extract(pattern = "[0-9]+") %>% as.integer()
  ActiveSkillDescription <- paste0(xml_contents(nodes[which(texts=="最小冷卻")+2]), collapse = "")

  Assistable <- texts %>% grepl(pattern = "此寵物可以作為輔助寵物") %>% any()

  AwokenSkillHeadLoc <- which(html_text(nodes)=="覺醒技能" & html_attr(nodes, "class") == "head")
  AwokenSkill <- nodes[AwokenSkillHeadLoc+1] %>% html_nodes("a") %>% html_attr("title") %>% str_match("^【(.*)】")
  if (length(AwokenSkill)==0) {
    AwokenSkill <- character()
  } else {
    AwokenSkill <- AwokenSkill[,2]
  }

  SuperAwokenHeadLoc <- which(html_text(nodes)=="超覺醒" & html_attr(nodes, "class") == "head")
  SuperAwokenSkill <- nodes[SuperAwokenHeadLoc+1] %>% html_nodes("a") %>% html_attr("title") %>% str_match("^【(.*)】")
  if (length(SuperAwokenSkill)==0) {
    SuperAwokenSkill <- character()
  } else {
    SuperAwokenSkill <- SuperAwokenSkill[,2]
  }

  LeaderSkillNameLoc <- which(grepl(x = texts, pattern = "^隊長技能 -"))
  LeaderSkillName <- sub(
    x = texts[LeaderSkillNameLoc],
    pattern = "隊長技能 - (.*)",
    replacement = "\\1"
  )
  # LeaderSkillDescription <- texts[LeaderSkillNameLoc+2]
  LeaderSkillDescription <- paste0(xml_contents(nodes[LeaderSkillNameLoc+2]), collapse = "")
  if (LeaderSkillName == "無") LeaderSkillDescription <- "無"

  hrefs <- webpage %>% html_nodes("link") %>% html_attr("href")
  # MonsterIconDownload <- hrefs[grepl("i1296.photobucket.com/albums/ag18/skyozora/pets_icon", hrefs)]
  MonsterIconDownload <- hrefs[4]
  ## Added on 2020-01-01. Icon is stored on host instead of photobucket
  MonsterIconDownload <- paste0("https://pad.skyozora.com/", MonsterIconDownload)

  evoTargets <- webpage %>% html_nodes(".EvoTarget") %>% html_attr("href")
  if (length(evoTargets) == 0) {
    evoList <- c()
  } else {
    evoTargets <- grep(x = evoTargets, pattern = "pets/[0-9]+", value = T)
    evoList <- as.integer(gsub(x = evoTargets, pattern = "pets/([0-9]+)", replacement = "\\1"))
  }

  monData <- list(
      MonsterId = MonsterId,
      JpName = JpName,
      CnName = CnName,
      Rarity = Rarity,
      MainAtt = MainAtt,
      SubAtt = SubAtt,
      Type = Type,
      LvMax = lvmax,
      Hp = hp_lvmax,
      Atk = atk_lvmax,
      Rcv = rcv_lvmax,
      Hp110 = hp_lv110,
      Atk110 = atk_lv110,
      Rcv110 = rcv_lv110,
      ActiveSkillName = ActiveSkillName,
      ActiveSkillDescription = ActiveSkillDescription,
      Assistable = Assistable,
      MaxCd = MaxCd,
      MinCd = MinCd,
      AwokenSkill = AwokenSkill,
      SuperAwokenSkill = SuperAwokenSkill,
      LeaderSkillName = LeaderSkillName,
      LeaderSkillDescription = LeaderSkillDescription,
      MonsterIconDownload = MonsterIconDownload,
      evoList = evoList
    )

  # monData <- lapply(monData, ifEmptythenNA)

}

monData.ls <- lapply(webpage.ls, parseMonData)

if (updateMode) {
  monData.ls_old <- readRDS(file = "monData.rds")
  monData.ls <- modifyList(x = monData.ls_old, val = monData.ls)
}

dropNonAtomic <- function(l) {
  l$Type <- NULL
  l$AwokenSkill <- NULL
  l$SuperAwokenSkill <- NULL
  l$evoList <- NULL
  l
}

monData.dt <- rbindlist(lapply(monData.ls, dropNonAtomic))

getTypeRelation <- function(l) {
  data.table(MonsterId = l$MonsterId, TypeName = l$Type)
}
TypeLong.dt <- rbindlist(lapply(monData.ls, getTypeRelation))
TypeRelation2.dt <- merge(TypeLong.dt, Type.dt, by = "TypeName", all.x = T)
TypeRelation2.dt[, c("TypeName", "TypeIconDownload") := NULL]
setorder(TypeRelation2.dt, MonsterId)
TypeRelation2.dt[, Id := .I]

getAwokenSkillRelation <- function(l) {
  if (length(c(l$AwokenSkill, l$SuperAwokenSkill)) == 0) return(NULL)
  d <- data.table(MonsterId = l$MonsterId, AwokenSkillName = c(l$AwokenSkill, l$SuperAwokenSkill), SuperAwoken = 1L)
  d[, Position := .I]
  d[Position <= length(l$AwokenSkill), SuperAwoken := 0L]
  d
}
AwokenSkillLong.dt <- rbindlist(lapply(monData.ls, getAwokenSkillRelation))
AwokenSkillRelation2.dt <- merge(AwokenSkillLong.dt, AwokenSkill.dt, by = "AwokenSkillName", all.x = T)
AwokenSkillRelation2.dt[, c("AwokenSkillName", "AwokenSkillIconDownload", "AwokenSkillDescription") := NULL]
setcolorder(AwokenSkillRelation2.dt, c("MonsterId", "AwokenSkillId", "Position", "SuperAwoken"))
setorder(AwokenSkillRelation2.dt, MonsterId, Position)
AwokenSkillRelation2.dt[, Id := .I]

ActiveSkill2.dt <- monData.dt[, c("ActiveSkillName", "ActiveSkillDescription", "MinCd", "MaxCd")]
## Some evo materials share same skill but their MinCd = MaxCd because they cannot level up
## Always use the minimum CD across monsters with the same skill
ActiveSkill2.dt[, MinCd := min(MinCd), by = ActiveSkillName]
ActiveSkill2.dt <- unique(ActiveSkill2.dt, by = "ActiveSkillName")
ActiveSkill2.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "images/drops", replacement = "img/Orb")]
ActiveSkill2.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = 'width="25"', replacement = 'width="19"')]
ActiveSkill2.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = '<img src="images/change.gif">', replacement = '變成')]
ActiveSkill2.dt[, ActiveSkillId := .I]

ActiveSkillType2.dt <- merge(
    ActiveSkill.dt[, c("ActiveSkillId", "ActiveSkillName")],
    ActiveSkillType.dt[, c("ActiveSkillId", "ActiveSkillType")],
    by = "ActiveSkillId"
  )
ActiveSkillType2.dt[, ActiveSkillId := NULL]
ActiveSkillType2.dt <- merge(
    ActiveSkill2.dt[, c("ActiveSkillId", "ActiveSkillName")],
    ActiveSkillType2.dt[, c("ActiveSkillName", "ActiveSkillType")],
    by = "ActiveSkillName"
  )
ActiveSkillType2.dt[, ActiveSkillName := NULL]
setkey(ActiveSkillType2.dt, ActiveSkillId)

LeaderSkill2.dt <- unique(
  monData.dt[, c("LeaderSkillName", "LeaderSkillDescription")],
  by = "LeaderSkillName")
LeaderSkill2.dt[, LeaderSkillId := .I]

evo.ls <- unique(lapply(monData.ls, function(l) l$evoList))
evo.ls <- evo.ls[lengths(evo.ls)>0]
evo.dt <- rbindlist(lapply(evo.ls, function(v) data.table(MonsterId = v)), idcol = "EvoGroup")

monData.dt <- merge(monData.dt, ActiveSkill2.dt[, c("ActiveSkillName", "ActiveSkillId")], by = "ActiveSkillName", all.x = T)
monData.dt <- merge(monData.dt, LeaderSkill2.dt[, c("LeaderSkillName", "LeaderSkillId")], by = "LeaderSkillName", all.x = T)
setkey(monData.dt, MonsterId)
Monster2.dt <- monData.dt[, c(
    "MonsterId", "JpName", "CnName", "Rarity", "MainAtt", "SubAtt",
    "LvMax", "Hp", "Atk", "Rcv",
    "Hp110", "Atk110", "Rcv110",
    "ActiveSkillId", "Assistable", "LeaderSkillId",
    "MonsterIconDownload"
  )]
Monster2.dt[, Id := .I]

con <- dbConnect(SQLite(), "padmonster.sqlite3")

dbExecute(con, "DELETE FROM Monster")
dbWriteTable(con, "Monster", Monster2.dt, append = T)

dbExecute(con, "DELETE FROM TypeRelation")
dbWriteTable(con, "TypeRelation", TypeRelation2.dt, append = T)

dbExecute(con, "DELETE FROM AwokenSkillRelation")
dbWriteTable(con, "AwokenSkillRelation", AwokenSkillRelation2.dt, append = T)

dbExecute(con, "DELETE FROM ActiveSkill")
dbWriteTable(con, "ActiveSkill", ActiveSkill2.dt, append = T)

dbExecute(con, "DELETE FROM ActiveSkillType")
dbWriteTable(con, "ActiveSkillType", ActiveSkillType2.dt, append = T)

dbExecute(con, "DELETE FROM LeaderSkill")
dbWriteTable(con, "LeaderSkill", LeaderSkill2.dt, append = T)

dbExecute(con, "DELETE FROM Evolution")
dbWriteTable(con, "Evolution", evo.dt, append = T)

dbDisconnect(con)

saveRDS(monData.ls, file = "monData.rds")
