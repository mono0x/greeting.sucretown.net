$(function() {
  if ($('.greeting-category').size() === 0) {
    return;
  }

  var tabs = [
    {
      hash: 'timetable',
      tabElement: $('#timetable-tab'),
      contentElement: $('#timetable')
    },
    {
      hash: 'character',
      tabElement: $('#character-tab'),
      contentElement: $('#character')
    }
  ];
  var twitterTab = {
    hash: 'twitter',
    tabElement: $('#twitter-tab'),
    contentElement: $('#twitter')
  };
  if (twitterTab.tabElement.size() !== 0) {
    tabs.push(twitterTab);
  }

  var updateTab = function(hash) {
    var tab = (function() {
      var i, n = tabs.length;
      for (i = 0; i < n; ++i) {
        if (hash.indexOf('#' + tabs[i].hash + '/') === 0) {
          return tabs[i];
        }
      }
    })();
    if (tab === undefined) {
      tab = tabs[0];
    }

    tabs.filter(function(t) { return t.hash != tab.hash; }).forEach(function(t) {
      t.tabElement.removeClass('active');
      t.contentElement.hide();
    });
    tab.tabElement.addClass('active');
    tab.contentElement.show();
  };

  var hashchange = function() {
    updateTab(location.hash);
  };

  $(window).on('hashchange', hashchange).triggerHandler('hashchange');

  $(document).on('click', 'a[href^="#"]', function() {
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
});
