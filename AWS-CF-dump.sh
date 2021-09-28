#!/bin/bash
# AWS List of CF stacks in a given REGION for complete DDI

echo "Enter DDI:" 
read DDI 
echo "Ënter Region:"
read REGION

faws account  --rackspace-account $DDI list-accounts -j | tr ' ' '_' | sed -E -e 's/^[^\{]+//g' > account-list-$DDI.json
for ACCOUNT in `jq '.awsAccounts[] | "\(.awsAccountNumber)"' account-list-$DDI.json | tr -d '"'` ; do
	echo "$ACCOUNT"
	eval "$(faws -r $DDI env -a $ACCOUNT)"
	aws cloudformation list-stacks --region $REGION
done
