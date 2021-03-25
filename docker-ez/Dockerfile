FROM reg.aichallenge.ir/python:3.8

RUN apt-get update && \
apt install -y default-jre cmake && \
pip3 install pyinstaller

# compiler module
COPY compile /usr/bin/compile
COPY compiler.sh /home/.compiler.sh
COPY jar-stub.sh /home/.jar-stub

RUN chmod +x /usr/bin/compile && chmod +x /home/.compiler.sh

WORKDIR /home
RUN mkdir code 
RUN curl -s https://api.github.com/repos/sharifaichallenge/aic21-server/releases/latest \
| grep "browser_download_url.*jar" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O .server.jar

COPY server /usr/bin/server
RUN chmod +x /usr/bin/server
WORKDIR /home/code
#CMD ["java -jar server.jar"]

