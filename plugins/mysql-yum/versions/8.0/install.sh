# -*- coding: utf-8 -*-
#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# https://downloads.mysql.com/archives/community/

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")
sysName=`uname`


install_tmp=${rootPath}/tmp/mw_install.pl
myDir=${serverPath}/source/mysql-yum

ARCH=`uname -m`
ARCH_NAME=''
case $(uname -m) in
    i386)   ARCH_NAME="386" ;;
    i686)   ARCH_NAME="386" ;;
    x86_64) ARCH_NAME="amd64" ;;
    arm)    ARCH_NAME="arm64" ;;
esac

bash ${rootPath}/scripts/getos.sh
OSNAME=`cat ${rootPath}/data/osname.pl`
VERSION_ID=`cat /etc/*-release | grep VERSION_ID | awk -F = '{print $2}' | awk -F "\"" '{print $2}'`
echo "VERSION_ID:${VERSION_ID}"

OS_SIGN=1.el9
if [ "$OSNAME" == "centos" ];then
	OS_SIGN=1.el${VERSION_ID}
elif [ "$OSNAME" == "fedora" ]; then
	OS_SIGN=10.fc${VERSION_ID}
elif [ "$OSNAME" == "suse" ]; then
	OS_SIGN=1.sl${VERSION_ID}
fi

MYSQL_VER=8.0.30
SUFFIX_NAME=${MYSQL_VER}-${OS_SIGN}.${ARCH}

YUM_INSTALL()
{

#######
mkdir -p $myDir

wget -O $myDir/mysql-${SUFFIX_NAME}.rpm-bundle.tar https://cdn.mysql.com/archives/mysql-8.0/mysql-${SUFFIX_NAME}.rpm-bundle.tar
cd ${myDir} && tar vxf mysql-${SUFFIX_NAME}.rpm-bundle.tar

mkdir -p ${serverPath}/mysql-yum/bin && cd ${serverPath}/mysql-yum/bin

rpm2cpio ${myDir}/mysql-community-client-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-client-${SUFFIX_NAME}.x86_64.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-common-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-debuginfo-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-devel-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-embedded-compat-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-icu-data-files-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-libs-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-libs-compat-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-server-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-server-debug-${SUFFIX_NAME}.rpm | cpio -div
rpm2cpio ${myDir}/mysql-community-test-${SUFFIX_NAME}.rpm | cpio -div

#######
}

YUM_UNINSTALL()
{
### YUM卸载 START ########
# yum -y remove mysql-server
rm -rf ${myDir}
### YUM卸载 END   ########
}


Install_mysql()
{

	echo '正在安装脚本文件...' > $install_tmp
	if id mysql &> /dev/null ;then 
	    echo "mysql uid is `id -u mysql`"
	    echo "mysql shell is `grep "^mysql:" /etc/passwd |cut -d':' -f7 `"
	else
	    groupadd mysql
		useradd -g mysql mysql
	fi

	isYum=`which yum`
	if [ "$isYum" != "" ];then
		YUM_INSTALL
	fi


	
	mkdir -p $serverPath/mysql-yum
	echo '8.0' > $serverPath/mysql-yum/version.pl
	echo '安装完成' > $install_tmp
}

Uninstall_mysql()
{
	isYum=`which yum`
	if [ "$isYum" != "" ];then
		YUM_UNINSTALL
	fi
	rm -rf $serverPath/mysql-yum
	echo '卸载完成' > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_mysql
else
	Uninstall_mysql
fi
