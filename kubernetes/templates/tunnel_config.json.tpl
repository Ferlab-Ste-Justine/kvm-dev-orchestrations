{
    "host_md5_fingerprint": "${ssh_fingerprint}",
    "host_url": "${ip}:22",
    "host_user": "tunnel",
    "auth_method": "key",
    "bindings": [
        {
            "local": "127.0.0.1:80",
            "remote": "127.0.0.1:80"
        },
        {
            "local": "127.0.0.1:443",
            "remote": "127.0.0.1:443"
        },
        {
            "local": "127.0.0.1:6443",
            "remote": "127.0.0.1:6443"
        }
    ]
}