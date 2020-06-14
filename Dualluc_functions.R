#Functions with Dual luc 

# import luc data from excel machine output
# give the relevant file name
# practice functions from software carpentry http://swcarpentry.github.io/r-novice-inflammation/02-func-R/index.html

load_raw <- function(filename) {# load all data from input excel sheet into an object
  dat1 <- read_excel(path = filename, sheet = "Results")
}

load_conditions <- function(filename) { #read data from condition-sheet in excel file and store in object
  dat2 <- read_excel(path = filename, sheet = "conditions")
  # specify which cells from the sheet contain the condition names
  conditions <- dat2[1:8,2:13] %>% unlist() 
}

subset_firefly <- function() {
  f1 <- all_data_from_excel[19:26,6:17] %>% unlist()
}

subset_renilla <- function() {
  r1 <- all_data_from_excel[40:47,6:17] %>% unlist()
}


