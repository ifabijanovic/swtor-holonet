#!/bin/sh

carthage version
carthage bootstrap --platform ios
cp Cartfile.resolved Carthage

