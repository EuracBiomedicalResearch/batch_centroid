mzML_dir <- "/data/massspec/mzML"  
out_dir <- "/data/massspec/RData" 
dir.create(out_dir, showWarnings = FALSE)

ncores <- Sys.getenv("SLURM_JOB_CPUS_PER_NODE", 3)
register(bpstart(MulticoreParam(ncores)))

library(xcms)
cwp <- CentWaveParam(
  peakwidth = c(2, 20), 
  ppm = 50, 
  snthresh = ,
  mzdiff = 0.001,
  prefilter = c(3, 100),
  noise = 100,
  integrate = 2)
mnp <- MergeNeighboringPeaksParam(
  expandRt = 2, 
  expandMz = 0.001, 
  ppm = 10,
  minProp = 0.66)

fls <- read.table(
  "/home/mgarciaaloy/CHRIS/chris-files.txt",
  sep = "\t", header = TRUE, as.is = TRUE)
fls <- fls$mzML_file

peak_detection_for_file <- function(x){
  require("xcms")
  fname <- x
  raw_data <- readMSData(files = paste0(mzML_dir, fname), 
                         mode = "onDisk")
  xdata <- findChromPeaks(raw_data, param = cwp)
  xdata <- refineChromPeaks(xdata, param = mnp)
  tmp <- paste0(out_dir, gsub(".mzML$", ".RData", fname))
  dir.create(dirname(tmp), recursive = TRUE, showWarnings = FALSE)
  save(xdata, file = tmp)
}

bplapply(fls, peak_detection_for_file)
