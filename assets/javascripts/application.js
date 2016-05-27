import Vue  from 'vue';
import moment from 'moment';
import $  from 'jquery';
import _ from 'underscore';

import 'jquery.scrollto';
import 'bootstrap-loader/extractStyles';

import '../stylesheets/application.css';

$(function() {
  if (window.DATA === undefined || DATA.type != 'schedule') {
    return;
  }

  let tabs = [
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
  let twitterTab = {
    hash: 'twitter',
    tabElement: $('#twitter-tab'),
    contentElement: $('#twitter')
  };
  if (twitterTab.tabElement.size() !== 0) {
    tabs.push(twitterTab);
  }

  let updateTab = function(hash) {
    let tab = (function() {
      let i, n = tabs.length;
      for (i = 0; i < n; ++i) {
        if (hash.indexOf('#' + tabs[i].hash + '/') === 0) {
          return tabs[i];
        }
      }
    })();
    if (tab === undefined) {
      tab = tabs[0];
    }

    tabs.filter(t => t.hash != tab.hash).forEach(t => {
      t.tabElement.removeClass('active');
      t.contentElement.hide();
    });
    tab.tabElement.addClass('active');
    tab.contentElement.show();
  };

  let hashchange = function() {
    updateTab(location.hash);
  };

  $(window).on('hashchange', hashchange).triggerHandler('hashchange');

  $(document).on('click', 'a[href^="#"]', function() {
    let hash = $(this).attr('href');

    updateTab(hash);

    $(window).off('hashchange', hashchange);
    location.hash = hash;
    $(window).on('hashchange', hashchange);

    let target = $('*[name="' + decodeURI(hash.substring(1)) + '"]');
    if (target.size() > 0) {
      $.scrollTo(target);
    }
    return false;
  });

  Vue.filter('to_time', function(value) {
    return moment(value).format('HH:mm');
  });

  let groupGreetings = function(greetings) {
    let table = {};
    _.each(greetings, greeting => {
      if (!(greeting.end_at in table)) {
        table[greeting.end_at] = {};
      }
      if (!(greeting.start_at in table[greeting.end_at])) {
        table[greeting.end_at][greeting.start_at] = [];
      }
      table[greeting.end_at][greeting.start_at].push(greeting);
    });

    let result = [];
    _.chain(table).keys().each(end_at => {
      _.chain(table[end_at]).keys().each(start_at => {
        result.push({
          start_at: start_at,
          end_at: end_at,
          greetings: table[end_at][start_at]
        });
      });
    });
    return result;
  };

  let vm = new Vue({
    el: '#contents',
    data: {
      rawGreetings: DATA.greetings,
      epoch: +new Date()
    },
    created: function() {
      setInterval(() => {
        if (moment().format('YYYY-MM-DD') == DATA.date) {
          $.ajax({
            url: '/api/schedule/' + moment(DATA.date).format('YYYY/MM/DD') + '/',
            dataType: 'json'
          }).done(data => {
            vm.$set('rawGreetings', data);
          });
        }
      }, 5 * 60 * 1000);

      setInterval(() => {
        let date;
        if (moment(date).format('YYYY-MM-DD') == DATA.date) {
          date = new Date();
          date.setMinutes(Math.floor(date.getMinutes() / 5) * 5);
          date.setSeconds(0);
          date.setMilliseconds(0);
        }
        else {
          date = moment(DATA.date).add(1, 'days').toDate();
        }
        vm.$data.epoch = +date;
      }, 1000);
    },
    computed: {
      groupedGreetingsDeleted: function() {
        let epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, greeting => greeting.deleted));
      },
      groupedGreetingsBeforeTheStart: function() {
        let epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, greeting => {
          return !greeting.deleted && epoch < (+new Date(greeting.start_at));
        }));
      },
      groupedGreetingsInSession: function() {
        let epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, greeting => {
          return !greeting.deleted && epoch >= (+new Date(greeting.start_at)) && epoch < (+new Date(greeting.end_at));
        }));
      },
      groupedGreetingsAfterTheEnd: function() {
        let epoch = this.epoch;

        return groupGreetings(_.filter(this.rawGreetings, greeting => {
          return !greeting.deleted && epoch >= (+new Date(greeting.end_at));
        }));
      },
      groupedGreetingsByCharacter: function() {
        let grouped = {};
        _.chain(this.rawGreetings).filter(greeting => !greeting.deleted).each(greeting => {
          _.each(greeting.characters, character => {
            if (!(character.name in grouped)) {
              grouped[character.name] = [];
            }
            grouped[character.name].push(greeting);
          });
        });

        return _.chain(grouped).pairs().map(pair => {
          return {
            character: _.find(pair[1][0].characters, character => character.name == pair[0]),
            greetings: pair[1]
          };
        }).value();
      }
    }
  });
});

$(function() {
  $('#report-form').submit(function() {
    let place = $('select[name="place_id"] option:selected', this).text();
    let character = $('select[name="character_id"] option:selected', this).text();
    let status = place + ' で ' + character + ' に会ったよ！';
    let width = 575;
    let height = 400;
    let left = ($(window).width() - width) / 2;
    let top = ($(window).height() - height) / 2;
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
