# Dual Reporter Pipeline
A pipeline to process dual luciferase assay results.

This R-based workflow is designed to standardize the analysis and publication of dual reporter systems. The main objective is to facilitate calculation and visualization of differential expression between a tested and reference gene. Promega's GloMax luminescence machine produces an excel sheet with expression data for the reporter and the control condition, which will be used as input for the script.

## Input data (expressed as arbitrary luminescence units)
* excel sheet containing 2 tables in 96-well lay-out (raw output from a Promega GloMax® Navigator)
* conditions.csv which is a CSV file in which conditions are indicated in a 96-well lay-out

## Data preparation
* Adjust conditions.csv to reflect the conditions (empyt cells will not be used in the analysis)

## Prepare R environment
install the necessary packages (if necessary):
install.packages("readxl", "tidyr", "ggplot2", "dplyr","gridExtra", "magrittr")


## Data loading
Excel data can be read by using the read_excel function and point directly to the sheet of interest.
* create a dataframe called "firefly" and "renilla" and read the data from the Glomax output
* firefly <- read_excel("DualReporter_example_data.xlsx", sheet = "firefly") 
* repeat this step for renilla internal control. 

## Normalizing to internal control
This step calculates the FR ratio which forms the basis of the experiments. This data is useful to visualize and summarise to get an 	impression of the quality of the experiment. After the normalization a summary plot (PNG) and table (PDF) are produced. 
* FR <- firefly / renilla
* FR_tidy <- gather(FR, condition, FR)

## Relative expressions
The newly obtained FR ratio can be used to calculate relative expression between experimental and reference conditions. A plot containing the datapoints is produced. 
* In the example data, column A contains data of the reference condition.
* Expression fold-changes should be calculated relative to column A.
* To obtain relative change in expression of condition B, calculate B/A

## Desired Output
* Summary table of normalized expression per condition --> FR ratios.
This table contains each datapoint, the mean, median and standard deviation
	
* Dot plot of data points, grouped per experimental condition.
	* x-axis: control and experimental conditions
	* y-axis: FR ratio
	* Stats: median 

* Dot plots of expression relative to the control condition (emtpy vector, vehicle etc) 
	* x-axis: experimental conditions
	* y-axis: Fold-Change expression / control condition
	* Stats: median 

## Output examples
![example plot of FR ratios of each reporter conditions. Bar shows median](https://github.com/ebrando/dual-luciferase/blob/master/FR_summary.png)
![example plot of relative expressions, normalized to the empty vector. Bar shows median](https://github.com/ebrando/dual-luciferase/blob/master/FC_lucexpression.png)
    
## Future
In case of multiple experimental conditions, it can be useful to plot a selection of relevant conditions. 

	
	


