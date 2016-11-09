#!/bin/bash

PLUGIN_NAME=voice_protection

echo "-- Creating directories"
mkdir -p build/amxmodx/data/lang build/amxmodx/scripting build/amxmodx/plugins
echo "-- Copying files"
cp voice_protection.sma build/amxmodx/scripting
cp voice_protection.txt build/amxmodx/data/lang

echo "-- Compiling"
SOURCE_FILE=$PWD/build/amxmodx/scripting/$PLUGIN_NAME.sma
OUTPUT_FILE=$PWD/build/amxmodx/plugins/$PLUGIN_NAME.amxx

cp $SOURCE_FILE $AMXX_COMPILER_PATH
(cd $AMXX_COMPILER_PATH && ./amxxpc $PLUGIN_NAME.sma && rm $PLUGIN_NAME.sma && mv $PLUGIN_NAME.amxx $OUTPUT_FILE)

echo "-- Create zip file"
rm $PLUGIN_NAME.zip
(cd build && zip -r ../$PLUGIN_NAME.zip amxmodx)
echo "-- Done!"
