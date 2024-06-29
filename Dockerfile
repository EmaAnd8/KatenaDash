# Use an official Canonical Ubuntu image as the base image
FROM --platform=linux/amd64 ubuntu:20.04

WORKDIR "$PATH:/new/path"
ADD . .
# Set environment variables to specify the Dart and Flutter versions



ENV DART_VERSION 2.15.1

ENV FLUTTER_VERSION 2.10.5

ENV DART_DOWNLOAD_URL https://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/sdk/dartsdk-linux-x64.tar.xz

ENV FLUTTER_DOWNLOAD_URL https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz


# Update the package lists and install required dependencies

RUN apt update

RUN apt install -y curl tar wget xz-utils git


# Download and extract the Dart SDK


RUN dpkg -i dart_3.4.4-1_amd64.deb


#RUN tar -xvf *.tar.bz2


# Set the PATH environment variable to include the Dart SDK

ENV PATH /usr/local/dart-sdk/bin:$PATH


# Verify that Dart is installed correctly

RUN dart --version

#discovering of flutter compiler


ENV PATH "$PATH:/flutter/bin"


COPY . /app

WORKDIR /app

#build creation
RUN flutter build web --release


CMD ["flutter", "run"]