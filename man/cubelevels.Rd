\name{cubelevels}
\alias{cubelevels}
\title{cubelevels - Explore available levels in an OLAP catalog}
\usage{
cubelevels(conn, datasource, catalog, cube = NULL)
}
\arguments{
\item{conn}{An object of class \code{RMDXConnector} created with \code{RMDX(...)}.  print() or str() conn to inspect connection details}
\item{datasource}{A string that indicates the name of the Catalog}
\item{catalog}{A string that indicates the name of the Catalog}
\item{cube}{An optional string that indicates the name of a specific Cube to be interrogated}
}
\description{
List the available levels in an OLAP catalog.
}
\examples{
\donttest{
cubelevels(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
}
}