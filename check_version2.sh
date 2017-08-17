#!/bin/bash
echo -n "Input customer: "
read customer
curl -s https://$customer.selectica.com/version.html | grep Release | awk '{ print $2 " " $3 " " $4 " " $5  }' | awk -F '<' '{print $1}'
