\name{RMDX}
\alias{RMDX}
\title{RMDX - XML/A OLAP interface, specifically Mondrian, but should support others eg: SAP HANA}
\description{
  create a connection object for accessing an XML/A OLAP service.  This could be Mondrian, SAP Hana, or MS-SQL Server.

  \code{RMDX} establishes an XML/A connection object to a specific MDX compliant XML/A server instance.
  There are two styles of passing the connection parameters:

  - \code{RMDX('conn.yml')} where the name of A YAML encoded file containing
    RMDX connection parameters is passed in

  - \code{RMDX(url='http://localhost:8080/pentaho/Xmla', userid='joe', password='password')}

    The individual connection parameters are:
  \itemize{
     \item{url} - the base URL for the XML/A service
     \item{userid} - XML/A service user name
     \item{password} - user password
  }
  
  There maybe some problems with SSL negotiation - especially if you are using
  self-signed certs.  The following Curl options may help - especially
  downgrading SSL to v3 (this must also be made available on the server):
  
  options(RCurlOptions = list(ssl.verifypeer = FALSE,
                            sslversion=3,
                            verbose = TRUE,
                            cainfo = "/etc/ssl/certs/some-certificate.pem",
                            followlocation = TRUE,
                            timeout = 100,
                            useragent = "myApp in R"))

}
\usage{
RMDX(...)

}%"

\arguments{
  \item{url}{the base URL for the XML/A service eg: \code{http://localhost:8080/pentaho/Xmla}}
  \item{userid}{XML/A service user name}
  \item{password}{user password}
}

\value{
  Returns an RMDXConnector object that you can  then use to pass to olapsources, olapcatalogs, olapcubes, cubedimensions, cubemeasures and mdxquery.
}

\details{
  Once a connection object has been obtained, then the follwoing functions can be applied to interrogate the server:

  \code{olapsources} enables the lookup of datasource names required as input to all other functions eg: \code{olapsources(conn)}.  A data.frame is returned with the data source details of the connected server.

  \code{olapcatalogs(conn, datasource)} - list the catalogs for a data source

  \code{olapcubes(conn, datasource, catalog)} - list the cubes for a catalog within a data source

  \code{cubedimensions(conn, datasource, catalog, cube)} - list the dimensions for a cube
  \code{cubemeasures(conn, datasource, catalog, cube)} - list the measures for a cube

  \code{mdxquery(conn, datasource, catalog, query)} - execute an MDX query and get a data.frame back

  \bold{Function arguments:}
  \itemize{
    \item{conn} - an object of class \code{RMDXConnector} created with \code{RMDX(...)}.  print() or str() conn to inspect connection details
    \item{datasource} - a string that indicates the name of the DataSourceInfo of the required call context
    \item{catalog} - a string that indicates the name of the Catalog
    \item{cube} - a string that indicates the name of the Cube interrogated
    \item{query} - a string that representing the MDX query to execute within the datasource/catalog context
  }
}


\note{
  Rd is a pain so for future reference - http://cran.r-project.org/doc/manuals/r-release/R-exts.html#Rd-format .
}

\references{\href{http://mondrian.pentaho.com/documentation/mdx.php}{MDX Reference}

  \href{http://en.wikipedia.org/wiki/XML_for_Analysis}{XML/A References}
}

\examples{\dontrun{
# Connecting to Pentaho BI Server 5.x

# full named parameter specification
conn <- RMDX(url='http://localhost:8080/pentaho/Xmla', userid='piers', password='password')

or

# connect using parameters
conn <- RMDX('http://localhost:8080/pentaho/Xmla', 'Admin', 'password')

or

# Use a YAML encoded parameter file
conn <- RMDX("conn.yml")
# conn.yml looks like:
# url: http://localhost:8080/pentaho/Xmla
# userid: Admin
# password: password

# list the data sources for a server
olapsources(conn)

# list the catalogs for a data source
olapcatalogs(conn, 'Pentaho')

# list the cubes for a catalog within a data source
olapcubes(conn, 'Pentaho', 'SampleData')

# list the dimensions and measures for a cube
cubedimensions(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
cubemeasures(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')

# execute an MDX query and get a data.frame back
r <- mdxquery(conn, 'Pentaho', 'SampleData', 'SELECT
    NON EMPTY {Hierarchize({{[Measures].[Actual], [Measures].[Budget], [Measures].[Variance]}})} ON COLUMNS,
    NON EMPTY CrossJoin([Department].[Department].Members, [Positions].[Positions].Members) ON ROWS
    FROM [Quadrant Analysis]')
}}

\author{
  Piers Harding
}
\seealso{
  \code{\link{RMDX-package}}, \code{\link{yaml.load}}
}
\keyword{IO}
\keyword{MDX}
\keyword{XMLA}
\keyword{Mondrian}
\keyword{Pentaho}
\keyword{SAPHana}
