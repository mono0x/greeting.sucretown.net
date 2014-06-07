$(function() {
  if ($('.greeting-category').size() === 0) {
    return;
  }

  var updateTab = function(hash) {
    var isTimetable = (hash.indexOf('#timetable/') === 0);
    var isCharacter = (hash.indexOf('#character/') === 0);

    if (!isTimetable && !isCharacter) {
      isTimetable = true;
    }

    $('#timetable').toggle(isTimetable);
    $('#timetable-tab').toggleClass('active', isTimetable);
    $('#character').toggle(isCharacter);
    $('#character-tab').toggleClass('active', isCharacter);
  };

  var hashchange = function() {
    updateTab(location.hash);
  };

  $(window).on('hashchange', hashchange).triggerHandler('hashchange');

  $('#timetable, #character').find(' a[href^="#"]').on('click', function() {
    var hash = $(this).attr('href');

    updateTab(hash);

    $(window).off('hashchange', hashchange);
    location.hash = hash;
    $(window).on('hashchange', hashchange);

    var target = $('*[name="' + decodeURI(hash.substring(1)) + '"]');
    if (target.size() > 0) {
      $.scrollTo(target);
    }
    return false;
  });

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
          $('.greeting-category-before-the-start .greetings').append(this);
          element.find('.panel').attr('class', 'panel panel-info');
        }
        else if (time >= start && time < end && !category.hasClass('greeting-category-in-session')) {
          $('.greeting-category-in-session .greetings').append(this);
          element.find('.panel').attr('class', 'panel panel-primary');
        }
        else if (time > end && !category.hasClass('greeting-category-after-the-end')) {
          $('.greeting-category-after-the-end .greetings').append(this);
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
