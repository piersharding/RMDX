test.mdxquery <- function()
{

    conn <- RMDX("conn.yml")
    i <- info(conn)
    checkEquals(i$url, "http://localhost:8080/pentaho/Xmla")
    checkEquals(i$userid, "Admin")
    checkEquals(i$password, "*****")
    checkTrue(class(conn) == 'RMDXConnector')

    # execute an MDX query and get a data.frame back
    r <- mdxquery(conn, 'Pentaho', 'SampleData', 'SELECT
        NON EMPTY {Hierarchize({{[Measures].[Actual], [Measures].[Budget], [Measures].[Variance]}})} ON COLUMNS,
        NON EMPTY CrossJoin([Department].[Department].Members, [Positions].[Positions].Members) ON ROWS
        FROM [Quadrant Analysis]')
    print(r)
}

