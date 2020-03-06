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

# import excel output GloMax with readxl into a dataframe.The datasheet needs a sheet labeled "Conditions" that indicates the conditions for each of the 96 wells
# import data into separate dataframes and convert each to a vector
# either point to number or name of the correct sheet 
firefly <- read_excel("DualReporter_example_data.xlsx", sheet = "Results", range = "F21:Q28", col_names = F) %>% unlist()
renilla <- read_excel("DualReporter_example_data.xlsx", sheet = "Results", range = "F42:Q49", col_names = F) %>% unlist()
condition <- read_excel("DualReporter_example_data.xlsx", sheet = "Conditions", range = "A1:L8", col_names = F) %>% unlist()

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
cond1 <- FR$B/FR$A
cond2 <- FR$C/FR$A
relative <- tibble(cond1, cond2)
relative_tidy <- gather(relative, condition, FC)
relative_tidy


p2 <- ggplot(relative_tidy, aes(condition, FC)) + 
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

