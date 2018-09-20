#!/bin/bash
R=/shared/bioinf/R/R-3.5.1-BioC3.7/bin/R
scrpt="~/Projects/git/EuracBiomedicalResearch/batch_centroid/centroiding.R"

$R --vanilla --file=$scrpt
