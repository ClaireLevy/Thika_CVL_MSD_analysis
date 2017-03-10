library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)
library(tidyr)

#This is a script for compiling MSD data for Thika samples for the sample runs from 24Feb17-6Mar17 for the 3 plex panel.

#read in raw data from all runs we have done so far by looking in the folders called "All 3 plex CSV files" within the Sample Runs folder and finding the .csv files.



#I'm also reading in data from 22Nov16. I already gave stacy data for those but only gave her neat data, and she really should have 1:10 and 1:100 for the 3plex. Iwent into DWB and exported a table of just the 3 plex data for 22Nov and put it in the "All 3 plex CSV files" folder with the rest of the 3 plex runs. The Samples are named differently so I'll fix that below.



files <- dir("../Sample Runs/All 3 plex CSV files", recursive=TRUE, full.names=TRUE, pattern= ".csv")



#read in the files as a list. check.names = FALSE means that column names won't be R-munged and % signs and spaces will be left in.
dat<-lapply(files, FUN=read.csv, skip = 1, check.names = FALSE)




#name the list elements based on the date that is in the file name for that run.
names(dat)<- str_extract(files, "\\d{1,}[A-Z]{1}[a-z]{2,}1[6|7]")

#bind all elements together and add a column called "run_date" to differentiate the dfs

dat<-bind_rows(dat,.id = "run_date" )

#all of the pool samples are lower case p 
sum(str_detect(dat$Sample, "p"))
sum(str_detect(dat$Sample, "P"))

#There are only the appropriate sample groups in the data
unique(dat$`Sample Group`)

#The values in Sample include the dilution that was done on those samples, 1:10 and 1:100. I want to put those dilutions in the Dilution column and remove the text "1:10" and "1:100" from Sample so the rest of the text in Sample will merge with Stacy's SpID column


#NOTE!! I am intentionally including a space before the " 1:10" and
#" 1:100" that I'm removing with str_replace because if the space is still there, the data in Sample won't match Stacy's SpIDs. This is different for the 22NOv16 data which I'll need to fix separately

dat <- dat %>%
  mutate(Dilution = ifelse(str_detect(Sample,"1:10{2}"),100,
  ifelse(str_detect(Sample,"1:10{1}"),10,Dilution)))%>%
  mutate(SpID = str_replace(Sample," 1:10{1,}",""))


#The entries in the Plate Name column are inconsistent so I'm going to make them in the same format here.

#this is what they started out like: 
dat%>%
  select(run_date, `Plate Name`)%>%
  unique()


dat<- dat %>%
  mutate(`Plate Name` = paste0(run_date,"_","3plex")) 
                               
                              
#Check again, looks ok.
 dat%>%
select(run_date, `Plate Name`)%>%
unique()
 


#Stacy wants us to use the SpID (year-SpNum) as the identifier for the data, which is what I now have in the Sample column for all but the 22Nov16 data.
 
 
#Take out the Nov22 data for now
 
 Nov22 <- dat %>%
   filter(run_date == "22Nov16")


notNov22<-dat %>%
  filter(run_date != "22Nov16")
 
 
#So, I need to merge the inventory Stacy sent us.

#I already made a column in the code above that contains the same data is called in Stacy's list amd called it SpID like in her data).


#Stacy sent us the following inventory of samples to run
List_2016_sep_23<-read.csv("List 2016-sep-23.csv", check.names = FALSE)

#merging Stacy's meta data with our msd data by the column they have in common: SpID


merged_List_and_MSD_noNov22 <- merge(List_2016_sep_23, notNov22, by ="SpID", all.x = TRUE, all.y = TRUE)

#Where are there entries in SpID but not in the Sample column?
#These are probably all the ones that we ran on Nov22 plus 2015-28410 which is addressed below.
x <- merged_List_and_MSD_noNov22 %>%
  select(SpID, Sample)%>%
  filter(is.na(Sample))




##### FIXING THE 22NOV data ########

#Stacy wants us to use the SpID (year-SpNum) as the identifier for the data instead of what we used, PTID-SpNum mo. X". 

#So, I need to merge the inventory Stacy sent us, which includes SpID, PTID, SpNum and some other identifiers with our MSD output so that there is a column with the correct SpID for her to use for analysis.


#I will create a column in the inventory that recapitulates our identifier scheme in part, a combination of PTID-SpNum

update_List_2016_sep_23 <- List_2016_sep_23 %>%
  mutate(PTID_SpNum = paste(PTID, SpNum, sep = "-"))

#Then I'll split up my data and isolate the PTID-SpNum part of the Sample from the "mo. X" part.
newCols<-colsplit(Nov22$Sample, pattern = " ", names =c("PTID_SpNum", "Month"))



#then bind it back to my original data
update_Nov22<-cbind(Nov22, newCols)

#now I'll merge my data into the modified inventory by the column that I created in each data set called "PTID_SpNum"
merge_update_List_update_Nov22 <- merge(update_List_2016_sep_23,
                             update_Nov22,
                             by = "PTID_SpNum", all.x = TRUE, all.y = TRUE)


#Since we added in sample 630851-9309( a different aliquots of 630851-9308 ), there is no record for it in the SpID column, only in the PTID_SpNum column, which is not the column Stacy is using as an identifier. So, I need to fill in the corresponding value in the SpID column in the cases where I have 630851-9309 in the PTID_SpNum column.

#Make the SpID characer, so the values don't get replaced with their factor level in the following command:

merge_update_List_update_Nov22<- mutate(merge_update_List_update_Nov22, SpID.x = ifelse(PTID_SpNum == "630851-9309", "2016-9309", as.character(SpID.x)))



#I don't want to include the column that I created called "Month" when I did colsplit above, so I'll remove it here. And I want to remove PTID_SpNum because I only used it for merging and it will just be a confusing redunant identifier. There is also a leftover SpID.y from the merge (I made that column when I read in all the 3 plex data)

merge_update_List_update_Nov22 <-select(merge_update_List_update_Nov22, -Month, -PTID_SpNum,-SpID.y)

#And also change SpID.x to just SpID

names(merge_update_List_update_Nov22)[4]<-"SpID"
################ END OF FIXING 22NOV DATA ########################

#Combine the fixed data from 22Nov16 with the rest of the data from the other 3plex sample runs

all_data <- rbind( merged_List_and_MSD_noNov22, merge_update_List_update_Nov22)


#Where are there entries in SpID but not in the Sample column?

x <- merged_List_and_MSD_noNov22 %>%
  select(SpID, Sample, PTID, run_date)%>%
  filter(is.na(Sample))


#Notes:
#Because of the variation we saw in cytokine levels for this panel when we ran test samples, we ran both a 1:10 and 1:100 dilution for all samples.

#The Dilution column indicates the dilution for the sample (either 10 for 1:10 or 100 for 1:100) but none of the results have been multiplied by these dilution factors, so you will need to do that multiplication to estimate the cytokine levels in an undiluted sample.


#We ran out of SpID 2015-28409 so had to use another aliquot, 2015-28410.  2015-28410 is not in Stacy's list so there are NAs in her data for that SpID.

# When we looked at the results of the 2Mar17 run it looked like sample 2015-18982 may not have been added to the wells (abnormally low output). Fernanda repeated this sample, and the other sample from this PTID, (2015-18562) on 7Mar17. Data from both runs are included in this data set.



