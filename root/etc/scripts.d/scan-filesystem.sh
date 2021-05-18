#!/usr/bin/with-contenv bash

# Required files and folders
LOG_FILE=/config/logs/clamav/clamscan.log
QUARANTINE_DIRECTORY=/var/clamav/quarantine

# Make required folders if not already exist
mkdir -p /config/logs/clamav
mkdir -p $QUARANTINE_DIRECTORY

echo "**** ClamAV scanning system for malicious files.... ****" | tee -a $LOG_FILE

# make sure action variable is lower case
CLAMAV_SYSTEM_SCAN=$(echo "${CLAMAV_SYSTEM_SCAN,,}")
CLAMAV_ACTION=$(echo "${CLAMAV_ACTION,,}")

# Exist script if file system scan was disabled
if [[ "$CLAMAV_SYSTEM_SCAN" == "disabled" ]]; then
  exit 0
fi

# Get folders to scan
if [ -n "$CLAMAV_SCAN_DIR" ]; then
  SCAN_FOLDERS=""
  for i in $(echo $CLAMAV_SCAN_DIR | sed "s/ / /g")
  do
    # Test if directory exists
    if [ -d "$i" ]; then
      # Add directory to scan list
      SCAN_FOLDERS="${SCAN_FOLDERS} ${i}"
    fi
  done
else
  SCAN_FOLDERS="/"
fi

# Get folders to ignore
IGNORE_FOLDERS="\/config\/clamav\/definitions\/*|\/sys\/kernel\/*|\/sys\/devices\/*|\/sys\/module\/*|\/sys\/bus\/*|\/sys\/fs\/*|\/sys\/class\/*|\/sys\/power\/*"
if [ -n "$CLAMAV_IGNORE_DIR" ]; then
  for i in $(echo $CLAMAV_IGNORE_DIR | sed "s/ / /g")
  do
    # Test if directory exists
    if [ -d "$i" ]; then
      # Remove last character '/' if exists
      if [[ "$i" == */ ]]; then
        i=${i%?}
      fi
      # Add expression for all files and subfolders
      i="${i}/*"
      # Make regex from directory path
      i=$(echo $i | sed -r 's/\//\\\//g')
      # Append regex to ignore list
      IGNORE_FOLDERS="${IGNORE_FOLDERS}|${i}"
      # Control will enter here if $DIRECTORY exists.
    fi
  done
fi

# Check which scan action should be used
SCAN_ACTION="-r -i"
if [[ "$CLAMAV_ACTION" == "delete" ]]; then
  SCAN_ACTION=" --remove"
elif [[ "$CLAMAV_ACTION" == "move" ]]; then
  SCAN_ACTION=" --move=${$QUARANTINE_DIRECTORY}"
  MOVE_MAIL_MESSAGE="Moved files are located in the directory \"${QUARANTINE_DIRECTORY}\" for quarantine reasons. Please check and remove/restore the files as needed."
fi

# Scan file system for any malicious files
SCAN_RESULT=$(clamscan $SCAN_ACTION --log=$LOG_FILE --exclude-dir="${IGNORE_FOLDERS}" $SCAN_FOLDERS)

# Check if infections found
INFECTED_FILES=$(echo $SCAN_RESULT | sed -e "s/.*Infected.files: //" | sed "s/\s.*$//")
if [[ $INFECTED_FILES > 0 ]]; then
  RESULT_SUBJECT="Infected files found during file system scan!"
else
  RESULT_SUBJECT="File system scan performed without any abnormalities."
fi

#Check if mail schould be send
if [[ $CLAMAV_MAIL_REPORT == 2 ]] || [[ $CLAMAV_MAIL_REPORT == 1 && $INFECTED_FILES > 0 ]] || [[ -z "$CLAMAV_MAIL_REPORT" && $INFECTED_FILES > 0 ]]; then

  # Check if smtp was configured with password file
  if [[ -n $SMTP_PASSWORD_FILE ]]; then
    if [ -s "$SMTP_PASSWORD_FILE" ]; then
      $SMTP_PASSWORD="$(head -n 1 $SMTP_PASSWORD_FILE)"		
    else
      echo "ERROR: SMTP password file does not exist or is empty. Can not enable fail2ban mail notifications. Please check your smtp server variables"
    fi;
  fi
  # Check if smtp password is available	
  if [[ -n $SMTP_PASSWORD ]]; then
    
    # Send mail
    echo "Subject: [ClamAV]: ${RESULT_SUBJECT}
Date: `LC_ALL=C date +"%a, %d %h %Y %T %z"`
From: ${SMTP_SENDER_NAME} <${SMTP_SENDER_MAIL}>
To: ${SMTP_RECEIVER}

Hello,

the automatic ClamAV file system scan found \"${INFECTED_FILES}\" infected files. For any infected file the action \"${CLAMAV_ACTION}\" was performed automatically as configured for this container. ${MOVE_MAIL_MESSAGE}

${SCAN_RESULT}

Regards,
Secure-Proxy" | /usr/sbin/sendmail -t -v -H 'exec openssl s_client -quiet -connect ${SMTP_SERVER} -starttls smtp' -au${SMTP_SENDER_MAIL} -ap${SMTP_PASSWORD} -f ${SMTP_SENDER_MAIL} ${SMTP_RECEIVER}
  
  fi
fi
