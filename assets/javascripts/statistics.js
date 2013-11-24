$(function() {
  if ($('.chart').size() === 0) {
    return;
  }

  var defaultOptions = {
    chartArea: { top: 0, height: '100%' },
    hAxis: {
      minValue: 0
    },
    legend: { position: 'none' }
  };

  var registerChart = function(element, type) {
    var data = $(element).data('chart');
    var options = $.extend(true, defaultOptions, $(element).data('options') || {});
    var table = new google.visualization.DataTable();
    var chart = new google.visualization[type](element);

    $.each(data.columns, function() {
      table.addColumn(this.type, this.name);
    });
    table.addRows(data.rows);

    $(window).resize(function() {
      chart.draw(table, options);
    });

    chart.draw(table, options);
  };

  var registerCharts = function() {
    $('.chart-bar').each(function() { registerChart(this, 'BarChart'); });
    $('.chart-pie').each(function() { registerChart(this, 'PieChart'); });
  };

  window.onGoogleApiReady = function() {
    delete window.onGoogleApiReady;
    google.load('visualization', '1.0', { packages: [ 'corechart' ], callback: registerCharts });
  };

  $.ajax('https://www.google.com/jsapi', {
    cache: true,
    dataType: 'jsonp',
    jsonp: 'callback',
    jsonpCallback: 'onGoogleApiReady'
  });
});
