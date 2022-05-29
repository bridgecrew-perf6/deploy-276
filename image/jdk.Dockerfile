FROM openjdk:11-slim

# install /bin/sh
RUN apt-get update && apt-get install -y --no-install-recommends bash

# install python
RUN apt-get update && apt-get install -y python3 python3-pip

# install pylint
RUN pip3 install pylint

ENTRYPOINT ["/usr/bin/java", "-jar"]
