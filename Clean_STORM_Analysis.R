library(dplyr)
library(ggplot2)
library(stringr)
library(purrr)
#Change folder path to match the location of your files
folder_path <- '/Users/tdavenpo/R_Programming/New_ROI_Analysis/Test'
file_names <- list.files(folder_path,pattern='*.csv',full.names=TRUE)

pixel_size <- 64

#define a function that takes a given .csv file containing a list of ROIs and their areas
#extract cell number and stim condition from filename (filename formatting is important)
#multiply area in pixels by pixel size to obtain area in nm^2
#label each punctae with cell number and stim
#return a dataframe
label <- function(storm_file){
  #The filename must start with "Reg" then the region number (e.g. Reg1_15HI.csv)
  count <- str_extract(storm_file,'(?<=Reg)[:alnum:]+')
  print(count)
  #The filename must include the stimulation conditions in the form 00AA (e.g.15HI or 0UN)
  stim <- str_extract(storm_file,'[:digit:]+[:alnum:]{2}')
  print(stim)
  storm_df <- read.csv(storm_file)
  colnames(storm_df) <- c('Pixels','Area','Cell_No','Stim')
  storm_df$Area <- storm_df$Pixels * pixel_size # convert pixel number to area in nm^2
  storm_df$Cell_No <- rep(count,length(storm_df$Pixels))
  storm_df$Stim <- rep(stim,length(storm_df$Pixels))
  storm_df
  }

#Open files and label them with their respective cell number and stim condition
labeled_files <- lapply(file_names,label)
#Combine all files into a single dataframe
all_df <- do.call('rbind',labeled_files)
#Save a csv containing all punctae areas
write.csv(all_df, file = "all_areas.csv")

#group punctae by stim condition and cell number,  report mean area, total area, and number of punctae for each cell
all_summary <- all_df %>% 
                  group_by(Stim,Cell_No) %>% 
                  summarise(mean_area = mean(Area), total_area = sum(Area), count=n())
#create a unique label for each stim_cell pair
all_summary$name <- paste(all_summary$Stim,all_summary$Cell_No,sep="_")
write.csv(all_summary, file = "all_summary.csv")

#define thresholds for "small", "medium", "large" punctae
small <- 9600
medium <- 48000

#filter dataframe to include only small punctae and report summary stats
small_df <- filter(all_df, Area < small)
small_summary <- small_df %>% 
                    group_by(Stim,Cell_No) %>% 
                    summarise(mean_area = mean(Area), total_area = sum(Area), count = n())
small_summary$name <- paste(small_summary$Stim,small_summary$Cell_No,sep="_")
#write.csv(small_summary, file = "small_summary.csv")

#filter dataframe to include only medium-sized punctae and report summary stats
medium_df <- filter(all_df, (Area > small) & (Area < medium))
medium_summary <- medium_df %>% 
                    group_by(Stim,Cell_No) %>% 
                    summarise(mean_area = mean(Area), total_area = sum(Area), count = n())
medium_summary$name <- paste(medium_summary$Stim,medium_summary$Cell_No,sep="_")
#write.csv(medium_summary, file = "medium_summary.csv")

#filter dataframe to include only large punctae and report summary stats
large_df <- filter(all_df, Area > medium)
large_summary <- large_df %>% 
                    group_by(Stim,Cell_No) %>% 
                    summarise(mean_area = mean(Area), total_area = sum(Area), count = n())
large_summary$name <- paste(large_summary$Stim,large_summary$Cell_No,sep="_")
#write.csv(large_summary, file = ,"large_summary.csv")

#select columns to join summaries into a simplified dataframe
n_cols = c('name','total_area','count')
summary_list <- list(all_summary[n_cols], small_summary[n_cols], medium_summary[n_cols], large_summary[n_cols])
#join dataframes using a 'full_join' to include missing values
simple_summary <- reduce(summary_list, full_join, by='name')
#replace NA values with 0
simple_summary[is.na(simple_summary)] <- 0
#rename columns
names(simple_summary) <- c('name','total_area_all','count_all','total_area_small','count_small','total_area_medium','count_medium','total_area_large','count_large')

#Calculate fractional area of small, medium, large punctae per cell
simple_summary$small_area_fraction <- simple_summary$total_area_small / simple_summary$total_area_all
simple_summary$medium_area_fraction <- simple_summary$total_area_medium / simple_summary$total_area_all
simple_summary$large_area_fraction <- simple_summary$total_area_large / simple_summary$total_area_all

#calculate fraction of spots that are small, medium, large per cell
simple_summary$small_spot_fraction <- simple_summary$count_small / simple_summary$count_all
simple_summary$medium_spot_fraction <- simple_summary$count_medium / simple_summary$count_all
simple_summary$large_spot_fraction <- simple_summary$count_large / simple_summary$count_all

write.csv(simple_summary, file = "Simple_summary.csv")
