Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash

echo 'test' > /home/ec2-user/user-script-output.txt

# Update packages
yum update -y

# Install Java
yum install -y java-1.8.0-amazon-corretto
# Install Telnet
yum install -y telnet


# Install Kafka
wget https://downloads.apache.org/kafka/3.4.0/kafka_2.12-3.4.0.tgz
tar -xzf kafka_2.12-3.4.0.tgz
rm kafka_2.12-3.4.0.tgz
mv kafka_2.12-3.4.0 /opt/kafka


# Install Spark
wget https://dlcdn.apache.org/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
tar -xzf spark-3.3.2-bin-hadoop3.tgz
rm spark-3.3.2-bin-hadoop3.tgz
mv spark-3.3.2-bin-hadoop3 /opt/spark/


# Set environment variables for all users
rm /etc/profile.d/sparkenv.sh

# Set JAVA HOME environment variable
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64/jre
echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile.d/sparkenv.sh

# Set SPARK HOME environment variable
export SPARK_HOME=/opt/spark
echo "export PATH=$SPARK_HOME/bin:$PATH" >> /etc/profile.d/sparkenv.sh

chmod +x /etc/profile.d/sparkenv.sh

# Start Zookeeper and Kafka Server
/opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
