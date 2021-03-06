#' @title MetabolitePlot
#' @description Give scatter plot for each feature.
#' @author Xiaotao Shen
#' \email{shenxt@@sioc.ac.cn}
#' @param MetFlowData.before MetFlowData before normalization or integration.
#' @param MetFlowData.after MetFlowData after normalization or integration.
#' @param path Work directory.
#' @param figure Figure type you want to draw. jpeg ot pdf, default is jpeg.
#' @return Return the metabolite plot before and after processing.
#' @examples
#' \donttest{
#' #load the demo data
#' data(data, package = "MetCleaning")
#' data(sample.information, package = "MetCleaning")
#'
#' ##create a folder for demo
#' dir.create("demo")
#' setwd("demo")
#'
#' # export the demo data as csv
#' write.csv(data, "data.csv", row.names = FALSE)
#' write.csv(sample.information, "sample.information.csv", row.names = FALSE)
#'
#' # MetCleaning process
#' MetCleaning(#ImportData para
#' data = "data.csv",
#' sample.information = "sample.information.csv",
#' polarity = "positive",
#' #DataNormalization
#' method = "svr",
#' threads = 2)
#'## run
#'MetabolitePlot(met.data.after.pre,
#'               met.data.after.pre,
#'               path = "Demo for MetabolitePlot")
#'               }

MetabolitePlot <- function(MetFlowData.before,
                           MetFlowData.after,
                           path = ".",
                           figure = "jpeg") {
  if (path != ".") {
    dir.create(path)
  }

  # browser()
  qc_bef <- MetFlowData.before@qc
  subject_bef <- MetFlowData.before@subject
  tags_bef <- MetFlowData.before@tags
  data_bef <- SplitBatch(MetFlowData = MetFlowData.before)
  subject_bef1 <- data_bef[[1]]
  qc_bef1 <- data_bef[[2]]
  subject.info_bef1 <- data_bef[[3]]
  qc.info_bef1 <- data_bef[[4]]


  qc_aft <- MetFlowData.after@qc
  subject_aft <- MetFlowData.after@subject
  tags_aft <- MetFlowData.after@tags
  data_aft <- SplitBatch(MetFlowData = MetFlowData.after)
  subject_aft1 <- data_aft[[1]]
  qc_aft1 <- data_aft[[2]]
  subject.info_aft1 <- data_aft[[3]]
  qc.info_aft1 <- data_aft[[4]]

  subject.order1 <- as.numeric(MetFlowData.before@subject.order)
  qc.order1 <- as.numeric(MetFlowData.before@qc.order)

  subject.order2 <- as.numeric(MetFlowData.after@subject.order)
  qc.order2 <- as.numeric(MetFlowData.after@qc.order)
  feature.name <- as.character(tags_bef[, "name"])

  cat("Draw metabolite plot (%)\n")
  for (i in 1:nrow(subject_bef)) {
    if (figure == "jpeg")
    {
      jpeg(file.path(path, paste(feature.name[i], ".jpeg", sep = "")),
           width = 960,
           height = 480)
    }
    else
    {
      pdf(file.path(path, paste(feature.name[i], ".pdf", sep = "")),
          width = 12,
          height = 6)
    }
    layout(matrix(c(1:2), ncol = 2))
    par(mar = c(5, 5, 4, 2))
    ## before
    plot(
      subject.order1,
      as.numeric(subject_bef[i, ]),
      xlab = "Injection order",
      ylab = "Intensity",
      pch = 19,
      col = "royalblue",
      cex.lab = 1.5,
      cex.axis = 1.3,
      main = "Before"
    )
    points(qc.order1,
           as.numeric(qc_bef[i, ]),
           pch = 19,
           col = "firebrick1")
    ## add lines
    for (j in seq_along(qc.info_bef1)) {
      abline(v = max(qc.info_bef1[[j]][, 2]), lty = 2)
    }
    ## after
    plot(
      subject.order2,
      as.numeric(subject_aft[i, ]),
      xlab = "Injection order",
      ylab = "Intensity",
      pch = 19,
      col = "royalblue",
      cex.lab = 1.5,
      cex.axis = 1.3,
      main = "After"
    )
    points(qc.order2,
           as.numeric(qc_aft[i, ]),
           pch = 19,
           col = "firebrick1")
    ## add lines
    for (j in seq_along(qc.info_aft1)) {
      abline(v = max(qc.info_aft1[[j]][, 2]), lty = 2)
    }

    dev.off()
    ##
    count <- floor(nrow(subject_bef) * c(seq(0, 1, 0.01)))
    if (any(i == count)) {
      cat(ceiling(i * 100 / nrow(subject_bef)))
      cat(" ")
    }

  }

  layout(1)
}
