FROM maven:3-jdk-11

RUN apt-get update && apt-get install -y curl

RUN mkdir -p /kobe/dataset

COPY init.sh /init.sh
# RUN git clone https://github.com/LiUSemWeb/Server.Java.git
# WORKDIR /Server.Java

# RUN git checkout feature-brtpf
# RUN mvn package install

COPY ldf-server.jar /ldf-server.jar
ENTRYPOINT /init.sh
