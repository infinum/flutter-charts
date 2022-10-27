'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "1878ecfb175a980235fb14f924e4c4a9",
"index.html": "b62558fb3803efe16652303b3a432720",
"/": "b62558fb3803efe16652303b3a432720",
"main.dart.js": "3a0436a0c17e5e2f17cd78e5ba0f7a8c",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/chart_image.png": "6afde1b007b806eb59febb3d9a39e11b",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"style.css": "f1543beaf83dea5fe884bf79e56152b6",
"manifest.json": "1c2362bc7ebfa6b4cc5086ad6688f2b4",
"assets/AssetManifest.json": "e0485a9532160840df8177ce307565ce",
"assets/NOTICES": "a2dbf5aeb99b052bf83422af2311fa7e",
"assets/FontManifest.json": "3967317d9a53836058ef1c7d8c9cf657",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flex_color_picker/assets/opacity.png": "49c4f3bcb1b25364bb4c255edcaaf5b2",
"assets/shaders/ink_sparkle.frag": "ce5c00e6c0f2d5d32aef2684c385f933",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/assets/svg/showcase.svg": "db9a0cb6e6057870146a8bf1a3b7fbb8",
"assets/assets/svg/deco_foreground.svg": "f277b15d3519654136593df709969bf0",
"assets/assets/svg/smoothed_no.svg": "0ceaa75d5ecd96a074aba471ef9ac87b",
"assets/assets/svg/strategy%2520stack.svg": "a20cab114e8bfcd94aae3a39c2e800ec",
"assets/assets/svg/line_no.svg": "4445806f637dc7c374bcdd18f456b5fc",
"assets/assets/svg/bar_chart_icon.svg": "406fc03895b2d339ce410fcbe114d0e7",
"assets/assets/svg/smoothed_yes.svg": "b1c13ce0f3c6bd5c9aac632e2aecf39b",
"assets/assets/svg/bubble_chart_icon.svg": "9dedef53663660f217ea44748b72bf58",
"assets/assets/svg/strategy%2520default.svg": "da8da9f2086cc1023e7966e60fb79c6e",
"assets/assets/svg/deco_background.svg": "a07ee0c107b1edef29d325ecc2a00236",
"assets/assets/svg/line_yes.svg": "a292fed2b7c480dff46b08b2c0e49cc3",
"assets/assets/png/futurama1.jpeg": "ef307fc6968980d104f55bbade0537af",
"assets/assets/png/general_horizontal_decoration_golden.png": "a9b69209985cb4c7a1e26cbd305fdb68",
"assets/assets/png/general_grid_decoration_golden.png": "f7d0d431c20477f80c709f0d593aa957",
"assets/assets/png/futurama5.jpeg": "2b454838c1979f7bf72b7119a0dd4eb7",
"assets/assets/png/general_sparkline_decoration_golden.png": "082076bc92fd8358ca843a67c5f9fa1e",
"assets/assets/png/general_vertical_decoration_golden.png": "15ddaf6d2cb1b0e555b0fbfc9423776d",
"assets/assets/png/futurama4.jpeg": "ce4bb9fdca0d373cd618cc5f13b17cfd",
"assets/assets/png/futurama_small.png": "deb078b9b32caf3f20bf1d6ed41a450a",
"assets/assets/png/futurama2.jpeg": "195532ac89558111656e0eabca693a7f",
"assets/assets/font/InterTight-SemiBold.ttf": "f44f39cc87eeee444bc808e55910e6e1",
"assets/assets/font/InterTight-Light.ttf": "f3333b57ec364ed4bc63a24d74e58cec",
"assets/assets/font/InterTight-Medium.ttf": "2231574d807b4dfac8ffa31be539fc9e",
"assets/assets/font/InterTight-Regular.ttf": "3d09a8a7d5815f2b6bb59b1041fc594c",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
