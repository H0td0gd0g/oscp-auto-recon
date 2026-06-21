# oscp auto recon script

An automated enumeration script I created to prepare for the OSCP exam

## Usage

```bash
./recon.sh -t <target_ip> [options]
```

### Required

| Option | Description |
|--------|-------------|
| `-t`, `--RHOST <ip>` | Target IP Address |

### Options

| Option | Description |
|--------|-------------|
| `-p`, `--RPORT <port>` | Target Web Port |
| `-n`, `--nmap` | Run nmap tcp & udp |
| `-f`, `--ferox` | Run feroxbuster |
| `-N`, `--nikto` | Run nikto |
| `-h`, `--help` | Help page |

### Examples

```bash
# Run all tools
./recon.sh -t 127.0.0.1

# Run nmap and feroxbuster only
./recon.sh -t 127.0.0.1 -n -f

# Specify web port
./recon.sh -t 127.0.0.1 -p 8080
```


## Disclaimer

This tool is intended for authorized penetration testing and educational purposes only. Unauthorized use against systems you do not own or have explicit permission to test is illegal.

## License

MIT