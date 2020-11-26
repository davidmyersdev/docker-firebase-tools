# docker-firebase-cli

A docker container for https://firebase.google.com/docs/cli - aka firebase-tools

##  Usage

### TLDR

Running the container will run `firebase --non-interactive emulators:start`. The `firebase.json` file included in this project will start a Firestore emulator (at port `8080`), an Auth emulator (at port `9099`), and the Emulator Suite UI (at port `4000` - if you pass a project id). To override this behavior, you can provide your own config files [using the instructions below](#use-your-own-firebase-config).

### Docker Run

```shell
docker run --rm -it -e FIREBASE_PROJECT_ID=project-123 -p 4000:4000 -p 8080:8080 -p 9099:9099 voraciousdev/firebase-cli
```

#### Firebase CLI Authorization

https://firebase.google.com/docs/cli#cli-ci-systems

Generate the authorization URL.

```shell
# port 9005 is required for the oauth redirect
docker run --rm -it -e FIREBASE_PROJECT_ID=project-123 -p 9005:9005 voraciousdev/firebase-cli login:ci
```

This should give you a URL similar to the following.

```
https://accounts.google.com/o/oauth2/auth?client_id=abc-123.apps.googleusercontent.com&scope=email%20openid%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloudplatformprojects.readonly%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffirebase%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform&response_type=code&state=123&redirect_uri=http%3A%2F%2Flocalhost%3A9005
```

Visit this URL on your host machine to authorize Firebase CLI via OAuth. After authorizing, you should see an auth token in your terminal.

Run the docker container with the auth token as `FIREBASE_TOKEN` to use any `firebase-tools` features that require authorization. This token can be reused across containers, but you can always generate a new one by following the steps above.

```shell
docker run --rm -it -e FIREBASE_TOKEN=token-123 -e FIREBASE_PROJECT_ID=project-123 -p 4000:4000 -p 8080:8080 -p 9099:9099 voraciousdev/firebase-cli
```

### Docker Compose

Things will be pretty similar for Docker Compose, but you will need to setup some configuration. Here is an example `docker-compose.yml` with a separate `.env` for your credentials. I recommend following the same steps above to generate your auth token if you need it.

```yaml
# docker-compose.yml
version: '3.1'
services:
  firebase:
    container_name: firebase
    environment:
      - FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
      - FIREBASE_TOKEN=${FIREBASE_TOKEN}
    image: voraciousdev/firebase-cli
    ports:
      - 4000:4000 # emulator suite ui
      - 8080:8080 # firestore
      - 9099:9099 # auth
    stdin_open: true
    tty: true
    volumes:
      - .:/firebase/volume
```

```shell
# .env
FIREBASE_PROJECT_ID=project-123
FIREBASE_TOKEN=your-oauth-token
```

Once your project is configured, you can just run it like normal.

```shell
docker-compose up
```

### Use your own Firebase config

If you want to use your own firebase configuration, you just need to mount a volume with your config files. This image has already been setup to accept a volume mounted at `/firebase/volume` in your container. For these examples, let's assume you have the following files on your host machine at `/home/firebase`.

```js
// firebase.json

{
  "firestore": {
    "rules": "firestore.rules"
  },
  "emulators": {
    "auth": {
      "host": "0.0.0.0",
      "port": 1234
    },
    "firestore": {
      "host": "0.0.0.0",
      "port": 2345
    },
    "ui": {
      "enabled": true,
      "host": "0.0.0.0",
      "port": 3456
    }
  }
}
```

```js
// firestore.rules

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow only authenticated content owners access
    match /some_collection/{userId}/{documents=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId
    }
  }
}
```

Note the alternative ports chosen.

#### Docker Run

Note the matching port bindings and the new `-v` argument. The host path is `/home/firebase` and the guest path (in your container) is `/firebase/volume`.

```shell
docker run --rm -it -e FIREBASE_PROJECT_ID=project-123 -v /home/firebase:/firebase/volume -p 1234:1234 -p 2345:2345 -p 3456:3456 voraciousdev/firebase-cli
```

#### Docker Compose

Note the matching port bindings and the new `volumes` key. The host path is `/home/firebase` and the guest path (in your container) is `/firebase/volume`.

```yaml
# docker-compose.yml
version: '3.1'
services:
  firebase:
    container_name: firebase
    environment:
      - FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
      - FIREBASE_TOKEN=${FIREBASE_TOKEN}
    image: voraciousdev/firebase-cli
    ports:
      - 1234:1234 # auth
      - 2345:2345 # firestore
      - 3456:3456 # emulator suite ui
    stdin_open: true
    tty: true
    volumes:
      - /home/firebase:/firebase/volume
```
