#from ubuntu:latest
from yg397/social-network-microservices
maintainer saurabh jha

#ENV TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

run apt-get update

run apt-get install libssl-dev libz-dev luarocks cmake g++ git ntpdate -y
run luarocks install luasocket

#run cd /

#run git clone https://github.com/giltene/wrk2.git wrk

#WORKDIR /wrk

#run ls

run apt install -y ntpdate
run true || ntpdate ntp.ubuntu.com
WORKDIR /social-network-microservices/wrk2/
run make clean && make ./Makefile all -j

