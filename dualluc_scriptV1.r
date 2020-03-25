# Dual Luciferase Analysis Pipeline
# Elias Brandorff, SILS Amsterdam Version 1
# import excel data from GloMax luminescence machine
# level 1 calculations: normalize expression to internal control 
# plot normalized expression values
# produce a summary table
# level 2 calculations: normalize expression of experimental to control condition
# plot relative expression 


#set working path
setwd("C:/DualReporterPipeline/")

# load the relevant libraries
library(readxl)
library(tidyr)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(magrittr)

# import complete excel output GloMax with readxl into a dataframe.
# either point to number or name of the correct sheet 
all_data_from_excel <- read_excel("Dual Luciferase Reporter Assay System ELIAS 2020.03.10 05_34_44.xlsx", sheet = "Results")

#Subset firefly data
firefly <- all_data_from_excel[19:26,6:17] %>% unlist()

#Subset renilla data
renilla <- all_data_from_excel[40:47,6:17] %>% unlist()

#Read conditions from a csv file - empty cells are interpreted as NA
df_conditions <- read.csv("conditions_exp3.csv", stringsAsFactors = FALSE, na.strings = c("","NA","na"))

#Subset the dataframe, to select only conditions (get rid of row names)
df_conditions <- df_conditions[1:8,2:13] 

#Convert the dataframe with conditions to a vector
condition <- df_conditions %>% unlist(use.names = FALSE)

#Combine all vectors in a (tidy) dataframe, remove data that has no condition associated with it
#Note: By using filtering for NA, the 'condition' vector defines the data you want to analyze/display
df <- data.frame(condition,firefly,renilla) %>% filter(!is.na(condition))

#add a column that in which data is normalized to internal control
df <- df %>% mutate(FR=firefly/renilla) %>% na.omit() #Remove NA from the table (i.e. cells without data)

#Ensure that the order of the conditions is kept (otherwise ordering is alphabetical)
df$condition <- factor(df$condition, levels=unique(df$condition))

#Use this line of code when you want to sort the data acoording to median of FR
# df$condition <- reorder(df$condition, df$FR, median, na.rm = TRUE)

FR_tidy <- df

#plotting FR ratios for data overview
p1 <- ggplot(FR_tidy, aes(x = condition, y = FR)) +
  geom_jitter(position=position_jitter(0.1), cex=2, color="grey40") +
  stat_summary(fun = median, fun.min = median, fun.max = median,
               geom = "crossbar", width = 0.2)

p1

#Save p1 in png format
png("FR_summary_exp1.png", width = 300, height = 300)
plot(p1)
dev.off()

#Attemp to spread the dataframe. 
FR_tidy5 <- df %>%
  select(condition, FR) %>%
  group_by(condition) %>%
  mutate(grouped_id = row_number()) %>%
  pivot_wider(id_cols = NULL, names_from = condition, values_from = FR) %>%
  summarize_all(funs(median)) %>%
  select(-grouped_id)
FR_tidy5

#The table is in the correct orientation now. But we want to ad the mean and median as the 2 bottom rows to a the FR-values

#produce a table in PDF for publication containing the mean FR ratio per condition
pdf("FRtable_exp1.pdf", height=11, width=10, pivot = TRUE)
grid.table(FR_tidy5)
dev.off()

#FR summary
FR2_tidy2 <- FR_tidy %>%
  group_by(condition) %>%
  summarise(median = median(FR, na.rm = TRUE), mean = mean(FR, na.rm = TRUE))
FR2_tidy2

#doing the relative calculation i.e. normalize to expression of the empty vector "Ev"
#Calculate the average of the EV control
#each condition gets it's own EV_mean
EV_mean1 <- FR_tidy %>% filter(condition=="control_DMSO") %>% summarise(mean_EV_FR=mean(FR))  %>% unlist(use.names = FALSE)
EV_mean2 <- FR_tidy %>% filter(condition=="control_ZNF91_DMSO") %>% summarise(mean_EV_FR=mean(FR))  %>% unlist(use.names = FALSE)
EV_mean3 <- FR_tidy %>% filter(condition=="control_PDS") %>% summarise(mean_EV_FR=mean(FR))  %>% unlist(use.names = FALSE)
EV_mean4 <- FR_tidy %>% filter(condition=="control_ZNF91_PDS") %>% summarise(mean_EV_FR=mean(FR))  %>% unlist(use.names = FALSE)

#Divide FR by treatment-dependent control value
FR_tidy <- FR_tidy %>% mutate(FC = FR/EV_mean1)
FR_tidy <- FR_tidy %>% mutate(FC = FR/EV_mean2)
FR_tidy <- FR_tidy %>% mutate(FC = FR/EV_mean3)
FR_tidy <- FR_tidy %>% mutate(FC = FR/EV_mean4)

####Here we can do an actual experiment. 
####For example, to answer the question: "What is the difference in reporter expression between THOC5_DMSO and THOC5_PDS?" 
####After normalization for renilla and the empty vector, we should be able to divide the normalized FC's of these conditions to observe the actual difference. 

p2 <- ggplot(FR_tidy, aes(condition, FC)) + 
  geom_point() +
  stat_summary(fun = median, fun.min = median, fun.max = median,
               geom = "crossbar", width = 0.2) +
  ylab("FC luciferase expression / EV normalized to renilla") +
  ylim(0,1)

p2

#Save p2 in png format  
png("FC_lucexpression1.png", width = 300, height = 300)
plot(p2)
dev.off()

tbl_median <- tableGrob(t(FR2_tidy2), theme = ttheme_default(8))
grid.arrange(p1, p2, tbl_median, ncol=2, nrow=2, as.table=TRUE, heights=c(3,1))
