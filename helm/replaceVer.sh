#!/usr/bin/env sh
sed -i "s/\${ver}/$1/g" ./helm/Chart.yaml
