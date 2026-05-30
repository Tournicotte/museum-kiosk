# Tablet Provisioning & Oracle Cloud Runner Setup

Operator runbook for first-time device setup and CI/CD infrastructure.

---

## 1. Generate a release keystore (once per project)

```bash
keytool -genkey -v \
  -keystore museum_kiosk.jks \
  -alias museum_kiosk \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Museum Kiosk, O=Kaasan, C=EE"
```

Encode for GitHub Secrets:

```bash
base64 -i museum_kiosk.jks | tr -d '\n'
```

Add to GitHub → Settings → Secrets and variables → Actions:

| Secret              | Value                                  |
|---------------------|----------------------------------------|
| `KEYSTORE_BASE64`   | base64-encoded `.jks` file             |
| `KEYSTORE_PASSWORD` | keystore password                      |
| `KEY_ALIAS`         | `museum_kiosk`                         |
| `KEY_PASSWORD`      | key password                           |
| `SUMUP_AFFILIATE_KEY` | SumUp affiliate key                  |
| `ADMIN_PIN`         | 4-digit staff PIN                      |
| `MUSEUM_NAME`       | Display name shown on attract screen   |
| `KIOSK_ID`          | Unique device ID, e.g. `kiosk-01`      |
| `TICKET_PRICE_CENTS`| Default price in cents, e.g. `400`     |
| `BACKEND_URL`       | Backend API base URL                   |
| `OCI_USER_OCID`     | Oracle Cloud user OCID                 |
| `OCI_TENANCY_OCID`  | Oracle Cloud tenancy OCID              |
| `OCI_KEY_FINGERPRINT` | OCI API key fingerprint              |
| `OCI_PRIVATE_KEY`   | OCI API private key (PEM, no passphrase) |
| `OCI_REGION`        | OCI region, e.g. `eu-frankfurt-1`      |

---

## 2. Oracle Cloud ARM runner setup (once)

### 2a. Provision ARM VM

1. Log in to Oracle Cloud → Compute → Instances → Create Instance.
2. Shape: **VM.Standard.A1.Flex** (Ampere A1 — always-free tier, up to 4 OCPU / 24 GB RAM).
3. OS: Ubuntu 22.04 LTS (aarch64).
4. Open port 22 in the VCN security list.

### 2b. Install dependencies on the VM

```bash
# Flutter
sudo snap install flutter --classic

# Java (required for Android build tools)
sudo apt install -y openjdk-17-jdk

# Android command-line tools
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip
mv cmdline-tools latest
echo 'export ANDROID_HOME=~/android-sdk' >> ~/.bashrc
echo 'export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-34"

# OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
# Configure: oci setup config
```

### 2c. Register as a GitHub Actions self-hosted runner

In the GitHub repo: Settings → Actions → Runners → New self-hosted runner.
Select **Linux / ARM64**, follow the displayed commands.

Add the runner label **`oracle-arm`**:

```bash
./config.sh --labels oracle-arm
sudo ./svc.sh install && sudo ./svc.sh start
```

### 2d. Oracle Object Storage bucket

1. Oracle Cloud → Storage → Buckets → Create Bucket.
2. Name: `museum-kiosk-artifacts`, Visibility: **Private**.
3. Create a Pre-Authenticated Request (PAR) if tablets pull via HTTPS without OCI CLI.

---

## 3. First tablet install

```bash
# Build locally if CI is not yet running
flutter build apk \
  --dart-define=ENV=production \
  --dart-define=MUSEUM_NAME="..." \
  --dart-define=SUMUP_AFFILIATE_KEY="..." \
  --dart-define=ADMIN_PIN="..." \
  --dart-define=KIOSK_ID="kiosk-01" \
  --dart-define=TICKET_PRICE_CENTS=400 \
  --dart-define=BACKEND_URL="https://..."

# Enable developer mode on tablet, connect via USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 4. Enable Device Owner kiosk lock-down

```bash
# Factory-reset the tablet first — Device Owner can only be set on a fresh device.
# Then install the APK (step 3) before any Google account is added.

adb shell dpm set-device-owner ee.kaasan.museum_kiosk/.AdminReceiver
```

The app now starts in lock-task mode on every boot. Home button and recents are blocked.

To disable during maintenance:

```bash
adb shell dpm remove-active-admin ee.kaasan.museum_kiosk/.AdminReceiver
```

---

## 5. APK update procedure (subsequent releases)

Once CI is running, updates are automatic:

1. Merge to `main` → GitHub Actions builds and uploads `museum-kiosk-latest.apk` to Object Storage.
2. Operator downloads the APK from Oracle Object Storage (or from the PAR URL).
3. `adb install -r museum-kiosk-latest.apk`  (`-r` keeps app data intact).

No Device Owner re-configuration needed — lock-task mode persists across updates.
