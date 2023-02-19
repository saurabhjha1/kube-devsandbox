#!/bin/bash
kubectl exec -ti load-generator -n bookinfo -- ./wrk -D exp -t 1 -c 100 -R 1000 -d 1000s  -L "http://productpage.bookinfo:9080/productpage?u=normal"
