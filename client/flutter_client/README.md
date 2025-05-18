# Noodle Client

## Description

 The current directory contains a client application written in the Flutter framework. This application receives the server URL through the API_URL environment variables, and communicates with the server using access tokens, which guarantees authorized access to files (in the launch guide, dart define will be used to pass the environment variable). The application also saves the login key and username in local memory. In the current version, the application can only be installed on Android, but in future versions, due to the cross-platform nature of the Flutter framework, this application will be able to run on IOS, Windows and the web.

## Installation guide

1. From Github release:
You can install our application using the .apk file from our latest release:
- https://github.com/BlazZ1t/NotGoogleDrive/releases/latest
This release will work with OUR server and you will not be able to use your server deployed somewhere

2. From source code:
If you want to deploy your own server or modify our application in any way, you can use the source code from this directory and run it using Flutter.
To do this you need to follow these steps:
 - Install on your device and add Flutter sdk to PATH. You can do this using the official Flutter website: https://docs.flutter.dev/install
 - Create a .env file in the flavours folder using the dev.env.example example (just a file with an environment variable).
 - Build the application apk with the modifier ```--dart-define-from-file=<path to your .env file>```. For example: ```flutter build apk --dart-define-from-file=flavours/dev.env --release```
 - install application using builded apk, that you can find at ```build\app\outputs\flutter-apk\app-release.apk```


## References
1. Our latest release - https://github.com/BlazZ1t/NotGoogleDrive/releases/latest
2. Flutter official installation site - https://docs.flutter.dev/install
3. Figma design - https://www.figma.com/design/z2TBKdqqPOh3jUjrIaBsxx/noodle?node-id=2-3&t=m8l9KJuoIZY6rp3W-1


