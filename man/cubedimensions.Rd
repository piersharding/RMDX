\name{cubedimensions}
\alias{cubedimensions}
\title{cubedimensions - Explore available dimensions in an OLAP catalog}
\usage{
cubedimensions(conn, datasource, catalog, cube = NULL)
}
\arguments{
\item{conn}{An object of class \code{RMDXConnector} created with \code{RMDX(...)}.  print() or str() conn to inspect connection details}
\item{datasource}{A string that indicates the name of the Data source}
\item{catalog}{A string that indicates the name of the Catalog}
\item{cube}{An optional string that indicates the name of a specific Cube to be interrogated}
}
\description{
List the available dimensions in an OLAP catalog.
}
\examples{
\donttest{
cubedimensions(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
}
}