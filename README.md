# IKEA Dirigera Hub Firmware Reverse-Engineering 

The IKEA Dirigera Hub Firmware, at the time of writing, is available for download as an unencrypted blob. This project allows you to extract and inspect the firmware files to reverse-engineer the functionality.

## Findings

### httpd
DIRIGERA runs a httpd under nosuid on port 8082. This allows us to read some of the files from the device, e.g.: `http://<dirigera_ip>:8082/usr/lib/node_modules/api-server/src/api/v1/api_specification/openapi.yaml`.

### iptables
The following tables are set on boot:

```bash
# ipv4
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i wpan+ -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -i wpan+ -p udp -m udp --dport 67 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -p udp -m udp --dport 1900 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 5353 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 5540 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 49154 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 61631 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8000 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8081 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8082 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8443 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9000 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
COMMIT

# ipv6
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i wpan+ -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -i wpan+ -p udp -m udp --dport 67 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p icmpv6 -j ACCEPT
-A INPUT -p udp -m udp --dport 1900 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 5353 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 5540 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 49154 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p udp -m udp --dport 61631 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8000 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8081 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8082 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8443 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9000 --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j ACCEPT
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -p udp -m udp --dport 5540 -m conntrack --ctstate NEW -j ACCEPT
COMMIT
```

## Installation

This project requires certain tools and libraries to be installed on your system. Follow the instructions below to set up your environment on Fedora and Ubuntu.

### Dependencies

- **Python 3 and venv**: For creating virtual environments and running Python scripts.
- **pip**: For installing Python packages.
- **squashfs-tools**: For managing `.squashfs` and `.squashfs.verity` files.
- **e2fsprogs**: For handling `.ext4` files using `debugfs`.

### Setup Instructions

#### Fedora

Install the required packages on Fedora with the following command:

```bash
sudo dnf install python3 python3-virtualenv squashfs-tools e2fsprogs
```

#### Ubuntu

On Ubuntu, you can install the dependencies using:

```bash
sudo apt update
sudo apt install python3 python3-venv python3-pip squashfs-tools e2fsprogs
```

## Running the Project

The Makefile included in this project can be used to download and extract the Dirigera Hub Firmware for local inspection. Follow these steps to run the project:

1. **Download and Extract Firmware**:
    Run the following command to set up the environment, download the firmware, and extract its contents:

    ```bash
    make all
    ```

2. **Inspect Extracted Firmware**:
    After running the above command, you can find the extracted firmware files in the following directory:

    ```plaintext
    build/fw-extract/<firmware version>/blocks
    ```

## Cleaning Up

To clean the build directory and remove all artifacts, run:

```bash
make clean
```

## Contributing

Contributions to this project are welcome. Fork the project and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE) file for details.
