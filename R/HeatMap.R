#' @title HeatMap
#' @description Heat map
#' @author Xiaotao Shen
#' \email{shenxt@@sioc.ac.cn}
#' @param MetFlowData MetFlowData.
#' @param log.scale log transformation or not.
#' @param color Color list for sample group.
#' @param variable "all" or "marker" for heatmap.
#' @param Group group for heatmap.
#' @param scale.method scale method.
#' @param show_rownames Default is FALSE.
#' @param show_colnames Default is FALSE.
#' @param path Work directory.
#' @param width Plot width
#' @param height Plot height.
#' @param border_color Default is NA.
#' @param fontsize_row Default is 10.
#' @param cluster_rows Default is TRUE.
#' @param cluster_cols Default is TURE.
#' @param clustering_method Default is"ward.D",
#' @param ... other parameters for pheatmap.
#' @return A heatmap plot.
#' @seealso \code{\link[pheatmap]{pheatmap}}
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
#'HeatMap(MetFlowData = met.data.after.pre,
#'        path = "Demo for HeatMap",
#'        Group = c("0", "1"),
#'        path = "Demo for HeatMap")
#'        }

HeatMap <- function(MetFlowData,
                    log.scale = FALSE,
                    color = c("palegreen",
                              "firebrick1",
                              "royalblue",
                              "yellow",
                              "black",
                              "cyan",
                              "gray48"),
                    variable = "all",
                    Group = c("control", "case"),
                    scale.method = "auto",
                    show_rownames = FALSE,
                    show_colnames = FALSE,
                    path = ".",
                    width = 7,
                    height = 7,
                    border_color = NA,
                    fontsize_row = 10,
                    cluster_rows = TRUE,
                    cluster_cols = TRUE,
                    clustering_method = "ward.D",
                    ...) {
  if (path != ".") {
    dir.create(path)
  }

  subject <- MetFlowData@subject
  tags <- MetFlowData@tags
  subject.info <- MetFlowData@subject.info
  group <- subject.info[, "group"]

  idx <- which(group %in% Group)
  subject.info <- subject.info[idx, ]
  subject <- subject[, idx]
  group <- subject.info[, "group"]
  ## data organization
  if (variable == "all") {
    data <- t(subject)
  } else{
    if (all(colnames(tags) != "is.marker")) {
      stop("Please select marker first.")
    }
    is.marker <- tags[, "is.marker"]
    var.index <- which(is.marker == "yes")
    data <- t(subject[var.index, ])
  }

  ##log transformation
  if (log.scale == FALSE) {
    data <- data
  }

  if (log.scale == "e") {
    data <- log(data + 1)
  }

  if (log.scale != FALSE & log.scale != "e") {
    data <- log(data + 1, as.numeric(log.scale))
  }

  data1 <- SXTscale(data, method = scale.method)
  data1.range <- abs(range(data1))
  dif <- data1.range[1] - data1.range[2]
  if (dif < 0) {
    data1[data1 > data1.range[1]] <- data1.range[1]
  }
  if (dif > 0) {
    data1[data1 < -1 * data1.range[2]] <- -1 * data1.range[2]
  }


  annotation_col <- data.frame(Group = factor(c(group)))


  rownames(annotation_col) <- rownames(data)


  # Specify colors
  ann_col <- NULL
  for (i in seq_along(Group)) {
    ann_col[i] <- color[i]
  }

  ann_colors = list(Group = ann_col)
  names(ann_colors[[1]]) <- Group

  pdf(file.path(path, "heatmap.pdf"),
      width = width,
      height = height)
  par(mar = c(5,5,4,2))
  pheatmap::pheatmap(
    t(data1),
    color = colorRampPalette(c("green", "black", "red"))(1000),
    scale = "none",
    show_rownames = show_rownames,
    show_colnames = show_colnames,
    border_color = border_color,
    annotation_col = annotation_col,
    annotation_colors = ann_colors,
    fontsize_row = fontsize_row,
    cluster_rows = cluster_rows,
    cluster_cols = cluster_cols,
    clustering_method = clustering_method,
    ...
  )
  dev.off()
}
