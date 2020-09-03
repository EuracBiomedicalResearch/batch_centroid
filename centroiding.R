## Script to perform centroiding of profile-mode mzML files from a
## folder.

## Directory where the profile mzML files can be found (can contain sub-folders
## etc.
in_dir <- "/data/massspec/bbbznas01/wiff/"
## in_dir <- "/Users/jo/data/bbbznas01/wiff/"


## Pattern in the full file path from the original input files that should be
## replaced with "path_replace".
path_pattern <- "/bbbznas01/wiff/"
path_replace <- "/mzML/"

## Log directory. Timings and output from the individual processes will be
## stored there.
## log_dir <- "/Users/jo/log/centroiding/"

## Number of CPUs to use in parallel. Takes by default the number of nodes
## specified for the slurm job.
ncores <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE", 4))
## ncores <- 4

## Script starts here.
library(MSnbase)
library(BiocParallel)
library(BatchJobs)
register(bpstart(MulticoreParam(ncores)))

## if (!dir.exists(log_dir))
##     dir.create(log_dir)

fls_in <- dir(in_dir, pattern = "mzML", full.names = TRUE, recursive = TRUE)
fls_out <- sub(pattern = path_pattern, replacement = path_replace, fls_in)

## Remove those that do already exist.
fls_exst <- file.exists(fls_out)
fls_in <- fls_in[!fls_exst]

centroid_one_file <- function(z, pattern, replacement, fixed = TRUE) {
    outf <- sub(pattern = pattern, replacement = replacement, z, fixed = fixed)
    outd <- dirname(outf)
    if (!dir.exists(outd))
        dir.create(outd, recursive = TRUE)
    tmp <- readMSData(z, mode = "onDisk")
    if (any(msLevel(tmp) == 1L)) {
        if (any(msLevel(tmp) > 1)) {
            tmp <- readMSData(z, mode = "onDisk")
            ## Do smoothing and centroiding only on MS level 1, report
            ## profile-mode MS2 data.
            suppressWarnings(
                tmp <- pickPeaks(smooth(tmp, method = "SavitzkyGolay",
                                        halfWindowSize = 4L, msLevel. = 1L),
                                 refineMz = "descendPeak",
                                 signalPercentage = 33,
                                 msLevel. = 1L)
            )
            suppressWarnings(
                tmp <- pickPeaks(tmp,
                                 halfWindowSize = 4L,
                                 SNR = 1L,
                                 refineMz = "descendPeak",
                                 signalPercentage = 50,
                                 msLevel. = 2L)
            )
        } else {
            tmp <- combineSpectraMovingWindow(
                readMSData(z, mode = "inMem", msLevel = 1), timeDomain = TRUE
            )
            suppressWarnings(
                tmp <- pickPeaks(
                    smooth(tmp, method = "SavitzkyGolay",
                           halfWindowSize = 6L),
                    refineMz = "descendPeak", signalPercentage = 33)
            )
        }
        writeMSData(tmp, file = outf, copy = TRUE)
    } else {
        message("File ", basename(z), " does not contain any MS1 spectra.")
    }
}

bplapply(fls_in, centroid_one_file, pattern = path_pattern,
         replacement = path_replace)
