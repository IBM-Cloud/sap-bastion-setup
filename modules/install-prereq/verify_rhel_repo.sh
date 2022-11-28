#!/bin/bash
###########

#Check status of RHEL subscritpion, and add 10 seconds delay for RHEL subscritpion registration. 
/usr/bin/sleep 10
output=$(subscription-manager status)

#Check if status is current.
echo -e "Check if RHEL subscription is enabled for bastion VSI ..."
if [[ $output =~ "Status: Current" ]]
then
 echo -e "VSI RHEL subscription status is enabled"
else
 echo -e "ERROR: VSI RHEL subscription is invalid, bastion VSI instantiation failed"
 exit 1
fi

#Check if RHEL repos are enabled for ansible-2-for-rhel-8-x86_64-rpms, rhel-8-for-x86_64-baseos-rpms
#rhel-8-for-x86_64-appstream-eus-rpms, rhel-8-for-x86_64-baseos-eus-rpms
checkSubsStatus () {

#dump subscription-manager repo output to temp file(out)
subscription-manager repos > subs_repo.txt

#get the repo enable status for all the required RHEL repos. 
repo_ansible=$(cat subs_repo.txt | grep -A 3 "ansible-2-for-rhel-8-x86_64-rpms" | egrep "Enabled|1")
repo_baseos=$(cat subs_repo.txt | grep -A 3 "rhel-8-for-x86_64-baseos-rpms" | egrep "Enabled|1")
repo_appstream_eus_rpms=$(cat subs_repo.txt | grep -A 3 "rhel-8-for-x86_64-appstream-eus-rpms" | egrep "Enabled|1")
repo_baseos_eus_rpms=$(cat subs_repo.txt | grep -A 3 "rhel-8-for-x86_64-baseos-eus-rpms" | egrep "Enabled|1")

#echo the status of RHEL repos. 
echo -e "repo_ansible, enabled: $repo_ansible"
echo -e "repo_baseos, enabled: $repo_baseos"
echo -e "repo_appstream-eus_rpms, enabled: $repo_appstream_eus_rpms"
echo -e "repo_baseos_eus_rpms, enabled: $repo_baseos_eus_rpms"

#extract the string "Enabled and active status"
ansible=$(echo $repo_ansible | grep -E "Enabled|1")
baseos=$(echo $repo_baseos | grep -E "Enabled|1")
appstream_eus=$(echo $repo_appstream_eus_rpms | grep -E "Enabled|1")
baseos_eus=$(echo $repo_baseos_eus_rpms | grep -E "Enabled|1")
}

#check if repos are enabled. 
checkSubsStatus
# If the repos are not enabled, retry 5 times with 10 seconds delay, this is a workaround to add some delay to allow the repos gets enabled.
for i in {1..5}
do
 #Check the status of RHEL repos. 
 
 if [[ $ansible =~ "Enabled: 1" && $appstream_eus =~ "Enabled: 1" ]] && [[ $baseos =~ "Enabled: 1" && $baseos_eus =~ "Enabled: 1" ]]
  then
   echo -e "ansible, baseos, appstream_eus, and baseos_eus repositories are enabled"
   break
 else
  # if all required repos not enabled, retry with 10 seconds sleep
  echo -e "sleep for 10 seconds and retry"
  /usr/bin/sleep 10
  checkSubsStatus
  if [[ $i == 5 ]]
   then
    #if RHEL repo's are disabled, display message and exit instalallation.
    echo -e "Error: RHEL repos's are disabled, please check if required RHEL repo's are enabled"
    exit 1
  fi
 fi
done