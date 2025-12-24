#!/bin/bash
# Description: Collect host data for diagnostical purposes
# Author: Ripley L

sudo apt-get update


# Check if smartctl is installed
if smartctl -V &> /dev/null; then
    echo "
    ##############################################
    ############smartctl is installed#############
    ##############################################
"
else
    echo "
    ##############################################
    ##smartctl is not installed. Installing...####
    ##############################################
"
    sudo apt-get install smartmontools -y
fi

# Check if dmidecode is installed
if dmidecode -V dmidecode &> /dev/null; then
    echo "
    ##############################################
    ##########dmidecode is installed##############
    ##############################################
"
else
    echo "
    ##############################################
    ########dmidecode is not installed############
    ##############################################
"
    sudo apt-get install dmidecode -y
fi

# Check if lm-sensors is installed
if sensors -v &> /dev/null; then
    echo "
    ##############################################
    ##########lm-sensors is installed#############
    ##############################################
"
else
    echo "
    ##############################################
    ########lm-sensors is not installed###########
    ##############################################
"
sudo apt install lm-sensors -y
fi


echo "
    ##############################################
    #############SYSTEM INFORMATION###############
    ##############################################
"
hostname
echo ""
dmidecode -t system
echo ""
lscpu | head -n 11
echo ""
sudo dmidecode -t memory | grep -i -E "Memory Device|Set|Locator|Serial Number|Size|Bank Locator|Asset Tag|Manufacturer|Part Number"
echo ""

# Iterate through all disks and run smartctl
echo "
    ##############################################
    ###############Checking Disks#################
    ##############################################
"

for disk in $(ls /dev/sd*); do
	errors=""

	#fetch smartctl output
	smartctl_output=$(smartctl -a $disk 2>&1)

	# Function to extract drive name and errors
	errors=$(echo "$smartctl_output" | grep "Model Family" -A 16)$'\n\n'
	errors+=$(echo "$smartctl_output" | grep "Error Log" -A 2)


	# Function to display the formatted table
	    echo "==============================="
	    echo "####SUMMARY TABLE: "$disk" ###"
	    echo "==============================="
	    echo -e "$errors"
	    echo "==============================="
	    echo ""
done

echo "
    ##############################################
    ##################Sensors#####################
    ##############################################
"
echo ""
sensors
echo ""


echo "
    ##############################################
    ################Check Logs####################
    ##############################################
"
error_keywords=("Hardware Error" "DIMM" "critical temperature" "Out of memory" "I/O error" "Bus Error" "GPU" "reset error" "Link is Down" "Kernel panic")

# Define the log files to search in
dmesg > /var/log/dmesg
log_files=("/var/log/dmesg" "/var/log/messages" "/var/log/kern.log" "/var/log/user.log" "/var/log/syslog")

# Loop through each log file and search for error keywords
for log_file in "${log_files[@]}"; do
    if [ -e "$log_file" ]; then
        echo "Searching for errors in $log_file:"
        for keyword in "${error_keywords[@]}"; do
            grep -i "$keyword" "$log_file"
        done
        echo "--------------------------"
    else
        echo "Log file $log_file not found."
    fi
done
