#!/bin/bash

# Backup Configuration
BACKUP_FOLDER=/backups

# ISPConfig Configuration
WEB_FOLDER=/var/www/clients
MYSQL_FOLDER=/var/lib/mysql
MAIL_FOLDER=/var/vmail
OTHER_FOLDERS=/etc

# Postgres folder (comment if you not have installed postgres)
PSQL_FOLDER=$(psql -U postgres -c "show data_directory;" | grep -- /)


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

# Make a backup of a folder content (/var/www, /var/vmail...) but putting subfolders in separated files
# PARAM 1: Full path to SOURCE folder
# PARAM 2: Full path to DESTINATION folder
# PARAM 3: Backup type (mysql, www...)
# PARAM 4: Incremental backup? True/False
function backupFolderIndependent () {
	echo Doing backup independent of $1 to $2

	destFolder=${2}
	mkdir -p ${destFolder}	

	FILES=""
	for i in `ls -a $1`; do
		if [[ "$i" != "." && "$i" != ".." && "$i" != "pg_xlog" ]]; then
			echo -e Comenzando backup de ${3} del directorio ${i}
			
			CURRENT_PATH="${1}/${i}"
			
			if [ -d "${CURRENT_PATH}" ]; then
				# Folder (independent tar file)
				file_name=${3}_$(basename "${i}").tar.gz
				tar Ppzcf $destFolder/$file_name --exclude-backups  --exclude=*backup* "${CURRENT_PATH}"
			else
				# File (grouped in the main tar)
				FILES="${FILES} ${CURRENT_PATH}"
			fi
			#DIRECTORIES=$DIRECTORIES" "$VARDIR"/"$i
			#echo $i
		fi
	done
	
	# TAR with files
	if [ -n "${FILES}" ]; then
		$(tar Pczf ${destFolder}/${3}.tar ${FILES})
	fi
	echo -e "\n"
}

# Make a backup of a folder content (/var/www, /var/vmail...)
# PARAM 1: Full path to SOURCE folder
# PARAM 2: Full path to DESTINATION folder
# PARAM 3: Backup type (mysql, www...)
# PARAM 4: Incremental backup? True/False
function backupFolder () {
	echo Doing backup of $1 to $2

	destFolder=${2}
	mkdir -p ${destFolder}	
	tar -pczf ${2}/${3}.tar.gz "${1}" > /dev/null
	
	echo -e "\n"
}


# START BACKUP PROCESS

DO_INCREMENTAL=false
CUR_DATE=$(date +%Y_%m_%d)


backupFolderIndependent $WEB_FOLDER $BACKUP_FOLDER/$CUR_DATE www $DO_INCREMENTAL
backupFolderIndependent $MYSQL_FOLDER $BACKUP_FOLDER/$CUR_DATE mysql $DO_INCREMENTAL
backupFolderIndependent $MAIL_FOLDER $BACKUP_FOLDER/$CUR_DATE vmail $DO_INCREMENTAL
backupFolder $OTHER_FOLDERS $BACKUP_FOLDER/$CUR_DATE others

# If PSQL_FOLDER defined and folder exist
if [ -n "$PSQL_FOLDER" ]; then

	# Trim text
	PSQL_FOLDER="$(echo -e "${PSQL_FOLDER}" | tr -d '[:space:]')"
	if [[ -d "$PSQL_FOLDER" ]]; then
		echo ${PSQL_FOLDER} backuping;
		backupFolderIndependent $PSQL_FOLDER $BACKUP_FOLDER/$CUR_DATE/PSQL postgresql $DO_INCREMENTAL

	fi
fi
