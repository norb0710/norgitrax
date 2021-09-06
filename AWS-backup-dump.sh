#!/bin/bash
# AWS Back dump for complete DDI
# v1 - 06-09-21 by Norbi @Rackspace
echo "Enter DDI:" 
read DDI 


faws account  --rackspace-account $DDI list-accounts -j | tr ' ' '_' | sed -E -e 's/^[^\{]+//g' > account-list-$DDI-`date +%d-%m-%y`.json
for ACCOUNT in `jq '.awsAccounts[] | "\(.awsAccountNumber)"' account-list-$DDI.json | tr -d '"'` ; do
	echo "$ACCOUNT" >> ~/dumps/backupdump-$DDI-`date +%d-%m-%y`.txt
	eval "$(faws -r $DDI env -a $ACCOUNT)"
	aws backup list-backup-vaults |grep 'BackupVaultName\|NumberOfRecoveryPoints' >> ~/dumps/backupdump-$DDI-`date +%d-%m-%y`.txt
	aws backup list-backup-plans |grep 'BackupPlanName\|LastExecutionDate' >> ~/dumps/backupdump-$DDI-`date +%d-%m-%y`.txt
	echo "Number of Protected Resources:`aws backup list-protected-resources |grep -c ResourceArn`" >> ~/dumps/backupdump-$DDI-`date +%d-%m-%y`.txt
	echo "Number of EC2's Backed up:`aws backup list-protected-resources |grep -c "ResourceType: EC2"`" >> ~/dumps/backupdump-$DDI-`date +%d-%m-%y`.txt
done
