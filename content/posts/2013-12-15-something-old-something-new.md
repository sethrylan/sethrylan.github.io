---
date: "2013-12-15T00:00:00Z"
title: Something Old, Something New
---

<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no">

<link href="https://api.mapbox.com/mapbox-gl-js/v3.12.0/mapbox-gl.css" rel="stylesheet">
<script src="https://api.mapbox.com/mapbox-gl-js/v3.12.0/mapbox-gl.js"></script>

<style>
#features {
  position: absolute;
  top: 0;
  right: 0;
  width: 50;
  background: rgba(255, 255, 255, 0.8);
}
body { margin: 0; padding: 0; }
#map { 
  position: relative;
  width: 100%;
  height: 800px;
  margin-bottom: 20px;
}
</style>

Choropleth map of the age of structures in the City of Charleston, [Old and Historic Districts](http://www.charleston-sc.gov/DocumentCenter/View/1270).

<div id="map"></div>
<pre id="features"></pre>

<script>
  mapboxgl.accessToken = 'pk.eyJ1Ijoic2V0aHJ5bGFuIiwiYSI6IlUzM0JHTEEifQ.JYoyI_v_M3aeZTiPD_7KyA';
  const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/sethrylan/cktp5sr5n0kee17t3bneo23wg',
    center: [-79.946670, 32.792113],
    zoom: 13,
    attributionControl: false
  });
  map.addControl(new mapboxgl.AttributionControl(), 'top-left');

  map.on('mousemove', (e) => {
    const features = map.queryRenderedFeatures(e.point);

    const year = features
      .map(feature => feature.properties['YEAR_BUILT'])
      .filter(Number);

    // Write object as string with an indent of two spaces.
    document.getElementById('features').innerHTML = JSON.stringify(
      year[0] ? year[0] : 0,
      null,
      2
    );
  });

</script>

