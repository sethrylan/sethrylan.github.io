---
layout: post
title: Something Old, Something New
sitemap:
  priority: 0.7
  changefreq: weekly
---

Choropleth map of the age of structures in the City of Charleston, [Old and Historic Districts](http://www.charleston-sc.gov/DocumentCenter/View/1270).

See similar projects for [Brooklyn](http://bklynr.com/block-by-block-brooklyns-past-and-present/), [Portland](http://www.theatlanticcities.com/neighborhoods/2013/07/vivid-mesmerizing-map-age-buildings-portland/6196/) and the [Netherlands](http://dev.citysdk.waag.org/buildings/).


<div id="map"></div>
 
<script>
  mapboxgl.accessToken = 'pk.eyJ1Ijoic2V0aHJ5bGFuIiwiYSI6IlUzM0JHTEEifQ.JYoyI_v_M3aeZTiPD_7KyA';
  const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/sethrylan/cktp5sr5n0kee17t3bneo23wg',
    center: [-79.946670, 32.792113],
    zoom: 11.15,
    attributionControl: false
  });
map.addControl(new mapboxgl.AttributionControl(), 'top-left');
</script>

