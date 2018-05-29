CreateECDF<-function(DF, GenotypeFactor, AnimalIDFactor, ECDFFactor){
# Creates an empirical cumulative disribution for the ECDFFactor for each individual grouped by GenotypeFactor. 
# DF - input dataframe
# GenotypeFactor is the grouping factor
# AnimalIDFactor - ID for individual
# ECDFFactor - an integer/binned variable
DF<-data.frame(MeasureForECDF=ECDFFactor)

DF <- DF %>% group_by(MeasureForECDF) %>%  
  dplyr::summarise(NumIntervals=n())

DF <- DF %>%  
  arrange(as.numeric(MeasureForECDF)) %>% 
  mutate(CumFrequency=cumsum(NumIntervals))
#And Normalise CumFrequency by max of CumFrequency
  DF<- DF %>%
    mutate(CumFrequency=CumFrequency/max(CumFrequency))

#Add Genotype
#if(GenotypeFactor=="WT"){
#  DF <- DF %>% 
#    mutate(Genotype="WT")
#}
#else{
#  SpikeCountDF <- SpikeCountDF %>% 
#    mutate(Genotype="J20")
#}
DF <- DF %>%
  mutate(Genotype=GenotypeFactor)
 
  DF$Genotype<-as.factor(DF$Genotype)
  
  #Add animalID
  DF<- DF %>%
    mutate(AnimalIDVariable=AnimalIDFactor)


return(DF) 
}

