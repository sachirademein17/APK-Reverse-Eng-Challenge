# Dockerfile for building Android APK
# Uses official Android SDK image with pre-installed tools

FROM mingc/android-build-box:latest

# Set working directory
WORKDIR /project

# Copy project files
COPY . .

# Make gradlew executable
RUN chmod +x gradlew

# Set environment variables
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Build the APK
CMD ["./gradlew", "assembleRelease", "--stacktrace", "--no-daemon"]
