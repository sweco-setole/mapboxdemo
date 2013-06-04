$ ->
  osm = new OpenLayers.Layer.XYZ 'mapbox', [
    "http://a.tiles.mapbox.com/v3/toblen.map-7kkard5p/${z}/${x}/${y}.png"
    "http://b.tiles.mapbox.com/v3/toblen.map-7kkard5p/${z}/${x}/${y}.png"
    "http://c.tiles.mapbox.com/v3/toblen.map-7kkard5p/${z}/${x}/${y}.png"
    "http://d.tiles.mapbox.com/v3/toblen.map-7kkard5p/${z}/${x}/${y}.png"]
   ,
    attribution: "&copy; <a href='http://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors"
    sphericalMercator: true
    wrapDateLine: true

  labelMap = 
    complaint:'Klagomål'
    analysis:'Analysresultat'
    c1:'Färg'
    c2:'Lukt'
    c3:'Smak'
    a1:'Otjänligt'
    a2:'Tjänligt m. anm'

  map = new OpenLayers.Map
    div: 'map'
    layers: [osm]
    center: [1480000, 7520000]
    zoom: 9
    units: 'm'
    controls: [new OpenLayers.Control.Navigation, new OpenLayers.Control.Attribution]
    
  styleContext =
    getColor: (feature) ->
      attr = feature.attributes
      
      if attr.type == 'temp'
        #Check for temporary (unsaved) feature
        '#66cccc'
      else if attr.type == 'complaint'
        #Handle complaints return color based on radiobutton values
        if $('#vc_all').prop 'checked'
          '#c00000'  
        else if $('#vc1').prop 'checked'
          '#ffc000'
        else if $('#vc2').prop 'checked'
          '#7030a0'
        else
          '#ff33cc'
      else
        #Handle analysis, return color based on radiobutton values
        if $('#va_all').prop 'checked'
          '#c00000'
        else if $('#va1').prop 'checked'
          '#ffc000'
        else
          '#7030a0'
    getDisplay: (feature) ->
      attr = feature.attributes
      
      #Check for temporary (unsaved) feature
      if attr.type == 'temp'
        return undefined
      
      #Check valid date
      attrDate = new Date attr.date
      attrDate.setHours 0,0,0
      
      fromDate = $('#view-datepicker-from').datepicker().datepicker 'getDate'
      fromDate.setHours 0,0,0
      
      toDate = $('#view-datepicker-to').datepicker().datepicker 'getDate'
      toDate.setHours 0,0,0
      
      if attrDate < fromDate || attrDate > toDate
        'none'
      else if attr.type == 'complaint'
        #Handle complaint, match radiobuttons with feature data
        if $('#vc_all').prop 'checked'
          undefined 
        else if ($('#vc1').prop 'checked') && attr.data['c1']
          undefined
        else if ($('#vc2').prop 'checked') && attr.data['c2']
          undefined
        else if ($('#vc3').prop 'checked') && attr.data['c3']
          undefined
        else
          'none'
      else
        #Handle analysis, match radiobuttons with feature data
        if $('#va_all').prop 'checked'
          undefined 
        else if ($('#va1').prop 'checked') && attr.data['a1']
          undefined
        else if ($('#va2').prop 'checked') && attr.data['a2']
          undefined
        else
          'none'
    getGraphic: (feature) ->
      #Select correct well known graphic based on report type
      attr = feature.attributes
      if attr.type == 'analysis'
        'square'
      else
        'circle'
  
  tpl = OpenLayers.Util.extend undefined, OpenLayers.Feature.Vector.style["default"]
  
  tpl.fillColor = '${getColor}'
  tpl.display = '${getDisplay}'
  tpl.graphicName = '${getGraphic}'
  tpl.strokeWidth = 0.5
  tpl.pointRadius = 5
  tpl.fillOpacity = 0.8
  tpl.strokeColor = '#000000'
  
  #Create a stylemap and pass context to be able to retreive correct color- and displayvalues
  style = new OpenLayers.Style tpl, context:styleContext
  
  markers = new OpenLayers.Layer.Vector 'markers',
    styleMap: new OpenLayers.StyleMap 
      default:style
      
  map.addLayer markers

  selectFeature = new OpenLayers.Control.SelectFeature markers
  map.addControl selectFeature
  selectFeature.activate()

  drawFeature = new OpenLayers.Control.DrawFeature markers, OpenLayers.Handler.Point
  map.addControl drawFeature
  
  reportedFeature = null

  count = 0
  
  #Create datepickers and set default values
  $('#report-datepicker').datepicker()
  $('#view-datepicker-from').datepicker().datepicker 'setDate', new Date '2010-01-01'
  
  toDate = new Date()
  toDate.setHours 23, 59, 59
  $('#view-datepicker-to').datepicker().datepicker 'setDate', toDate
  
  $('#login').button()
    .click ->
      $('#login').fadeOut()
      $('#draw').fadeIn()
      $('#viewpanel').fadeIn()
      
      popup = null
      
      features = []
      for f in svData
        features.push new OpenLayers.Feature.Vector (new OpenLayers.Geometry.Point f.x,f.y), f.attr
      
      markers.addFeatures features
      
      for f in markers.features
        count += 1
        f.fid = count
      
      #Redraw markers when values in datepickers are changed
      $('#view-datepicker-from').change (e) ->
        markers.redraw()
      
      $('#view-datepicker-to').change (e) ->
        markers.redraw()
      
      #Logic to uncheck radios viewpanel when checkbox "Visa alla" is checked. Also redraws markers when needed
      $('input[type=checkbox][name=viewtype]').change (e) ->
      	if $(this).prop('value') == 'complaint'
      	  if $(this).prop('checked')
      	    $('#view-complaint').find('input[type=radio][name=complainttype]').prop 'checked', false
        else
          if $(this).prop('checked')
            $('#view-analysis').find('input[type=radio][name=view-analysistype]').prop 'checked', false
        markers.redraw()
      
      #Logic to uncheck checkbox "Visa alla" (complaints) when radios are checked.
      $('input[type=radio][name=complainttype]').change (e) ->
        $('input[type=checkbox][name=viewtype][value=complaint]').prop 'checked', false
        markers.redraw()
        
      #Logic to uncheck checkbox "Visa alla" (analysis) when radios are checked.
      $('input[type=radio][name=view-analysistype]').change (e) ->
        $('input[type=checkbox][name=viewtype][value=analysis]').prop 'checked', false
        markers.redraw()
      
      #Logic to disable fields and labels in the reportpanel
      $('input[type=radio][name=reporttype]').change (e) ->
      	if $(this).prop('value') is 'complaint'
          $('#report-complaint').find('input[type=checkbox]').prop 'disabled', ''
          $('#report-complaint').find('label').removeClass 'disabled'
          $('#report-analysis').find('input[type=radio][name=analysistype]').prop 'disabled', 'disabled'
          $('#report-analysis').find('label').addClass 'disabled'
          $('#report-analysis').find('input[type=radio][name=analysistype]').prop 'checked', ''
        else
          $('#report-analysis').find('input[type=radio][name=analysistype]').prop 'disabled', ''
          $('#report-analysis').find('label').removeClass 'disabled'
          $('#report-complaint').find('input[type=checkbox]').prop 'disabled', 'disabled'
          $('#report-complaint').find('label').addClass 'disabled'
          $('#report-complaint').find('input[type=checkbox]').prop 'checked', ''
      
      $('#draw').button(
        icons: { primary: "ui-icon-pencil" }
      ).click (e) ->
        $(this).button(
        	disabled:true
        )
        drawFeature.activate()
        $('#report-datepicker').datepicker 'setDate', new Date
        
      
      $('#save').button(
      	icons: { primary: "ui-icon-check" }
      ).click ->
      	$('#reportpanel').fadeOut()
      	$('#draw').button(
      		disabled:false
      	)
      	
      	attributes = reportedFeature.attributes
      	attributes.type = $('input[type=radio][name=reporttype]:checked').prop 'value'
      	
      	reportDate = $('#report-datepicker').datepicker('getDate')
      	attributes.date = $.datepicker.formatDate 'yy-mm-dd', reportDate
      	attributes.data = {}
      	
      	if attributes.type is 'complaint'
      	  cbs = $('#report-complaint').find 'input[type=checkbox]'
      	  for cb in cbs
      	    attributes.data[$(cb).prop 'id'] = $(cb).prop 'checked'
      	else
          radios = $('#report-analysis').find 'input[type=radio][name=analysistype]'
          for radio in radios
            attributes.data[$(radio).prop 'id'] = $(radio).prop 'checked'
      	
      	reportedFeature = null
      	markers.redraw()
      	
      $('#cancel').button(
      	icons: { primary: "ui-icon-circle-close" }
      ).click ->
      	$('#reportpanel').fadeOut()
      	$('#draw').button(
      		disabled:false
      	)
      	markers.destroyFeatures([reportedFeature])
      
      markers.events.register 'beforefeatureadded', null, (e) ->
        panel = $ '#reportpanel'
        
        panel.find('input[type=radio][name=analysistype]').prop 'checked', ''
        panel.find('input[type=checkbox]').prop 'checked', ''
        
        panel.fadeIn()

        drawFeature.deactivate()
        count += 1
        e.feature.fid = count
        e.feature.attributes.type = 'temp'
        reportedFeature = e.feature
        
      markers.events.register 'featureselected', null, (e) ->
        if popup?
          map.removePopup popup
        
        attr = e.feature.attributes
        

        html = '<div class="popup">'
        html +=   '<h3>' + labelMap[attr.type]  + ', ' + attr.date + '</h3>'
        for key,value of attr.data
          html += '<p>'
          if value
            html += '<span class="ui-icon ui-icon-check" style="display:inline-block"></span>'
          else
            html += '<span class="ui-icon ui-icon-minus" style="display:inline-block"></span>'
          
          html += '<span class="result-label">' + labelMap[key] + '</span>'
          html += '</p>'
                  
        popup = new OpenLayers.Popup 'featureinfo', (new OpenLayers.LonLat e.feature.geometry.x, e.feature.geometry.y), (new OpenLayers.Size 200, 150), html, false
        map.addPopup popup
        
      markers.events.register 'featureunselected', null, (e) ->
        if popup?
          map.removePopup popup
          
      markers.events.register 'beforefeatureselected', null, (e) ->
        if e.feature.attributes.type == 'temp'
          false
