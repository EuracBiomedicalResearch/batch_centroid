# Perform R-based centroiding

This repository provides functions to perform batch centroiding of profile mzML
files using `MSnbase`.

## Perform centroiding of all files in a folder

- Edit the [centroiding.R](centroiding.R) script to adapt the path, specifically
  the `in_dir`, `path_pattern`, `path_replace`.
- Eventually edit also the [centroiding.sh](centroiding.sh) shell script e.g. if
  the R version changed.
- Start the job on the queuing system:
  `sbatch --mem-per-cpu=8000 -w mccalc07 -c 12 ./centroiding.sh`
  
## Check if files are centroided

We are simply checking if a) we can read the mzML file and b) if it is indeed
centroided.

- Edit the [checkfiles.R](checkfiles.R) script.
- Eventually change/edit the `chech_files.sh` script.
- Run the job, similar to the one described in the previous section.
