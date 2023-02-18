### install vagrant and dependecies
```
./requirements_ubuntu.sh
```

### create virtual machines using vagrant and install kubernetes
```
vagrant up
```

### get the config file

```
./get_config.sh

mv config ~/.kube/config
```

### install monitoring tools
```
post-init.sh
```