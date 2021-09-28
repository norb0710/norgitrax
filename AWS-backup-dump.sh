#!/bin/bash
# AWS Back dump for complete DDI
# v2 - 28-09-21 by Norbi @Rackspace
echo "Enter DDI:" 
read DDI 


faws account  --rackspace-account $DDI list-accounts -j | tr ' ' '_' | sed -E -e 's/^[^\{]+//g' > account-list-$DDI-`date +%d-%m-%y`.json
for ACCOUNT in `jq '.awsAccounts[] | "\(.awsAccountNumber)"' account-list-$DDI.json | tr -d '"'` ; do
	echo "$ACCOUNT"
	eval "$(faws -r $DDI env -a $ACCOUNT)"
	aws backup list-backup-vaults |grep 'BackupVaultName\|NumberOfRecoveryPoints'
	aws backup list-backup-plans |grep 'BackupPlanName\|LastExecutionDate'
	aws backup list-backup-plans \
	        --query 'BackupPlansList[*].BackupPlanId' | \
	        cut -c 3-41 | \
	while read BackupPlanId ; do
	        lifecycle=$( aws backup get-backup-plan \
	        --backup-plan-id $BackupPlanId \
	        --query 'BackupPlan.Rules[*].{DeleteAfterDays:Lifecycle.DeleteAfterDays}')
	        echo -e "\t$BackupPlanId\t$lifecycle"
	done	
	echo "Number of Protected Resources:`aws backup list-protected-resources |grep -c ResourceArn`"
	echo "Number of EC2's Backed up:`aws backup list-protected-resources |grep -c "ResourceType: EC2"`"
	echo "Number of EFS Backed up:`aws backup list-protected-resources |grep -c "ResourceType: EFS"`"
done
