$ ->
  osm = new OpenLayers.Layer.XYZ 'mapbox', [
    "http://a.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png"
    "http://b.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png"
    "http://c.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png"
    "http://d.tiles.mapbox.com/v3/bjornharrtell.map-em5abk65/${z}/${x}/${y}.png"]
   ,
    attribution: "&copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors"
    sphericalMercator: true
    wrapDateLine: true

  map = new OpenLayers.Map
    div: 'map'
    layers: [osm]
    center: [1480000, 7520000]
    zoom: 9
    units: 'm'
    controls: [new OpenLayers.Control.Navigation, new OpenLayers.Control.Attribution]
    
  markers = new OpenLayers.Layer.Vector 'markers',
    styleMap: new OpenLayers.StyleMap
      default:
        strokeWidth: 0.5
        pointRadius: 5
        fillColor: '#ff0000'
  
  map.addLayer markers
  
  drawFeature = new OpenLayers.Control.DrawFeature markers, OpenLayers.Handler.Point
  map.addControl drawFeature
  
  selectFeature = new OpenLayers.Control.SelectFeature markers
  map.addControl selectFeature
  selectFeature.activate()
  
  selectedFeature = null
  
  markers.events.register 'featureselected', null, (e) ->
    $('.panel').fadeIn()
    f = e.feature
    $('#v1').prop 'checked', f.attributes.v1
    $('#v2').prop 'checked', f.attributes.v2
    $('#v3').prop 'checked', f.attributes.v3
    $('#errortitle').text "Felanmälan #{f.fid}"
    selectedFeature = f

  count = 0
  
  $('#login').button()
    .click ->
      $('#login').fadeOut()
      $('#draw').fadeIn()
      a =
        v1: false
        v2: false
        v3: false
      markers.addFeatures [
        new OpenLayers.Feature.Vector (new OpenLayers.Geometry.Point 1445067,7475858), a
        new OpenLayers.Feature.Vector (new OpenLayers.Geometry.Point 1442443,7441135), a
        new OpenLayers.Feature.Vector (new OpenLayers.Geometry.Point 1433729,7571251), a
      ]
      for f in markers.features
        count += 1
        f.fid = count
      
      $('#draw').button(
        icons: { primary: "ui-icon-pencil" }
      ).click ->
        drawFeature.activate()
      
      markers.events.register 'featureadded', null, (e) ->
        $('.panel').fadeIn()
        drawFeature.deactivate()
        count += 1
        e.feature.fid = count
        e.feature.attributes =
          v1: false
          v2: false
          v3: false
        selectFeature.select e.feature
  
  $('input[type=checkbox]').click (e) ->
    selectedFeature?.attributes[this.id] = $(this).is(':checked')
    true


