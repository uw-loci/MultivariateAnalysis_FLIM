library(readxl)
library(ggplot2)
library(dplyr)
library(patchwork)

#user input
path <- 'C:/Users/hwilson23/Documents/GitHub/MultivariateAnalysis_FLIM/' #path to file
#textfilename <- 'data3withcoverslip.txt' #name of text file
textfilename <- 'fluoresceindetailsv2.txt'
#textfilename<- 'blank'


# Call Matlab -------------------------------------------------------------




library(R.matlab)
  runfile <- 'streamlinedversion.m'
  
Matlab$startServer()
matlab <- Matlab()
isOpen <- open(matlab)
if (!isOpen) throw("MATLAB server is not running: waited 30 seconds.")
setVariable(matlab,textfilename = textfilename)

evaluate(matlab,paste0("run('", path, runfile, "')"))


filename <- getVariable(matlab,"filename")

close(matlab)


# Graphs ------------------------------------------------------------------


#Import Cropped Image Data

#croppedinfo <- read_xlsx("C:/Users/hwilson23/Documents/GitHub/MultivariateAnalysis_FLIM/croppeddataeditednames.xlsx")
toOpen <- paste0(path, filename)

fluorescin <- read_xlsx(toOpen)


#Filter out each dye type by lifetime values
#RhoBcrop <- filter(croppedinfo, CCVMean <2500)
#Rho110crop <- filter(croppedinfo, CCVMean >2500)

#Filter fluorescein data for different parameters
fluwnoKI <- filter(fluorescin, KIValue == "none")
fluhighCFD <- filter(fluorescin, ManualCFDClass =="h")
flu45secandHCFD <- filter(fluhighCFD, CollectionTime == "45")
flu100ssec <- filter(fluorescin, CollectionTime > 45)



#Plot lifetime standard deviation vs mean
# Rho110p1 <- ggplot() +
#   geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVCoV, ),color = "red", size=2)+
#   xlab("Tm Mean")+
#   ylab("Tm CoV")
#   
# 
# RhoBp2 <- ggplot() +
#   geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVCoV, ),color = "blue", size = 2)+
#   xlab("Tm Mean")+
#   ylab("Tm CoV")

fluo <- ggplot() +
  geom_point(data = fluwnoKI, aes(x = CCVMean, y = CCVCoV, ), color = "green",size = 2)+
  xlab("Tm Mean")+
  ylab("Tm CoV")
  


patchwork12 <-  fluo #Rho110p1 + RhoBp2 +
patchwork12 + plot_annotation(title = "1 Tm Mean vs Tm CoV for no KI")

fluCCVSTDEV <- ggplot()+
  #geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV, ),color = "red", size=2)+
  #geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVSTDEV, ),color = "blue", size = 2)+
  geom_point(data = flu45secandHCFD, aes(x = CCVMean, y = CCVCoV, shape = KIValue, color = ManualCFDClass),  size = 3)+
  xlab("Tm Mean")+
  ylab("Tm CCVCoV")

fluCCVSTDEV + plot_annotation(title = "2 Fluorescein: Tm Mean vs Tm CoV")



#Plot lifetime standard deviation vs mean
# Rho110p3 <- ggplot() +
#   geom_point(data = Rho110crop, aes(x = CFD, y = CCVCoV,shape = PowerCategory), size=3) +
#   scale_shape_manual(values=c(3, 2, 0,1))+
#   ylab("Tm CoV - Rho110")+
#   xlab("Pockels Cell")+
#   theme(legend.position="bottom")
# 
# 
# RhoBp4 <- ggplot() +
#   geom_point(data = RhoBcrop, aes(x = CFD, y = CCVCoV, shape = PowerCategory), size = 3)+
#   scale_shape_manual(values=c( 2, 0,1))+
#   ylab("Tm CoV - RhoB")+
#   xlab("Pockels Cell")+
#   theme(legend.position="bottom")
# 
# patchwork34 <- Rho110p3 + RhoBp4
# patchwork34 + plot_annotation(title = "3 Tm Mean vs Tm CoV")

# #Plot lifetime standard deviation vs mean
# Rho110noE <- subset(Rho110crop, PowerCategory != "E")
# Rho110p5 <- ggplot() +
#   geom_point(data = croppedinfo, aes(x = PhotonsMean, y = CCVSTDEV,color = PowerCategory, shape = PowerCategory),  size=3) +
#   #scale_shape_manual(values=c(3, 2, 15,16))+
#   theme(legend.position="bottom")+
#   xlab("PhotonsMean")+
#   ylab("Tm StDev")
# 
# 
# 
# 
 RhoBp6 <- ggplot() +
   geom_point(data = flu100ssec, aes(x = KIConcen, y = CCVCoV,color = IntensityMean),size = 3)+
   theme(legend.position="bottom") +
   xlab("KI Value (M)")+
  ylab("Tm CoV")


patchwork56 <- RhoBp6
 patchwork56 + plot_annotation(title = "4 Tm Mean vs Tm Stdev")

###
###
##filter out power categories
# rho110filter <- filter(Rho110crop, PowerCategory == "H")
# rhobfilter <- filter(RhoBcrop, PowerCategory == "H")
####


RhoBp7 <- ggplot() +
  #geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVCoV, color = "blue"), size = 2,)+
  #geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVCoV, color = "red"), size = 2,)+
  geom_point(data = flu45secandHCFD, aes(x = CCVMean, y = CCVCoV, color = CollectionTime), size =2)+
  scale_shape_manual(values=c( 3,2,15,16))+
  theme(legend.position="bottom")+
  xlab("Tm Mean (ps)")+
  ylab("Tm CoV")

RhoBp7 + theme(text = element_text(size = 15))  
RhoBp7 + plot_annotation(title = "5 ALL FLU DYES Tm Mean vs Tm CoV")






##
#histograms and shaprio tests
##
##
# 



#Plot lifetime standard deviation vs mean
# Rho110p8 <- ggplot() +
#   geom_histogram(data = Rho110crop, aes(x = CCVMean),color = "blue")+
#   xlab("Rho110 Tm Mean")
# RhoBp9 <- ggplot() +
#   geom_histogram(data = RhoBcrop, aes(x = CCVMean),color = "red")+
#   xlab("RhoB Tm Mean")
#   
# 
# patchwork89 <- Rho110p8 + RhoBp9
# patchwork89 + plot_annotation(title = "6 Tm Mean Histogram")



# shapiro.test(Rho110crop$CCVMean)
# shapiro.test(RhoBcrop$CCVMean)

##filtering data
# nooutliershighCFD <- filter(uhoh, ManualCFDClass == "h")
# 
# fourfivesec <- filter(nooutliershighCFD, PhotonsMean<100)
# before <- filter(fourfivesec, Day == 'one' | Day == 'two' | Day == 'three' )
# newdyesolution <- filter(fourfivesec, Day == 'five'| Day == 'four')
# 
# fluCCVcov <- ggplot()+
#   #geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV, ),color = "red", size=2)+
#   #geom_point(data = RhoBcrop, aes(x = CCVMean, y = CCVSTDEV, ),color = "blue", size = 2)+
#   geom_point(data = fourfivesec, aes(x = CCVMean, y = CCVCoV, shape = KIValue, color = Day),  size = 3)+
#   xlab("Tm Mean")+
#   ylab("Tm CCVCoV")
# 
# fluCCVcov + plot_annotation(title = "7 Fluorescein: Tm Mean vs Tm CoV (five days)")
# 
# #Day == 'five' |
# fludayfive <- filter(fluhighCFD,  Day == 'bintwo')
# dayfiveplot <- ggplot()+
#   geom_point(data=fludayfive, aes(x=CCVMean,y=CCVCoV, color = PhotonsMean), size = 3)
# 
# dayfiveplot + plot_annotation(title = "8 Fluorescein: Day 5 only")
# 
# 
# junktest <- ggplot()+
#   geom_point(data=uhoh, aes(x=PhotonsMean,y=CCVCoV, color = CCVMean), size = 3)
# 
# junktest + plot_annotation(title = "9 I screwed up")
# 
# fluCCVcov <- ggplot()+
#   #geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV, ),color = "red", size=2)+
#   geom_point(data = before, aes(x = CCVMean, y = CCVCoV), color = "black", size = 3)+
#   geom_point(data = newdyesolution, aes(x = CCVMean, y = CCVCoV), color = "blue",  size = 3)+
#   xlab("Tm Mean (ps)")+
#   ylab("Tm CCVCoV")
# 
# fluCCVcov + plot_annotation(title = "10 Fluorescein: Tm Mean vs Tm CoV (45 sec data)")
# 
# fluCCVcov <- ggplot()+
#   #geom_point(data = Rho110crop, aes(x = CCVMean, y = CCVSTDEV, ),color = "red", size=2)+
#   geom_point(data = before, aes(x = KIConcen, y = CCVCoV), color = "black", size = 3)+
#   geom_point(data = newdyesolution, aes(x = KIConcen, y = CCVCoV), color = "blue",  size = 3)+
#   xlab("KI Concentration (M)")+
#   ylab("Tm CoV") + theme(axis.text = element_text(size = 15))
# 
# fluCCVcov + plot_annotation(title = "11 Fluorescein: KI Concentration vs Tm CoV (45 sec data)")
# 
# 
# 
# variable <- "CCVCoV"
# nooutliersCoVAverages <- c(colMeans(subset(fourfivesec, KIConcen == 0, select = c(variable))),
#                            colMeans(subset(fourfivesec, KIConcen == 0.02, select = c(variable))),
#                            colMeans(subset(fourfivesec, KIConcen == 0.03, select = c(variable))),
#                            colMeans(subset(fourfivesec, KIConcen == 0.04, select = c(variable))))
#                            
# nooutliersfourfive <- data.frame(CoVAvg = nooutliersCoVAverages, KIConcen = c(0, 0.02, 0.03, 0.04))
# 
# likeJenusPlot <- ggplot()+
#   geom_point(data = nooutliersfourfive, aes(x = KIConcen, y = CoVAvg), size = 3) +
#   xlab("KI Concentration (M)")+
#   ylab("Average Tm CoV") +
#   theme(axis.text = element_text(size = 15))
# 
# likeJenusPlot + plot_annotation(title = "12 Fluorescein: Average Cov by KI Concentration")
# 



