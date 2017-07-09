#!/bin/bash

# Backup Configuration
BACKUP_FOLDER=/backups

# ISPConfig Configuration
WEB_FOLDER=/var/www/clients
MYSQL_FOLDER=/var/lib/mysql
MAIL_FOLDER=/var/vmail
OTHER_FOLDERS=/etc

# Delete all current backups (temporal)
rm -rf $BACKUP_FOLDER/*

if [ ! -d ${BACKUP_FOLDER} ]; then
	echo BACKUP DIRECTORY NOT EXIST
	echo PLEASE, CREATE MANUALLY OR MOUNT A PARTITION IN IT
	echo 
	echo mkdir $BACKUP_FOLDER
	echo mount /dev/sdxx $BACKUP_FOLDER
	echo 
	exit 1;
fi


# Functions

# Make a backup of a folder content (/var/www, /var/vmail...)
# PARAM 1: Full path to SOURCE folder
# PARAM 2: Full path to DESTINATION folder
# PARAM 3: Backup type (mysql, www...)
# PARAM 4: Incremental backup? True/False
function backupFolder () {
	echo Doing backup of $1 to $2

	mkdir -p ${2}	
	tar -pczf ${2}/${3}.tar.gz "${1}" > /dev/null
	#for i in `ls -a $1`; do
	#	if [[ "$i" != "." && "$i" != ".." ]]; then
	#		DIRECTORIES=$DIRECTORIES" "$VARDIR"/"$i
	#		echo $i
	#	fi
	#done

	echo -e "\n"
}

DO_INCREMENTAL=false
CUR_DATE=$(date +%Y_%m_%d)

backupFolder $WEB_FOLDER $BACKUP_FOLDER/$CUR_DATE www $DO_INCREMENTAL
backupFolder $MYSQL_FOLDER $BACKUP_FOLDER/$CUR_DATE mysql $DO_INCREMENTAL
backupFolder $MAIL_FOLDER $BACKUP_FOLDER/$CUR_DATE vmail $DO_INCREMENTAL
backupFolder $OTHER_FOLDERS $BACKUP_FOLDER/$CUR_DATE others


