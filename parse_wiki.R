# load packages
library(RCurl)
library(XML)
library(stringr)

# 1. Lets parse the table of  all sovereign states from here: http://en.wikipedia.org/wiki/List_of_sovereign_states
# to get url's to English page of each state

html <- getURL("http://en.wikipedia.org/wiki/List_of_sovereign_states", followlocation = TRUE)

# parse html
doc <-  htmlParse(html, asText=TRUE)
tbls <- xpathSApply(doc, "//table[@class='sortable wikitable']", saveXML)
x <- tbls[nchar(tbls) == max(nchar(tbls))]

str <- unlist(strsplit(x, '</span><a href="/wiki/'))
str <- gsub(pattern = '\\\"(.*)', replacement = '', x = str, perl = TRUE)
str <- gsub(pattern = '\\\"(.*)', replacement = '', x = str, perl = TRUE)
str <- gsub(pattern = '(\\\n)(.*)', replacement = "", x = str, perl = TRUE)
countries <- str[-1]
# add ones not included in the list, but can be found in countrycode-package
countries <- c(countries,"Aland_Islands")
# remove possible duplicates
countries <- countries[!duplicated(countries)]
urls <- paste0("http://en.wikipedia.org/wiki/",countries)



# 2. Now we have the links, so lets go through each country page and 
# fetch the links to each language version of that page - and get there the
# language name in English AND country name in the language in question

for (i in 1:length(urls)){
  
  # download html
  html <- getURL(urls[i], followlocation = TRUE)
  
  # parse html
  doc <-  htmlParse(html, asText=TRUE)
  lists <- xpathSApply(doc, "//div[@class='body']/ul", saveXML)
  x <- lists[nchar(lists) == max(nchar(lists))]
  str <- unlist(strsplit(x, "title="))[-1]
  str <- gsub(pattern = '(\\\n)(.*)', replacement = "", x = str, perl = TRUE)
  str <- gsub(pattern = "(lang)(.*)", replacement = "", x = str, perl = TRUE)
  str <- str_replace_all(str, '\\\"','')
  
  str <- str_replace_all(str, ' – ',';')
  str <- str[grep(";", str)]
  str <- str_trim(str)
  str <- str_replace_all(str, "'","")
  
  
  ## as there are some strings with no ; marks, we get rid of them
  dd <- read.table(text = str, sep = ";", colClasses = "character")
  names(dd) <- c(countries[i],"lang")

  ## English language region name from title-element
  title <- xpathSApply(doc, "//title", saveXML)
  title <- gsub(pattern = "( - Wikipedia)(.*)", replacement = "", x = title, perl = TRUE)
  title <- str_replace_all(title, '<title>','')
  # fix this exception ""Northern economic region, Russia"
  newrow <- data.frame(title,"English.wikipedia")
  names(newrow) <- c(countries[i],"lang")
  dd <- rbind(dd,newrow)
    
  if (i == 1) dat <- dd
  dat <- dat[!duplicated(dat["lang"]),]
  if (i != 1) dat <- merge(dat,dd,by="lang", all.x=TRUE)
}

# finally, transpose the data

data <- as.data.frame(t(dat[-1]))

# create language names from row.names of the dat and refine them a bit
new_names <- paste0("country.name.",tolower(as.character(dat[[1]])))
new_names <- str_replace_all(new_names, " ", ".")
new_names <- str_replace_all(new_names, "/", ".")
new_names <- str_replace_all(new_names, "\\.{3}", ".")
new_names <- str_replace_all(new_names, "\\.{2}", ".")
new_names <- str_replace_all(new_names, "\\)", "")
new_names <- str_replace_all(new_names, "\\(", "")
names(data) <- new_names

# then the for merging with countrycode "base" data
merge.name <- row.names(data)
## remove the .x's and .y's
merge.name <- str_replace_all(merge.name, "\\.x", "")
merge.name <- str_replace_all(merge.name, "\\.y", "")
## apply the new naMES
data$merge.name <- merge.name

for (i in 1:ncol(data)) {
  data[[i]] <- as.character(data[[i]])
}

# load the wiki-key data to be able to combine with original data in prep.R script
library(RCurl)
GHurl <- getURL("https://raw.githubusercontent.com/muuankarski/data/master/world/wiki_key.csv")
wiki <- read.csv(text = GHurl)
wiki[2][wiki[2] == ""] <- NA

data <- merge(data,wiki[1:2],by="merge.name")

write.csv(data, "data/wiki_names.csv", row.names = FALSE)

## Colnames to exclude in countrycode()-function
# cat(paste(shQuote(names(data), type="cmd"), collapse=", "))