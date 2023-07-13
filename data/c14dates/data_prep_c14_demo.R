library(here)
library(rcarbon)
# library(rnaturalearth)
# library(sf)
# library(maptools)
# library(rgeos)
library(dplyr)
# library(spdep)
source(here('src','dbscanID.R'))

# Read 14C Data ----
c14db  <- read.csv(here('data','c14dates','c14db_1.0.0.csv'))
c14db.raw  <- read.csv(here('data','c14dates','binded.csv')) 
c14db <- left_join(c14db,c14db.raw,by=c('LabCode'='LabCode'))

# Subset to Key Regions ----
c14db <- subset(c14db,!is.na(Latitude)&!is.na(Longitude)&!Prefecture%in%c('Hokkaido','Okinawa'))
c14db  <- c14db[,-which(colnames(c14db)=='Region')]
region.match  <- read.csv(here('data','c14dates','prefecture_region_match.csv'))
c14db <- left_join(c14db,region.match)
c14db  <- subset(c14db,Region%in%c('Tokai','Chubu'))


# Aggregate into aritifical Sites using DBSCAN ----
# Add SiteID based on DBSCAN
source(here('data','c14dates','dbscanID.R'))
c14db$SiteID  <- dbscanID(sitename=c14db$SiteNameEn,longitude = c14db$Longitude,latitude = c14db$Latitude,eps=100)

# Handle Dates
c14db$C14Age = c14db$UnroundedCRA
i = which(is.na(c14db$C14Age))
c14db$C14Age[i] = c14db$CRA[i]

c14db$C14Error = c14db$UnroundedCRAError
i = which(is.na(c14db$C14Error))
c14db$C14Error[i] = c14db$CRAError[i]

c14db  <- subset(c14db,!is.na(C14Age) & !is.na(C14Error))

# Consider only terrestrial dates ----
c14db  <- subset(c14db,Material=='Terrestrial')

# Consider only anthropogenic dates ----
anthropicGrep = c("住居","埋葬","竪穴建物","掘立柱","墓","包含層","土坑","ピット","土器","捨場","遺構","炉","人骨","木舟","住","柱","Pit","焼土","カマド","床面","溝中","溝底部","建物跡","木製品","埋土","水田","竪坑","羨道","集石","漆器","トチ塚","層","貯蔵穴","掘立","木棺","方形周溝","配石","窯","遺物","竪穴","道","棺","石室","址","室","SI","SB","SK")
c14db$anthropic = grepl(paste(anthropicGrep,collapse="|"),c14db$SamplingLocation) #sum(c14db$anthropic) 10683
# write.csv(unique(select(c14db,SamplingLocation,anthropic)),file="temp.csv")
c14db  <- subset(c14db,anthropic==TRUE)
save(c14db,file=here('data','c14demo.RData'))
