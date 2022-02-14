#!/usr/bin/bash

###
# Script that flips partitions in partition table on a given 
# storage device. Usefull for RPI4 that does not have a bootloader.
#
# Input arguments:
# @<path-to-device> - absolute path to the storage device
#                     e.g. /dev/sdd
###

# Global variables
declare SHOW=true
declare separator="-------------------"

# Numerical variables
declare -i drive_info_reached=0
declare -i num_drive_lines=0

# Array
declare rest=()
declare drive_lines=()

# Iterate over lines
while read -r line; do
    # Count drive lines and save drive lines
    if [ $drive_info_reached == 1 ]; then
        num_drive_lines+=1
        drive_lines+=("$line")
    else
        rest+=("$line")
    fi
    # Flip flag when drive info reached
    if [ "$line" == "" ]; then
        drive_info_reached=1
    fi
done < <(sudo sfdisk -d $1)

# Next to last line as first line
let "tmp=num_drive_lines-1"  # simple arithmetical expressions
pattern="$1$tmp"
replacement="$11"
new_first_line=${drive_lines[$num_drive_lines-2]/$pattern/$replacement}

# Last line to second line
pattern="$1$num_drive_lines"
replacement="$12"
new_second_line=${drive_lines[$num_drive_lines-1]/$pattern/$replacement}

# New drive lines
declare -a new_drive_lines=()
new_drive_lines+=("$new_first_line")
new_drive_lines+=("$new_second_line")

# Move all other drive letters two lines lower and adjust drive numbers
for (( i=3; i<=$num_drive_lines; i++ )); do
    let "tmp=i-2"
    pattern="$1$tmp"
    replacement="$1$i"
    new_line=${drive_lines[$i-3]/$pattern/$replacement}
    new_drive_lines+=("$new_line")
done

# Create new partition table
declare -a new_lines=()
new_lines+=("${rest[@]}")
new_lines+=("${new_drive_lines[@]}")

print_pt () {
    echo $separator
    echo "Current partition table."
    echo $separator
    while read -r line; do
        echo "$line"
    done < <(sudo sfdisk -d $1)
}

print_new_pt () {
    echo ""
    echo $separator
    echo "New partition table."
    echo $separator
    for (( i=0; i<${#new_lines[@]}; i++ )); do
        echo "${new_lines[$i]}"
    done
}

write_to_file () {
    file_name=/tmp/$(date +%Y-%m-%d_%H-%M).txt
    touch $file_name # empty file
    for (( i=0; i<${#new_lines[@]}; i++ )); do
        echo "${new_lines[$i]}" >> $file_name
    done
}

apply_new_pt () {
    # Alters partition table
    echo ""
    sudo sfdisk --no-reread /dev/sdd < $1
}

remove_file () {
    rm $1
}

# End commands
print_pt $1
print_new_pt

echo $separator
echo "Apply new partition table? [y/n]:"
while : ; do
    read -n 1 var <&1
    if [ "$var" == "y" ] || [ "$var" == "Y" ]; then
        write_to_file
        apply_new_pt $file_name
        remove_file $file_name
        echo ""
        echo "Applied new partition table"
        break
    else
        echo ""
        echo "Aborting."
        break
    fi
done
