

#' XML/A OLAP interface, specifically Mondrian, but should support others eg:
#' SAP HANA
#' 
#' XML/A OLAP interface, specifically Mondrian, but should support others eg:
#' SAP HANA
#' 
#' \tabular{ll}{ Package: \tab RMDX\cr Type: \tab Package\cr Version: \tab
#' 1.0\cr Date: \tab 2015-01-29\cr License: \tab GPLv3\cr } ~~ An overview of
#' how to use the package, including the most important functions ~~
#' 
#' @name RMDX-package
#' @aliases RMDX-package RMDX
#' @docType package
#' @author Piers Harding <piers@@ompka.net>
#' 
#' Maintainer: Piers Harding <piers@@ompka.net>
#' @seealso \code{\link[yaml:yaml.load]{yaml}}
#' 
#' \code{\link[RMDX:RMDX]{RMDX manpage}}
#' @references Nada
#' @keywords package
#' @examples
#' 
#' 
#' # connect using a YAML file
#' conn <- RMDX('conn.yml')
#' 
#' # connect using parameters
#' conn <- RMDX('http://localhost:8080/pentaho/Xmla', 'Admin', 'password')
#' 
#' # list the data sources for a server
#' olapsources(conn)
#' 
#' # list the catalogs for a data source
#' olapcatalogs(conn, 'Pentaho')
#' 
#' # list the cubes for a catalog within a data souce
#' olapcubes(conn, 'Pentaho', 'SampleData')
#' 
#' # list the dimensions and measures for a cube
#' cubedimensions(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
#' cubemeasures(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
#' 
#' # execute an MDX query and get a data.frame back
#' r <- mdxquery(conn, 'Pentaho', 'SampleData', 'SELECT
#'     NON EMPTY {Hierarchize({{[Measures].[Actual], [Measures].[Budget], [Measures].[Variance]}})} ON COLUMNS,
#'     NON EMPTY CrossJoin([Department].[Department].Members, [Positions].[Positions].Members) ON ROWS
#'     FROM [Quadrant Analysis]')
#' 
#' 
NULL



