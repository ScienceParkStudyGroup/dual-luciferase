# Dual Luciferase Analysis Pipeline
# Elias Brandorff, SILS Amsterdam Version 1
# import excel data from GloMax luminescence machine
# level 1 calculations: normalize expression to internal control 
# plot normalized expression values
# produce a summary table
# level 2 calculations: normalize expression of experimental to control condition
# plot relative expression 

###########
# Library
###########
if (! "checkpoint" %in% installed.packages()){
  install.packages("checkpoint")
}

library("checkpoint")
checkpoint("2020-01-01")

# load the relevant libraries
library(readxl)
library(tidyverse)
library(gridExtra)
library(magrittr)
library(remotes)
if (! "gt" %in% installed.packages()){
  remotes::install_github("rstudio/gt") # not available on CRAN yet
}
library(gt)
library(webshot)
# webshot::install_phantomjs() this needs to be run once


#############
# Data import
#############

# import excel output GloMax with readxl into a dataframe.
# The datasheet must be prepared by creating separate sheets for firefly and renilla.
# import both data into separate dataframes
#  either point to number or name of the correct sheet 
firefly <- read_excel("DualReporter_example_data.xlsx", sheet = "firefly")
renilla <- read_excel("DualReporter_example_data.xlsx", sheet = "renilla")


# normalization to internal control
FR <- firefly / renilla

# convert dataframe to tidy format
FR_tidy <- gather(FR, condition, FR)

#######
# Plots
#######
# plotting FR ratios for data overview
p1 <- ggplot(FR_tidy, aes(x = condition, y = FR)) +
  geom_jitter(position=position_jitter(0.1), cex=2, color="grey40") +
  stat_summary(fun.y = median, fun.ymin = median, fun.ymax = median,
               geom = "crossbar", width = 0.2)

p1

ggsave(filename = "FR_summary.png", width = 7, height = 5, dpi = 300)


# FR summary
FR2_tidy2 <- FR_tidy %>%
  group_by(condition) %>%
  summarise(median = median(FR, na.rm = TRUE), mean = mean(FR, na.rm = TRUE))




#######
# Table
#######
# produce a table in PDF for publication containing the mean FR ratio per condition
# Use of the RStudio gt table package
FR2_tidy2 %>% 
  gt() %>% 
  tab_header(title = "Firefly to renilla ratios") %>% 
  gtsave(filename = "FR1.pdf")



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


tbl_median <- tableGrob(t(FR2_tidy2), theme = ttheme_default(8))
grid.arrange(p1, p2, tbl_median, ncol=2, nrow=2, as.table=TRUE, heights=c(3,1))

