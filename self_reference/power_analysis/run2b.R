Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools")
library(rmarkdown)
rmarkdown::render('power_analysis_2b.Rmd', 'html_document')



