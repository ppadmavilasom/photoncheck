#!/bin/bash
echo $RELEASEVER

pushd /etc/yum.repos.d
for repo in $(ls *.repo)
do
sed -i 's|dl.bintray.com/vmware|packages.vmware.com/photon/$releasever|' $repo
done
popd

cat /etc/yum.repos.d/*.repo | grep baseurl

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
