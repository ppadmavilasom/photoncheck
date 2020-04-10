#!/bin/bash
echo $RELEASEVER

if [ ! -f '/usr/bin/sed' ]
then
  tdnf install sed -y
fi

pushd /etc/yum.repos.d
for repo in $(ls *.repo)
do
sed -i 's|dl.bintray.com/vmware|packages.vmware.com/photon/$releasever|' $repo
done
popd

cat /etc/yum.repos.d/*.repo | grep baseurl

enabled_repos=`cat /etc/yum.repos.d/*.repo | grep enabled=1 | wc -l`
tdnf repolist
repolist_result_enabled=`tdnf repolist | grep enabled | wc -l`

if [ $repolist_result_enabled -ne $enabled_repos ]
  then
    echo "Expected $enabled_repos enabled repos in repolist. Found $repolist_result_enabled"
    exit 1
fi

for f in $(cat updates/$RELEASEVER)
do
  tdnf list $f
  if [ $? -ne 0 ]
    then exit 1
  fi
done

for f in $(cat updates/$RELEASEVER.debuginfo)
do
  tdnf --enablerepo=photon-debuginfo list $f
  if [ $? -ne 0 ]
    then exit 1
  fi
done
