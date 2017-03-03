library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)
library(tidyr)

#This is a script for compiling MSD data for Thika samples for the sample runs from 22Nov16-19Jan17



#read in raw data from all runs we have done so far by looking in the folders within the Sample Runs folder and finding the .csv files.

files <- dir("../Sample Runs/", recursive=TRUE, full.names=TRUE, pattern= ".csv")

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


#Also exclude any remaining samples that include the text "1:10" (this will also exclude anything that has "1:100") because those are leftover from when we were testing 1:10 and 1:100 dilutions.


#use back ticks so my column name with spaces works with dplyr
dat_Thika_22Nov_16_to_19Jan17 <- dat %>%
  filter(`Sample Group` != "German")%>%
  filter(!str_detect(Sample, "Cocktail"))%>%
  filter(!str_detect(Sample, "pool CVL 1:10"))%>%
  filter(!str_detect(Sample, "1:10"))


#Some of the unknowns are listed in the Sample Group column as "Unknowns" while others are "Auto_Created_Unknown" Here I will make them all say "Auto_Created_Unknown", which is the default unknown designation in the software. I don't know why we replaced it with unknowns in some places.

dat_Thika_22Nov_16_to_19Jan17 <-dat_Thika_22Nov_16_to_19Jan17%>%
  mutate(`Sample Group` = str_replace(`Sample Group`,"Unknowns", "Auto_Created_Unknown"))

#Stacy wants us to use the SpID (year-SpNum) as the identifier for the data instead of what we used, PTID-SpNum mo. X". 

#So, I need to merge the inventory Stacy sent us, which includes SpID, PTID, SpNum and some other identifiers with our MSD output so that there is a column with the correct SpID for her to use for analysis.

#she sent us the following inventory of samples to run
List_2016_sep_23<-read.csv("List 2016-sep-23.csv", check.names = FALSE)

#I will create a column in the inventory that recapitulates our identifier scheme in part, a combination of PTID-SpNum

update_List_2016_sep_23 <- List_2016_sep_23 %>%
  mutate(PTID_SpNum = paste(PTID, SpNum, sep = "-"))

#Then I'll split up my data and isolate the PTID-SpNum part of the Sample from the "mo. X" part.
newCols<-colsplit(dat_Thika_22Nov_16_to_19Jan17$Sample, pattern = " ", names =c("PTID_SpNum", "Month"))



#then bind it back to my original data
update_dat_Thika_22Nov_16_to_19Jan17<-cbind(dat_Thika_22Nov_16_to_19Jan17, newCols)

#now I'll merge my data into the modified inventory by the column that I created in each data set called "PTID_SpNum"
merged_List_and_MSD <- merge(update_List_2016_sep_23,
                             update_dat_Thika_22Nov_16_to_19Jan17,
                             by = "PTID_SpNum", all.x = TRUE, all.y = TRUE)

#Are there any that didn't merge? YAAAS
sum(is.na(merged_List_and_MSD$SpID))



#Here are the  PTID_SpNum in update_List_2016_sep_23 that are not found in my update_dat_Thika_22Nov_16_to_19Jan17, i.e. the samples that we were supposed to run but didn't.

update_List_2016_sep_23[which(!update_List_2016_sep_23$PTID_SpNum %in% update_dat_Thika_22Nov_16_to_19Jan17$PTID_SpNum), "PTID_SpNum"]

#The only missing one is 630851-9308, which is correct, because we didn't run that one (by mistake we ran 630851-9309 and I included those data.



#HOWEVER: Since we added in sample 630851-9309, there is no record for it in the SpID column, only in the PTID_SpNum column, which is not the column Stacy is using as an identifier. So, I need to fill in the corresponding value in the SpID column in the cases where I have 630851-9309 in the PTID_SpNum column.

#Make the SpID characer, so the values don't get replaced with their factor level in the following command:

merged_List_and_MSD<- mutate(merged_List_and_MSD,SpID = ifelse(PTID_SpNum == "630851-9309", "2016-9309", as.character(SpID)))



#I don't want to include the column that I created called "Month" when I did colsplit above, so I'll remove it here. And I want to remove PTID_SpNum because I only used it for merging and it will just be a confusing redunant identifier.

merged_List_and_MSD <-select(merged_List_and_MSD, -Month, -PTID_SpNum)


#NOTE
#15Dec16 9plexA 630457-18758 mo. 3, 630457-19448 mo. 6, 630503-18866 mo. 3, 630503-19054 mo. 6 replicates are not grouped together as replicates in the data readout because we had to put them in non-adjacent wells because of a pipetting error. This means that there will not be a value for a replicate mean in the Discovery workbench output. 

write.csv(merged_List_and_MSD, file = "compiled_Thika_data_22Nov_16_to_19Jan17.csv", row.names = FALSE)

  

#This is me fooling around with the data...

#setting up for MDS or principle comp


#set the below detection samples to < the minimum calc. concentration (0.00046...)
x<- merged_List_and_MSD %>%
  mutate(`Calc. Concentration` = ifelse(str_detect(`Detection Range`,"Below"),0.0003, `Calc. Concentration`))%>%
  mutate(`Detection Range` = ifelse(str_detect(`Detection Range`, "Below"), "Below", as.character(`Detection Range`))) %>%
  filter(`Sample Group` != "Standards")%>%
  filter(Assay != "RANTES" & Assay != "MIG" & Assay != "IL1-RA")
 
  
  
repsInRange<-x%>%
  group_by(SpID, Assay, `Detection Range`)%>%
  summarize(Number_Reps = n())
  


mergeRepsInRange <- x %>%
  merge(.,repsInRange, by = c("SpID", "Assay", "Detection Range"))
  




#The  rows of data that I want will fit the following criteria:

#Detection.Range = Below and Number_reps = 2 (both reps are below)
#Detection.Range != Below and Number_reps = 2 (both reps are good)
#Detection.Range != Below and Number_reps = 1 (The in/above range rep from a discordant set)



#I am doing this by filtering for the things I want to keep, then combining those dfs, rather than writing one expression to say what to exclude. (mostly because I couldnt figure it out...)

bothBad <- mergeRepsInRange %>%
  filter(`Detection Range` =="Below"& Number_Reps ==2)

discordGood<- mergeRepsInRange %>%
  filter(`Detection Range` != "Below"& Number_Reps ==1)

bothGood <- mergeRepsInRange %>%
  filter(`Detection Range` != "Below"& Number_Reps == 2)



#combine all the reps

OKtoAvg <- rbind(bothBad,discordGood, bothGood)



avgConc <- OKtoAvg %>%
  group_by(SpID, Assay, PTID, run_date)%>%
  summarize(avgConc = mean(`Calc. Concentration`))%>%
  drop_na(SpID)%>%
  ungroup()%>%
  #remove the rows where the is no SpID. Not sure why it is missing...
  mutate(PTID = ifelse(SpID == "2016-9309", "630851",PTID))
  
#make it wide for PCA
avgConc_spread <- spread(avgConc, key = Assay, value = avgConc)

#just the assay columns and the SpID
for_pca<-avgConc_spread %>%
  select(-c(PTID, run_date))


matrix_for_pca<-as.matrix(for_pca[,-1])
                                
                                
rownames(matrix_for_pca)<-for_pca$SpID




pca<-prcomp(matrix_for_pca, scale = TRUE)

# from here :https://tgmstat.wordpress.com/2013/11/28/computing-and-visualizing-pca-in-r/
#how much is each pc contributing?

plot(pca, type = "lines")

#quantify the "importance" of components
summary(pca)

#The results we want are in pca$x, these are the values of the rotated data, which are the coefficients of the linear combinations of the continuous variables.

#I want to make the pca$x object into a data frame, then merge in some other data so I can annotate the plot based on other variables.


pca_values <- pca$x

pca_values<-as.data.frame(pca_values)
  
pca_values$SpID<-rownames(pca_values)

rownames(pca_values)<-NULL

#make it long format, 1:17 tells it which columns to gather.
#long_pca_values<-gather(pca_values, key = components, value = values, 1:17)


#merge other non-numeric variables from the avgConc df by SpID and Assay

meta_data<-avgConc%>%
  select(SpID, PTID, run_date)


merged_pca_meta<-merge(pca_values, meta_data, by = "SpID")

#for this plot I just plot the first two components 

pc_1_2_merged_pca_meta<-merged_pca_meta %>%
  select(SpID, PTID, PC1, PC2, run_date)

ggplot(merged_pca_meta, aes(x = PC1, y = PC2))+
  geom_point(aes(color = run_date))

#outliers?
#2015-35313 on 13Jan17 
#2016-7279 on 19Jan17

#or just do this...from here: https://cran.r-project.org/web/packages/ggfortify/vignettes/plot_pca.html

#this is plotting the rotations though I think, not the values in pca$x
library(ggfortify)
autoplot(prcomp(matrix_for_pca),
         label = TRUE, label.size = 2,
         loadings = TRUE)

#which is the same as
ggplot(prcomp(matrix_for_pca), aes(PC1, PC2))+
  geom_point()


#or maybe from here: https://www.analyticsvidhya.com/blog/2016/03/practical-guide-principal-component-analysis-python/

#where scale = 0 "ensures that arrows are scaled to represent the loadings"
#this appears to be the same as when I plotted from pca$x
biplot(pca, scale =0)

  

