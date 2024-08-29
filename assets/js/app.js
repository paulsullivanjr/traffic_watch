// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const MapTrace = {
  async initMap() {
    const mapConfig = {
      container: "map",
      style: {
        version: 8,
        sources: {
          osm: {
            type: "raster",
            tiles: [
              "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
              "https://b.tile.openstreetmap.org/{z}/{x}/{y}.png",
              "https://c.tile.openstreetmap.org/{z}/{x}/{y}.png",
            ],
            tileSize: 256,
            attribution:
              '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',
          },
        },
        layers: [
          {
            id: "osm-layer",
            type: "raster",
            source: "osm",
          },
        ],
      },
      center: [-97.7431, 30.2672],
      zoom: 11,
    };

    const map = new maplibregl.Map(mapConfig);

    const data = await waitForData();
    let list_stops = JSON.parse(data.list_stops);
    let geojsonList = data.geojson_list;
    let bounds = new maplibregl.LngLatBounds();

    // Iterate over each stop in the list and add markers to the map
    for (let stop of list_stops) {
      if (Array.isArray(stop[1]) && stop[1].length === 2) {
        // Convert the coordinates from strings to floats
        const lngLat = [parseFloat(stop[1][0]), parseFloat(stop[1][1])];

        // Check that the coordinates are valid numbers
        if (!isNaN(lngLat[0]) && !isNaN(lngLat[1])) {
          // Create a new marker and add it to the map
          new maplibregl.Marker().setLngLat(lngLat).addTo(map);

          // Extend the bounds to include this marker's coordinates
          bounds.extend(lngLat);
        } else {
          console.error("Invalid coordinates:", lngLat);
        }
      } else {
        console.error("Invalid stop format:", stop);
      }
    }

    // Check if bounds are valid before fitting the map
    if (bounds.isEmpty()) {
      console.error("No valid markers to fit bounds.");
    } else {
      // Adjust the map view to fit all markers
      map.fitBounds(bounds, {
        padding: { top: 50, bottom: 50, left: 50, right: 50 }, // Adjust the padding as needed
        maxZoom: 15, // Optionally, set a maximum zoom level
        duration: 1000, // Optional: duration of the transition in milliseconds
      });
    }

    // Iterate over each GeoJSON object in the list and add them to the map
    geojsonList.forEach((geojson, index) => {
      const sourceId = `route-${index}`;
      const layerId = `route-layer-${index}`;

      // Add each GeoJSON object as a new source
      if (!map.getSource(sourceId)) {
        map.addSource(sourceId, {
          type: "geojson",
          data: geojson,
        });

        // Add a layer for each source
        map.addLayer({
          id: layerId,
          type: "line",
          source: sourceId,
          layout: {
            "line-join": "round",
            "line-cap": "round",
          },
          paint: {
            "line-color": "#ff6600",
            "line-width": 4,
          },
        });
      } else {
        map.getSource(sourceId).setData(geojson);
      }
    });

    return map;
  },

  mounted() {
    this.initMap();
    this.pushEvent("after_render", {});
  },
};

function waitForData() {
  return new Promise((resolve) => {
    window.addEventListener("phx:initiate_data", (event) => {
      resolve(event.detail);
    });
  });
}

const Hooks = {
  MapTrace,
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
