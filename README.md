RMDX
====

RMDX - is an XML/A OLAP MDX interface

Copyright (C) Piers Harding 2015 - and beyond, All rights reserved

## Summary

Welcome to the RMDX R module.  This module is an XML/A OLAP interface for MDX, specifically Mondrian, but should support others eg: SAP HANA.

This has been specifically tested with Pentaho BiServer 5.x


### Prerequisites:
Please insure that YAML, RCurl, and XML are installed:
install.packages('yaml', 'XML', 'RCurl')


### Installation:

    install.packages('RMDX', repos=c('http://piersharding.com/R'))

OR:

    require(devtools)
    install_github('RMDX', 'piersharding')

### Examples:

 See the files in the tests/ directory.
 NOTE!!! Make sure Xmla is enabled for SampleData in the data source manager in the Pentaho BiServer

### Documentation:
 help(RMDX)

To run the tests:

    rm run_tests.Rout; R CMD BATCH run_tests.R; more run_tests.Rout

### Bugs:
I appreciate bug reports and patches, just mail me! piers@ompka.net

RMDX is Copyright (c) 2015 - and beyond Piers Harding.
It is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

A copy of the GNU Lesser General Public License (version 3) is included in
the file LICENSE.

