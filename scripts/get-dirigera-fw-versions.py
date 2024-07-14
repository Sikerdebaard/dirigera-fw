import argparse
import requests
import ssl
import os
import json
from hashlib import sha3_256 as hashfunc

def fetch_firmware_list(verify):
    req = requests.get('https://fw.ota.homesmart.ikea.com/check/update/prod', verify=verify)
    req.raise_for_status()
    return req.json()

def download_firmware(fw_url, output_dir, expected_hash, verify):
    # Extract the filename from the URL
    filename = os.path.basename(fw_url)
    filepath = os.path.join(output_dir, filename)
    
    # Check if file exists and verify the hash
    if os.path.exists(filepath):
        with open(filepath, 'rb') as f:
            filedata = f.read()
            current_hash = hashfunc(filedata).hexdigest()
            if current_hash == expected_hash:
                print(f"No download needed for {filename}, hash matches.")
                return

    # Proceed with download
    response = requests.get(fw_url, verify=verify)
    response.raise_for_status()
    with open(filepath, 'wb') as f:
        f.write(response.content)
    print(f"Downloaded {filename} to {output_dir}")

def main(output_dir, cert_path):
    # ikea self-signed cert is currently broken due to a missing SAN
    # so we must disable verification for the script to work :(
    if not os.path.exists(cert_path):
        verify = False
    else:
        # enable this code once the IKEA cert is fixed
        # verify = cert_path
        # remove the verify=False when the above is enabled
        verify = False
    
    firmwares = fetch_firmware_list(verify)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for fw in firmwares:
        if 'dirigera' in fw['fw_binary_url'].lower():
            download_firmware(fw['fw_binary_url'], output_dir, fw['fw_sha3_256'], verify)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Download firmware binaries to a specified directory if hashes have changed.')
    parser.add_argument('--output-dir', type=str, required=True, help='The directory where firmware binaries will be saved.')
    parser.add_argument('--cert-path', type=str, default='data/trustChain.pem', help='Path to the SSL certificate for verifying the server.')
    args = parser.parse_args()

    main(args.output_dir, args.cert_path)
