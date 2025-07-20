document.addEventListener("DOMContentLoaded", () => {
  const map = L.map("map").setView([0, 0], 2); // Default view (worldwide)

  // Add OpenStreetMap tiles
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: '© OpenStreetMap contributors',
  }).addTo(map);

  // Fetch events from the server and add markers
  fetch("/api/events")
    .then((response) => response.json())
    .then((events) => {
      if (events.length === 0) {
        console.log("No events found.");
        return;
      }

      events.forEach((event) => {
        const marker = L.marker([event.latitude, event.longitude]).addTo(map);
        marker.bindPopup(`
          <b>${event.title}</b><br>
          ${event.description}<br>
          Date: ${event.date}<br>
          Location: ${event.location}
        `);
      });

      // Adjust map bounds to fit all markers
      const bounds = events.map((event) => [event.latitude, event.longitude]);
      if (bounds.length > 0) {
        map.fitBounds(bounds);
      }
    })
    .catch((error) => console.error("Error fetching events:", error));
});
