'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"manifest.json": "9e31d8e21e7e8d88a1b3100bee42b3ae",
"assets/FontManifest.json": "4a2e27eb89c99586a54a53c43730d95e",
"assets/assets/fonts/helvetica.ttf": "1b580d980532792578c54897ca387e2c",
"assets/assets/fonts/helvetica_bold.ttf": "d13db1fed3945c3b8c3293bfcfadb32f",
"assets/assets/fonts/blazeface.ttf": "52197ff28afbf666c99977c8c4e4ecf1",
"assets/assets/fonts/helvetica_light.ttf": "9a8c18bd1dbe8508bc2525be7e07d0ff",
"assets/assets/fonts/helvetica_neue_wide.ttf": "365834cfa7beb7ca64c00476397ddc32",
"assets/assets/fonts/helvetica_neue_light.ttf": "513e00a92551c7f365c8d2d6cb475658",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/remixicon/fonts/Remix.ttf": "83628e3d1253bfac699c4ef96121bd72",
"assets/packages/fluentui_system_icons/fonts/FluentSystemIcons-Regular.ttf": "200a97d5d84aaabf189447eec9de4f93",
"assets/packages/fluentui_system_icons/fonts/FluentSystemIcons-Filled.ttf": "41a9b3130d857b928160fa40ab867b13",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "d10ac4ee5ebe8c8fff90505150ba2a76",
"assets/packages/ionicons/assets/fonts/Ionicons.ttf": "a48ca9e5bcc89fccac32592416234257",
"assets/packages/nanc/assets/fonts/blueprint_font_non_commercial.ttf": "af53292c2c749eed3192541a9e78d185",
"assets/packages/nanc/assets/animations/spring_robot_rive.riv": "d95adfefa25df25c34f6d9f5cb4ee9e0",
"assets/packages/nanc/assets/animations/simple_tree_rive.riv": "418280e6c29f1a6a7d414fdaffe64f47",
"assets/packages/nanc/assets/animations/document_icon_rive.riv": "a7225720561367ed39c7fe977f713761",
"assets/packages/nanc/assets/animations/robo_cleaner_rive.riv": "335a03e80a0597714cd78854a44cbc01",
"assets/packages/nanc/assets/animations/lights_transparent_rive.riv": "1c79db27cc6fd1c8cc8b69644a6c05f0",
"assets/packages/nanc/assets/animations/cute_robot_rive.riv": "e8616c368860eeeb4b5e77d8dba28142",
"assets/packages/nanc/assets/animations/construction_lottie.json": "a65193e1909eb26e184ce0f092e03452",
"assets/packages/nanc/assets/animations/tree_demo_transparent_rive.riv": "5f92bf04c270626e7ae05a36980f4a14",
"assets/packages/nanc/assets/animations/knight_rive.riv": "4142c0b1b7472b0480f65f14aa6eb6e1",
"assets/packages/nanc/assets/images/narrow_logo.png": "60ede89c2506eb4b359619bbbb1401c8",
"assets/packages/nanc/assets/images/logo_light.svg": "2f7cd8e212cdad3cb8215c088b96f82e",
"assets/packages/nanc/assets/images/name_light.svg": "c69dbe70f0330563e24c7d7c21982615",
"assets/AssetManifest.bin": "8c8fc07d6387aa0be4366fc0b4429965",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "5c252ba0cc2544a6d2efd21ed07243b6",
"assets/NOTICES": "4028c18e4e3f62ab6b8b5130ce857bc0",
"assets/AssetManifest.json": "ab3e4b5c9d0a8701972743776038e8bc",
"index.html": "d3ab228ae3aab29ec6ee8936c67efdd1",
"/": "d3ab228ae3aab29ec6ee8936c67efdd1",
"main.dart.js": "daee3ca52fd25349e72132fb26453fcd",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"version.json": "2a65764c87d6e69e8220eb7d95375093",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
