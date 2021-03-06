
SXTMVimputation <- function(data,
                   method = "knn",
                   ## knn parameters
                   k = 10,
                   rowmax = 0.5,
                   colmax = 0.8,
                   maxp = 1500,
                   rng.seed = 362436069,
                   ## missForest parameters
                   maxiter = 10,
                   ntree = 100,
                   decreasing =FALSE,
                   mtry = floor(sqrt(nrow(data))),
                   replace = TRUE,
                   classwt = NULL,
                   cutoff = NULL,
                   strata = NULL,
                   sampsize = NULL,
                   nodesize = NULL,
                   maxnodes = NULL,
                   xtrue = NA,
                   parallelize = 'no',
                   ##BPCA PPCA, and SVD parameters
                   nPcs = 2,
                   maxSteps = 100,
                   threshold = 1e-04
                   ) {
 # browser()

  ## KNN method
  if (method == "knn") {
    # library(impute)
    if(exists(".Random.seed")) rm(.Random.seed)
    data.knn <- impute::impute.knn(as.matrix(data),
                           k = k,
                           rowmax = rowmax,
                           colmax = colmax,
                           maxp = maxp,
                           rng.seed = rng.seed)
    data.knn <- data.knn[["data"]]
    return(data.knn)
  }

  #missForest
  if (method=="rf") {
    # library(missForest)
    data.rf <- missForest::missForest(t(data),
                          maxiter = maxiter,
                          ntree = ntree,
                          decreasing = decreasing,
                          mtry = mtry,
                          replace = replace,
                          classwt = classwt,
                          cutoff = cutoff,
                          strata = strata,
                          sampsize = sampsize,
                          nodesize = nodesize,
                          maxnodes = maxnodes,
                          xtrue = xtrue,
                          parallelize = 'no')
    data.rf <- t(data.rf$ximp)
    return(data.rf)
  }

  ## mean imputation
  if (method == "mean") {
    data.mean <-
  apply(data,1,function(x) {x <- ifelse (is.na(x), mean(x, na.rm = TRUE), x)})
    return(t(data.mean))
  }

  ## median imputation
  if (method == "median") {
    data.median <-
apply(data,1,function(x) {x <- ifelse (is.na(x), median(x, na.rm = TRUE), x)})
    return(t(data.median))
  }

  ## zero imputation
  if (method == "zero") {
    data.zero <- data
    data.zero[is.na(data.zero)] <- 0
    return(data.zero)
  }

  ## minimum imputation
  if (method == "minimum") {
    data.minimum <-
  apply(data,1,function(x) {x <- ifelse (is.na(x), min(x, na.rm = TRUE), x)})
    return(t(data.minimum))
  }

  ##BPCA
  if (method == "bpca") {
    data.bpca <- pcaMethods::pca(t(data),
                     method="bpca",
                     nPcs = nPcs,
                     maxSteps = maxSteps,
                     threshold = threshold)
    data.bpca <- t(pcaMethods::completeObs(data.bpca))
    return(data.bpca)
  }

##SVD imputation
  if (method == "svd") {
    data.svd <- pcaMethods::pca(t(data),
                    method="svdImpute",
                    nPcs=nPcs)
    data.svd <- t(pcaMethods::completeObs(data.svd))
    return(data.svd)
  }

  ##PPCA imputation
  if (method == "ppca") {
    data.ppca <- pcaMethods::pca(t(data),
                    method = "ppca",
                    nPcs = nPcs)
    data.ppca <- t(pcaMethods::completeObs(data.ppca))
    return(data.ppca)
  }

}