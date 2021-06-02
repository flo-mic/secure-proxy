#!/bin/sh

# Enable early exit in case of errors
set -e
set -o pipefail

# Move to work dir
cd /tmp

# Clone and install ssdeep package
echo "Install ssdeep package"
SSDEEP_VERSION=$(curl https://api.github.com/repos/ssdeep-project/ssdeep/releases/latest -s | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/release-//')
wget --quiet https://github.com/ssdeep-project/ssdeep/releases/download/release-${SSDEEP_VERSION}/ssdeep-${SSDEEP_VERSION}.tar.gz
tar -xzf ssdeep-${SSDEEP_VERSION}.tar.gz
cd ssdeep-${SSDEEP_VERSION}
./configure 
make -j${CPU_CORES}
make install
cd /tmp


# Clone ModSecurity
echo "Install ModSecurity libraries"
git clone -b "v${MODSECURITY_VERSION}" --depth 1 --quiet https://github.com/SpiderLabs/ModSecurity
git -C /tmp/ModSecurity submodule update --init --recursive --quiet


# Install Modsecurity
cd "/tmp/ModSecurity"
./build.sh
./configure --with-lmdb --disable-doxygen-doc
make -j${CPU_CORES}
make install
cd /tmp


# Get OWASP Core rule set
echo "Get OWASP core rule set"
git clone -b "v${OWASP_VERSION}/master" --depth 1 --quiet https://github.com/coreruleset/coreruleset.git /tmp/owasp-modsecurity-crs
mkdir -p /default/nginx/owasp-crs.d
mkdir -p /tmp/owasp-modsecurity-crs/plugins # Create missing plugin folder on OWASP 3.3 and prepare already for 3.4
cp /tmp/owasp-modsecurity-crs/crs-setup.conf.example /default/nginx/owasp-crs.d/crs-setup.conf
cp /tmp/owasp-modsecurity-crs/LICENSE /default/nginx/owasp-crs.d/LICENSE
cp -r /tmp/owasp-modsecurity-crs/rules /default/nginx/owasp-crs.d/rules/
cp -r /tmp/owasp-modsecurity-crs/util /default/nginx/owasp-crs.d/util/
cp -r /tmp/owasp-modsecurity-crs/plugins /default/nginx/owasp-crs.d/plugins/


# Get OWASP Core rule set decode plugin with single decode configuration
git clone https://github.com/coreruleset/auto-decoding-plugin /tmp/crs_decoding_plugin
cp /tmp/crs_decoding_plugin/plugins/* /default/nginx/owasp-crs.d/plugins/

# Get OWASP Core rule set antivirus plugin
git clone https://github.com/coreruleset/antivirus-plugin /tmp/crs_antivirus_plugin
cp /tmp/crs_antivirus_plugin/plugins/* /default/nginx/owasp-crs.d/plugins/
sed -i "s/setvar:'tx.antivirus-plugin_clamav_socket_file=.*$/setvar:'tx.antivirus-plugin_clamav_socket_file=\/run\/clamav\/clamd.sock',\\\\/" /default/nginx/owasp-crs.d/plugins/antivirus-config-before.conf
