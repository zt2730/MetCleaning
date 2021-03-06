
SXTpca <- function(subject = NULL,
                   qc = NULL,
                   info = NULL,
                   #used data
                   QC = FALSE,
                   scale.method = "auto",
                   path = ".") {
  if (path != ".") {
    dir.create(path)
  }
  if (any(is.na(subject)) |
      any(is.na(qc)))
    stop("Please impute MV in subject or QC samples.")
  if (is.null(subject))
    stop("Subject sample is NULL")
  if (!is.null(qc)) {
    if (nrow(subject) != nrow(qc))
      stop("ThSe row number of Subject and QC must same")
  }
  if (is.null(qc) & QC)
    stop("QC shoud be FALSE because qc is NULL")
  if (is.null(info))
    stop("Info must not be NULL")

  #select the subject in info and need QC or not
  index <- NULL
  for (i in seq_along(info)) {
    index1 <- as.character(info[[i]])
    index <- c(index, index1)
  }

  if (length(which(index == "")) != 0)  {
    index <- index[-which(index == "")]
  }

  index <- index[!is.na(index)]
  index <- match(index, colnames(subject))
  index <- index[!is.na(index)]
  subject <- subject[, index]


  ##discard the subject's name who is not in the subject data
  for (i in seq_along(info)) {
    idx <- as.character(info[[i]])
    idx <- match(idx, colnames(subject))
    idx <- idx[!is.na(idx)]
    info[[i]] <- colnames(subject)[idx]
  }

  if (QC) {
    int <- cbind(subject, qc)
  }
  else {
    int <- subject
  }

  ifelse(QC, int <- cbind(subject, qc) , int <- subject)
  name <- colnames(int)
  #browser()
  q <- grep("QC", name)

  if (scale.method == "auto") {
    int <- apply(int, 1, function(x) {
      (x - mean(x)) / sd(x)
    })
    int <- t(int)
  }
  if (scale.method == "pareto") {
    int <- apply(int, 1, function(x) {
      (x - mean(x, na.rm = TRUE)) / sqrt(sd(x, na.rm = TRUE))
    })
    int <- t(int)
  }

  if (scale.method == "no") {
    int <- int
  }
  if (scale.method == "center") {
    int <- apply(int, 1, function(x) {
      (x - mean(x, na.rm = TRUE))
      int <- t(int)
    })
  }

  ## PCA analysis
  int.pca <-
    prcomp(t(data.frame(int)),
           retx = TRUE,
           center = FALSE,
           scale = FALSE)
  sample.pca <- int.pca

  SXTpcaData <- list(
    sample.pca = sample.pca,
    subject = subject,
    qc = qc,
    info = info,
    QC = QC,
    scale.method = scale.method
  )
  class(SXTpcaData) <- "SXTpcaData"
  return(SXTpcaData)
}
