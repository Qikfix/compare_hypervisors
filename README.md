This script should be executed on Satellite/Foreman Server and will check and compare the hypervisor information coming from virt-who and the current information in the DB. We are looking for different FQDN where the UUID is the same.

Before you start, just download the script:
```
# wget https://raw.githubusercontent.com/waldirio/compare_hypervisors/master/compare_hypers.sh
# chmod +x compare_hypers.sh
```

Below an example:
```
# ./compare_hypers.sh 
###################################
Hypervisors on Satellite DB ......: 6
Hypervisors on vCenter Inventory .: 5
###################################



If no output above, everything is fine (UUID and FQDN matching).
```

If something is different, the output should be as below:
```
# ./compare_hypers.sh                               
###################################
Hypervisors on Satellite DB ......: 6
Hypervisors on vCenter Inventory .: 5
###################################

DIFFERENT INFO
SAT FQDN .......: server.domain.local
VCENTER FQDN ...: XPTO.domain.local
SAT UUID .......: 30393137-3436-584d-5136-303730304747
VCENTER UUID ...: 30393137-3436-584d-5136-303730304747



If no output above, everything is fine (UUID and FQDN matching).
```

Hope you enjoy it.
