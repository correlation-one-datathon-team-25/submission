bases = read.csv("bases.csv")
demo = read.csv("demographics.csv")
geo = read.csv("geographic.csv")
zones = read.csv("zones.csv")

#uber_2014 = read.csv("uber_trips_2014.csv")
#uber_2015 = read.csv("uber_trips_2015.csv")
uber_2014f = read.csv("uber14_filtered.csv")
uber_2015f = read.csv("uber15_filtered.csv")
greenf = read.csv("green_filtered2.csv")
yellowf = read.csv("yellow14Q2_filtered.csv")

save.image(file="data.RData")

nona <- function(x){
  x[!is.na(x)]
}

library(rgeos)
library(sp)
library(rgdal)
library(scales)
longs = geo[seq(1, nrow(geo),2),]
lats = geo[seq(2, nrow(geo),2),]
spl = list()
for(col in 1:ncol(longs)){
  p1 <- Polygon(cbind(x=nona(longs[,col]), y=nona(lats[,col])), hole=FALSE)
  lp <- list(p1)
  pls <- Polygons(lp, ID=colnames(longs)[col])
  spl = c(spl, pls)
}

sps <- SpatialPolygons(spl)
plot(sps) #, col="magenta", pbg="cyan")

plot_nta <- function(col){
  p1 <- Polygon(cbind(x=nona(longs[,col]), y=nona(lats[,col])), hole=FALSE)
  lp <- list(p1)
  pls <- Polygons(lp, ID=colnames(longs)[col])
  spl <- list(pls)
  plot(SpatialPolygons(spl))
}
              
#library(rworldmap)
#newmap <- getMap(resolution = "low")
#plot(newmap, xlim = c(-20, 59), ylim = c(35, 71), asp = 
uber = uber_2014[sample(1:nrow(uber_2014),10000,F),]

get_nta <- function(zone_id){
   return zones[zone_id,]$nta_code
}

green_nz = green[green$dropoff_longitude!=0,]
green_nz2 = green_nz[green_nz$pickup_longitude!=0,]
greenq = green_nz[sample(1:nrow(green_nz),10000,F),]
greenq2 = green_nz2[sample(1:nrow(green_nz2),10000,F),]

points(uber$pickup_longitude, uber$pickup_latitude, col = "red", cex = .3)
points(greenq2$pickup_longitude, greenq2$pickup_latitude, col = "blue", cex = .3)
points(greenq$dropoff_longitude, greenq$dropoff_latitude, col = "green", cex = .3)

dat <- SpatialPoints(data.frame(Longitude = greenq2$pickup_longitude,
                  Latitude = greenq2$pickup_latitude,
                  names = 1:nrow(greenq2)))
m <- over(dat, sps)
plot_nta(m[3])
points(greenq2$pickup_longitude[3], greenq2$pickup_latitude[3], col = "blue", cex = 1.0)


#plotting
uber_smpl = uber_2014f[sample(1:nrow(uber_2014f),10000,F),]
green_nz2 = greenf[greenf$pickup_longitude!=0,]
green_smpl = green_nz2[sample(1:nrow(green_nz2),10000,F),]
yellow_nz2 = yellowf[yellowf$pickup_longitude!=0,]
yellow_smpl = yellow_nz2[sample(1:nrow(yellow_nz2),10000,F),]
par(mfrow=c(2,2))
plot(sps, border="gray", main = "Pickup Locations for Each Service") 
for(i in 1:5){
  points(uber_smpl$pickup_longitude, uber_smpl$pickup_latitude, col = alpha("red",0.02), cex = 0.3)
  points(green_smpl$pickup_longitude, green_smpl$pickup_latitude, col = alpha("green",0.02), cex = 0.3)
  points(yellow_smpl$pickup_longitude, yellow_smpl$pickup_latitude, col = alpha("yellow",0.02), cex = 0.3)
}
plot(sps, border="gray", main = "Pickup Locations (Uber 2014)") 
points(uber_smpl$pickup_longitude, uber_smpl$pickup_latitude, col = alpha("red",0.1), cex = 0.3)
plot(sps, border="gray", main = "Pickup Locations (Green Cab)") 
points(green_smpl$pickup_longitude, green_smpl$pickup_latitude, col = alpha("green",0.1), cex = 0.3)
plot(sps,border="gray",  main = "Pickup Locations (Yellow Cab 2014 Q1)") 
points(yellow_smpl$pickup_longitude, yellow_smpl$pickup_latitude, col = alpha("yellow",0.1), cex = 0.3)


#
#points(greenf$pickup_longitude[, greenf$pickup_latitude[3], col = "blue", cex = 1.0)


library(chron)
get_ntas_by_loc <- function(dat){
  pts <- SpatialPoints(data.frame(Longitude = dat$pickup_longitude,
                                  Latitude = dat$pickup_latitude,
                                  names = 1:nrow(dat)))
  colnames(geo)[over(pts, sps)]
}
get_nta_indices <- function(codes){
  q = rep(0, length(codes))
  for(i in 1:length(codes)){
    q[i] = which(demo$nta_code==codes[i]) 
  }
  q
}
countCharOccurrences <- function(char, s) {
  s2 <- gsub(char,"",s)
  return (nchar(s) - nchar(s2))
}
filter_by_morning <- function(dat,  ymd = "y-m-d"){
  dtparts = t(as.data.frame(strsplit(as.vector(dat$pickup_datetime),' ')))
  row.names(dtparts) = NULL
  hms = "h:m:s" #ifelse(seconds, "h:m:s", "h:m")

  ttm = ifelse(countCharOccurrences(":",dtparts[,2])==2, dtparts[,2], paste(dtparts[,2],rep(":00",nrow(dtparts)),sep=""))
  times = chron(dates=dtparts[,1],times=ttm,
                                       format=c(ymd,hms))
  #print(which(is.na(times))[1:100])
  hrs = hours(times)
  wks = is.weekend(times)
  holidays = is.holiday(times)
  return(dat[!wks & !holidays & hrs >=5 & hrs<=7,])
}


hist(demo$mean_income, xlim=c(0,400000),breaks=seq(from=0,to=400000,length.out=20))

weighted <- c()
for(r in 1:nrow(demo)){
  nt = demo[r,]
  for(k in 1:round(nt$population / 3000)){
    weighted = rbind(weighted, nt)
  }
}

green_morning <- filter_by_morning(greenf)
ntas <- get_ntas_by_loc(green_morning)
tp="Green Cab"

uber_morning <- filter_by_morning(uber_2014f,  ymd="m/d/y")
ntas <- get_ntas_by_loc(uber_morning)
tp="Uber"

yellow_morning <- filter_by_morning(yellowf)
ntas <- get_ntas_by_loc(yellow_morning)
tp="Yellow Cab"

ntasn <- ntas[!is.na(ntas)]
nta_indices <- get_nta_indices(ntasn)
ntad <- demo[nta_indices,]


par(mfrow=c(1,1))
hist(ntad$mean_income / 1000, xlim=c(0,400),breaks=seq(from=0,to=400,length.out=20), main=paste("Estimated Mean Income Distribution\nfor ",tp," Customers",sep=""), freq=T, xlab="Mean Income by NTA  (in thousands of dollars)")
hist(weighted$mean_income / 1000, xlim=c(0,400),breaks=seq(from=0,to=400,length.out=20), main="Estimated Mean Income Distribution\nfor NYC", freq=T, xlab = "Mean Income by NTA (in thousands of dollars)")

hist(ntad$median_age, xlim=c(15,60),breaks=seq(from=15,to=60,length.out=20), main = paste("Estimated Median Age Distribution\nfor ",tp," Customers",sep=""), xlab="Median Age by NTA", freq=F)
hist(weighted$median_age, xlim=c(15,60),breaks=seq(from=15,to=60,length.out=20), main = "Estimated Median Age Distribution\nfor NYC", xlab="Median Age by NTA",freq=F)

library(mgcv)
dtparts = t(as.data.frame(strsplit(as.vector(greenf$pickup_datetime),' ')))
row.names(dtparts) = NULL
hms = "h:m:s"
ymd = "y-m-d"
ttm = ifelse(countCharOccurrences(":",dtparts[,2])==2, dtparts[,2], paste(dtparts[,2],rep(":00",nrow(dtparts)),sep=""))
green_times = chron(dates=dtparts[,1],times=ttm,
              format=c(ymd,hms))
mnt = months(green_times)
green_t = as.numeric(as.character(years(green_times)))+(as.numeric(mnt)-1)/12 + as.numeric(as.character(days(green_times))) / 30
smp <- sample(1:length(green_t), 10000, replace=F)
greens = green_t[smp]
greenfs = greenf[smp,]
plot(greens, greenfs$trip_distance)
plot(greens, greenfs$total_amount, xlab="Year",ylab="Dollars Spent on Ride",ylab = "Green Cab Fares")
gam1 <- gam(greenfs$trip_distance ~ s(greens))

gam1 <- gam(dst ~ s(tm), data = data.frame(dst = greenfs$trip_distance, tm = greens))

gam1 <- gam(greenf$trip_distance ~ s(green_t))

gam2 <- gam(dst ~ s(tm), data = data.frame(dst = greenfs$total_amount, tm = greens))

gam3 <- gam(amt ~ dst + s(tm), data = data.frame(dst = greenfs$trip_distance, amt = greenfs$total_amount, tm = greens))

grid = data.frame(dst=rep(3, 100), tm = seq(from=2014, to=2016.5, length.out=100))
plot(grid$tm, predict(gam3, newdata=grid), xlab="Year", ylab="Average Cost for 3 Mile Trip", main="Green Cab Price Over Time")

grid = data.frame(dst=seq(from=1,to=10,length.out=100), tm =2015)
plot(grid$dst, predict(gam3, newdata=grid))

#grid=seq(from=2014,to=2016,length.out=100)
curve(predict(gam1, newdata=data.frame(tm=x)), col="green", add=TRUE)


curve(predict(gam2, newdata=data.frame(tm=x)), col="green", add=TRUE)
#dtparts = t(as.data.frame(strsplit(as.vector(green$pickup_datetime),' ')))
#row.names(dtparts) = NULL
#hms = "h:m:s" #ifelse(seconds, "h:m:s", "h:m")

#ttm = ifelse(countCharOccurrences(":",dtparts[,2])==2, dtparts[,2], paste(dtparts[,2],rep(":00",nrow(dtparts)),sep=""))
#yellow_times = chron(dates=dtparts[,1],times=ttm,
#                    format=c(ymd,hms))