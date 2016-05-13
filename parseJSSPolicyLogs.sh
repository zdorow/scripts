#!/bin/bash

##########################################################################################
#
# Author: Sean Burke
# Date: 5-27-2015
# Purpose:  Script to parse Policy Logs to create a CSV Summary
#
##########################################################################################


##################
##  VARIABLES  ### 
##################

# Take in Parameter 1 as the HTML file to parse
inputHTML=$1

newEntry=""

successful=0
pending=0
failed=0

machineName=""
userName=""
policyTime=""
policyStatus=""

# Output File Information
currentDate=`date +"%m_%d_%y"`
reportOutput="/Users/Shared/policy_report-$currentDate.csv"

# Process the HTML file and parse for the section that contains all the computer and status info
htmlResult=`cat "$inputHTML" | sed -n "/<tbody/,/<\/tbody>/p"`

######################
##  END VARIABLES  ### 
######################


# Read in HTML format
read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}


# Write headers to the CSV File
echo "Machine Name, User, Policy Status, Policy Time" >> "$reportOutput"

# Write to CSV File with contents
write_line()
{
    echo "$1, $2, $3, $4" >> "$reportOutput"
}

numProcessed=0
while read_dom; do

    CONTENT=`echo $CONTENT | sed 's/^ *//'`

    # TBODY contains all the computer info we need
    if [[ "$ENTITY" == *"tbody"* ]]
    then
        newEntry="properSection"
    fi

    # Looks for the specific TBODY section which contains 
    if [ "$newEntry" ]
    then
        # a href is the link to the computer object, which marks a new entry to process     
        if [[ "$ENTITY" == *"a href"* ]]
        then
            ((numProcessed++))
            echo "---- START COMPUTER ----\n"
            # Remove any commas or quotes which may throw off the CSV writing
            machineName=`echo "$CONTENT" | sed 's/,/''/g' | sed 's/\"//g'`
            # Re-Set the other variables to blank, in case they are actually blank for the new record
            userName=""
            policyTime=""
            policyStatus=""
            echo "Content: $CONTENT"
        fi

        if [[ "$ENTITY" == *"td"* ]]
        then
            if [ "$CONTENT" ]
            then
                # Process the Status of the Machine
                if [[ "$CONTENT" == *"Pending" ]] || [[ "$CONTENT" == *"Completed" ]] || [[ "$CONTENT" == *"Failed"* ]]
                then 
                    if [[ "$CONTENT" == *"Pending"* ]]
                    then
                        ((pending++))
                    elif [[ "$CONTENT" == *"Completed"* ]]
                    then
                        ((successful++))
                    else
                        ((failed++))
                    fi              
                    policyStatus="$CONTENT"
                    echo "Content: $CONTENT"
                    echo "---- END COMPUTER ----\n"
                    write_line "$machineName" "$userName" "$policyStatus" "$policyTime"
                    echo "Num Processed: $numProcessed"
                else
                    # If the entry contains the word at, we know it's talking about a policy time entry
                    if [[ "$CONTENT" == *"at"* ]]
                    then
                        echo "Policy Time: $CONTENT"
                        policyTime="$CONTENT"
                    else
                        userName="$CONTENT"
                    fi
                fi
            fi
        fi
    fi  
done <<< "$htmlResult"

write_line "" "" "" ""
write_line "" "" "" ""

write_line "Num Success: $successful"
write_line "Num Pending: $pending"
write_line "Num Failed: $failed"