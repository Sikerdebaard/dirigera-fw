#!/bin/bash

# Define the URL from which to fetch the certificate chain
URL="fw.ota.homesmart.ikea.com"
PORT=443

# Define the output file for the certificate chain
OUTPUT_DIR="./data"
OUTPUT_FILE="$OUTPUT_DIR/trustChain.pem"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Fetch the certificate chain using OpenSSL and save all certificates
echo "Fetching certificate chain from $URL..."
openssl s_client -connect ${URL}:${PORT} -showcerts </dev/null 2>/dev/null | \
awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".pem"; print >out}'

# Concatenate all certificates into one file
cat cert*.pem > "$OUTPUT_FILE"
rm cert*.pem  # Clean up individual files

echo "Certificate chain saved to $OUTPUT_FILE"

# Make sure the certificate chain was actually retrieved and saved
if [ -s "$OUTPUT_FILE" ]; then
    echo "Certificate chain successfully retrieved and saved."
else
    echo "Failed to retrieve certificate chain."
    rm -f "$OUTPUT_FILE"  # Clean up empty file if something went wrong
fi

