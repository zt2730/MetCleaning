#' @title RSDfilter
#' @description Filter features according to RSD in QC samples.
#' @author Xiaotao Shen
#' \email{shenxt@@sioc.ac.cn}
#' @param MetFlowData MetFlowData.
#' @param rsd.cutoff The cutoff value of RSD. Default is 30. It means that for
#' a feature, if its RSD larger than 30\%, it will be removed form the dataset.
#' @return Return a MetFlowData whose features have been removed.
#' @details \href{https://www.readcube.com/library/fe13374b-5bc9-4c61-9b7f-6a354690947e:abe41368-d08d-4806-871f-3aa035d21743}{Dunn}
#' recommen the cutoff value of RSD should be set as 20\% in LC-MS
#' data and 30\% in GC-MS data.
#' @export
#' @examples
#' data(met.data, package = "MetCleaning")
#' new.met.data <- RSDfilter(met.data)

RSDfilter <- function(MetFlowData,
                      rsd.cutoff = 30) {
  ##RSD filtering
  qc <- MetFlowData@qc
  qc.rsd <- apply(qc, 1, function(x) {sd(x)*100/mean(x)})

  var.index <- which(qc.rsd <= rsd.cutoff)
  MetFlowData@qc <- MetFlowData@qc[var.index,]
  MetFlowData@tags <- MetFlowData@tags[var.index,]
  MetFlowData@subject <- MetFlowData@subject[var.index,]
  return(MetFlowData)
}


#S4 class
setClass("MetFlowData",
         representation(
           subject = "matrix",
           qc = "matrix",
           tags = "matrix",
           tags.old = "matrix",
           subject.info = "matrix",
           qc.info = "matrix",
           subject.order = "numeric",
           qc.order = "numeric",
           ## some preprocessing information
           mv.imputation = "character",
           imputation.method = "character",
           zero.filter = "character",
           zero.filter.criteria = "character",
           normalization = "character",
           normalization.method = "character",
           data.integration = "character",
           data.integration.method = "character",
           hasIS = "character",
           hasQC = "character",
           peak.identification = "character",
           foldchange = "character",
           marker.selection.condition = "character",
           mv.filter = "character",
           mv.filter.criteria = "character",
           univariate.test = "character",
           qc.outlier.filter = "character",
           subject.outlier.filter = "character"
         )
)
