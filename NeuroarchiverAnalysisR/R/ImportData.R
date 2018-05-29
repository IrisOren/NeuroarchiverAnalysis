#Import data from all processor output files in data_dir to create a dataframe
#INPUT: data_dir is directory in local R folder with all processor output
# data_dir should be of the form 'Data/JFXXX/SCPP3V2_TCL' 
#OPERATION: Sets variable names and remove NaNs
#OUTPUT: Returns dataframe of data from all output files
#v1: 300716
#v2: 130617: Amended for SCPP3 which has loss as a float instead of EpochClass
#v3: 200617: Amended for SCPP4 to add burst count
#v4: 100716: Amend to import from output files saved in individual subdirectories for each folder
#v5: 061117: Changed for CDKL5 data and DeltaThetaGamma processed files
#v6: 120418: Changed for SCPP4V2

ImportData<-function(data_dir){
  DirList<-list.dirs(path=data_dir)
  EndDir<-length(DirList)-1  #Number of directories minus the current /. directory
  for (CurrentDir in 1:EndDir){
    #setwd(Dirist[CurrentDir])
    DataSubDir<- DirList[CurrentDir+1]
    FileList<-list.files(DataSubDir, pattern="*SCPP4V2.txt") #List of all SCPP4V1.txt files in working directory
    EndFile<-length(FileList)  
    for (i in 1:EndFile){
      #Write to a temp dataframe
      path_and_file<-paste(DataSubDir, FileList[i], sep="/") #Use full path to file to allow for knitr to work
      DF_temp<-read.table(path_and_file, sep=" ")
      #Change variable names
      names(DF_temp)<-c("FileName", "Seconds", "Chan", "Loss", "Spike", "Burst", "Delta", "Theta", "Gamma1", "Gamma2", "Broadband1", "Broadband2")
      #Remove columns with null data
      DF_temp<-select(DF_temp, FileName, Seconds, Chan, Loss, Spike, Burst, Delta, Theta, Gamma1, Gamma2, Broadband1, Broadband2) 
      #Add current temp dataframe to combined DF
       if(i==1 & CurrentDir==1){    #If importing first file in first subdirectory
        DF<-DF_temp
      }
      else{
        DF<-rbind(DF, DF_temp)
      }
    }
  }
  
  return(DF)
  
}