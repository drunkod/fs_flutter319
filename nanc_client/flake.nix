{
  description = "Personal flutter devshell with android development support";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; # Changed
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          # Consider if tools/platform-tools/emulator versions are still appropriate for nixos-24.11
          # Or if flutter319 has specific minimums. These should generally be okay.
          # toolsVersion = "26.1.1"; # This is quite old; newer might be available/better
          cmdLineToolsVersion = "8.0"; # emulator related: newer versions are not only compatible with avdmanager
          
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ "30.0.3" "33.0.2" "34.0.0" ];
          includeEmulator = false;
          # emulatorVersion = "34.1.9"; # Latest available on unstable at time of writing, may be older on 24.11
          platformVersions = [ "28" "31" "32" "33" "34" ];          
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
          cmakeVersions = [ "3.22.1" "3.18.1"]; # This is very old for CMake; Flutter may prefer newer.
                                        # e.g., "3.22.1" is common. Test if "3.10.2" is sufficient for your NDK needs.
          includeNDK = true;
          ndkVersions = [ "25.1.8937393"];  
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell =
          with pkgs;
          mkShell {
            GRADLE_USER_HOME = "/home/user/.emu/.gradle";
            PUB_CACHE = "/home/user/.emu/.pub-cache";

            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            # JAVA_HOME = pkgs.jdk17; # Ensure Flutter 3.19 is compatible with JDK 17. It generally is.
            # CHROME_EXECUTABLE = "${pkgs.ungoogled-chromium}/bin/chromium";
            buildInputs = [
              gcc
              # flutter319 # Changed
              # firebase-tools
              # python3 # web serve locally 'python -m http.server'
              androidSdk # The customized SDK that we've made above
              sqlite
              # jdk17
            ];
            # shellHook is not strictly necessary here as LD_LIBRARY_PATH is set as an attribute
            # mkShell automatically exports attributes like LD_LIBRARY_PATH to the environment
            LD_LIBRARY_PATH = lib.makeLibraryPath [
              sqlite # This is a more robust way to get the lib path
            ];
            # Or, if you explicitly need the `${sqlite}/lib` structure as before:
            # LD_LIBRARY_PATH = "${pkgs.sqlite}/lib";
          };
      }
    );
}