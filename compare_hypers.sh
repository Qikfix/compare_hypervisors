#!/bin/bash

# To collect from the local DB
echo "select cp.name,cpf.element from cp_consumer_facts as cpf, cp_consumer as cp, cp_consumer_hypervisor as cph where cp.id=cpf.cp_consumer_id and cph.consumer_id=cp.id and cpf.mapkey='dmi.system.uuid'" | su - postgres -c "psql candlepin" >/tmp/hyper_uuid_sat.log

# To collect from virt-who
systemctl stop virt-who
virt-who -op >/tmp/virt-who-full.json 2>/dev/null
systemctl start virt-who
cat /tmp/virt-who-full.json | json_reformat | grep -E '(uuid|dmi.system.uuid)' > /tmp/hyper_uuid_vcenter.log


# Parsing sat DB Info
cat /tmp/hyper_uuid_sat.log | sed '1,2d' | sed -e 's/|/,/g' | sed -e 's/ //g' | grep -v ^\( | grep -v ^$ | sort > /tmp/hyper_uuid_sat_final.log

# Parsing virt-who/vcenter Info
cat /tmp/hyper_uuid_vcenter.log | paste -s -d "" | sed -e 's/ //g' | sed -e 's/"uuid":"/\n/g' | awk 'FS="\"" {print $1","$5}' | grep -v ^, | sort > /tmp/hyper_uuid_vcenter_final.log

echo "###################################"
echo "Hypervisors on Satellite DB ......: $(wc -l /tmp/hyper_uuid_sat_final.log | awk '{print $1}')"
echo "Hypervisors on vCenter Inventory .: $(wc -l /tmp/hyper_uuid_vcenter_final.log | awk '{print $1}')"
echo "###################################"

while read line
do
#  echo - $line
  fqdn=$(echo $line | cut -d, -f1)
  uuid=$(echo $line | cut -d, -f2)

  #grep ^$fqdn hyper_uuid_sat_final.log
  #stage=$(grep ^$fqdn hyper_uuid_sat_final.log)
  stage=$(grep $uuid$ /tmp/hyper_uuid_sat_final.log)
  if [ "$stage" != "" ]; then
#    echo "something here: $stage"
    sat_db_fqdn=$(echo $stage | cut -d, -f1)
    sat_db_uuid=$(echo $stage | cut -d, -f2)

    if [ "$uuid" == "$sat_db_uuid" ] && [ "$fqdn" == "$sat_db_fqdn" ]; then
      :
#      echo "OK MATCH LINE ...: $line"
#      echo "OK MATCH STAGE ..: $stage"
#      echo
    else
      echo "DIFFERENT INFO"
      echo "SAT FQDN .......: $sat_db_fqdn"
      echo "VCENTER FQDN ...: $fqdn"
      echo "SAT UUID .......: $sat_db_uuid"
      echo "VCENTER UUID ...: $uuid"
      echo
    fi
  else
    :
#    echo "NOTHING: $stage"
  fi
done < /tmp/hyper_uuid_vcenter_final.log
echo
echo
echo
echo "If no output above, everything is fine (UUID and FQDN matching)."
