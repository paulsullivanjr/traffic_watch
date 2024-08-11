# TrafficWatch


## TODO
- [x] Make it deploy
- [x] Scaffold basic UI
- [x] add API for traffic data
- [x] add authentication
- [ ] Clustering Markers
      When there are many incidents close to each other, the map can get cluttered. You can use marker clustering to group nearby incidents into clusters that expand when zoomed in.
      Library: Leaflet.markercluster
      Example: Show the number of incidents in a cluster. When the user clicks or zooms in, the cluster expands to show individual incidents.
- [ ] Heatmap Layer
      A heatmap visually represents the density of incidents, making it easy to see hotspots where incidents are most frequent.
      Library: Leaflet.heat
      Example: Convert your incident markers into a heatmap to show areas with high traffic incidents or hazards.
- [ ] Incident Filtering
      Allow users to filter incidents based on criteria like the type of incident (e.g., "Traffic Hazard", "Accident"), date, or severity.
      Example: Provide a UI with dropdowns or checkboxes that filter the markers on the map based on the selected criteria.
- [ ] Filter/search
- [ ] Real time updates
- [ ] Ratelimiting
