# Keyspace

```
%{ for idx, val in keyspace ~}
${val.key} : |
  ${indent(2, val.value)}
%{ endfor ~}
```