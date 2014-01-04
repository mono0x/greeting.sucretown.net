$(function() {
  if ($('.greeting-category').size() === 0) {
    return;
  }

  var time = Math.floor(+new Date() / 600) * 600;

  var update = function() {
    $('.greeting-group').each(function() {
      var element = $(this);
      var start = new Date(element.data('start-at'));
      var end = new Date(element.data('end-at'));
      if (time < start && !element.hasClass('greeting-category-before-the-start')) {
        $('.greeting-category-before-the-start .greetings').append(this);
        element.find('.panel').attr('class', 'panel panel-info');
      }
      else if (time >= start && time < end && !element.hasClass('greeting-category-in-session')) {
        $('.greeting-category-in-session .greetings').append(this);
        element.find('.panel').attr('class', 'panel panel-primary');
      }
      else if (time > end && !element.hasClass('greeting-category-after-th-end')) {
        $('.greeting-category-after-the-end .greetings').append(this);
        element.find('.panel').attr('class', 'panel panel-success');
      }
    });

    $('.greeting-category').each(function() {
      var element = $(this);
      var greetings = element.find('.greetings');
      if (greetings.children().size() > 0) {
        element.removeClass('greeting-category-empty');
      }
      else {
        element.addClass('greeting-category-empty');
      }
    });
  };

  update();

  setInterval(function() {
    var next = +new Date();
    if (next - time >= 60000) {
      time = Math.floor(next / 60000) * 60000;
      update();
    }
  }, 1000);
});
