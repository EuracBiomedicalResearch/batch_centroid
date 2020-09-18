#!/bin/bash
# R=/shared/bioinf/R/R-3.6.0-BioC3.9/bin/R
# scrpt="~/Projects/git/EuracBiomedicalResearch/batch_centroid/centroiding.R"
#  $R --vanilla --filscrpt

R=/shared/bioinf/R/bin/R-4.0.0-BioC3.11
scrpt="/home/jrainer/Projects/git/EuracBiomedicalResearch/batch_centroid/centroiding.R"
$R --file=$scrpt
