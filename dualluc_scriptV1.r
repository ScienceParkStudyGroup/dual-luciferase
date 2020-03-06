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
all_data_from_excel <- read_excel("DualReporter_example_data.xlsx", sheet = "Results")

#Subset firefly data
firefly <- all_data_from_excel[19:26,6:17] %>% unlist()

#Subset renilla data
renilla <- all_data_from_excel[40:47,6:17] %>% unlist()

#Read conditions from a csv file
df_conditions <- read.csv("conditions.csv", stringsAsFactors = FALSE, na.strings = c("","NA","na"))

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

# FR <- firefly / renilla

# convert dataframe to tidy format
# FR_tidy <- gather(FR, condition, FR)

#plotting FR ratios for data overview
p1 <- ggplot(FR_tidy, aes(x = condition, y = FR)) +
  geom_jitter(position=position_jitter(0.1), cex=2, color="grey40") +
  stat_summary(fun.y = median, fun.ymin = median, fun.ymax = median,
               geom = "crossbar", width = 0.2)

p1

#Save p1 in png format
png("FR_summary.png", width = 300, height = 300)
plot(p1)
dev.off()

#FR summary
FR2_tidy2 <- FR_tidy %>%
  group_by(condition) %>%
  summarise(median = median(FR, na.rm = TRUE))

#Display FR2 in command line
FR2_tidy2


#produce a table in PDF for publication containing the mean FR ratio per condition
pdf("FR1.pdf", height=11, width=10)
grid.table(FR_tidy2)
dev.off()

#doing the relative calculation i.e. normalize to expression of the empty vector "Ev"
#Calculate the average of the EV control
EV_mean <- FR_tidy %>% filter(condition=="Control") %>% summarise(mean_EV_FR=mean(FR))  %>% unlist(use.names = FALSE)

#Divide FR by EV control value
FR_tidy <- FR_tidy %>% mutate(FC = FR/EV_mean)

# cond1 <- FR$B/FR$A
# cond2 <- FR$C/FR$A
# relative <- tibble(cond1, cond2)
# relative_tidy <- gather(relative, condition, FC)
# relative_tidy


p2 <- ggplot(FR_tidy, aes(condition, FC)) + 
  geom_point() +
  stat_summary(fun.y = median, fun.ymin = median, fun.ymax = median,
               geom = "crossbar", width = 0.2) +
  ylab("FC luciferase expression / EV normalized to renilla") +
  ylim(0,1250)

p2

#Save p2 in png format  
png("FC_lucexpression.png", width = 300, height = 300)
plot(p2)
dev.off()


tbl_median <- tableGrob(t(FR2_tidy2), theme = ttheme_default(8))
grid.arrange(p1, p2, tbl_median, ncol=2, nrow=2, as.table=TRUE, heights=c(3,1))

