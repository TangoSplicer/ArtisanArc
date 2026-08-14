# Persistent Android Release Signing

ArtisanArc Personal is configured to sign release APKs with a persistent Android signing identity when the required GitHub Actions secrets are present. This makes future APKs install as normal updates instead of being rejected because a temporary cloud runner created a different signing key.

## Required repository secrets

Open the repository’s **Settings → Secrets and variables → Actions** page and create the following secrets. Their values must come from the protected signing recovery bundle retained by the application owner; never commit them to the repository or paste them into source files.

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | The release `.jks` keystore encoded as one line of Base64 text |
| `ANDROID_KEYSTORE_PASSWORD` | The keystore password |
| `ANDROID_KEY_PASSWORD` | The key password |
| `ANDROID_KEY_ALIAS` | The signing key alias |

## Workflow behaviour

The GitHub Actions workflow decodes the keystore only inside the build runner, creates a temporary `android/key.properties` file, builds the signed release APK, and deletes the temporary key files before the artifact upload step. Pull requests or environments without secrets still build with Android’s debug-signing fallback, so automated validation does not expose signing material.

> Keep two offline copies of the keystore and its credentials in separate secure locations. If this key is lost, Android will not allow future versions of the same application ID to update installations signed by it.

## Rotating the key

Do not rotate the signing key unless there is a confirmed compromise and an Android key-upgrade strategy has been planned. A casual rotation breaks the normal update path for existing installations.
