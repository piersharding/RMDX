# file RMDX/R/RMDX.R
# copyright (C) 2015 and onwards, Piers Harding
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 or 3 of the License
#  (at your option).
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/
#
#  Function library of R integration with MDX OLAP service
#
#

# load dependent libraries for HTTP via Curl and XML parsing
.onLoad <- function(libname, pkgname)
{
    if(is.null(getOption("dec")))
        options(dec = Sys.localeconv()["decimal_point"])
    library("XML")
    library("RCurl")
    library(yaml)
}

# Constructor
RMDX <- function (...)
{
    args <- list(...)
    if (length(args) == 0) {
        stop("No arguments supplied")
    }
    if (typeof(args[[1]]) == "list") {
        args = args[[1]]
    }

    # did we get passed a config file?
    if (typeof(args[[1]]) == "character" && file.exists(args[[1]])) {
        # parse config file and go around again with parameters
        config <- yaml.load_file(args[[1]])
        newargs <- list()
        for (x in names(config)) { newargs[[x]] <- as.character(config[[x]]); }
        return(RMDX(newargs))
    }

    # if unamed parameters are passed
    if (!is.element("url", names(args))) {
        if (length(args) >= 3) {
            names(args) <- c('url', 'userid', 'password')
        }
        else {
            stop("must call with 'url', 'userid', and 'password'")
        }
    }

    # ensure we have the parameters we need
    if (!exists("url", where=args) || !exists("userid", where=args) || !exists("password", where=args)) {
        stop("must call with 'url', 'userid', and 'password'")
    }
    curlopts <- list()
    # pass curlopts if supplied
    if (exists("curlopts", where=args)) {
      curlopts <- args$curlopts
    }

    # Create connector object and hand back
    res <- RMDXConnector(url=args$url, userid=args$userid, password=args$password, curlopts=curlopts)
    if (exists("debug", where=args)) {
        res@debug = args$debug
    }
    return(res)
}

# when connector is printed give back connection info
str.RMDXConnector <- function(x, ...) {
    print(x)
}

# when connector is printed give back connection info
print.RMDXConnector <- function(x, ...) {
    cat("\n")
    print(as.data.frame(info(x)))
    cat("\n")
}

info.RMDXConnector <- function(x, ...) {
    curlopts <- paste(mapply(function(key,value) { paste(key, value, sep="=") }, key=names(x@curlopts), value=x@curlopts), collapse=", ")
    return(list(url=x@url, userid=x@userid, password='*****', curlopts=curlopts))
}

# define connector class
setClass("RMDXConnector",
    representation=representation(
        url="character",
        userid="character",
        password="character",
        debug="logical",
        curlopts="list"),
    validity=function(object) {
        if (length(object@url) == 0)
            "'url', 'userid' and 'password' must be supplied"
        else TRUE
    })

# connector object constructor function
RMDXConnector <- function(url=character(), userid=character(), password=character(), curlopts=list(), ...) {
    return(new("RMDXConnector", url=url, userid=userid, password=password, curlopts=curlopts, ...))
}


# utility for HTTP and XML handling
# curl -v --insecure --user 'Admin:password' -H "Content-Type: text/xml" -d '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Header /><SOAP-ENV:Body><Discover xmlns="urn:schemas-microsoft-com:xml-analysis"><RequestType>DISCOVER_DATASOURCES</RequestType><Restrictions><RestrictionList/></Restrictions><Properties><PropertyList><Format>Tabular</Format></PropertyList></Properties></Discover></SOAP-ENV:Body></SOAP-ENV:Envelope>' "http://localhost:8080/pentaho/Xmla"
call_olap <- function(conn, request, withFactors=FALSE,toNumeric=TRUE, toDate=TRUE, ...){

            extra <- list(...)
            extra <- mapply(function(key,value) { paste(paste('param', key, sep=""), value, sep="=") }, key=names(extra), value=extra)

            url <-conn@url
            if (length(extra) > 0) {
                url <- paste(conn@url, '?', paste(extra, collapse="&"), sep="")
            }
            soapheader <-
'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<SOAP-ENV:Header />
<SOAP-ENV:Body>';
            soaptail <- '</SOAP-ENV:Body>
</SOAP-ENV:Envelope>';
            request <- paste0(soapheader, request, soaptail);
            httpauth <- 1L
            if (is.element("httpauth", names(conn@curlopts))) {
                httpauth <- conn@curlopts$httpauth
            }
            myheader=c(Connection = "close",
                       'Content-Type' = "text/xml",
                       'Content-length' =  nchar(request, type = "bytes"));
            xml <- paste(RCurl::getURL(url=URLencode(url),
                                       postfields=request,
                                       httpheader=myheader,
                                       verbose=conn@debug,
                                       ssl.verifypeer = FALSE,
                                       userpwd=paste0(conn@userid, ':', conn@password),
                                       httpauth=httpauth,
                                       .encoding = 'UTF-8'), collapse="");
            if (nchar(xml, type = "bytes") == 0) {
                return(data.frame())
            }
            
            # Check for error messages in the response and stop if present
            if(grepl("<faultcode>", xml)) {
              xml <- xmlToList(xml)
              fault <- xml$Body$Fault
              stop(paste0(fault$faultcode, ': ', fault$faultstring))
            }

            # xml <- xmlParseString(xml);
            xml  <- xmlTreeParse(xml, asText = TRUE, useInternalNodes=TRUE, encoding = 'UTF-8')
            return(xml);
}

# Utility functions
toNumericFunc <- function(ds){
    if (withFactors == TRUE) {
        return(as.numeric(levels(ds)[ds]));
    }
    else {
        return(as.numeric(ds));
    }
}

setGeneric("mdxquery", function(conn, datasource, catalog, query, withFactors=FALSE,toNumeric=TRUE, toDate=TRUE, ...) standardGeneric("mdxquery"));

setMethod("mdxquery", "RMDXConnector",
        def = function(conn, datasource, catalog, query, withFactors=FALSE,toNumeric=TRUE, toDate=TRUE, ...){
# SELECT
# NON EMPTY {Hierarchize({[Measures].[No. People]})} ON COLUMNS,
# NON EMPTY {Hierarchize({[AccessToInternet].[AccessToInternet].Members})} ON ROWS
# FROM [Census2006]
#
# r <- mdxquery(conn, 'OTI', 'OTI Financial Reporting', 'SELECT
# NON EMPTY Hierarchize(Union(CrossJoin({[Measures].[Amount]}, [Effective Date].[EffectiveYear].Members), Union(CrossJoin({[Measures].[Amount]}, [Effective Date].[EffectiveMonth].Members), Union(CrossJoin({[Measures].[Amount]}, [Effective Date].[EffectiveDay].Members), Union(CrossJoin({[Measures].[No. Installments]}, [Effective Date].[EffectiveYear].Members), Union(CrossJoin({[Measures].[No. Installments]}, [Effective Date].[EffectiveMonth].Members), CrossJoin({[Measures].[No. Installments]}, [Effective Date].[EffectiveDay].Members))))))) ON COLUMNS,
# NON EMPTY {Hierarchize({[Module].[Module].Members})} ON ROWS
# FROM [Transactions]')
#
# r <- mdxquery(conn, 'Pentaho', 'SampleData', 'SELECT
# NON EMPTY {Hierarchize({{[Measures].[Actual], [Measures].[Budget], [Measures].[Variance]}})} ON COLUMNS,
# NON EMPTY CrossJoin([Department].[Department].Members, [Positions].[Positions].Members) ON ROWS
# FROM [Quadrant Analysis]')

            request <- paste0('<Execute xmlns="urn:schemas-microsoft-com:xml-analysis">
<Command>
<Statement><![CDATA[', query, '
]]></Statement>
</Command>
<Properties>
<PropertyList>
<DataSourceInfo>', datasource, '</DataSourceInfo>
<Catalog>', catalog, '</Catalog>
<Format>Tabular</Format>
<AxisFormat>TupleFormat</AxisFormat>
</PropertyList>
</Properties>
</Execute>');
            xml <- call_olap(conn, request);
            
            # convert the query results to a data.frame
            results <- xmlToDataFrame(getNodeSet(xml,
                      "//SOAP-ENV:Envelope/SOAP-ENV:Body/cxmla:ExecuteResponse/cxmla:return/x:root/x:row",
                      c(cxmla = 'urn:schemas-microsoft-com:xml-analysis',
                        'SOAP-ENV' = 'http://schemas.xmlsoap.org/soap/envelope/',
                        xsi="http://www.w3.org/2001/XMLSchema-instance",
                        xsd="http://www.w3.org/2001/XMLSchema", x='urn:schemas-microsoft-com:xml-analysis:rowset')),
                        stringsAsFactors = withFactors);
            
            # If results are empty, return empty frame
            if(length(results) == 0) {
              return(data.frame())
            }
              
            # set the column names
            nodes <- getNodeSet(xml,
                      "//SOAP-ENV:Envelope/SOAP-ENV:Body/cxmla:ExecuteResponse/cxmla:return/x:root/xsd:schema/xsd:complexType/xsd:sequence/xsd:element",
                      c(cxmla = 'urn:schemas-microsoft-com:xml-analysis',
                        'SOAP-ENV' = 'http://schemas.xmlsoap.org/soap/envelope/',
                        xsi="http://www.w3.org/2001/XMLSchema-instance",
                        xsd="http://www.w3.org/2001/XMLSchema", x='urn:schemas-microsoft-com:xml-analysis:rowset'));
            labels <- sapply(nodes, xmlGetAttr, name = "field");
            names(results) <- labels;

            # set measures to numeric - type attribute missing on measures
            measures <- getNodeSet(xml,
                      "//SOAP-ENV:Envelope/SOAP-ENV:Body/cxmla:ExecuteResponse/cxmla:return/x:root/xsd:schema/xsd:complexType/xsd:sequence/xsd:element[not(@type)]",
                      c(cxmla = 'urn:schemas-microsoft-com:xml-analysis',
                        'SOAP-ENV' = 'http://schemas.xmlsoap.org/soap/envelope/',
                        xsi="http://www.w3.org/2001/XMLSchema-instance",
                        xsd="http://www.w3.org/2001/XMLSchema", x='urn:schemas-microsoft-com:xml-analysis:rowset'));
            for (i in sapply(measures, xmlGetAttr, name = "field")) {
                results[[i]][is.na(results[[i]])] <- '0';
                results[[i]] <- as.numeric(results[[i]]);
            }

            # adjust names
            names(results) <- sub("\\.\\[MEMBER_CAPTION\\]", '', names(results));
            return(results)
         },
         valueClass = "data.frame"
       )

getResults <- function(xml) {
    xmlToDataFrame(getNodeSet(xml,
          "//SOAP-ENV:Envelope/SOAP-ENV:Body/cxmla:DiscoverResponse/cxmla:return/x:root/x:row",
          c(cxmla = 'urn:schemas-microsoft-com:xml-analysis',
            'SOAP-ENV' = 'http://schemas.xmlsoap.org/soap/envelope/',
            xsi="http://www.w3.org/2001/XMLSchema-instance",
            xsd="http://www.w3.org/2001/XMLSchema", x='urn:schemas-microsoft-com:xml-analysis:rowset')));
}

setGeneric("olapsources", function(conn) standardGeneric("olapsources"));

setMethod("olapsources", "RMDXConnector",
        def = function(conn){

            request <- paste0('<Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
<RequestType>DISCOVER_DATASOURCES</RequestType>
<Restrictions>
<RestrictionList/>
</Restrictions>
<Properties>
<PropertyList>
<Format>Tabular</Format>
</PropertyList>
</Properties>
</Discover>');
            xml <- call_olap(conn, request);
            results <- getResults(xml);
            return(results)
         },
         valueClass = "data.frame"
       )


setGeneric("olapcatalogs", function(conn, datasource) standardGeneric("olapcatalogs"));

setMethod("olapcatalogs", "RMDXConnector",
          def = function(conn, datasource){
            
            request <- paste0('<Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
<RequestType>DBSCHEMA_CATALOGS</RequestType>
<Restrictions>
<RestrictionList/>
</Restrictions>
<Properties>
<PropertyList>
<DataSourceInfo>', datasource, '</DataSourceInfo>
<Format>Tabular</Format>
</PropertyList>
</Properties>
</Discover>');
            xml <- call_olap(conn, request);
            catalogs <- getResults(xml);
            return(catalogs)
          },
          valueClass = "data.frame"
)



setGeneric("olapcubes", function(conn, datasource, catalog) standardGeneric("olapcubes"));

setMethod("olapcubes", "RMDXConnector",
          def = function(conn, datasource, catalog){
            
            request <- paste0('<Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
<RequestType>MDSCHEMA_CUBES</RequestType>
<Restrictions>
<RestrictionList/>
</Restrictions>
<Properties>
<PropertyList>
<DataSourceInfo>', datasource, '</DataSourceInfo>
<Catalog>', catalog, '</Catalog>
<Format>Tabular</Format>
</PropertyList>
</Properties>
</Discover>');
            xml <- call_olap(conn, request);
            cubes <- getResults(xml);
            return(cubes)
          },
          valueClass = "data.frame"
)


setGeneric("cubeexplore", function(conn, datasource, catalog, schema, cube = NULL) standardGeneric("cubeexplore"));

setMethod("cubeexplore", "RMDXConnector",
          def = function(conn, datasource, catalog, schema, cube = NULL){
            
            request <- paste0('<Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
<RequestType>MDSCHEMA_', toupper(schema), '</RequestType>
<Restrictions>
<RestrictionList>',
                              ifelse(is.null(cube), '', paste0('<CUBE_NAME>', cube, '</CUBE_NAME>')),
                              '</RestrictionList>
</Restrictions>
<Properties>
<PropertyList>
<DataSourceInfo>', datasource, '</DataSourceInfo>
<Catalog>', catalog, '</Catalog>
<Format>Tabular</Format>
</PropertyList>
</Properties>
</Discover>
');
            xml <- call_olap(conn, request);
            result <- getResults(xml);
            return(result)
          },
          valueClass = "data.frame"
)

setGeneric("cubedimensions", function(conn, datasource, catalog, cube = NULL) standardGeneric("cubedimensions"));

setMethod("cubedimensions", "RMDXConnector",
          def = function(conn, datasource, catalog, cube = NULL){
            cubeexplore(conn = conn, datasource = datasource, catalog = catalog, schema = "DIMENSIONS", cube = cube)
          },
          valueClass = "data.frame"
)

setGeneric("cubemeasures", function(conn, datasource, catalog, cube = NULL) standardGeneric("cubemeasures"));

setMethod("cubemeasures", "RMDXConnector",
          def = function(conn, datasource, catalog, cube = NULL){
            cubeexplore(conn = conn, datasource = datasource, catalog = catalog, schema = "MEASURES", cube = cube)
          },
          valueClass = "data.frame"
)

setGeneric("cubelevels", function(conn, datasource, catalog, cube = NULL) standardGeneric("cubelevels"));

setMethod("cubelevels", "RMDXConnector",
          def = function(conn, datasource, catalog, cube = NULL){
            cubeexplore(conn = conn, datasource = datasource, catalog = catalog, schema = "LEVELS", cube = cube)
          },
          valueClass = "data.frame"
)

setGeneric("info", function(x, ...) standardGeneric("info"));
setMethod("info", "RMDXConnector",
          def = function(x, ...){
            return(info.RMDXConnector(x))
          },
          valueClass = "data.frame"
)