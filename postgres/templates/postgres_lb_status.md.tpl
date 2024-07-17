# Postgres Lb Status

## Effective

```
%{ for entry in effective ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

## Up

```
%{ for entry in up ~}
Name: ${entry.name}
Ip:   ${entry.address}

%{ endfor ~}
```

## Down

```
%{ for entry in down ~}
Name:  ${entry.name}
Ip:    ${entry.address}
Error: ${entry.error}

%{ endfor ~}
```