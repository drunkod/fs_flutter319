# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }:

# This 'let' block allows us to define intermediate values, similar to the flake's 'let' block.
let
  # --- Android SDK Configuration ---
  # This replicates the androidComposition from your flake.
  # We use the 'pkgs' provided by Project IDX.
  # androidComposition = pkgs.androidenv.composeAndroidPackages {
  #   # Versions from your flake, with considerations for stable-24.11:
  #   # Command line tools version (SDK manager, avdmanager etc.)
  #   # "26.1.1" is quite old. pkgs.android-tools on stable-24.11 will provide a newer version.
  #   # Often, for `composeAndroidPackages`, you might not need to specify `toolsVersion`
  #   # if the default provided by `pkgs.android-tools` (which `androidenv` uses) is sufficient.
  #   # Let's try omitting it first, or use a more recent known good one if issues arise.
  #   # For stability, we can pin it if necessary. Let's keep your specified one for now.
  #   toolsVersion = "26.1.1"; # Check if this specific old version is crucial or if a newer default works.

  #   # Platform tools (adb, fastboot)
  #   platformToolsVersion = "34.0.5"; # This is reasonably current.

  #   # Build tools versions required by your projects.
  #   buildToolsVersions = [
  #     "33.0.1" # Common for projects targeting SDK 33
  #     "34.0.0" # Good to have for SDK 34
  #   ];

  #   # Android SDK Platform versions (API levels)
  #   platformVersions = [
  #     "33" # Android 13
  #     "34" # Android 14
  #     # "35" # As noted in your flake, might not be available in stable-24.11 yet.
  #            # Check nixpkgs manifest for android_sdk_pkgs if needed.
  #   ];

  #   # NDK (Native Development Kit)
  #   includeNDK = true;
  #   # NDK r22. Flutter 3.19 should be fine with this or newer ones like r25/r26.
  #   # If you encounter NDK issues, consider using a newer version available in nixpkgs.
  #   # e.g., pkgs.android-ndk-r25c or let androidenv pick a default.
  #   ndkVersions = [ "22.0.7026061" ]; # NDK r22b

  #   # CMake for NDK
  #   # "3.10.2" is very old. NDK often bundles its own or works with newer system CMake.
  #   # Flutter uses Gradle, which handles CMake versions.
  #   # It might be safer to use a more modern CMake if problems arise, e.g., "3.22.1"
  #   # Or let the NDK bundle handle it if `includeNDK = true`.
  #   # For `composeAndroidPackages`, this cmake is often for NDK samples/builds.
  #   cmakeVersions = [ "3.10.2" ]; # "3.22.1" or "3.27.7" (latest stable) are alternatives

  #   # Emulator - typically not run directly inside IDX container, but good for SDK completeness.
  #   # For IDX, you usually connect a physical device or use IDX's emulators if available.
  #   includeEmulator = false; # As per your flake, sensible for IDX.
  #   # emulatorVersion = "34.1.9"; # If includeEmulator was true

  #   # Other options from your flake:
  #   includeSources = false;
  #   includeSystemImages = false; # If true, specify systemImageTypes and abiVersions
  #   # systemImageTypes = [ "google_apis_playstore" ];
  #   # abiVersions = [ "armeabi-v7a", "arm64-v8a" ];
  #   useGoogleAPIs = false; # Set to true if you need Google Play Services APIs in SDK platforms
  #   useGoogleTVAddOns = false;
  # };

  # The actual Android SDK derivation
  # customAndroidSdk = androidComposition.androidsdk;

  # Define JDK version once
  # Flutter 3.19 generally works well with JDK 17.
  # pkgs.jdk17 is a common choice.
  # You can also use pkgs.temurin-17.jdk for an OpenJDK build from Adoptium.
  selectedJdk = pkgs.jdk17;

in
{
  # Which nixpkgs channel to use.
  channel = "stable-24.11"; # Matches your flake's nixpkgs input

  # --- Nixpkgs Configuration ---
  # This is where you set allowUnfree and android_sdk.accept_license
  # nixpkgs.config = {
  #   android_sdk.accept_license = true;
  #   allowUnfree = true; # Required for Android SDK components and potentially other proprietary tools
  # };

  # Use https://search.nixos.org/packages to find packages
  packages = [
    # --- Flutter and Android Development ---
    pkgs.flutter319 # Your specified Flutter version
    # customAndroidSdk # Our custom-built Android SDK
    selectedJdk      # Java Development Kit

    # --- Common Android/Flutter Dependencies & Tools ---
    pkgs.git
    # pkgs.firebase-tools # From your flake
    # pkgs.python3        # For `python -m http.server` or other scripts
    pkgs.sqlite         # From your flake
    pkgs.unzip          # Often needed for various SDK tools or archives
    pkgs.which          # Useful for debugging PATH issues
    # pkgs.jq             # For JSON manipulation, often handy
    # pkgs.chromium or pkgs.google-chrome-stable # For Flutter web testing, if needed

    # --- General Utilities from previous example (optional) ---
    # pkgs.curl
    # pkgs.wget
  ];
  

  # Sets environment variables in the workspace
  env = {
    # --- Android SDK Environment Variables ---
    # NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = true;
    
    # ANDROID_SDK_ROOT = "${customAndroidSdk}/libexec/android-sdk";
    # ANDROID_HOME = "${customAndroidSdk}/libexec/android-sdk"; # Often synonymous with ANDROID_SDK_ROOT
    # PATH an EXAMPLE: IDX usually handles PATH setup for `packages`.
    # However, if some tools from the SDK aren't automatically on PATH:
    # PATH = "${customAndroidSdk}/libexec/android-sdk/cmdline-tools/latest/bin:${customAndroidSdk}/libexec/android-sdk/platform-tools:${customAndroidSdk}/libexec/android-sdk/emulator:${pkgs.flutter319}/bin:$PATH";
    # Note: Flutter and SDK tools should generally be on PATH automatically if installed via `packages`.
    # Verify with `which adb`, `which flutter`, etc. in the IDX terminal.

    # --- Java Environment Variable ---
    JAVA_HOME = "${selectedJdk}"; # Path to the JDK

    # --- Flutter Specific (Optional, Flutter often finds Chrome automatically) ---
    # CHROME_EXECUTABLE = "${pkgs.chromium}/bin/chromium"; # If using pkgs.chromium for web tests

    # --- For SQLite (if its libraries are needed by runtime linked tools) ---
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.sqlite ]; # Ensures .so files from sqlite are findable
    PUB_CACHE = "/home/user/.emu/.pub-cache";
    # --- Other useful variables ---
    # EXAMPLE_VAR = "Hello from Nix!";
    # NODE_ENV = "development";
  };

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      # "vscodevim.vim"
      "Dart-Code.flutter"      # Essential for Flutter development
      "Dart-Code.dart-code"    # Essential for Dart development
      # "GitHub.copilot"
      # "eamodio.gitlens"
      # "esbenp.prettier-vscode" # If you use Prettier for other files
    ];

    # Enable previews
    previews = {
      enable = false;
      previews = {
        # Example: if you have a web part of your Flutter app or a separate web server
        # web-preview = {
        #   command = ["flutter" "run" "-d" "chrome" "--web-port" "$PORT"]; # Runs Flutter web on $PORT
        #   manager = "web";
        #   env = {
        #     PORT = "$PORT";
        #   };
        #   # Optional: if your web output is in a specific directory
        #   # rootDir = "build/web";
        # };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        setup-flutter = ''
          export NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1
          echo "Setting up Flutter..."
          flutter doctor -v # Run doctor to check setup and download any missing Dart SDK components
          # flutter precache # Optionally precache artifacts for common platforms
          echo "Flutter setup complete."
        '';
        # Example: install JS dependencies from NPM if also a web project
        # npm-install = "if [ -f package.json ]; then npm install; fi";

        default.openFiles = [
          ".idx/dev.nix"
          "README.md"
        ];
      };
      # Runs when the workspace is (re)started
      onStart = {
        start-message = "echo 'Flutter & Android environment ready! Run `flutter doctor` to verify.'";
        # Example: start a background task (if any)
        # watch-backend = "npm run watch-backend";
      };
    };
  };
}
