#!/bin/bash -x
while read customer ;do 
      $(echo $customer - $(curl -s https://$customer.selectica.com/version.html | grep Release | awk ' { print $2 " " $3 " " $4 " " $5  }' | awk -F '<' '{print $1}') >> /media/truecrypt1/clm_version_for_stage)
done 
