// global vars
var dataGlobal = null;
var color = d3.schemeCategory20;
var currentMonth = null;
var tooltip = d3.select('body')
.append('div')
.attr('class', 'tooltip')
.style('opacity', 0);

// global const
var RADIUS = 30;
var MIN_VERSION = 39;

function initMap(){
  // initializes a leaflet map in the #map element in the dom
  var map = L.map('map').setView([43.7384, 7.4246], 5);
  mapLink =
  '<a href="http://openstreetmap.org">OpenStreetMap</a>';
  L.tileLayer(
    'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; ' + mapLink + ' Contributors',
      maxZoom: 18,
    }
  ).addTo(map);
  map._initPathRoot();
  return map;
}


function updatePieCharts(){
  // fiter only data for the current month
  var filteredData = _.filter(dataGlobal,
    function(singleDate){return singleDate.sd == curMonth;
  })

  // logic that would be in updatePieCharts
  var pies = g.selectAll('.pies').data(filteredData);

  pies.exit().remove();

  // arc helper is per arc / slice of the pie
  function arcHelper(d, i) {
    return d3.arc()
      .innerRadius(0)
      .outerRadius(1000 * (+d.data.prop_city_month))(d, i);
  }

  var pie = d3.pie()
  .sort(null)
  .value(function(d) { return d.prop_cnt_month; })

  // new pie charts
  var new_pies = pies.enter()
  .append('g')
  .on('mouseover', function(d){
    console.log('hover');
    // enable to tooltip for a group
    tooltip.transition()
    .duration(200)
    .style('opacity', .9);
    // build html for tooltip
    var htmlStr = ''
    htmlStr += '<span> <strong>city</strong>: ' + d.city + '</span></br>'
    htmlStr += '<span> <strong>prop_city_month</strong>: ' + d.prop_city_month.toFixed(3) + '</span>'
    htmlStr += '<table><tr><th>appversion</th><th>prop_cnt_month</th></tr>'
    for(var i = 0; i < d.zipped.length; i++){
      appver = d.zipped[i].appversion
      prop_cnt = d.zipped[i].prop_cnt_month.toFixed(3);
      htmlStr +=  '<tr><td>' + appver + '</td><td>' + prop_cnt + '</td></tr>'
    }
    htmlStr += '</table>'

    tooltip.html(htmlStr)
    .style('left', (d3.event.pageX) + 'px')
    .style('top', (d3.event.pageY - 28) + 'px');
  }).on('mouseout', function(d){
    tooltip.transition()
    .duration(500)
    .style('opacity', 0);
  })
  .attr('class','pies');

  // the new pie charts need arcs
  var arcs = new_pies.selectAll('g')
  .data(function(d){return pie(d.zipped) })

  arcs.exit().remove();

  new_arcs = arcs.enter()
  .append('g')
  .attr('class', 'arc')
  .append('path')
  .attr('d', arcHelper)
  .attr('fill',function(d){
    var colorIndex = d.data.appversion - MIN_VERSION;
    return color[colorIndex];
  })

  function zoomHandler(){
    // transform all of the pie charts
    new_pies.attr('transform', function(d){
      return 'translate('+
      map.latLngToLayerPoint(d.LatLng).x +','+
      map.latLngToLayerPoint(d.LatLng).y +')';
    });
    pies.attr('transform', function(d){
      return 'translate('+
      map.latLngToLayerPoint(d.LatLng).x +','+
      map.latLngToLayerPoint(d.LatLng).y +')';
    });

  }

  // perform transform of each <g> tag
  map.on('viewreset', zoomHandler);
  zoomHandler();
}

var map = initMap();
// access the D3 layer
var g = d3.select('#map').select('svg').append('g');

d3.json('static/main_cities_sized.json', function(error, data){
  dataGlobal = data;

  // nest/zip the data for pie charts
  for(var i = 0; i < dataGlobal.length; i++){
    var singleDate = dataGlobal[i]
    singleDate.zipped = []
    for(var j = 0; j < singleDate.appversion.length; j++){
      var obj = {
        'appversion': singleDate.appversion[j],
        'prop_cnt_month':singleDate.prop_cnt_month[j],
        'prop_city_month':singleDate.prop_city_month
      }
      singleDate.zipped.push(obj)
    }
  }

  // initialize a latitude & longitude for the data
  dataGlobal.forEach(function(d){
    d.LatLng = new L.LatLng(
      d.lat,
      d.lng
    )
  });

  // updating pie charts
  curMonth = '2016-08';
  updatePieCharts();
  // curMonth = '2016-09';
  // updatePieCharts();
  // debugger;
  // curMonth = '2016-06';
  // updatePieCharts();
  // deleting pie charts
});

d3.select(".pies").on("mouseover", function(){ console.log("hover");})
