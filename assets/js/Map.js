import L from "leaflet";

const Map = {
  mounted() {
    // const map = L.map("map").setView([41, 69], 2);
    const map = L.map("map").setView([30.2672, -97.7431], 13);

    // Add OpenStreetMap tiles
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    L.marker([30.2672, -97.7431])
      .addTo(map)
      .bindPopup("Hello from Austin!")
      .openPopup();

    this.map = map;
  },
};

export default Map;
