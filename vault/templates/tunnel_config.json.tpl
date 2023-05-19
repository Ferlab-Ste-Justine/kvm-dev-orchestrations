{
    "host_sha256_fingerprint": "${ssh_fingerprint}",
    "host_url": "${ip}:22",
    "host_user": "tunnel",
    "auth_method": "key",
    "bindings": [
        {
            "local": "127.0.0.1:443",
            "remote": "127.0.0.1:443"
        },
        {
            "local": "127.0.0.1:4431",
            "remote": "127.0.0.1:4431"
        },
        {
            "local": "127.0.0.1:4432",
            "remote": "127.0.0.1:4432"
        },
        {
            "local": "127.0.0.1:4433",
            "remote": "127.0.0.1:4433"
        }
    ]
}