$(function() {
  if (window.DATA === undefined || DATA.type != 'schedule') {
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

  Vue.filter('to_time', function(value) {
    return moment(value).format('HH:mm');
  });

  var groupGreetings = function(greetings) {
    var table = {};
    _.each(greetings, function(greeting) {
      if (!(greeting.end_at in table)) {
        table[greeting.end_at] = {};
      }
      if (!(greeting.start_at in table[greeting.end_at])) {
        table[greeting.end_at][greeting.start_at] = [];
      }
      table[greeting.end_at][greeting.start_at].push(greeting);
    });

    var result = [];
    _.chain(table).keys().each(function(end_at) {
      _.chain(table[end_at]).keys().each(function(start_at) {
        result.push({
          start_at: start_at,
          end_at: end_at,
          greetings: table[end_at][start_at]
        });
      });
    });
    return result;
  };

  var vm = new Vue({
    el: '#contents',
    data: {
      rawGreetings: DATA.greetings,
      epoch: +new Date()
    },
    created: function() {
      setInterval(function() {
        if (moment().format('YYYY-MM-DD') == DATA.date) {
          $.ajax({
            url: '/api/schedule/' + moment(DATA.date).format('YYYY/MM/DD') + '/',
            dataType: 'json'
          }).done(function(data) {
            vm.$set('rawGreetings', data);
          });
        }
      }, 5 * 60 * 1000);

      setInterval(function() {
        var date = new Date();
        date.setMinutes(Math.floor(date.getMinutes() / 5) * 5);
        if (moment(date).format('YYYY-MM-DD') == DATA.date) {
          vm.$set('epoch', +date);
        }
      }, 1000);
    },
    computed: {
      groupedGreetingsDeleted: function() {
        var epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, function(greeting) {
          return greeting.deleted;
        }));
      },
      groupedGreetingsBeforeTheStart: function() {
        var epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, function(greeting) {
          return !greeting.deleted && epoch < (+new Date(greeting.start_at));
        }));
      },
      groupedGreetingsInSession: function() {
        var epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, function(greeting) {
          return !greeting.deleted && epoch >= (+new Date(greeting.start_at)) && epoch <= (+new Date(greeting.end_at));
        }));
      },
      groupedGreetingsAfterTheEnd: function() {
        var epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, function(greeting) {
          return !greeting.deleted && epoch > (+new Date(greeting.end_at));
        }));
      },
      groupedGreetingsByCharacter: function() {
        var grouped = {};
        _.chain(this.rawGreetings).filter(function(greeting) {
          return !greeting.deleted;
        }).each(function(greeting) {
          _.each(greeting.characters, function(character) {
            if (!(character.name in grouped)) {
              grouped[character.name] = [];
            }
            grouped[character.name].push(greeting);
          });
        });

        return _.chain(grouped).pairs().map(function(pair) {
          return {
            character: _.find(pair[1][0].characters, function(character) {
              return character.name == pair[0];
            }),
            greetings: pair[1]
          };
        }).value();
      }
    }
  });
});
