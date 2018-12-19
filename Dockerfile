FROM crystallang/crystal:latest

WORKDIR .
RUN shards init
RUN shards install
RUN ls
RUN crystal run main.cr
