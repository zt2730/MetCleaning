% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PrintMethodsForMyClass.R
\docType{class}
\name{MetFlowData-class}
\alias{MetFlowData-class}
\title{MetFlowData}
\value{
MetFlowData
}
\description{
S4 class for data in MetCleaning.
}
\section{Slots}{

\describe{
\item{\code{subject}}{Subject data.}

\item{\code{qc}}{QC data.}

\item{\code{tags}}{Peak information.}

\item{\code{tags.old}}{Old peak information.}

\item{\code{subject.info}}{Subject data information.}

\item{\code{qc.info}}{QC data information.}

\item{\code{subject.order}}{Subject data injection order.}

\item{\code{qc.order}}{QC injection order.}

\item{\code{mv.imputation}}{MV imputation or not.}

\item{\code{imputation.method}}{MV imputation method.}

\item{\code{zero.filter}}{Zero filtering or not.}

\item{\code{zero.filter.criteria}}{Zero filtering criteria.}

\item{\code{normalization}}{Normalization or not.}

\item{\code{normalization.method}}{Normalization method.}

\item{\code{data.integration}}{Data integration or not.}

\item{\code{data.integration.method}}{Data integration method.}

\item{\code{hasIS}}{Data has internal standard or not.}

\item{\code{hasQC}}{QC or not.}

\item{\code{peak.identification}}{Peak identification or not.}

\item{\code{foldchange}}{How to calculate fold change.}

\item{\code{marker.selection.condition}}{Marker selection condition.}

\item{\code{mv.filter}}{MV filtering or not.}

\item{\code{mv.filter.criteria}}{MV filtering condition.}

\item{\code{univariate.test}}{univariate test method.}

\item{\code{qc.outlier.filter}}{QC outlier filtering or not.}

\item{\code{subject.outlier.filter}}{Subject outlier filtering or not.}
}}

\author{
Xiaotao Shen
\email{shenxt@sioc.ac.cn}
}
