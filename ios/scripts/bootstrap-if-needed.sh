#!/bin/sh

cd ios

if ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  echo "Dependencies out of date, bootstrapping..."
  scripts/bootstrap.sh
else
  echo "Dependencies up to date"
fi

