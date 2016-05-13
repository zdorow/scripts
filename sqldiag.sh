#!/bin/bash

read -p "MySQL Username [jamfsoftware]: " mysqluser
	mysqluser=${mysqluser:-jamfsoftware}
read -p "MySQL Password [jamfsw03]: " mysqlpassword
	mysqlpassword=${mysqlpassword:-jamfsw03}
read -p "Database Name  [jamfsoftware]: " database
	database=${database:-jamfsoftware}
echo ""
echo "Top 10 tables by size: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "SELECT CONCAT(table_schema, '.', table_name) as table_name, CONCAT(ROUND(table_rows / 1000000, 2), 'M') rows, CONCAT(ROUND(data_length / ( 1024 * 1024 * 1024 ), 2), 'G') DATA, CONCAT(ROUND(index_length / ( 1024 * 1024 * 1024 ), 2), 'G') idx, CONCAT(ROUND(( data_length + index_length ) /( 1024 * 1024 * 1024 ), 2), 'G') total_size, ROUND(index_length / data_length, 2) idxfrac FROM information_schema.TABLES ORDER BY data_length + index_length DESC LIMIT 10;" 2>/dev/null
echo "Computers with duplicate UDIDs: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count, udid, computer_name from computers group by udid having count(*) > 1;" 2>/dev/null
echo "Mobile devices with duplicate UDIDs: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count, udid, display_name from mobile_devices group by udid having count(*) > 1;" 2>/dev/null
echo "Pending mobile device management commands count: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from mobile_device_management_commands where apns_result_status != 'Acknowledged';" 2>/dev/null
echo "Mobile devices without denormalized entries: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from mobile_devices where mobile_device_id not in (select mobile_device_id from mobile_devices_denormalized);" 2>/dev/null
echo "Computers without denormalized entries: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from computers where computer_id not in (select computer_id from computers_denormalized);" 2>/dev/null
echo "Mobile devices with names set to MAC addresses: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from mobile_devices m JOIN mobile_devices_denormalized d ON LOCATE(m.mobile_device_id, d.mobile_device_id) where m.display_name=m.wifi_mac_address;" 2>/dev/null
echo "Mobile device configuration profiles with null identifiers: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from mobile_device_configuration_profiles where payload_identifier is null;" 2>/dev/null
echo "Smart computer groups with blank criteria: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select criteria, computer_group_id from smart_computer_group_criteria where criteria = '';" 2>/dev/null
echo "Duplicate smart computer group criteria: "
mysql -u $mysqluser p-$mysqlpassword --database $database -e "select computer_group_id, count(*) from smart_computer_group_criteria group by computer_group_id, search_field, search_type, criteria having count(*)>1;" 2>/dev/null
echo "Duplicate smart mobile device group criteria: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select mobile_device_group_id, count(*) from smart_mobile_device_group_criteria group by mobile_device_group_id, search_field, search_type, criteria having count(*)>1;" 2>/dev/null
echo "Extension attributes not in reports table: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from extension_attribute_values where report_id not in (select report_id from reports);" 2>/dev/null
echo "Orphan computer records: "
mysql -u $mysqluser -p$mysqlpassword --database $database -e "select count(*) as count from logs where computer_id not in(select computer_id from computers);" 2>/dev/null


#
#mysql -u $mysqluser -p$mysqlpassword --database $database -e "select * from mobile_device_management_commands where profile_id in (select mobile_device_configuration_profile_id from mobile_device_configuration_profiles where deleted=1 and command IN ("InstallProfile", "RemoveProfile"));" 2>/dev/null