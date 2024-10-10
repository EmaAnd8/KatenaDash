# Use the latest Ubuntu LTS version as a base
FROM ubuntu:latest

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install required tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    wget \
    xz-utils \
    libglu1-mesa \
    apt-transport-https \
    gnupg \
    ca-certificates \
    xvfb \
    libgtk-3-0 \
    libgbm1 \
    libnss3 \
    libxss1 \
    unzip \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.10 python3.10-venv python3.10-distutils python3-pip
  # Python and pip

# Install Chrome for Flutter web builds
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# Install Dart SDK
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/dart-archive-keyring.gpg' \
    && echo 'deb [signed-by=/usr/share/keyrings/dart-archive-keyring.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list \
    && apt-get update \
    && apt-get install -y dart

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="$PATH:/usr/local/flutter/bin"
RUN git config --global --add safe.directory /usr/local/flutter

# Create a non-root user to run Flutter
RUN useradd -m flutteruser \
    && chown -R flutteruser:flutteruser /usr/local/flutter

# Copy the entire project directory (where the Dockerfile is located) into the image
COPY . /app
COPY chrome-launcher.sh /usr/local/bin/chrome-launcher

# Set executable permissions and configure the custom Chrome launcher
RUN chmod +x /usr/local/bin/chrome-launcher && \
    ln -sf /usr/local/bin/chrome-launcher /usr/bin/google-chrome && \
    chown -R flutteruser:flutteruser /app

# Switch to non-root user
USER flutteruser
WORKDIR /app

# Crea un ambiente virtuale Python
RUN python3.10 -m venv venv

COPY req.txt /app

# Attiva l'ambiente virtuale e installa le dipendenze
RUN . venv/bin/activate && pip install --upgrade pip && pip install -r req.txt


# Run basic check to download Dart SDK and Flutter SDK
RUN flutter doctor

# Set up the environment for headless Chrome executione
ENV DISPLAY=:99

# Expose default port for Flutter web (now using a different port for Python server)
EXPOSE 8080 5001 8765

# Build the Flutter project (assuming web build output is directly accessible)
RUN flutter build web

USER root

# Copia lo script di avvio
COPY script.sh /app/script.sh

# Imposta i permessi di esecuzione
RUN chmod +x /app/script.sh

# Imposta il comando di avvio
CMD ["/app/script.sh"]

