FROM --platform=linux/arm64/v8 debian:latest AS build-env
ENV DEBIAN_FRONTEND="noninteractive"
ENV JAVA_VERSION="17"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
ENV ANDROID_VERSION="33"
ENV ANDROID_BUILD_TOOLS_VERSION="33.0.3"
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV GRADLE_VERSION="8.0"
ENV GRADLE_USER_HOME="/opt/gradle"
ENV GRADLE_URL="http://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$GRADLE_USER_HOME/bin:$PATH"
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH="/root/.pub-cache/bin:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:${PATH}"

# Install android dependencies
RUN apt-get update
RUN apt-get install -y \
    openjdk-$JAVA_VERSION-jdk \
    curl \
    unzip \
    sed \
    git \
    gdb \
    bash \
    xz-utils \
    which \
    libglvnd0 \
    ssh \
    xauth \
    x11-xserver-utils \
    libglu1 \
    libx11-6 libxcb1 libxdamage1 libnss3 libxcursor1 libxi6 libxext6 libxfixes3 \
    libstdc++6 \
    libpulse0 \
    libxcomposite1 \
    libgconf-2-4 \
    libgl1-mesa-glx \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev

RUN apt-get clean

# Install Gradle.
RUN curl -L $GRADLE_URL -o gradle-$GRADLE_VERSION-bin.zip \
  && apt-get install -y unzip \
  && unzip gradle-$GRADLE_VERSION-bin.zip \
  && mv gradle-$GRADLE_VERSION $GRADLE_USER_HOME \
  && rm gradle-$GRADLE_VERSION-bin.zip

# Install the Android SDK.
RUN mkdir /root/.android \
  && touch /root/.android/repositories.cfg \
  && mkdir -p $ANDROID_SDK_ROOT \
  && curl -o android_tools.zip $ANDROID_TOOLS_URL \
  && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip \
  && rm android_tools.zip \
  && mv $ANDROID_SDK_ROOT/cmdline-tools $ANDROID_SDK_ROOT/latest \
  && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
  && mv $ANDROID_SDK_ROOT/latest $ANDROID_SDK_ROOT/cmdline-tools/latest \
  && yes "y" | sdkmanager \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
RUN yes "y" | flutter doctor --android-licenses