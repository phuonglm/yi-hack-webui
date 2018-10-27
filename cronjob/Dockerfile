FROM ubuntu
RUN apt-get update && apt-get install -y lftp telnet iputils-ping
RUN mkdir -p /app/
ADD ./yiantcopy.sh /app/yiantcopy.sh
CMD bash -c /app/yiantcopy.sh