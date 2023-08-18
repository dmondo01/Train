# train

Find information about your train or station in France

## Getting Started

```
git clone https://github.com/dmondo01/Train.git
```

## Requirements
[Flutter](https://docs.flutter.dev/get-started/install)

## Use
1. [Request an API key from SNCF](https://numerique.sncf.com/startup/api/token-developpeur/)
2. Copy the SNCF key in lib>api_key.dart
```
// SNCF API KEY
const sncfApiKey = 'YOUR_API_KEY';
```
3. [Request an API key from Google](https://console.cloud.google.com/google/maps-apis)
4. Copy the Google key in lib>api_key.dart
```
// GOOGLE API KEY
const googleApiKey = 'YOUR_API_KEY';
```
5. Copy the Google Key in ios>Runner>AppDelegate.swift
```
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```
6. Copy the Google Key in android>app>src>main>AndroidManifest.xml
```
   <meta-data android:name="com.google.android.geo.API_KEY"
   android:value="YOUR_GOOGLE_API_KEY"/>
```