FROM erlang:25 AS build
RUN mkdir /usr/local/src/doctorworm
WORKDIR /usr/local/src/doctorworm
COPY . /usr/local/src/doctorworm
RUN apt update && apt install make
RUN make
