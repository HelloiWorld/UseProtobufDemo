#!/bin/bash
BASEDIR=$(dirname "$0")
cd "$BASEDIR"

# relative url
rm -rf ./Module\&Src/*.pbobjc.*

protoc -I=./Module\&Src --objc_out=./Module\&Src ./Module\&Src/*.proto
