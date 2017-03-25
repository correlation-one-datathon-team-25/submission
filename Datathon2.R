green_filtered = read.csv("green_filtered2.csv")
uber14_filtered = read.csv("uber14_filtered.csv")
uber15_filtered = read.csv("uber15_filtered.csv")
yellow14Q2_filtered = read.csv("yellow14Q2_filtered.csv")
yellow14Q3_filtered = read.csv("yellow14Q3_filtered.csv")
yellow15Q1_filtered = read.csv("yellow15Q1_filtered.csv")
yellow15Q2_filtered = read.csv("yellow15Q2_filtered.csv")

yellow14Q2_filtered$date = substr(yellow14Q2_filtered$pickup_datetime, gregexpr("-", yellow14Q2_filtered$pickup_datetime)[[1]][1] + 1, gregexpr("-", yellow14Q2_filtered$pickup_datetime)[[1]][2] - 1)
unique(yellow14Q2_filtered$date)
yellow14Q3_filtered$date = substr(yellow14Q3_filtered$pickup_datetime, gregexpr("-", yellow14Q3_filtered$pickup_datetime)[[1]][1] + 1, gregexpr("-", yellow14Q3_filtered$pickup_datetime)[[1]][2] - 1)
unique(yellow14Q3_filtered$date)
yellow15Q1_filtered$date = substr(yellow15Q1_filtered$pickup_datetime, gregexpr("-", yellow15Q1_filtered$pickup_datetime)[[1]][1] + 1, gregexpr("-", yellow15Q1_filtered$pickup_datetime)[[1]][2] - 1)
unique(yellow15Q1_filtered$date)
yellow15Q2_filtered$date = substr(yellow15Q2_filtered$pickup_datetime, gregexpr("-", yellow15Q2_filtered$pickup_datetime)[[1]][1] + 1, gregexpr("-", yellow15Q2_filtered$pickup_datetime)[[1]][2] - 1)
unique(yellow15Q2_filtered$date)

yellow = c(table(yellow14Q2_filtered$date), table(yellow14Q3_filtered$date), c(NA, NA, NA), table(yellow15Q1_filtered$date), table(yellow15Q2_filtered$date))
yellow = ts(as.vector(yellow), start=c(2014, 4), frequency=12)
plot(yellow * 100)

uber14_filtered$date = substr(uber14_filtered$pickup_datetime, 1, gregexpr("/", uber14_filtered$pickup_datetime)[[1]][1] - 1)
unique(uber14_filtered$date)

uber15_filtered$date = substr(uber15_filtered$pickup_datetime, gregexpr("-", uber15_filtered$pickup_datetime)[[1]][1] + 1, gregexpr("-", uber15_filtered$pickup_datetime)[[1]][2] - 1)
unique(uber15_filtered$date)

uber = c(table(uber14_filtered$date), c(NA, NA, NA), table(uber15_filtered$date))
uber = ts(as.vector(uber), start=c(2014, 4), frequency=12)

green_filtered$date = substr(green_filtered$pickup_datetime, 1, gregexpr("-", green_filtered$pickup_datetime)[[1]][2] - 1)
unique(green_filtered$date)

green = ts(as.vector(table(green_filtered$date)), start=c(2014, 4), frequency=12)



#-------------------------------------------------------------------------------------------------------------

plot(uber * 100, lwd=3, main="Trips 2014-2015", ylab="Frequency (In Millions)", xaxt="n", yaxt="n", xlab="", col="red", ylim=c(0,15000000))
axis(1, at=c(2014.25, 2014.333, 2014.417, 2014.5, 2014.583, 2014.666, 2014.75, 2014.833, 2014.917, 2015, 2015.083, 2015.167, 2015.25, 2015.333, 2015.417), labels=c("April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June"), las=2)
axis(2, at=c(0, 1000000, 2000000, 3000000, 4000000, 5000000, 6000000, 7000000, 8000000, 9000000, 10000000, 11000000, 12000000, 13000000, 14000000, 15000000), labels=0:15)
lines(green * 100, lwd=3, col="green")
lines(yellow * 100, lwd=3, col="darkorange")
legend(95, 95, legend=c("Uber", "Green Taxis", "Other FHVs"), col=c("red", "green", "blue"), lwd=3)

predict(green)
predict(uber)
