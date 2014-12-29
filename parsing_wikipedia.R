library(XML)
# A-C
theurl <- "http://en.wikipedia.org/wiki/List_of_country_names_in_various_languages_%28A%E2%80%93C%29"
tables <- readHTMLTable(theurl)

ta <- as.data.frame(tables[2])
tb <- as.data.frame(tables[3])
tc <- as.data.frame(tables[4])

# D-I
theurl <- "http://en.wikipedia.org/wiki/List_of_country_names_in_various_languages_%28D%E2%80%93I%29"
tables <- readHTMLTable(theurl)

td <- as.data.frame(tables[2])
te <- as.data.frame(tables[3])
tf <- as.data.frame(tables[4])
tg <- as.data.frame(tables[5])
th <- as.data.frame(tables[6])
ti <- as.data.frame(tables[7])

# J-P
theurl <- "http://en.wikipedia.org/wiki/List_of_country_names_in_various_languages_%28J%E2%80%93P%29"
tables <- readHTMLTable(theurl)

tj <- as.data.frame(tables[2])
tk <- as.data.frame(tables[3])
tl <- as.data.frame(tables[4])
tm <- as.data.frame(tables[5])
tn <- as.data.frame(tables[6])
to <- as.data.frame(tables[7])
tp <- as.data.frame(tables[8])

# Q-Z
theurl <- "http://en.wikipedia.org/wiki/List_of_country_names_in_various_languages_%28Q%E2%80%93Z%29"
tables <- readHTMLTable(theurl)

tq <- as.data.frame(tables[3])
tr <- as.data.frame(tables[4])
ts <- as.data.frame(tables[5])
tt <- as.data.frame(tables[6])
tu <- as.data.frame(tables[7])
tv <- as.data.frame(tables[8])
tw <- as.data.frame(tables[9])
ty <- as.data.frame(tables[10])
tz <- as.data.frame(tables[11])

rm(tables)
rm(theurl)

tbls <- unique(apropos("^t[a-z]$"))

df <- data.frame()
for (i in tbls) {
  dat <- get(i)
  dat <- dat[1:2] # only two columns
  names(dat) <- c("english","other")
  df <- rbind(df,dat)
}

library(stringr)
library(zoo)

for (i in 1:nrow(df)) {
  row <- df[i,]
  lang <- as.character(row[[2]])
  if (nchar(lang) < 50) next # in case there a such as "Burma see Myanmar
  # -- use parenthesis as distinguisher between name and language: name is always followed by language in parenthesis
  ## for simplicity all ) and ), -> ;
  lang <- str_replace_all(lang, "),", ";") # 
  lang <- str_replace_all(lang, ")", ";") 
  # -- lets split our sting into separate name & language strings
  str <- unlist(strsplit(lang, ";"))
  # -- many langiages share the same country name, which are separate by comma in parenthesis after the name
  ## therefore we need to create unique row for each language by
  str <- str_replace_all(str, ",", ";(") # replacing dot with ";(" (opening parethesis separates name from language ) 
  str <- unlist(strsplit(str, ";")) # splitting the string using ; gives as long vector as there are languages 
  ## then we replace all openning parenthesis with ; and 
  d <- str_replace_all(str, "\\(", ";")
  ## as there are some strings with no ; marks, we get rid of them
  d <- d[grep(";", d)]
  ## and there are some with two "; ;", so we replace with a single
  d <- str_replace_all(d, "; ;", ";")
  d <- str_replace_all(d, "'", "")
  ## some names also have two options sepatated with / -> so we shall replace that with OR 
  #d <- str_replace_all(d, "/", " OR ")
  #d <- str_replace_all(d, "\n", "")
  ## - Korean language seem problematic - removing it
  if (!(i %in% c(65,123,192,205,224,237))) d <- d[-grep(";Korean", d)]
  # -- few problematic rows
  ## in row 35 (Burundi) row 50 causes error)
  if (i == 16) d <- d[c(-58)]
  if (i == 35) d <- d[c(-41,-50)]
  if (i == 40) d <- d[c(-4:-6,-21)]
  if (i == 41) d <- d[c(-16,-49)]
  if (i == 44) d <- d[c(-78)]
  if (i == 47) d <- d[c(-29)]
  if (i == 56) d <- d[c(-32)]
  if (i == 72) d <- d[c(-48)]
  if (i == 89) d <- d[c(-11)]
  if (i == 107) d <- d[c(-52)]
  if (i == 110) d <- d[c(-50)]
  if (i == 112) d <- d[c(-56,-61)]
  if (i == 114) d <- d[c(-46,-66)]
  if (i == 122) d <- d[c(-8)]
  if (i == 124) d <- d[c(-36)]
  if (i == 147) d <- d[c(-55)]
  if (i == 163) d <- d[c(-50)]
  if (i == 166) d <- d[c(-8)]
  if (i == 196) d <- d[c(-1)]
  if (i == 204) d <- d[c(-15)]
  if (i == 207) d <- d[c(-40)]
  if (i == 223) d <- d[c(-20,-27,-28)]
  if (i == 228) d <- d[c(-1)]
  if (i == 235) d <- d[c(-48)]
  if (i == 236) d <- d[c(-15)]
  if (i == 239) d <- d[c(-40)]
  if (i == 249) d <- d[c(-8)]
  if (i == 255) d <- d[c(-20)]
  if (i == 281) d <- d[c(-8)]
  ## 
  ## split each string into two columns based on ; 
  dd <- read.table(text = d, sep = ";", colClasses = "character")
  # -- now we have a data.frame with empty values where there should be the name nearest above 
  # -- so we replace emtpy with NA 
  dd$V1[dd$V1 == ""] <- NA
  ## use na.locf() from package zoo to replace NA values with nearest value from above
  dd <- na.locf(dd)
  # leave only the foreing character part of country names
  dd$V1 <- gsub("^.*\\-", "", dd$V1)
  dd$V1 <- gsub("^.*\\–", "", dd$V1)
  
  
  # then we remove the whitespaces from both columns
  dd$V1 <- str_trim(dd$V1)
  dd$V2 <- str_trim(dd$V2)
  #  new col names
  names(dd) <- c(as.character(row[[1]]),"lang")
  
  if (i == 1) dat <- dd
  dat <- dat[!duplicated(dat["lang"]),]
  if (i != 1) dat <- merge(dat,dd,by="lang", all.x=TRUE)
}

# transpose dat
data <- as.data.frame(t(dat[-1]))
names(data) <- paste0("country.name.",tolower(as.character(dat[[1]])))
data$country.name.english <- row.names(data)
data <- data[c(65,1:64)]

# load the wiki-key data
library(RCurl)
GHurl <- getURL("https://raw.githubusercontent.com/muuankarski/data/master/world/wiki_key.csv")
wiki <- read.csv(text = GHurl)
wiki[2][wiki[2] == ""] <- NA

# load countrycode data
load("data/countrycode_data.rda")

# -- two-step merge
## 1. countrycode data with wiki-key
dat1 <- merge(countrycode_data,wiki,by="country.name")
## 2. countrycode data with whole wikipedia-countryname data
dat2 <- merge(dat1,data,by="country.name.english", all.x=TRUE)
countrycode_data <- dat2[c(2:16,1,17:80)]

for (i in 16:80) {
  countrycode_data[[i]] <- as.character(countrycode_data[[i]])
}

save(countrycode_data, file="data/countrycode_data.rda")
write.csv(countrycode_data, file="data/countrycode_data.csv")

