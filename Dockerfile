FROM alpine:3
RUN apk add --quiet --update --no-cache openjdk8-jre nodejs npm vim
RUN npm install -g firebase-tools
RUN mkdir -p /firebase/volume
WORKDIR /firebase
COPY entrypoint.sh .
# the mount point for a project
VOLUME /firebase/volume
WORKDIR /firebase/volume
COPY firebase.json .
COPY firestore-dev.rules .
# required to launch ui
ENV FIREBASE_PROJECT_ID=
# required to perform some cli operations
# https://firebase.google.com/docs/cli#cli-ci-systems
ENV FIREBASE_TOKEN=
# the default ports used by cli
# https://firebase.google.com/docs/emulator-suite/install_and_configure#port_configuration
EXPOSE 4000
EXPOSE 5000
EXPOSE 5001
EXPOSE 8080
EXPOSE 8085
EXPOSE 9000
# 9005 is used by `firebase login:ci`
EXPOSE 9005
ENTRYPOINT ["/firebase/entrypoint.sh"]
# the default operation is running the emulators
CMD ["--non-interactive", "emulators:start"]
