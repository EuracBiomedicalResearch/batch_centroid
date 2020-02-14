# Converting Sciex wiff files to mzML

Before being able to do any centroiding or data analysis at all the data has to
be converted from the vendor-specific *wiff* format into *mzML* files. The
[proteowizard] software, specifically the `msconvert` script, is one of the
default tools for this task - requires however Microsoft Windows (and vendor
*dll* files) to work properly. There is however a nice alternative to the
Windows installation of the tools: docker.

## Installing proteowizard docker image

- Use the command `docker pull
  chambm/pwiz-skyline-i-agree-to-the-vendor-licenses` to get the official
  Proteowizard docker image.
- Use the following command to convert a file (replacing */your/data* with the
  path to the raw files on the local computer and *file.raw* with the name of
  the file to be converted.

```
docker run -it --rm -e WINEDEBUG=-all \
	-v /your/data:/data \
	chambm/pwiz-skyline-i-agree-to-the-vendor-licenses \
	wine msconvert /data/file.raw
```

## Converting wiff to (profile) mzML files

The [convert_to_mzML.sh](convert_to_mzML.sh) script uses this dockerized
msconvert to convert all wiff files in a specified folder to mzML.Configure the
variables within the script to point to the folder containing all wiff files,
and optionally to the folder containing the **centroided** mzML files (the
latter is useful if a large batch of files was already centroided and
centroiding should then only be performed on the new files). Converted
profile-mode mzML files are stored in the same folder the wiff files reside.

To run the script on the cluster using `slurm`:

```
sbatch --mem-per-cpu=8000 -w calc04 -c 1 ./convert_to_mzML.sh
```

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
- Eventually use `-p slow` to run the job immediately if the cluster is full.
- After centroiding eventually remove all profile-mode mzML files: change into
  the directory where the wiff files are stored and call:
  `find . -type f -name "*.mzML" -delete`.

## Check if files are centroided

We are simply checking if a) we can read the mzML file and b) if it is indeed
centroided.

- Edit the [checkfiles.R](checkfiles.R) script.
- Eventually change/edit the `chech_files.sh` script.
- Run the job, similar to the one described in the previous section.

# Conversion workflow on the IFB calculation servers

- Ensure wiff files are properly copied into */data/massspec/wiff*.
- Run the `convert_to_mzML.sh` script ensuring `SOURCE="/data/massspec/wiff"`
  and `DEST="/data/massspec/mzML"`. This will only convert wiff files to
  profile-mode mzML files if no centroided mzML file with the same name does
  already exist in */data/massspec/mzML*.
- Run the `centroiding.sh` script to centroid the profile-mode mzML files.
  

# Perform centroiding using proteowizard's `msconvert`

For very fast checks (e.g. for system suitability tests) it might be OK to use
proteowizard's centroiding.

# Tipps and tricks

For our cluster it might be helpful to put jobs in e.g. the *slow* queue, as
this will cause other jobs to be paused to automatically run mine (i.e. add `-p
slow` as a parameter.
