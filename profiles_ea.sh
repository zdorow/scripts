echo "<result>`sudo profiles -P | grep profileIdentifier | sed 's/.*profileIdentifier: //' | sort -k 2 | tr '\n' ' '`</result>" | sed 's/ </</'
