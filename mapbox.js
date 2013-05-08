var osm = new OpenLayers.Layer.XYZ(
    "osm",
    [
        "http://a.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png",
        "http://b.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png",
        "http://c.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png",
        "http://d.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png"
    ], {
        attribution: "&copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors",
        sphericalMercator: true,
        wrapDateLine: true
    }
);

var map = new OpenLayers.Map({
    div: "map",
    layers: [osm],
    center: [1721973.373208, 9047015.384574],
    zoom: 5,
    controls: [new OpenLayers.Control.Navigation(), new OpenLayers.Control.Attribution()]
});

$('button').button({
  icons: { primary: "ui-icon-pencil" }
}).click(function() {
  $('.panel').fadeIn();
});

/*
$('input[type="checkbox"]').button({
  icons: { primary: "ui-icon-check" },
  text: false
});

*/
