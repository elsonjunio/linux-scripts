#!/bin/bash

# Install weaton an update system
apt update && apt upgrade -y apt install weston

# Generate self signed certificate 
mkdir -p /etc/ca-certificates/weston_rdp
cd /etc/ca-certificates/weston_rdp
openssl genpkey -algorithm RSA -out key.pem -pkeyopt rsa_keygen_bits:2048
openssl req -new -x509 -key key.pem -out cert.pem -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=internal.use"
chmod 444 /etc/ca-certificates/weston_rdp/*


# Add user
sudo useradd --system --no-create-home --shell /usr/sbin/nologin weston-user

# Add Systemd configuration
cat <<EOF > /etc/systemd/system/weston-rdp.service
    [Unit]
    Description=Weston RDP Service
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/bin/weston --backend=rdp-backend.so --rdp-tls-cert=/etc/ca-certificates/weston_rdp/cert.pem --rdp-tls-key=/etc/ca-certificates/weston_rdp/key.pem
    User=weston-user
    Environment=XDG_RUNTIME_DIR=/tmp/weston
    ExecStartPre=/bin/mkdir -p /tmp/weston
    ExecStartPost=/bin/chown weston-user:weston-user /tmp/weston
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable weston-rdp.service
systemctl start weston-rdp.service
systemctl status weston-rdp.service