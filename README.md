# STORM-spot-size-summary
## Calculate % of fluorescence area composed of spots of a chosen size from analyzed STORM images

This R code accepts .csv files which are assumed to contain a list of areas of fluorescent spots from an analyzed STORM image. These .csv files can be generated using ImageJ or FIJI on a .tif representation of STORM data, thresholding the image to create a binary, finding ROIs, and measuring areas. 

The spot area list for each region imaged by STORM can be saved separately into a chosen directory (an example input file is provided with this repository).

This code analyzes all appropriately labeled .csv files in the chosen directory (see code comments), and outputs a single .csv file in your R directory (called 'simple_summary.csv') that summarizes the % of the total fluorescence area for each cell that is composed of 'small' spots less than a chosen threshold, 'intermediate' spots between the low and high threshold, and 'large' spots, above the high threshold. This data is grouped by cell and by condition to look at variability among cells.

If you choose to use this code, change the `folder_path` variable to reflect your working directory, double check that your filename formatting will work with the program, ensure that the `pixel_size` variable is correct for your images, and change your thresholds (`small` and `medium` variables) to meet your needs.

