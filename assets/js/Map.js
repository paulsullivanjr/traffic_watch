import L from "leaflet";

const Map = {
  mounted() {
    const map = L.map("map").setView([30.2672, -97.7431], 13);

    // Add OpenStreetMap tiles
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    // Handle incoming events from LiveView
    this.handleEvent("add_markers", ({ markers }) => {
      markers.forEach((marker) => {
        L.marker([marker.lat, marker.lng])
          .addTo(map)
          .bindPopup(marker.popup)
          .openPopup();

        markers.push([marker.lat, marker.lng]);
      });

      if (markers.length > 0) {
        let bounds = L.latLngBounds(markers);
        this.map.fitBounds(bounds);
      }
    });

    this.map = map;
  },
};

export default Map;
