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

#install tidyverse package wich contains 3 essential componetns: tydr, ggplot2 and readxl. readxl enables reading excel files. 
install.packages("tidyverse")
# load the relevant libraries
library(readxl)
library(tidyr)
library(ggplot2)
library(dplyr)

# import excel output GloMax with readxl into a dataframe.The datasheet must be prepared by creating separate sheets for firefly and renilla.
# import both data into separate dataframes
#  either point to number or name of the correct sheet 
firefly <- read_excel("DualReporter_example_data.xlsx", sheet = "firefly")
renilla <- read_excel("DualReporter_example_data.xlsx", sheet = "renilla")


#normalization to internal control
FR <- firefly / renilla

# convert dataframe to tidy format
FR_tidy <- gather(FR, condition, FR)

#plotting FR ratios for data overview
p1 <- ggplot(FR_tidy, aes(x = condition, y = FR)) +
  geom_jitter(position=position_jitter(0.1), cex=2, color="grey40") +
  stat_summary(fun.y = median, fun.ymin = median, fun.ymax = median,
               geom = "crossbar", width = 0.2)

p1
png("FR_summary.png", width = 300, height = 300)
plot(p1)
dev.off()


#FR summary
FR2_tidy2 <- FR_tidy %>%
  group_by(condition) %>%
  dplyr::summarise(mean = mean(FR, na.rm = TRUE))
FR_tidy2

# produce a summar table
install.packages("gridExtra")
library(gridExtra)


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
  
png("FC_lucexpression.png", width = 300, height = 300)
plot(p2)
dev.off()
