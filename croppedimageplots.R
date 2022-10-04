library(readxl)
library(ggplot2)
library(dplyr)
library(patchwork)

#Import Cropped Image Data

croppedinfo <- read_xlsx("C:/Users/hwilson23/Documents/UserDataOWS/croppedretest.xlsx")
segmentedinfo <- read_xlsx("C:/Users/hwilson23/Documents/UserDataOWS/fitFilesHelen/chisegmentedimagematlaboutputs.xlsx")

#Filter out each dye type by lifetime values
RhoBcrop <- filter(croppedinfo, CCVMean <2500)
Rho110crop <- filter(croppedinfo, CCVMean >2500)

RhoBseg <- filter(segmentedinfo, CCVMean <2500)
Rho110seg <- filter(segmentedinfo, CCVMean >2500)

#Plot lifetime standard deviation vs mean
Rho110p1 <- ggplot() +
  geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV), color = "blue", size=2) +
  geom_point(data = Rho110seg, aes(x = CCVMean, y = CCVSTDEV), color = "green", size = 1)

RhoBp2 <- ggplot() +
  geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVSTDEV), color = "blue", size = 2) +
  geom_point(data = RhoBseg, aes(x = CCVMean, y = CCVSTDEV), color = "green", size = 1)


patchwork12 <- Rho110p1 + RhoBp2
patchwork12 + plot_annotation(title = "Tm Mean vs Tm Stdev")

#Plot photon mean vs lifetime median
Rho110p3 <- ggplot() +
  geom_point(data = Rho110crop, mapping = aes(x = PhotonsMean, y = CCVMedian), color = "blue", size = 2) +
  geom_point(data = Rho110seg, mapping = aes(x = PhotonsMean, y = CCVMedian), color = "green", size = 1)

RhoBp4 <- ggplot() +
  geom_point(data = RhoBcrop, mapping = aes(x = PhotonsMean, y = CCVMedian), color = "blue", size = 2) +
  geom_point(data = RhoBseg, mapping = aes(x = PhotonsMean, y = CCVMedian), color = "green", size = 1)


patchwork34 <- Rho110p3 + RhoBp4
patchwork34 + plot_annotation("PhotonsMean vs Tm Median")

#Plot photon mean vs lifetime mean with error bars 
Rho110p5 <- ggplot() +
  geom_point(data = Rho110crop, mapping = aes(x = PhotonsMean, y = CCVMean), color = "blue", size=2) +
  geom_errorbar(data = Rho110crop, aes(x = PhotonsMean, y = CCVMean, ymin = CCVMean-CCVSTDEV, ymax = CCVMean+CCVSTDEV), alpha = 0.4)+
  geom_point(data = Rho110seg, mapping = aes(x = PhotonsMean, y = CCVMean), color = "green", size = 1) 
  

RhoBp6 <- ggplot() +
  geom_point(data = RhoBcrop, mapping = aes(x = PhotonsMean, y = CCVMean), color = "blue", size=2) +
  geom_errorbar(data = RhoBcrop, aes(x = PhotonsMean, y = CCVMean, ymin = CCVMean-CCVSTDEV, ymax = CCVMean+CCVSTDEV), alpha = 0.4) +
  geom_point(data = RhoBseg, mapping = aes(x = PhotonsMean, y = CCVMean), color = "green", size = 1) 
  


patchwork56 <- Rho110p5 + RhoBp6
patchwork56 + plot_annotation("Tm Mean w/ stdev vs PhotonsMean")


#Plot lifetime mean vs chi mean, and Chi error bars
Rho110p7 <- ggplot() +
  geom_point(data = Rho110crop, mapping = aes(x = CCVMean, y = CHIMean), color = "blue", size=2) +
  geom_errorbar(data = Rho110crop, aes(x = CCVMean, y = CHIMean, ymin = CHIMean-CHISTDEV, ymax = CHIMean+CHISTDEV), alpha = 0.4) +
  geom_point(data = Rho110seg, mapping = aes(x = CCVMean, y = CHIMean),color = "green", size = 1)

RhoBp8 <- ggplot() +
  geom_point(data = RhoBcrop, mapping = aes(x = CCVMean, y = CHIMean), color = "blue", size=2) +
  geom_errorbar(data = RhoBcrop, aes(x = CCVMean, y = CHIMean, ymin = CHIMean-CHISTDEV, ymax = CHIMean+CHISTDEV), alpha = 0.4) +
  geom_point(data = RhoBseg, mapping = aes(x = CCVMean, y = CHIMean), color = "green", size = 1)
  

patchwork78 <- Rho110p7 + RhoBp8
patchwork78 + plot_annotation("CHIMean w CHIstdev bars vs Tm Mean")


#Plot lifetime standard deviation vs mean
Rho110p9 <- ggplot() +
  geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV), color = "blue", size=2)

RhoBp10 <- ggplot() +
  geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVSTDEV), color = "blue", size = 2)


patchwork910 <- Rho110p9 + RhoBp10
patchwork910 + plot_annotation(title = "Tm Mean vs Tm Stdev cropped data")