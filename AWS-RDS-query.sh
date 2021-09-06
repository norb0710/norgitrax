#!/bin/bash
# AWS query details of all RDS instances for a selected DDI
# v1 - 06-09-21 by Norbi @Rackspace

echo "Enter DDI:" 
read DDI 


faws account  --rackspace-account $DDI list-accounts -j | tr ' ' '_' | sed -E -e 's/^[^\{]+//g' > account-list-$DDI-`date +%d-%m-%y`.json
for ACCOUNT in `jq '.awsAccounts[] | "\(.awsAccountNumber)"' account-list-$DDI.json | tr -d '"'` ; do
	echo "$ACCOUNT" >> ~/dumps/RDSdump-$DDI-`date +%d-%m-%y`.txt
	eval "$(faws -r $DDI env -a $ACCOUNT)"
	aws rds describe-db-instances --query 'DBInstances[*].{Type:Engine,Id:DBInstanceIdentifier,DeletionProtection:DeletionProtection,BackupRetentionPeriod:BackupRetentionPeriod}' >> ~/dumps/RDSdump-$DDI-`date +%d-%m-%y`.txt
done
