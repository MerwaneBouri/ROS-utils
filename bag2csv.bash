#!/bin/bash

# Check if ROS environment is set up
if ! command -v rostopic &> /dev/null
then
    echo "ROS is not sourced properly. Please source ROS."
    exit 1
fi

# Check if a bag file exists in the current directory
file_path="$(find . -maxdepth 1 -name '*.bag' -type f -print -quit)"
if [ -z "$file_path" ]
then
    echo "No bag file found in the current directory."
    exit 1
fi

# Extract topics from the bag file 
echo "Extracting topics from $file_path"
topics=$(rostopic list -b "$file_path")

# Print a numbered list of topics for the user to select from
echo "Select topics to extract (comma-separated), or press enter for all:"
topic_list=($topics)
for i in "${!topic_list[@]}"; do 
    echo "$i. ${topic_list[$i]}"
done

# Read user input and extract selected topics to CSV files
read -r input
if [ -z "$input" ]
then
    selected_topics=$topics
else
    selected_topics=""
    input_list=(${input//,/ })
    for i in "${input_list[@]}"; do 
        if ! [[ "$i" =~ ^[0-9]+$ ]] || [ "$i" -ge "${#topic_list[@]}" ]
        then
            echo "Invalid topic number $i"
            exit 1
        fi
        selected_topics+="${topic_list[$i]} "
    done
fi

for topic in $selected_topics
do
    # Replace any forward slashes in the topic name with underscores
    topic_csv_name="${topic//\//_}.csv"
    echo "Extracting topic $topic to $topic_csv_name"
    rostopic echo -b "$file_path" -p "$topic" > "$topic_csv_name"
done

echo "Extraction completed." 

