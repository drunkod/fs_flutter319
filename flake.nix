{
  description = "Personal flutter devshell with android development support (updated for NixOS 25.11 and newer Android tooling)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # updated
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        # Updated tool versions — tweak if your nixpkgs doesn't include them
        toolsVersion = "33.0.2";           # SDK tools (legacy) — often not required on newer manifests
        platformToolsVersion = "35.0.4";   # adb, fastboot
        buildToolsVersions = [ "34.0.0" "33.0.2" ];
        includeEmulator = true;            # enable emulator in the dev shell (optional)
        emulatorVersion = "35.2.0";
        platformVersions = [
          "29"
          "30"
          "31"
          "32"
          "33"
          "34"
          "35"
        ];
        includeSources = false;
        includeSystemImages = false;       # keep false if you prefer to install system images separately
        systemImageTypes = [ "google_apis_playstore" ];
        abiVersions = [
          "armeabi-v7a"
          "arm64-v8a"
        ];
        cmakeVersions = [ "3.22.1" "3.25.0" ]; # more recent CMake versions commonly needed
        includeNDK = true;
        ndkVersions = [ "25.1.8937393" ];      # NDK r25b — update if unavailable in your nixpkgs
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
      };

      androidSdk = androidComposition.androidsdk;

    in {
      devShell = with pkgs; mkShell {
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";

        # If you prefer a specific JDK, enable it here:
        JAVA_HOME = "${pkgs.openjdk17}";

        buildInputs = [
          androidSdk
          sqlite
          # Uncomment/add the flutter package available in your channel:
          # pkgs.flutter # or pkgs.flutter_3_19 or pkgs.flutterDev
          pkgs.python3
          pkgs.nodejs         # useful for firebase-tools / web tooling
          #pkgs.firebase-cli   # if available in your nixpkgs, else use npm-installed firebase-tools
        ];

        # Export library path(s)
        LD_LIBRARY_PATH = lib.makeLibraryPath [
          sqlite
        ];

        # Optional shell hooks to make emulator usable
        shellHook = ''
          export PATH="${androidSdk}/libexec/android-sdk/emulator:${androidSdk}/libexec/android-sdk/platform-tools:$PATH"
          echo "Android SDK: ${ANDROID_SDK_ROOT}"
        '';
      };
    }
  );
}
