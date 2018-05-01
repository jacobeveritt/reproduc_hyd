# *------------------------------------------------------------------
# | PROGRAM NAME: 03_ap_model_fit
# | FILE NAME: 03_ap_model_fit.R
# | DATE: 
# | CREATED BY:  Jim Stagge         
# *----------------------------------------------------------------
# | PURPOSE:  This is a code wrapper to fit the Annual Percentile (AP) model.
# | It fits cumulative probability distributions for annual and monthly flows.
# |
# |
# *------------------------------------------------------------------
# | COMMENTS:               
# |
# |  1:  
# |  2: 
# |  3: 
# |*------------------------------------------------------------------
# | DATA USED:               
# | USGS gauge flow data
# | Annual reconstructions from:
# | Allen, E.B., Rittenour, T.M., DeRose, R.J., Bekker, M.F., Kjelgren, R., Buckley, B.M., 2013. A tree-ring based reconstruction of Logan River streamflow, northern Utah. Water Resources Research 49, 8579–8588. doi:10.1002/2013WR014273.
# |
# | DeRose, R.J., Bekker, M.F., Wang, S.Y., Buckley, B.M., Kjelgren, R.K., Bardsley, T., Rittenour, T.M., Allen, E.B., 2015. A millennium-length reconstruction of Bear River stream flow, Utah. Journal of Hydrology 529, Part 2, 524–534. doi:10.1016/j.jhydrol.2015.01.014.
# |
# |*------------------------------------------------------------------
# | CONTENTS:               
# |
# |  PART 1:  
# |  PART 2: 
# |  PART 3: 
# *-----------------------------------------------------------------
# | UPDATES:               
# |
# |
# *------------------------------------------------------------------

### Clear any existing data or functions.
rm(list=ls())

###########################################################################
## Set the Paths
###########################################################################
### Path for Data and Output	
data_path <- "../../data"
output_path <- "../../output"
global_path <- "../global_func"
function_path <- "./functions"

### Set output location
output_name <- "reproduc"
write_output_base_path <- file.path(output_path, output_name)

dir.create(write_output_base_path)

### Set input location
data_path<- file.path(data_path, "reproduc")

###########################################################################
###  Load functions
###########################################################################
### Load these functions for all code
require(colorout)
require(assertthat)
require(staggefuncs)
require(tidyverse)
require(colorblindr)

### Load these functions for this unique project
require(stringr)

### Fix the select command
select <- dplyr::select

### Load project specific functions
file.sources = list.files(function_path, pattern="*.R", recursive=TRUE)
sapply(file.path(function_path, file.sources),source)

### Load global functions
file.sources = list.files(global_path, pattern="*.R", recursive=TRUE)
sapply(file.path(global_path, file.sources),source)



###########################################################################
## Set Initial Values
###########################################################################

journal_abbrev <- c("EM&S", "HESS", "JoH", "JAWRA", "JWRP&M", "WRR")
journal_colors <- cb_pal("custom", n=6, sort=FALSE)

###########################################################################
## Set Additional Output Folders
###########################################################################
### Set up output folders
write_figures_path <- file.path(write_output_base_path, "figures")
dir.create(file.path(write_figures_path,"png"), recursive=TRUE)
dir.create(file.path(write_figures_path,"pdf"), recursive=TRUE)
dir.create(file.path(write_figures_path,"svg"), recursive=TRUE)

###########################################################################
###  Read in Data
###########################################################################

### Read in reproducibility data
read_location <- file.path(data_path, "Reproducibility survey_April18_final.csv")

reproduc_df <- read.csv(file = read_location)

### Consider trying the function str_clean()  from explarotaory packages to clean up \n and things like that

### Can use this to pull out comma delimited data into separate rows
#mutate(`Select Investors` = str_split(`Select Investors`, ", "))
#unnest(`Select Investors`)

###########################################################################
###  Fix http in Q3
###########################################################################
### Remove doi.org/
### Remove https://doi.org/
reproduc_df$Q3 <- str_replace(reproduc_df$Q3, "https://", "")
reproduc_df$Q3 <- str_replace(reproduc_df$Q3, "doi.org/", "")
reproduc_df$Q3 <- as.character(reproduc_df$Q3)
 


###########################################################################
###  Drop duplicates
###########################################################################
### Check for duplicates
duplicate_df <- reproduc_df %>% 
	group_by(Q3) %>% 
	filter(n()>1) %>% 
	summarize(n=n(), Reviewer=Q1[1], Title=Q4[1]) %>%
	arrange(Reviewer, Q3)

duplicate_df <- data.frame(duplicate_df)

### Output to csv
write.csv(duplicate_df, file.path(write_output_base_path, "duplicates_by_number.csv"))

duplicate_full <- reproduc_df[reproduc_df$Q3 %in% duplicate_df$Q3,] %>%
	arrange(Q3)

### Output to csv
write.csv(duplicate_full, file.path(write_output_base_path, "duplicates_full.csv"))


### Remove duplicates based on DOI (Q3)
reproduc_df <- reproduc_df %>% 
  	distinct("Q3") %>%
  	arrange(Q2, Q1, Q3)


# Q2 = journal
# Q3 = doi
# Q4 = citation
# Q5 = Some or all available?*** Data-less? Not specified?
# Q6 = Author request, third party, available only in article, Some or all found online*** [[[Comma separated column, can be multiples]]]
# Q7 = ***Directions to run, Code/Model/Software, Input Data,      Hardware/Software requirements, File format, instructions to open [[[Comma separated column]]]
# Q8 = comments
# Q9 = Do I think i can do it: yes**, no, not sure**, not familiar with computational**

###########################################################################
###  Read in publication summary table
###########################################################################
pub_summary_table <- read.csv(file.path(write_output_base_path, "articles/pub_summary_table.csv"))

### Add  publication abbreviations to publication summary table
pub_summary_table$journal_abbrev <- factor(pub_summary_table$journal_abbrev, levels=journal_abbrev)


###########################################################################
###  Add keywords
###########################################################################
### Read in Papers
paper_assign <- read.csv(file.path(write_output_base_path, "articles/paper_assign.csv"))
sampled_keywords <- read.csv(file.path(write_output_base_path, "articles/sampled_keywords.csv"))
sampled_nonkeywords <- read.csv(file.path(write_output_base_path, "articles/sampled_nonkeywords.csv"))

head(sampled_nonkeywords)

### Create a column for keyword selection and merge into a single dataframe
sampled_nonkeywords$keyword <- FALSE
sampled_keywords$keyword <- TRUE
sampled_df <- rbind(sampled_nonkeywords, sampled_keywords)

### Join the paper assignments with keyword column based on index
paper_assign_merge <- paper_assign %>% 
	left_join(sampled_df, by = c("index" = "x")) %>%
	select(DOI, keyword)

### Merge back with reproduc_df to add keyword column
reproduc_df <- reproduc_df %>%
	left_join(paper_assign_merge, by = c("Q3" = "DOI"))
	

### Check missing DOIs
check_df <- reproduc_df %>%
	full_join(paper_assign_merge, by = c("Q3" = "DOI"))

missing_doi <- paper_assign_merge$DOI[!(paper_assign_merge$DOI %in% reproduc_df$Q3)]
missing_papers <- paper_assign[paper_assign$DOI %in% missing_doi, ]

### Output to csv
write.csv(missing_papers, file.path(write_output_base_path, "missing_papers.csv"))

###########################################################################
###  Process Q2 - Journal Abbreviation
###########################################################################
### Create a column of journal abbreviations
journal_names <- levels(reproduc_df$Q2)
reproduc_df$Q2_abbrev <- factor(reproduc_df$Q2, levels=journal_names, labels=journal_abbrev)

###########################################################################
###  Process Q5 - "Availability Claim"
###########################################################################
### Create a column of simplified Q5
q5_levels <- levels(reproduc_df$Q5)
reproduc_df$Q5 <- factor(reproduc_df$Q5, levels=q5_levels, labels=c("Dataless or review", "No availability", "Some or all available"))


###########################################################################
###  Process Q6 - "Availability Source"
###########################################################################
q6_labels <- c("Some or All\nAvailable Online", "Only In\nArticle", "Author\nRequest", "Third\nParty", "None")

### Create columns for each of the sources (allow duplicates) 
q6_df <- reproduc_df %>% 
	dplyr::select(Q2_abbrev, Q3, Q6) %>%
	mutate(some = str_detect(Q6, "online"))  %>%
	mutate(article = str_detect(Q6, "figures/tables/text")) %>%
	mutate(author = str_detect(Q6, "Author")) %>%
	mutate(third = str_detect(Q6, "Third"))

### Create a column for none
q6_df$none <- q6_df %>% 
	dplyr::select(-Q2_abbrev, -Q3, -Q6) %>%
	apply(., 1, sum) == 0

### Summarize, count number of each, grouped per journal
q6_journal_count <- q6_df %>%
	dplyr::select(-Q6, -Q3) %>%
	group_by(Q2_abbrev) %>%
  	summarize(author = sum(author), article = sum(article), third = sum(third), some = sum(some), none = sum(none), n= n()) %>%
  	ungroup()

### Add a total row at the bottom
q6_journal_count <- q6_journal_count %>% 
  		dplyr::select(-Q2_abbrev) %>% 
  		summarise_all(funs(sum)) %>%
  		add_column(Q2_abbrev="Total", .before=1) %>%
  		rbind(q6_journal_count, .)	

### Divide by n to get percent in each category  	
q6_journal_perc  <- q6_journal_count %>%
  	mutate(author = author/n, article = article/n, third = third/n, some=some/n, none=none/n) %>%
  	dplyr::select(-n)

### Output to csv
write.csv(q6_journal_count, file.path(write_output_base_path, "q6_journal_count.csv"))
write.csv(q6_journal_perc, file.path(write_output_base_path, "q6_journal_perc.csv"))

### Create rules for how to classify Q6
q6_df$Q6_grouping <- NA
q6_df$Q6_grouping[q6_df$article == TRUE] <- "Only In\nArticle"
q6_df$Q6_grouping[q6_df$some == TRUE] <-  "Some or All\nAvailable Online"
### End with third party or authors because these trump, disqualify
q6_df$Q6_grouping[q6_df$third == TRUE] <-  "Third\nParty"
q6_df$Q6_grouping[q6_df$author == TRUE] <-  "Author\nRequest"
q6_df$Q6_grouping[q6_df$none == TRUE] <- "None"

### Put back into reproducability df
reproduc_df$Q6_grouping <- q6_df$Q6_grouping
reproduc_df$Q6_grouping <- factor(reproduc_df$Q6_grouping, levels=q6_labels)

### Data prep
#reproduc_df$Q6_grouping <- "No"
### If it contains Author Request at all
#reproduc_df$Q6_grouping[str_detect(reproduc_df$Q6, "Author")] <- "Author\nRequest"
### If it contains Tin article at all
#reproduc_df$Q6_grouping[str_detect(reproduc_df$Q6, "figures/tables")] <- "In\nArticle"
### If it contains Third Party Request at all (trumps Author Request)
#reproduc_df$Q6_grouping[str_detect(reproduc_df$Q6, "Third Party")] <- "Third\nParty"
### If available in paper
#reproduc_df$Q6_grouping[str_detect(reproduc_df$Q6, "online")] <- "Some or\nAll Available"

#reproduc_df$Q6_grouping <- factor(reproduc_df$Q6_grouping, levels=q6_labels)



###########################################################################
###  Process Q7 - "Available Components"
###########################################################################
#Directions to run
#Code/Model/Software
#Input data

#Hardware/Software requirements
#Materials linked by unique and persistent identifiers
#Metadata to describe the code
#Common file format /instructions to open
q7_df <- data.frame(Q3=reproduc_df$Q3, Q7=reproduc_df$Q7)

### Test for each of the primary answers
q7_df$dir <- str_detect(reproduc_df$Q7, "Directions to run")
q7_df$code <- str_detect(reproduc_df$Q7, "Code/Model/Software")
q7_df$data <- str_detect(reproduc_df$Q7, "Input data")

### Count number of primary
q7_df$primary_n <- q7_df %>% 
	dplyr::select(c("dir", "code", "data")) %>%
	rowSums(.)

### Test for all primary
q7_df$primary <- q7_df$primary_n == 3	

### Test for each of the secondary answers
q7_df$hardw <- str_detect(reproduc_df$Q7, "Hardware/Software requirements")
q7_df$doi <- str_detect(reproduc_df$Q7, "Materials linked by unique and persistent identifiers")
q7_df$meta <- str_detect(reproduc_df$Q7, "Metadata to describe the code")
q7_df$common <- str_detect(reproduc_df$Q7, "Common file format /instructions to open")

### Count number of secondary
q7_df$secondary_n <- q7_df %>% 
	dplyr::select(c("hardw", "doi", "meta", "common")) %>%
	rowSums(.)
	
### Test for some of secondary
q7_df$secondary_some <- q7_df$secondary_n > 0	
q7_df$secondary_all <- q7_df$secondary_n == 4	

### Test for all
q7_df$all <- q7_df$primary == TRUE & q7_df$secondary_all == TRUE 


### Test plot
q7_melt <- q7_df %>%
	dplyr::select(-Q3, -Q7, -primary_n, -secondary_n) %>%
	gather()
	
ggplot(q7_melt, aes(x=key, fill=value)) + geom_bar()	

### Merge back into reproduc_df
sum(q7_df$Q3 != reproduc_df$Q3)

q7_df <- q7_df %>% dplyr::select(-Q7, -Q3)
names(q7_df) <- paste0("Q7_", names(q7_df))

#names(q7_df)[1] <- "Q3"
#reproduc_df <- left_join(reproduc_df, q7_df, by="Q3")

reproduc_df <- cbind(reproduc_df, q7_df)




q7_df$Q2_abbrev <- reproduc_df$Q2_abbrev

### Summarize, count number of each, grouped per journal
q7_journal_count <- q7_df %>%
	dplyr::select(-Q7_primary_n, -Q7_primary, -Q7_secondary_n, -Q7_secondary_some, -Q7_secondary_all, -Q7_all) %>%
	group_by(Q2_abbrev) %>%
  	summarize(dir = sum(Q7_dir), code = sum(Q7_code), data = sum(Q7_data), hardw = sum(Q7_hardw), doi = sum(Q7_doi), meta = sum(Q7_meta), common = sum(Q7_common), n= n()) %>%
  	ungroup()

### Add a total row at the bottom
q7_journal_count <- q7_journal_count %>% 
  		dplyr::select(-Q2_abbrev) %>% 
  		summarise_all(funs(sum)) %>%
  		add_column(Q2_abbrev="Total", .before=1) %>%
  		rbind(q7_journal_count, .)	

### Divide by n to get percent in each category  	
q7_journal_perc  <- q7_journal_count %>%
  	mutate(dir = dir/n, code = code/n, data = data/n, hardw = hardw/n, doi = doi/n, meta = meta/n, common = common/n) %>%
  	dplyr::select(-n)
  	
  	
###########################################################################
###  Process Q9 - "Availability Determination"
###########################################################################
# "I'm not familiar with the required computational resources.\n(specify required computational resources (e.g., R, Fortran, Linux)"
# "No"                                                                                                                              
# "Not sure (unclear materials.....hard to follow)"                                                                                 
# "Yes"

### Separate Q9    
q9_reframe <- as.character(reproduc_df$Q9)

### Convert NAs to No
q9_reframe[q9_reframe == ""] <- "No"

### Create labels and levels
q9_labels <- c("Yes", "Unfamiliar Methods", "Not Sure", "No")
q9_levels <- unique(q9_reframe)
q9_levels <- q9_levels[c(3,4,2,1)]
q9_labels
q9_levels

q9_reframe <- factor(q9_reframe, levels=q9_levels, labels=q9_labels)

### Factor q9
reproduc_df$Q9 <- q9_reframe

### Check plot
ggplot(reproduc_df, aes(x=Q9)) + geom_bar()



###########################################################################
###  Save progress
###########################################################################
save(reproduc_df, q6_labels, q6_journal_perc, q6_journal_count, q7_journal_perc, q7_journal_count, q9_labels, file=file.path(write_output_base_path, "reproduc_data.rda"))







 