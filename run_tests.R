
library(RUnit)
library(RMDX)

test.suite <- defineTestSuite("RMDX",
                              dirs = file.path("tests"),
                              testFileRegexp = '^\\d+\\.R')

test.result <- runTestSuite(test.suite)

printTextProtocol(test.result)

