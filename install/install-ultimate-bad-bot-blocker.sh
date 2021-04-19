#!/bin/sh

# Install ultimate bad bot blocker
echo "**** Installing ultimate bad bot blocker ****"

# Create needed folders
mkdir -p /default/nginx/bots.d
mkdir -p /default/nginx/conf.d
mkdir -p /default/nginx/sites-conf.d
mkdir -p /etc/scripts.d

# Download installer
curl -sL https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker \
    -o /etc/scripts.d/install-ngxblocker


# Run ultimate-bad-bot-blocker installer
chmod +x /etc/scripts.d/install-ngxblocker
./etc/scripts.d/install-ngxblocker -x \
    -b /default/nginx/bots.d \
    -c /default/nginx/conf.d \
    -s /etc/scripts.d


# Manual setup as the setup-ngxblocker will not work with seperated conf.d file for includes
# download include_filelist
curl -sL https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/include_filelist.txt \
    -o /tmp/include_filelist.txt


# Extract includes for vhost from this file and place in custom conf file
mv /tmp/default/nginx/sites-conf.d/ultimate-bad-bot-blocker.conf /default/nginx/sites-conf.d/ultimate-bad-bot-blocker.conf
VHOST_INCLUDES=$(sed -n '/^VHOST_INCLUDES=\"$/,/^$/{ /^VHOST_INCLUDES=\"$/d; /^$/d; p;}' /tmp/include_filelist.txt | head -n -1 | sed -e 's/^[[:space:]]*//')
for include in $VHOST_INCLUDES
do
    if ! grep -q "include /default/nginx/bots.d/${include};" /default/nginx/sites-conf.d/ultimate-bad-bot-blocker.conf; then
        echo "include /default/nginx/bots.d/${include};" >> /default/nginx/sites-conf.d/ultimate-bad-bot-blocker.conf;
    fi
done

# Update conf.d and bots.d paths inside downloaded files
for file in $(find /default/nginx/ -type f -print)
do
    sed -i 's/\/etc\/nginx\/conf.d/\/config\/nginx\/conf.d/' $file
    sed -i 's/\/etc\/nginx\/bots.d/\/config\/nginx\/bots.d/' $file
done
