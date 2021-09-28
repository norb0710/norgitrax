#!/bin/bash
# AWS List of ELB in for complete DDI

echo "Enter DDI:" 
read DDI 
echo "Enter Region:"
read REGION

faws account  --rackspace-account $DDI list-accounts -j | tr ' ' '_' | sed -E -e 's/^[^\{]+//g' > account-list-$DDI-`date +%d-%m-%y`.json
for ACCOUNT in `jq '.awsAccounts[] | "\(.awsAccountNumber)"' account-list-$DDI.json | tr -d '"'` ; do
	echo "$ACCOUNT"
	eval "$(faws -r $DDI env -a $ACCOUNT)"
	aws elb describe-load-balancers --region $REGION
done
