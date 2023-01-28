# Ips List

## Ferlab

```
%{ for entry in ferlab ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```