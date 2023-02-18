#!/bin/bash
kubectl exec -ti load-generator -n bookinfo -- ./wrk -D exp -t 1 -c 100 -R 40 -d 60s  -L "http://productpage.bookinfo:9080/productpage?u=normal"
