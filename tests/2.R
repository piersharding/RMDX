test.introspection <- function()
{

    conn <- RMDX("conn.yml")
    i <- info(conn)
    checkEquals(i$url, "http://localhost:8080/pentaho/Xmla")
    checkEquals(i$userid, "Admin")
    checkEquals(i$password, "*****")
    checkTrue(class(conn) == 'RMDXConnector')

    # list the data sources for a server
    print(olapsources(conn))

    # list the catalogs for a data source
    print(olapcatalogs(conn, 'Pentaho Mondrian'))

    # list the cubes for a catalog within a data source
    # NOTE!!! Make sure Xmla is enabled for SampleData in the data source manager
    print(olapcubes(conn, 'Pentaho Mondrian', 'SampleData'))

    # list the dimensions and measures for a cube
    print(cubedimensions(conn, 'Pentaho Mondrian', 'SampleData', 'Quadrant Analysis'))
    print(cubemeasures(conn, 'Pentaho Mondrian', 'SampleData', 'Quadrant Analysis'))

}

