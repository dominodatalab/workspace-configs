options(repos=structure(c(CRAN="https://cran.rstudio.com")))

.domino.IsSvgAvailable <- function () {
  return(capabilities('cairo'))
}

.domino.SetupDefaultGraphicsDeviceAsResult <- function () {
  if (.domino.IsSvgAvailable()) {
    grDevices::svg(filename = "results/Rplot%03d.svg", onefile = FALSE)
  } else {
    grDevices::pdf(file = "results/Rplot%03d.pdf", onefile = FALSE)
  }
}

# RStudio will set the env variable RSTUDIO=1 when it runs
if (Sys.getenv("RSTUDIO") != 1) {
  setHook(
    packageEvent("grDevices", "onLoad"),
    function(...) {
      # cat('[domino] Setting default graphics to output to results/ folder...\n')
      .domino.SetupDefaultGraphicsDeviceAsResult()
    }
  )
}

.domino.dumpFrames <- function () {
  cat("[domino] Saving output of dump.frames to 'domino.last.dump.Rda'. You can load it with R's 'debugger' function to debug your script.\n", file = stderr())
  dump.frames(dumpto = "domino.last.dump", to.file = TRUE)
}

.domino.dumpWorkspace <- function () {
  totalBytes = sum(sapply(ls("package:base", all.names=TRUE), function(theObj) object.size(get(theObj))))
  twoGB = 2 * 1024 * 1024 * 1024
  if (totalBytes < twoGB) {
    cat("[domino] Saving your workspace to 'domino.workspace.RData' in case you want to access your intermediate results.\n", file = stderr())
    save.image(file = "domino.workspace.RData")
  } else {
    cat("[domino] Your workspace was more than 2GB, so we are not saving it for you, sorry.\n", file = stderr())
  }
}

.domino.handleError <- function () {
  # RStudio will set the env variable RSTUDIO=1 when it runs
  if (!exists(".domino.notebook") & Sys.getenv("RSTUDIO") != 1) {
    # Create dump files to help debug scripts that were not executed as a notebook.
    .domino.dumpFrames()
    .domino.dumpWorkspace()
    # Abort script (except for notebook sessions).
    q(status = 1)
  }
}

options(error = .domino.handleError)
