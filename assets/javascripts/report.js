$(function() {
  $('#report-form').submit(function() {
    var place = $('select[name="place_id"] option:selected', this).text();
    var character = $('select[name="character_id"] option:selected', this).text();
    var status = place + ' で ' + character + ' に会ったよ！';
    var width = 575;
    var height = 400;
    var left = ($(window).width() - width) / 2;
    var top = ($(window).height() - height) / 2;
    window.open(
      'https://twitter.com/share?via=puro_greeting&' + [
        'text=' + encodeURIComponent(status),
        'url=',
        'hashtags=' + encodeURIComponent('ピューログリ')
      ].join('&'),
      'twitter',
      [
        'status=1',
        'width=' + width,
        'height=' + height,
        'left=' + left,
        'top=' + top
      ].join(',')
    );
    return false;
  });
});
