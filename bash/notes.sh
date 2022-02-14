#!/usr/bin/bash

###
# Collection of usefull notes gathered while learning bash.
###

# declare STRING variable
#STRING="Hello World"
# print variable on a screen
#echo $STRING

# Date:
#date +%Y-%m-%d
#date +%Y-%m-%d_%H-%M
#touch $(date +%Y-%m-%d_%H-%M).txt

# Input arguments:
# $1 $2 $3
#something=$1
#echo $something

# Iterates over words
# for line in $(sudo sfdisk -d $1)
# do
#     echo $line
# done

# Will break because result of $line is split into multiple words
if [ $line == "" ]; then
    drive_info_reached=1
fi
# fix: (force words into string)
if [ "$line" == "" ]; then
    drive_info_reached=1
fi
