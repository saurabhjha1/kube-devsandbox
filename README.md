### install vagrant and dependecies
```
./requirements_ubuntu.sh
```

### create virtual machines using vagrant and install kubernetes (or deploy kubernetes using any other way e.g., rancher/ansible etc)
```
sh ./vagrant.sh
```

### get the config file

```
sh ./get_config.sh

mv config ~/.kube/config
```

### install monitoring tools
```
sh ./post-init.sh
```

### apps 

#### social-network from DeathStarBench

```
git submodule update --remote
cd apps/social-network
sh ./deploy.sh install # installs social network from deathstar bench
sh ./deploy.sh init # creates a fake social graph for social network 
sh ./deploy.sh test # generates a fake workload
```
