#!/bin/bash
R=/shared/bioinf/R/R-3.6.0-BioC3.9/bin/R
scrpt="~/Projects/git/EuracBiomedicalResearch/batch_centroid/centroiding.R"

$R --vanilla --file=$scrpt
