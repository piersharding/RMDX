test.introspection <- function()
{

    conn <- RMDX("conn.yml")
    i <- info(conn)
    checkEquals(i$url, "http://localhost:8080/pentaho/Xmla")
    checkEquals(i$userid, "Admin")
    checkEquals(i$password, "*****")
    checkTrue(class(conn) == 'RMDXConnector')

    # list the data sources for a server
    olapsources(conn)

    # list the catalogs for a data source
    olapcatalogs(conn, 'Pentaho')

    # list the cubes for a catalog within a data source
    olapcubes(conn, 'Pentaho', 'SampleData')

    # list the dimensions and measures for a cube
    cubedimensions(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')
    cubemeasures(conn, 'Pentaho', 'SampleData', 'Quadrant Analysis')

}

