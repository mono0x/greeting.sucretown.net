$(function() {
  if ($('.greeting-category').size() === 0) {
    return;
  }

  var time = Math.floor(+new Date() / 60000) * 60000;

  var update = function() {
    $('.greeting-category').each(function() {
      var category = $(this);
      if (category.hasClass('greeting-category-deleted')) {
        return true; // continue
      }
      category.find('.greeting-group').each(function() {
        var element = $(this);
        var start = new Date(element.data('start-at'));
        var end = new Date(element.data('end-at'));
        if (time < start && !category.hasClass('greeting-category-before-the-start')) {
          category.find('.greetings').append(this);
          element.find('.panel').attr('class', 'panel panel-info');
        }
        else if (time >= start && time < end && !category.hasClass('greeting-category-in-session')) {
          category.find('.greetings').append(this);
          element.find('.panel').attr('class', 'panel panel-primary');
        }
        else if (time > end && !category.hasClass('greeting-category-after-th-end')) {
          category.find('.greetings').append(this);
          element.find('.panel').attr('class', 'panel panel-success');
        }
      });
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
