library(readxl)
library(ggplot2)
library(dplyr)
library(patchwork)

#Import Cropped Image Data

croppedinfo <- read_xlsx("C:/Users/hwilson23/Documents/UserDataOWS/neweditednames/croppeddataeditednames.xlsx")


#Filter out each dye type by lifetime values
RhoBcrop <- filter(croppedinfo, CCVMean <2500)
Rho110crop <- filter(croppedinfo, CCVMean >2500)


#Plot lifetime standard deviation vs mean
Rho110p1 <- ggplot() +
  geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV, color = PowerCategory), size=2)
  

RhoBp2 <- ggplot() +
  geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVSTDEV, color = PowerCategory), size = 2)
  


patchwork12 <- Rho110p1 + RhoBp2
patchwork12 + plot_annotation(title = "Tm Mean vs Tm Stdev")