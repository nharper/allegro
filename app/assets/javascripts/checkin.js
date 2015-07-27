/* KeyboardListener class. Very simple - listens for all keystrokes, and posts
 * characters from them to callback one line at a time.
 * |callback| will be called with 1 argument of type string, and its return
 * value will be ignored.
 */
function KeyboardListener(callback) {
  this.buffer = '';
  document.addEventListener('keypress', function(e) {
    var code = e.keyCode;
    // 13 is CR, 10 is LF (or NL); recognize either as 'Enter'
    if (code == 13 || code == 10) {
      callback(this.buffer);
      this.buffer = '';
      return;
    }
    this.buffer += String.fromCharCode(code);
  }.bind(this));
}

function Numpad(root, enter_callback) {
  this.root_ = root;
  this.callback_ = enter_callback;
  this.value_ = '';
  this.display_dom_node_ = root.querySelector("#numpad-input");

  for (var i = 0; i < 10; i++) {
    var key = this.root_.querySelector("#n" + i);
    key.addEventListener('click', function(i) {
      this.value_ += i;
      this.updateDisplay();
    }.bind(this, i));
  }
  this.root_.querySelector("#delete").addEventListener('click', function(e) {
    this.value_ = this.value_.slice(0, -1);
    this.updateDisplay();
  }.bind(this));
  this.root_.querySelector("#enter").addEventListener('click', function(e) {
    this.callback_(this.value_);
    this.value_ = '';
    this.updateDisplay();
  }.bind(this));

  this.updateDisplay = function() {
    this.display_dom_node_.innerHTML = this.value_ ? this.value_ : "&nbsp;";
  };
};

/* Performer class
 */
function Performer(name, cn, section) {
  this.name_ = name;
  this.cn_ = cn;
  this.section_ = section;

  this.name = function() { return this.name_; };
  this.chorus_number = function() { return this.cn_; };
  this.section = function() {
    var section = "";
    if (this.cn_) {
      section += this.cn_;
    }
    if (this.section_) {
      if (section) {
        section += " ";
      }
      section += this.section_;
    }
    return section;
  };

}

function PerformerStore() {
  this.table_ = {
    '03437124': new Performer('Brad Gibson', 291),
    '03445828': new Performer('David Wallace', 243),
    '03454788': new Performer('Gregory Sandritter', 213),
    '07342500': new Performer('Jeff Ford', 131),
    '07347364': new Performer('Jimmy White', 424),
    '07347620': new Performer('Kevin Jones', 248),
    '11405380': new Performer('Kevin Koerner', 138),
    '11464004': new Performer('Kim Boyd', 327),
    '11464260': new Performer('Kyle Fowler', 294),
    '13823648': new Performer('Logan Ahlgren', 214),
    '13850288': new Performer('Melvin Fujikawa', 397),
    '14035216': new Performer('Michael Tate', 226),
    '14214960': new Performer('Peter Hartikka', 420),
    '14258064': new Performer('Phillip Calvin', 310),
    '16956068': new Performer('Ross Woodall', 210),
    '17150692': new Performer('Scott Mills', 175),
    '17151204': new Performer('Steve Gallagher', 125),
    '23747876': new Performer('Steven Harvey', 415),
    '23748900': new Performer('Tony McIntosh', 110),
    '23750180': new Performer('William Healey', 193),
  };

  this.lookupPerformer = function(id) {
    var matches = id.match(/%(.*)\?/);
    if (matches) {
      id = matches[1];
    }
    return this.table_[id];
  }

  this.lookupByChorusNumber = function(num) {
    for (var id in this.table_) {
      var performer = this.table_[id];
      if (performer.chorus_number() == num) {
        return performer;
      }
    }
  }
}

function performer_card_from_checkin(performer, time) {
  var name = "Card not recognized";
  var section = "";
  if (performer != null) {
    name = performer.name();
    section = performer.section();
  }
  var div = document.createElement('div');
  div.setAttribute('class', 'card');

  var time_span = document.createElement('span');
  time_span.setAttribute('class', 'time');
  time_span.appendChild(document.createTextNode(format_time(time)));
  div.appendChild(time_span);

  var performer_div = document.createElement('div');
  performer_div.setAttribute('class', 'performer');
  var img = document.createElement('img');
  img.setAttribute('class', 'pic');
  performer_div.appendChild(img);
  var name_span = document.createElement('span');
  name_span.setAttribute('class', 'name');
  name_span.appendChild(document.createTextNode(name));
  performer_div.appendChild(name_span);
  performer_div.appendChild(document.createElement('br'));
  var section_span = document.createElement('span');
  section_span.setAttribute('class', 'section');
  section_span.appendChild(document.createTextNode(section));
  performer_div.appendChild(section_span);

  div.appendChild(performer_div);
  return div;
}

function format_time(time) {
  var h = time.getHours();
  var m = time.getMinutes();
  var pm = h > 12;
  h = h % 12;
  m = m < 10 ? "0" + m : m;
  return h + ":" + m + (pm ? " PM" : " AM");
}

function addCheckin(performer, time) {
  var card = performer_card_from_checkin(performer, time);
  var container = document.getElementById('checkin-list');
  if (container.firstChild) {
    container.insertBefore(document.createElement('hr'), container.firstChild);
    container.insertBefore(card, container.firstChild);
  } else {
    container.appendChild(card);
  }
}

function runCheckin() {
  var store = new PerformerStore();
  var k = new KeyboardListener(function(str) {
    var performer = store.lookupPerformer(str);
    addCheckin(performer, new Date());
  });
  var numpad = new Numpad(document.getElementById('numpad'), function(str) {
    var performer = store.lookupByChorusNumber(str);
    addCheckin(performer, new Date());
  });

  displayTime();
  setInterval(displayTime, 5000);
}

function displayTime() {
  var time = document.getElementById('current-time');
  while (time.lastChild) {
    time.removeChild(time.lastChild);
  }
  time.appendChild(document.createTextNode(format_time(new Date())));
}
