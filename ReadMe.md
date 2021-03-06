# Reproducibility in Hydrology

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1467417.svg)](https://doi.org/10.5281/zenodo.1467417)

This repository contains code associated with paper, entitled, 'A novel replicability survey tool to measure and promote reproducibility in hydrology'. When run, it will replicate the results published in Stagge et al. (2018, [in review, preprint](https://github.com/jstagge/reproduc_hyd/blob/master/assets/stagge_et_al_reproducibility_preprint.pdf)). It is provided here for transparency and so that other users may benefit from its underlying code. Please cite both the paper and this repository if you make use of any part of this.

## Access or edit the survey tool  
The survey flowchart, the online live survey, and the survey form are availabe [here](https://github.com/jstagge/reproduc_hyd/blob/master/assets/Survey_files.md)   

## Getting Started

*Choose an option*:

### Option 1: Run code live in the cloud with no prerequisites

Click at this badge to execute the analysis and replicate results using R-Studio in the cloud without needing to install R or its dependencies on your local machine.    
RStudio: [![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/jstagge/reproduc_hyd/master?urlpath=rstudio)

If you want to share this live RStudio link with others, please share this URL: http://mybinder.org/v2/gh/jstagge/reproduc_hyd/master?urlpath=rstudio

*Note*, URLs that contain (https://hub.mybinder.org.....) will become invalid after few minutes of inactivity.

Once RStudio launches online, it will come with all the prerequisites installed and ready to execute. So skip ```Rscript 00_prepare_file_system.R``` step in running the code.    
 

### Option 2: Run code on a local machine   
These instructions will allow you to process the reproducibility survey data on your local machine for testing purposes. All code is written in R. See Prerequisites and Running sections below for detailed instructions.  

### Prerequisites

In order to run this code, you must install:
* [R for Statistical Computing](https://www.r-project.org/)

All necesary R packages will be installed automatically in the first file.

## Running the Code

First, make sure to set the working directory to the downloaded and unzipped folder.  

### Running all scripts at once

Code is numbered based on the order of operations.  If you would like to simply recreate the results of Stagge et al. (2018, in review), you may run the following from any command line after installing R. For more detailed information about each file, see below:

```
Rscript 00_prepare_file_system.R
Rscript 01_article_analysis.R
Rscript 02_reproduc_data_handling.R
Rscript 03_reproduc_figs.R
Rscript 04_pop_estimate.R
```

### Running scripts step-by-step
The following file prepares the file system, installing any necesary packages and creating folders for model output. 

If you're using the cloud option, skip this step.  
```
Rscript 00_prepare_file_system.R
```
The next script processes all articles from 2017, plots their keywords, separates the keyword or non-keyword papers, and randomly assigns papers to reviewers.

This code will randomly assign papers, so it will not exactly reproduce results from Stagge et al. (2018). Results from the initial run are included in the data/article_analysis folder.
```
Rscript 01_article_analysis.R
```
The following script performs all calculations on the results of the  reproducibility survey. It prepares the data to be plotted using code file number 3. All results will be saved into a large .RDS file. This allows for the data to be plotted immediately or to be loaded later for additional analysis.

```
Rscript 02_reproduc_data_handling.R
```
The following file plots all figures from the analysis, incuding many that are not provided in the published paper. All files will be saved to a folder located at /output/figures.
```
Rscript 03_reproduc_figs.R
```
The final code file creates a estimate for all articles published in these journals during 2017 (i.e. the population).
```
Rscript 04_pop_estimate.R
```
## Results       
After you run the scripts above, look into a new generated folder called "Output". Then open the sub-folder inside it called "publication_figures which will contain the figures 2,3,4, and 6 as reported in the paper.   


## Preprint

[Preprint manuscript file](https://github.com/jstagge/reproduc_hyd/blob/master/assets/stagge_et_al_reproducibility_preprint.pdf) with all text, figures, tables, etc. submitted to Scientific Data.

Please note, this publication is currently under review and is presented here only as reference for the code repository. As per the policies of Scientific Data, this work is subject to press embargo until published.

## Reference and How to Cite

For any description of this methodology, please use the following citation (s):

* Stagge, J.H., Rosenberg, D.E., Abdallah, A.M., Akbar, A., Attallah, N., and James, R. (In review) "A survey tool to assess and improve data availability and research reproducibility." Scientific Data. [In review, preprint](https://github.com/jstagge/reproduc_hyd/blob/master/assets/stagge_et_al_reproducibility_preprint.pdf)

* Stagge, J.H., Abdallah, A.M., and Rosenberg, D.E. (2018) "jstagge/reproduc_hyd: Source code accompanying "A survey tool to assess and improve data availability and research reproducibility" doi: 10.5281/zenodo.1467417


## Authors

* **James H. Stagge** - *Owner* - [jstagge](https://github.com/jstagge)

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


## Acknowledgments   
This material is based upon work supported by Utah Mineral Lease Funds, the National Science Foundation, funded through OIA – 1208732, and the U.S. Fullbright Program. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of any of the funding organizations. 

The authors thank Amber S Jones for providing feedback on an early draft, Stephen Maldonado and Marcos Miranda for external review of the code repository, and Ayman Alafifi for participation in early discussions to develop the survey tool. 


