##############svr normalization function
SXTsvrNor <- function(sample,
                      QC,
                      tags,
                      sample.order,
                      QC.order,
                      #used data
                      multiple = 5,
                      rerun = TRUE,
                      peakplot = TRUE,
                      path = NULL,
                      datastyle = "tof",
                      dimension1 = TRUE,
                      threads = 1
                      #parameters setting
) {
  # browser()
  options(warn = -1)
  ######is there the e1071?
  if (is.null(path)) {
    path <- getwd()
  } else{
    dir.create(path)
  }

  path1 <- file.path(path, "svr normalization result")
  dir.create(path1)

  if (!rerun) {
    cat("Use previous normalization data\n")
    # Sys.sleep(1)
    load(file.path(path1, "normalization file"))
  }

  else {
    # library(snow)
    # library(wordcloud)
    cl <- snow::makeCluster(threads, type = "SOCK")
    nc <- length(cl)
    options(warn = -1)
    ichunks <- split((1:ncol(sample)), 1:threads)
    options(warn = 0)
    # clusterExport (cl, "imputefunction")
    ######PLSDCV is the double cross validation
    svr.data <-
      snow::clusterApply(
        cl,
        x = ichunks,
        fun = svr.function,
        sample = sample,
        QC = QC,
        sample.order = sample.order,
        QC.order = QC.order,
        multiple = multiple
      )
    snow::stopCluster(cl)
    save(svr.data, file = file.path(path, "svr.data"))

    sample.nor <- NULL
    QC.nor <- NULL
    index <- NULL

    for (i in 1:nc) {
      sample.nor <- cbind(sample.nor, svr.data[[i]]$sample.nor)
      QC.nor <- cbind(QC.nor, svr.data[[i]]$QC.nor)
      index <- c(index, svr.data[[i]]$index)
    }

    sample.nor <- sample.nor[, order(index)]
    QC.nor <- QC.nor[, order(index)]

    QC.median <- apply(QC, 2, median)
    if (dimension1) {
      QC.nor <- t(t(QC.nor) * QC.median)
      sample.nor <- t(t(sample.nor) * QC.median)
    }

    if (datastyle == "tof") {
      colnames(QC.nor) <- colnames(sample.nor) <- tags["name", ]
    }
    if (datastyle == "mrm") {
      colnames(QC.nor) <- colnames(sample.nor) <- tags["name", ]
    }

    save(QC.nor, sample.nor, file = file.path(path1, "normalization file"))
  }

  rsd <- function(x) {
    x <- sd(x) * 100 / mean(x)
  }

  #following objects are the rsd of sample
  #and QC before and after normalization
  sample.rsd <- apply(sample, 2, rsd)
  sample.nor.rsd <- apply(sample.nor, 2, rsd)
  QC.rsd <- apply(QC, 2, rsd)
  QC.nor.rsd <- apply(QC.nor, 2, rsd)


  #sample.no.nor is the no normalization data added rsd information
  #sample.svr is the normalization data added rsd information


  sample.no.nor <- rbind(tags, sample.rsd, QC.rsd, sample, QC)
  sample.svr <-
    rbind(tags, sample.nor.rsd, QC.nor.rsd, sample.nor, QC.nor)

  save(sample.nor,
       QC.nor,
       tags,
       sample.order,
       QC.order,
       file = file.path(path1, "data svr nor"))
  write.csv(t(sample.svr), file.path(path1, "data svr nor.csv"))

  #generate all peaks plot

  if (peakplot) {
    path2 <- file.path(path1, "peak plot")
    dir.create(path2)

    cl <- snow::makeCluster(threads, type = "SOCK")
    nc <- length(cl)
    options(warn = -1)
    ichunks <- split((1:ncol(sample)), 1:threads)

    if (datastyle == "tof")
    {
      snow::clusterApply(
        cl,
        x = ichunks,
        fun = peakplot5,
        sample = sample,
        sample.nor = sample.nor,
        QC = QC,
        QC.nor = QC.nor,
        sample.order = sample.order,
        QC.order = QC.order,
        tags = tags,
        path = path2,
        sample.rsd = sample.rsd,
        QC.rsd = QC.rsd,
        sample.nor.rsd = sample.nor.rsd,
        QC.nor.rsd = QC.nor.rsd
      )
    }
    else {
      snow::clusterApply(
        cl,
        x = ichunks,
        fun = peakplot6,
        sample = sample,
        sample.nor = sample.nor,
        QC = QC,
        QC.nor = QC.nor,
        sample.order = sample.order,
        QC.order = QC.order,
        tags = tags,
        path = path2,
        sample.rsd = sample.rsd,
        QC.rsd = QC.rsd,
        sample.nor.rsd = sample.nor.rsd,
        QC.nor.rsd = QC.nor.rsd
      )
    }
  }


  ##generate some statistics information

  compare.rsd(
    sample.rsd = sample.rsd,
    sample.nor.rsd = sample.nor.rsd,
    QC.rsd = QC.rsd,
    QC.nor.rsd =
      QC.nor.rsd,
    path = path1
  )
  options(warn = 0)
  cat("SVR normalization is done\n")
}

svr.function <-
  function(index,
           sample,
           QC,
           sample.order,
           QC.order,
           multiple) {
    # library(e1071)
    cat("SVR normalization is finished: %\n")
    QC.nor <- NULL
    sample.nor <- NULL

    data.order <- c(sample.order, QC.order)

    if(multiple != 1){
      data <- rbind(sample, QC)
      QC.cor <- cor(data, method = "spearman")
      #not normal distribution, so use spearman correction
    }

    for (i in index) {
      if (multiple != 1) {
        cor.peak <-
as.numeric(which(QC.cor[, i] %in% rev(sort(QC.cor[-i, i]))[1:as.numeric(multiple)]))
        svr.reg <- e1071::svm(QC[, cor.peak], QC[, i])
      } else{
        svr.reg <- e1071::svm(unlist(QC[, i]) ~ QC.order)
      }

      predict.QC <- summary(svr.reg)$fitted
      QC.nor1 <- QC[, i] / predict.QC

      #if the predict value is 0, then set the ratio to 0
      QC.nor1[is.nan(unlist(QC.nor1))] <- 0
      QC.nor1[is.infinite(unlist(QC.nor1))] <- 0
      QC.nor1[is.na(unlist(QC.nor1))] <- 0
      QC.nor1[which(unlist(QC.nor1) < 0)] <- 0

      colnames(sample) <- colnames(QC)
      if (multiple != 1) {
        predict.sample <- predict(svr.reg, sample[, cor.peak])
      }
      else{
        predict.sample <-
          predict(svr.reg, data.frame(QC.order = c(sample.order)))
      }

      sample.nor1 <- sample[, i] / predict.sample
      sample.nor1[is.nan(unlist(sample.nor1))] <- 0
      sample.nor1[is.infinite(unlist(sample.nor1))] <- 0
      sample.nor1[is.na(unlist(sample.nor1))] <- 0
      sample.nor1[which(unlist(sample.nor1) < 0)] <- 0

      QC.nor <- cbind(QC.nor, QC.nor1)
      sample.nor <- cbind(sample.nor, sample.nor1)
      count <- floor(ncol(sample[, index]) * c(seq(0, 1, 0.01)))
      if (any(match(i, index) == count)) {
        cat(ceiling(match(i, index) * 100 / ncol(sample[, index])))
        cat(" ")
      }

    }
    svr.data <-
      list(sample.nor = sample.nor,
           QC.nor = QC.nor,
           index = index)
    return(svr.data)
    cat("\n")
    cat("Normalization sample and QC are got\n")
  }


##peakplot5 and peakplot6 are functions to draw peak plot
peakplot5 <-
  function(index,
           sample,
           sample.nor,
           QC,
           QC.nor,
           sample.order,
           QC.order,
           tags,
           path = NULL,
           sample.rsd = sample.rsd,
           QC.rsd = QC.rsd,
           sample.nor.rsd = sample.nor.rsd,
           QC.nor.rsd = QC.nor.rsd) {
    cat("Drawing the peak plots: %\n")
    if (is.null(path)) {
      path = getwd()
    }
    # Sys.sleep(1)

    for (i in index) {
      tiff(file.path(path, sprintf('Peak %s plot.tiff', tags["name", i])),
           width =
             1600,
           height = 800)
      layout(matrix(c(1, 2), ncol = 2))
      plot(
        sample.order,
        sample[, i],
        xlab = "Injection order",
        ylim = c(0, 2 * median(c(sample[, i], QC[, i]))),
        ylab = "Intensity",
        main = sprintf('Peak %s', tags["name", i]),
        pch = 19,
        col = "royalblue",
        cex.lab = 1.3,
        cex.axis = 1.3
      )
      points(QC.order, QC[, i], pch = 19, col = "firebrick1")

      legend(
        "topleft",
        c(
          sprintf("Sample RSD %.2f%s", sample.rsd[i], "%"),
          sprintf("QC RSD %.2f%s", QC.rsd[i], "%")
        ),
        col = c("royalblue", "firebrick1"),
        pch = c(19, 19),
        bty = "n",
        cex = 1.3,
        pt.cex = 1.3
      )

      plot(
        sample.order,
        sample.nor[, i],
        xlab = "Injection order",
        ylim = c(0, 2 * median(c(
          sample.nor[, i], QC.nor[, i]
        ))),
        ylab = "Intensity(svr)",
        main = sprintf('Peak %s', tags["name", i]),
        pch =
          19,
        col = "royalblue",
        cex.lab = 1.3,
        cex.axis = 1.3
      )

      legend(
        "top",
        c(
          sprintf("Sample RSD %.2f%s", sample.nor.rsd[i], "%"),
          sprintf("QC RSD %.2f%s", QC.nor.rsd[i], "%")
        ),
        col = c("royalblue", "firebrick1"),
        pch = c(19, 19),
        horiz = TRUE,
        bty = "n",
        cex = 1.3,
        pt.cex = 1.3
      )

      points(QC.order, QC.nor[, i], pch = 19, col = "firebrick1")

      dev.off()

      count <- floor(ncol(sample[, index]) * c(seq(0, 1, 0.01)))
      if (any(match(i, index) == count)) {
        cat(ceiling(match(i, index) * 100 / ncol(sample[, index])))
        cat(" ")
      }

    }
    cat("\n")
    cat("Peak plot is done\n")
    # Sys.sleep(1)
  }

peakplot6 <-
  function(index,
           sample,
           sample.nor,
           QC,
           QC.nor,
           sample.order,
           QC.order,
           tags,
           path = NULL,
           best.span = best.span,
           best.degree = best.degree,
           sample.rsd = sample.rsd,
           QC.rsd = QC.rsd,
           sample.nor.rsd =
             sample.nor.rsd,
           QC.nor.rsd = QC.nor.rsd) {
    cat("Drawing the peak plots: %\n")
    if (is.null(path)) {
      path = getwd()
    }
    # Sys.sleep(1)
    par(mar = c(5, 5, 4, 2))
    for (i in 1:ncol(sample)) {
      tiff(file.path(path, sprintf('Peak %s plot.tiff', tags["name", i])),
           width =
             1600,
           height = 800)
      layout(matrix(c(1, 2), ncol = 2))

      plot(
        sample.order,
        sample[, i],
        xlab = "Injection order",
        ylim = c(0, 2 * median(c(sample[, i], QC[, i]))),
        ylab = "Intensity",
        main = sprintf('Peak %s', tags["name", i]),
        pch =
          19,
        col = "royalblue",
        cex.lab = 1.3,
        cex.axis = 1.3
      )
      points(QC.order, QC[, i], pch = 19, col = "firebrick1")

      legend(
        "topleft",
        c(
          sprintf("Sample RSD %.2f%s", sample.rsd[i], "%"),
          sprintf("QC RSD %.2f%s", QC.rsd[i], "%")
        ),
        col = c("royalblue", "firebrick1"),
        pch = c(19, 19),
        bty = "n",
        cex = 1.3,
        pt.cex = 1.3
      )

      plot(
        sample.order,
        sample.nor[, i],
        xlab = "Injection order",
        ylim = c(0, 2 * median(c(
          sample.nor[, i], QC.nor[, i]
        ))),
        ylab = "Intensity(svr)",
        main = sprintf('Peak %s', tags["name", i]),
        pch =
          19,
        col = "royalblue",
        cex.lab = 1.3,
        cex.axis = 1.3
      )

      legend(
        "top",
        c(
          sprintf("Sample RSD %.2f%s", sample.nor.rsd[i], "%"),
          sprintf("QC RSD %.2f%s", QC.nor.rsd[i], "%")
        ),
        col = c("royalblue", "firebrick1"),
        pch = c(19, 19),
        horiz = TRUE,
        bty =
          "n",
        cex = 1.3,
        pt.cex = 1.3
      )

      points(QC.order, QC.nor[, i], pch = 19, col = "firebrick1")

      dev.off()

      count <- floor(ncol(sample[, index]) * c(seq(0, 1, 0.01)))
      if (any(match(i, index) == count)) {
        cat(ceiling(match(i, index) * 100 / ncol(sample[, index])))
        cat(" ")
      }

    }
    cat("Peak plot is done\n")
    # Sys.sleep(1)
  }
