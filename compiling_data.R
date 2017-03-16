library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)
library(tidyr)

#This is a script for compiling MSD data for Thika samples for the sample runs from 22Nov16-19Jan17

#read in raw data from all runs we have done so far by looking in the folders within the Sample Runs folder and finding the .csv files.

files <- dir("../Sample Runs/8plex_9plex and all panels 22Nov16/", recursive=TRUE, full.names=TRUE, pattern= ".csv")

#read in the files as a list. check.names = FALSE means that column names won't be R-munged and % signs and spaces will be left in.
dat<-lapply(files, FUN=read.csv, skip = 1, check.names = FALSE)

#name the list elements based on the date that is in the file name for that run.
names(dat)<- str_extract(files, "\\d{1,}[A-Z][a-z]{2}1[6|7]\\s")

#bind all elements together and add a column called "run_date" to differentiate the dfs

dat<-bind_rows(dat,.id = "run_date" )

#fix the weirdness of greek letters
dat$Assay <-recode(dat$Assay,
                   "IFN-Î±2a" = paste("IFN-\U03B1","2a", sep = ""),
                   "IL-1Î±" = "IL-1\U03B1",
                   "MIP-1Î±"="MIP-1\U03B1",
                   "TNF-Î±" = "TNF-\U03B1",
                   "MIP-3Î±" = "MIP-3\U03B1",
                   "MIP-1Î²" = "MIP-1\U03B2",
                   "IL-1Î²" = "IL-1\U03B2",
                   "IFN-Î³" = "IFNg")

#want to make all the controls labeled the same, so replace "P" with "p" in the "pool" samples and remove the "stock" that is in some of them.

dat$Sample<-str_replace(dat$Sample,"P","p")
dat$Sample<-str_replace(dat$Sample," stock","") #include the space before stock!

#we ran samples for German on 19Jan17 and 15Dec16. I don't want to include any of his samples. They have "German" in the Sample.Group column


#we also ran samples for the Schiffer group on 7Dec16 that I don't want to include in the final data set. Those samples were called "Pool Cocktail", "Pool Cocktail 1:10" and "pool CVL 1:10" and I will exclude them here ("P" is already changed to "p" by the above code)



#use back ticks so my column name with spaces works with dplyr
dat <- dat %>%
  filter(`Sample Group` != "German")%>%
  filter(!str_detect(Sample, "Cocktail"))

#Also exclude any remaining samples that include the text "1:10" (this will also exclude anything that has "1:100") because those are leftover from when we were testing 1:10 and 1:100 dilutions EXCEPT for the 3 plex samples

#take out the 3 plex samples (will include neat, 1:10 and 1:100)

nov22_3plex <- dat %>%
  filter(str_detect(`Plate Name`, "3plex"))
           
#Now from the rest of the data, remove the 3plex samples and anything that is diluted. 
neat_no_3plex  <- dat %>%
  filter(!str_detect(`Plate Name`, "3plex"))%>%
  filter(!str_detect(Sample, "1:10{1,}")) 


#now combine the two sets: All the 3plex data AND the neat 8 and 9 plex data

dat <- rbind(neat_no_3plex,nov22_3plex)

#Fix the dilution column and take away any text in the Sample column that says "1:10" or "1:100"

dat <- dat %>%
  mutate(Dilution = ifelse(str_detect(Sample,"1:10{2}"),100,
                           ifelse(str_detect(Sample,"1:10{1}"),10,Dilution))) %>%
  mutate(Sample = str_replace(Sample," 1:10{1,}",""))


#There is a problem where some of the samples have 63006 as the PTID in the Sample column instead of 630066 (there should be 66 on the end, not just 6)

#To fix that I will replace anything that says 63006 OR 630066 to the correct 630066


dat <- dat %>%
  mutate(Sample = str_replace( Sample, "63006{1,}", "630066"))



#Some of the unknowns are listed in the Sample Group column as "Unknowns" while others are "Auto_Created_Unknown" Here I will make them all say "Auto_Created_Unknown", which is the default unknown designation in the software. I don't know why we replaced it with unknowns in some places.

dat <-dat%>%
  mutate(`Sample Group` = str_replace(`Sample Group`,"Unknowns", "Auto_Created_Unknown"))

#Stacy wants us to use the SpID (year-SpNum) as the identifier for the data instead of what we used, PTID-SpNum mo. X". 

#So, I need to merge the inventory Stacy sent us, which includes SpID, PTID, SpNum and some other identifiers with our MSD output so that there is a column with the correct SpID for her to use for analysis.

#she sent us the following inventory of samples to run
List_2016_sep_23<-read.csv("List 2016-sep-23.csv", check.names = FALSE)

#I will create a column in the inventory that recapitulates our identifier scheme in part, a combination of PTID-SpNum

update_List_2016_sep_23 <- List_2016_sep_23 %>%
  mutate(PTID_SpNum = paste(PTID, SpNum, sep = "-"))

#Then I'll split up my data and isolate the PTID-SpNum part of the Sample from the "mo. X" part.
newCols<-colsplit(dat$Sample, pattern = " ", names =c("PTID_SpNum", "Month"))



#then bind it back to my original data
update_dat<-cbind(dat, newCols)


##### MERGE #######

#now I'll merge my data into the modified inventory by the column that I created in each data set called "PTID_SpNum"
merged_List_and_MSD <- merge(update_List_2016_sep_23,
                             update_dat,
                             by = "PTID_SpNum", all.x = TRUE, all.y = TRUE)

#Are there any that didn't merge? YAAAS
sum(is.na(merged_List_and_MSD$SpID))



#Here are the  PTID_SpNum in update_List_2016_sep_23 that are not found in my update_dat_Thika_22Nov_16_to_19Jan17, i.e. the samples that we were supposed to run but didn't.

update_List_2016_sep_23[which(!update_List_2016_sep_23$PTID_SpNum %in% update_dat$PTID_SpNum), "PTID_SpNum"]

#The only missing one is 630851-9308, which is correct, because we didn't run that one (by mistake we ran 630851-9309 and I included those data.



#HOWEVER: Since we added in sample 630851-9309, there is no record for it in the SpID column, only in the PTID_SpNum column, which is not the column Stacy is using as an identifier. So, I need to fill in the corresponding value in the SpID column in the cases where I have 630851-9309 in the PTID_SpNum column.

#Make the SpID characer, so the values don't get replaced with their factor level in the following command:

merged_List_and_MSD<- mutate(merged_List_and_MSD,SpID = ifelse(PTID_SpNum == "630851-9309", "2016-9309", as.character(SpID)))



#I don't want to include the column that I created called "Month" when I did colsplit above, so I'll remove it here. And I want to remove PTID_SpNum because I only used it for merging and it will just be a confusing redunant identifier.

merged_List_and_MSD <-select(merged_List_and_MSD, -Month, -PTID_SpNum)


#NOTE
#15Dec16 9plexA 630457-18758 mo. 3, 630457-19448 mo. 6, 630503-18866 mo. 3, 630503-19054 mo. 6 replicates are not grouped together as replicates in the data readout because we had to put them in non-adjacent wells because of a pipetting error. This means that there will not be a value for a replicate mean in the Discovery workbench output. 


#This is ALL the data from 22Nov16, including both neat and diluted 3plex data

write.csv(merged_List_and_MSD, file = "compiled_data_for_Wald_group/neat_and_diluted_3plex_22Nov16_to_19Jan17.csv" )



#here is a file that only contains neat data, this is the first thing I sent to Stacy on 31Jan17, then updated on 10Feb17.

merged_all_neat <-merged_List_and_MSD %>%
  filter(Dilution == 1)

write.csv(merged_all_neat, file = "compiled_data_for_Wald_group/compiled_Thika_data_22Nov_16_to_19Jan17.csv", row.names = FALSE)


#this is a file that only contains the DILUTED 3 PLEX data (from 22Nov16)

merged_diluted_3plex_22Nov16 <- merged_List_and_MSD %>%
  filter(Dilution != 1)

#Check to see where there are Sample names but no SpID
#looks good, the only ones without SpID are the pool CVL samples.
x<- merged_diluted_3plex_22Nov16 %>%
  select(SpID, Sample)%>%
  filter(is.na(SpID))



write.csv(merged_diluted_3plex_22Nov16, file = "compiled_data_for_Wald_group/diluted_3plex_22Nov16.csv")

################## END 22NOV16- 19Jan17 #######################



#The following is a script for compiling MSD data for Thika samples for the sample runs from 24Feb17-6Mar17 for the 3 plex panel.

#read in raw data from all runs we have done so far by looking in the folders called "All 3 plex CSV files" within the Sample Runs folder and finding the .csv files.

files_3plex <- dir("../Sample Runs/3_plex", recursive=TRUE, full.names=TRUE, pattern= ".csv")

#read in the files_3plex as a list. check.names = FALSE means that column names won't be R-munged and % signs and spaces will be left in.
dat_3plex<-lapply(files_3plex, FUN=read.csv, skip = 1, check.names = FALSE)

#name the list elements based on the date that is in the file name for that run.
names(dat_3plex)<- str_extract(files_3plex, "\\d{1,}[A-Z]{1}[a-z]{2,}1[6|7]")

#bind all elements together and add a column called "run_date" to differentiate the dfs

dat_3plex<-bind_rows(dat_3plex,.id = "run_date" )

#all of the pool samples are lower case p 
sum(str_detect(dat_3plex$Sample, "p"))
sum(str_detect(dat_3plex$Sample, "P"))

#There are only the appropriate sample groups in the data
unique(dat_3plex$`Sample Group`)

#The values in Sample include the dilution that was done on those samples, 1:10 and 1:100. I want to put those dilutions in the Dilution column and remove the text "1:10" and "1:100" from Sample so the rest of the text in Sample will merge with Stacy's SpID column


#NOTE!! I am intentionally including a space before the " 1:10" and
#" 1:100" that I'm removing with str_replace because if the space is still there, the data in Sample won't match Stacy's SpIDs. This is different for the 22NOv16 data which I'll need to fix separately

dat_3plex <- dat_3plex %>%
  mutate(Dilution = ifelse(str_detect(Sample,"1:10{2}"),100,
                           ifelse(str_detect(Sample,"1:10{1}"),10,Dilution)))%>%
  mutate(SpID = str_replace(Sample," 1:10{1,}",""))


#The entries in the Plate Name column are inconsistent so I'm going to make them in the same format here.

#this is what they started out like: 
dat_3plex%>%
  select(run_date, `Plate Name`)%>%
  unique()


dat_3plex<- dat_3plex %>%
  mutate(`Plate Name` = paste0(run_date,"_","3plex")) 


#Check again, looks ok.
dat_3plex%>%
  select(run_date, `Plate Name`)%>%
  unique()



#Stacy wants us to use the SpID (year-SpNum) as the identifier for the data, which is what I now have in the Sample column for all but the 22Nov16 data.



#I already made a column in the code above that contains the same data is called in Stacy's list and called it SpID like in her data).

#Stacy sent us the following inventory of samples to run
List_2016_sep_23<-read.csv("List 2016-sep-23.csv", check.names = FALSE)

### CORRECTION ###
#I checked with Fernanda and found that although the data says that 2016-9308 was run on 3Mar17, it was actually 2016-9309. I will correct that here:

dat_3plex <- dat_3plex %>%
  mutate(SpID = str_replace(SpID, "2016-9308","2016-9309")) %>%
  mutate(Sample = str_replace(Sample,"9308","9309"))
  

#### MERGE 2 24Feb17-7March17 ######

#merging Stacy's meta data with our msd data by the column they have in common: SpID

merged_List_and_3plex_MSD <- merge(List_2016_sep_23, dat_3plex, by ="SpID",all.x = TRUE, all.y = TRUE)

#Which samples have SpID from Stacy but no corresponding Sample from us?
yes_SpID_no_sample <- merged_List_and_3plex_MSD %>%
  select(SpID, Sample)%>%
  filter(is.na(Sample))



#let's look at the samples that were run on 22Nov for the 3plex

nov_samples_3plex<-merged_List_and_MSD %>%
  filter(str_detect(`Plate Name`, "3plex"))%>%
  select(SpID, Sample)%>%
  filter(Sample != "pool CVL")%>%
  filter(!str_detect(Sample, "S00"))%>%
  unique()


#which of the SpID that are missing a Sample the later 3 plex data are present in the data from 22Nov (i.e were already run and we don't need to worry about it)?

yes_SpID_no_sample[which(yes_SpID_no_sample$SpID %in% nov_samples_3plex$SpID),"SpID"]


#and which are NOT present in the 22Nov data, i.e. we didn't make a Sample name for them and therefore they were not run?

yes_SpID_no_sample[which(!yes_SpID_no_sample$SpID %in% nov_samples_3plex$SpID),"SpID"]

#They only ones are 2015-28409 which we didnt run because we ran out (used 2015-28410 instead) and 2016-9308 for which we ran 2016-9309 instead)

#Because we know that all SpIDs with NA for sample were already run on 22Nov (except 2015-28409), I will drop them from the merged data so I can rbind with the 22Nov16-19Jan17 data and not have those NAs there. This will also drop 2015-28409.

#now drop the rows with na's in the Sample column from the data

no_NA_merged_List_and_3plex_MSD <- merged_List_and_3plex_MSD %>%
  drop_na(Sample)



##### rbind of 22Nov16-19Jan17 and 24Feb17-7Mar17 #####

#now rbind in the data from Sample 2015-28409 and from merged_List_and_MSD, which contains the compiled data from 22Nov16-19Jan17.


complete_List_and_MSD<- rbind(no_NA_merged_List_and_3plex_MSD, merged_List_and_MSD )

#now I'll also drop the row with Stacy's meta data for  sample 2016-9308 since we don't have any MSD for it. It is the only sample with no run date, 
complete_List_and_MSD[is.na(complete_List_and_MSD$run_date),"SpID"]

# so I will just drop any rows with na in the run_date column.

complete_List_and_MSD <- complete_List_and_MSD %>%
  drop_na(run_date)

#When we looked at the results of the 2Mar17 run it looked like sample 2015-18982 may not have been added to the wells (abnormally low output). Fernanda repeated this sample along with the other sample from this PTID, (2015-18562) on 7Mar17. This confirmed that sample 2015-18982 was not added to the well on 2March17 so I am removing the data for this PTID from 2Mar17 here, leaving just the 7Mar17 data:

complete_List_and_MSD <- complete_List_and_MSD%>%
  filter(!(run_date == "2March17" & PTID == "630574"))




#### write to .csv ####

write.csv(complete_List_and_MSD, file = "compiled_data_for_Wald_group/compiled_Thika_data_22Nov16_to_7Mar17.csv", row.names = FALSE )




#### Notes on 24Feb17-7Mar17 data ####

#Because of the variation we saw in cytokine levels for this panel when we ran test samples, we ran both a 1:10 and 1:100 dilution for all samples.

#The Dilution column indicates the dilution for the sample (either 10 for 1:10 or 100 for 1:100) but none of the results have been multiplied by these dilution factors, so you will need to do that multiplication to estimate the cytokine levels in an undiluted sample.


#We ran out of SpID 2015-28409 so had to use another aliquot, 2015-28410.  2015-28410 is not in Stacy's list so there are NAs in her data for that SpID.

# When we looked at the results of the 2Mar17 run it looked like sample 2015-18982 may not have been added to the wells (abnormally low output). Fernanda repeated this sample, and the other sample from this PTID, (2015-18562) on 7Mar17. I removed the 2Mar17 data.



