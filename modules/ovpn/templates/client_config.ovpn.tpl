# (C) Copyright IBM Corp. 2021.

client
dev tun
proto ${protocol}
port ${port}
remote ${hostname}
resolv-retry infinite
remote-cert-tls server
nobind

auth SHA256
cipher AES-256-GCM
verb 3

<ca>
${ca}
</ca>

<cert>
${client_cert}
</cert>

<key>
${client_key}
</key>

reneg-sec 0
