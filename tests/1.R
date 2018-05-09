test.connecting <- function()
{
    conn <- RMDX(url='http://localhost:8080/pentaho/Xmla', userid='Admin', password='password', curlopts=list(a=1,b=2,c='A_B'))
    print(conn)
    i <- info(conn)
    checkEquals(i$url, "http://localhost:8080/pentaho/Xmla")
    checkEquals(i$userid, "Admin")
    checkEquals(i$password, "*****")
    checkTrue(class(conn) == 'RMDXConnector')

    conn <- RMDX("conn.yml")
    i <- info(conn)
    checkEquals(i$url, "http://localhost:8080/pentaho/Xmla")
    checkEquals(i$userid, "Admin")
    checkEquals(i$password, "*****")
    checkTrue(class(conn) == 'RMDXConnector')
}

#test.deactivation <- function()
#{
# DEACTIVATED('Deactivating this test function')
#}
