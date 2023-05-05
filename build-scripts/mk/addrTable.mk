#################################################################################
# Clean
#################################################################################
clean_address_tables:
	@rm -rf ${ADDRESS_TABLE_CREATION_PATH}address_tables
	@rm -rf ${ADDRESS_TABLE_CREATION_PATH}config*.yaml
#################################################################################
# address tables
#################################################################################

${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_%/ :
	mkdir -p ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_$*/

${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_%/address_apollo.xml: ${ADDRESS_TABLE_CREATION_PATH}config_%.yaml ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_%/
	./build-scripts/BuildAddressTable.py -l $< -t address_apollo.xml -o ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_$*/modules_$*/ -m modules_$*
	@rm -rf ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table
	@ln -s address_table_$* ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table

${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_%/address_%.xml: ${ADDRESS_TABLE_CREATION_PATH}config_%.yaml ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_%/
	./build-scripts/BuildAddressTable.py -l $< -t address_$*.xml -o ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table_$*/modules_$*/ -m modules_$*
	@rm -rf ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table
	@ln -s address_tables/address_table_$* ${ADDRESS_TABLE_CREATION_PATH}address_tables/address_table


