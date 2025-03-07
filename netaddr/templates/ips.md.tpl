# Ferlab

## Usage

```
Capacity: ${ferlab_usage.capacity}
Used Capacity: ${ferlab_usage.used_capacity}
Free Capacity: ${ferlab_usage.free_capacity}
```

## Ips List

```
%{ for entry in ferlab ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

## Key Space

First Address: ${ferlab_keyspace.first_address}
Last Address: ${ferlab_keyspace.last_address}
Next Address: ${ferlab_keyspace.next_address}

### Addresses

```
%{ for entry in ferlab_keyspace.addresses ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

### Generated Addresses

```
%{ for entry in ferlab_keyspace.generated_addresses ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

### Hardcoded Addresses

```
%{ for entry in ferlab_keyspace.hardcoded_addresses ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

### Deleted Addresses

```
%{ for entry in ferlab_keyspace.deleted_addresses ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```