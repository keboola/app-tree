#!/bin/bash
set -e

R CMD build 
R CMD check keboola.r.custom.application.tree_1.0.tar.gz --as-cran --no-manual
