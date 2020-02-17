mzML_dir <- "/Users/jo/data/mzML/"
out_dir <- "/Users/jo/tmp/timestamp/"

dir.create(out_dir, showWarnings = FALSE)
ncores <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE", 2))

library(CompMetaboTools)
library(mzR)
library(BiocParallel)
register(bpstart(MulticoreParam(ncores)))

fls <- dir(mzML_dir, pattern = "mzML$", full.names = TRUE, recursive = TRUE)

timestamp_for_file <- function(x) {
    fname <- basename(x)
    res <- extract_time_stamp(x, BPPARAM = SerialParam())
    cat(format(res, "%Y-%m-%d %H:%M:%S"),
        file = paste0(out_dir, fname, ".tstmp"))
}

bplapply(fls, timestamp_for_file)
