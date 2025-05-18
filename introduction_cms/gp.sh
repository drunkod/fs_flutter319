#!/bin/bash  
  
# Step 1: Extract version from pubspec.yaml  
extract_version() {  
  file_path="./pubspec.yaml"  
  version=$(grep 'version:' "$file_path" | awk '{ print $2 }' | awk -F'+' '{ printf "v%s+%s", $1, $2 }')  
}  
  
extract_version  
echo "Starting build $version for introduction_app"  
  
# Step 2: Clean and prepare the project  
echo "Cleaning project..."  
flutter clean  
flutter pub get  
# flutter pub run build_runner build --delete-conflicting-outputs  
  
# Step 3: Build web version  
echo "Building web version..."  
flutter build web --no-pub \
  --web-renderer canvaskit \
  --dart2js-optimization=O2 \
  --no-tree-shake-icons \
  --base-href /fs_flutter319/
  
# Step 4: Prepare for GitHub Pages  
echo "Preparing for GitHub Pages deployment..."  
# Create a docs directory (GitHub Pages can serve from /docs in main branch)  
rm -rf ../docs  
mkdir -p ../docs  
cp -R build/web/* ../docs/  
  
# Create a .nojekyll file to prevent Jekyll processing  
#touch docs/.nojekyll  
  
# Create an index.html redirect in the root (optional)  
echo '<meta http-equiv="refresh" content="0;url=docs/index.html">' > ../index.html  
  
# Step 5: Commit and push to GitHub  
echo "Committing and pushing to GitHub..."  
git add ../docs ../index.html  
git commit -m "Deploy introduction_app web version $version to GitHub Pages"  
git push origin nanc_demo  
  
echo "Deployment complete! Your app should be available at https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/"
