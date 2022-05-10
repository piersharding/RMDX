\name{cubeexplore}
\alias{cubeexplore}
\title{cubeexplore - Explore schema information in OLAP catalog}
\usage{
cubeexplore(conn, datasource, catalog, schema, cube = NULL)
}
\arguments{
\item{conn}{An object of class \code{RMDXConnector} created with \code{RMDX(...)}.  print() or str() conn to inspect connection details}
\item{datasource}{A string that indicates the name of the Data source}
\item{catalog}{A string that indicates the name of the Catalog}
\item{schema}{A string that indicates the name of the Schema to explore}
\item{cube}{An optional string that indicates the name of a specific Cube to be interrogated. You should get most of the useful information from the following filelds: 'Cubes', 'Hierarchies', 'Levels' and 'Measures'. All available fields to explore can be found \href{https://docs.microsoft.com/en-us/dotnet/api/microsoft.analysisservices.adomdclient.adomdschemaguid?view=analysisservices-dotnet#fields}{here}.}
}
\description{
Explore schema information in OLAP catalog.
}
\examples{
\donttest{
cubelexplore(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
}
}