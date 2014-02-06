// Generated by CoffeeScript 1.6.3
(function() {
  var Axis, ECcnt, ECs, Q, QC, QcircuitGrid, Qcircuit_black_dot, Qcircuit_component, Qcircuit_gate, Qcircuit_label, Qcircuit_line, Qcircuit_measure, Qcircuit_measureD, Qcircuit_measuretab, Qcircuit_meter, Qcircuit_multigate, Qcircuit_qswap, Qcircuit_target, Qcircuit_white_dot, Qcircuit_wire, QueueEvent, X, Y, center, click_event, clog, cols, dashed_box, draw, drawer, get_cur_rel_pos, insert_tab, locate_mouse, mk_table, rows, sz_cfg;

  cols = 8;

  rows = 6;

  draw = SVG('drawing').size(cols * 60, rows * 60);

  clog = console.log;

  ECs = $("#ECs tbody");

  ECcnt = 0;

  Axis = (function() {
    function Axis(_default, cnt) {
      var i, _i;
      this["default"] = _default;
      this.dx = [0];
      for (i = _i = 1; 1 <= cnt ? _i <= cnt : _i >= cnt; i = 1 <= cnt ? ++_i : --_i) {
        this.dx.push(this["default"]);
      }
      this.sum = function(x, y) {
        return x + y;
      };
      this.upd_xs();
    }

    Axis.prototype.upd_xs = function() {
      var cnt, i, x, _i, _j, _len, _ref, _ref1;
      this.last = 0;
      this.xs = [];
      this.rep = [];
      cnt = 0;
      _ref = this.dx;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        for (x = _j = 0, _ref1 = i - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          this.rep.push(cnt);
        }
        this.last += i;
        this.xs.push(this.last);
        cnt += 1;
      }
      return clog("xs: " + this.xs);
    };

    Axis.prototype.set_default = function(_default) {
      this["default"] = _default;
    };

    Axis.prototype.set = function(col, width) {
      return this.dx[col] = width;
    };

    Axis.prototype.get = function(col) {
      return this.dx[col];
    };

    Axis.prototype.left = function(x) {
      if (x > this.xs.length) {
        x = this.xs.length;
      }
      return this.xs[x - 1];
    };

    Axis.prototype.right = function(x) {
      if (x >= this.xs.length) {
        return this.last;
      }
      return this.xs[x];
    };

    Axis.prototype.center = function(x) {
      return this.dx[x] / 2 + this.xs[x - 1];
    };

    Axis.prototype.locate = function(x) {
      if (x >= this.last) {
        return this.xs.length;
      }
      return this.rep[x];
    };

    return Axis;

  })();

  sz_cfg = {
    'circle': 12,
    'gate': 40,
    'target': 30,
    'qswap': 5,
    'classical-wire': 8,
    'meter': 50
  };

  X = new Axis(60, rows);

  Y = new Axis(60, cols);

  center = function(x, y) {
    return [X.center(x), Y.center(y)];
  };

  insert_tab = function(elem, id, type, args) {
    var ret, tab_id;
    clog("insert: " + type + " " + args);
    tab_id = "EC" + id;
    ECs.append("<tr id='" + tab_id + "'><td>" + id + "</td><td>" + type + "</td><td>" + args + "</td><td><button class='btn btn-primary' onclick='remove_elem(" + id + ")'>Delete</button></td></tr>");
    return ret = $("#" + tab_id).click(function(event) {
      var color, dom;
      dom = elem.dom;
      color = '';
      if (dom.flagged) {
        color = 'black';
        dom.flagged = false;
      } else {
        color = 'red';
        dom.flagged = true;
      }
      return dom.each(function(_) {
        return this.stroke({
          color: color
        });
      });
    });
  };

  Qcircuit_black_dot = (function() {
    function Qcircuit_black_dot(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'black-dot';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_black_dot.prototype.draw = function(svg) {
      var rad, x2c, xc, y2c, yc, _ref, _ref1;
      rad = sz_cfg['circle'] / 2;
      _ref = center(this.x1, this.y1), xc = _ref[0], yc = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      this.dom = svg.group();
      svg.line(yc, xc, y2c, x2c).addTo(this.dom).stroke({
        width: 1
      });
      svg.circle(rad * 2).addTo(this.dom).move(yc - rad, xc - rad);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "black-dot", "" + this.x1 + " " + this.y1 + " " + this.x2 + " " + this.y2);
      }
    };

    Qcircuit_black_dot.prototype.apply = function(map) {
      return map[this.x1][this.y1] += "\\ctrl{" + (this.x2 - this.x1) + "}";
    };

    return Qcircuit_black_dot;

  })();

  Qcircuit_white_dot = (function() {
    function Qcircuit_white_dot(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'white-dot';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_white_dot.prototype.draw = function(svg) {
      var rad, x2c, xc, y2c, yc, _ref, _ref1;
      rad = sz_cfg['circle'] / 2;
      _ref = center(this.x1, this.y1), xc = _ref[0], yc = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      this.dom = svg.group();
      svg.line(yc, xc, y2c, x2c).addTo(this.dom).stroke({
        width: 1
      });
      svg.circle(rad * 2).addTo(this.dom).move(yc - rad, xc - rad).attr({
        'stroke-width': 2,
        'fill': 'white',
        'fill-opacity': 1
      });
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "white-dot", "" + this.x1 + " " + this.y1 + " " + this.x2 + " " + this.y2);
      }
    };

    Qcircuit_white_dot.prototype.apply = function(map) {
      return map[this.x1][this.y1] += "\\ctrlo{" + (this.x2 - this.x1) + "} ";
    };

    return Qcircuit_white_dot;

  })();

  Qcircuit_target = (function() {
    function Qcircuit_target(x, y) {
      this.x = x;
      this.y = y;
      this.type = 'target';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_target.prototype.draw = function(svg) {
      var rad, xc, yc, _ref;
      rad = sz_cfg['target'] / 2;
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      this.dom = svg.group();
      svg.circle(rad * 2).addTo(this.dom).move(yc - rad, xc - rad).attr({
        'stroke-width': 2,
        'fill-opacity': 0
      });
      svg.line(yc - rad, xc, yc + rad, xc).addTo(this.dom).stroke({
        width: 1
      });
      svg.line(yc, xc - rad, yc, xc + rad).addTo(this.dom).stroke({
        width: 1
      });
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "target", "" + this.x + " " + this.y);
      }
    };

    Qcircuit_target.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\targ ";
    };

    return Qcircuit_target;

  })();

  Qcircuit_line = (function() {
    function Qcircuit_line(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'line';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_line.prototype.draw = function(svg) {
      var x1c, x2c, y1c, y2c, _ref, _ref1;
      _ref = center(this.x1, this.y1), x1c = _ref[0], y1c = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      this.dom = svg.group();
      svg.line(y1c, x1c, y2c, x2c).addTo(this.dom).stroke({
        width: 1
      });
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "line", "" + this.x1 + " " + this.y1 + " " + this.x2 + " " + this.y2);
      }
    };

    Qcircuit_line.prototype.apply = function(map) {
      var x, x1, x2, y, y1, y2, _i, _ref, _ref1, _results;
      _ref = this.x1 < this.x2 ? [this.x1, this.x2] : [this.x2, this.x1], x1 = _ref[0], x2 = _ref[1];
      _ref1 = this.y1 < this.y2 ? [this.y1, this.y2] : [this.y2, this.y1], y1 = _ref1[0], y2 = _ref1[1];
      _results = [];
      for (x = _i = x1; x1 <= x2 ? _i <= x2 : _i >= x2; x = x1 <= x2 ? ++_i : --_i) {
        _results.push((function() {
          var _j, _results1;
          _results1 = [];
          for (y = _j = y1; y1 <= y2 ? _j <= y2 : _j >= y2; y = y1 <= y2 ? ++_j : --_j) {
            _results1.push(map[x][y] += "\\qw ");
          }
          return _results1;
        })());
      }
      return _results;
    };

    return Qcircuit_line;

  })();

  Qcircuit_qswap = (function() {
    function Qcircuit_qswap(x, y) {
      this.x = x;
      this.y = y;
      this.type = 'qswap';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_qswap.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['qswap'];
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      this.dom = svg.group();
      svg.line(yc - d, xc - d, yc + d, xc + d).addTo(this.dom).stroke({
        width: 3
      });
      svg.line(yc + d, xc - d, yc - d, xc + d).addTo(this.dom).stroke({
        width: 3
      });
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "qswap", "" + this.x + " " + this.y);
      }
    };

    Qcircuit_qswap.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\qswap ";
    };

    return Qcircuit_qswap;

  })();

  Qcircuit_gate = (function() {
    function Qcircuit_gate(x, y, txt) {
      this.x = x;
      this.y = y;
      this.txt = txt;
      this.type = 'gate';
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_gate.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['gate'] / 2;
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      this.dom = svg.group();
      svg.rect(d * 2, d * 2).move(yc - d, xc - d).addTo(this.dom).attr({
        'stroke': 'black',
        'fill': 'white',
        'fill-opacity': 1
      });
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d, d).addTo(this.dom).move(yc - d / 2, xc - d / 2);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "gate", "" + this.x + " " + this.y + " " + this.txt);
      }
    };

    Qcircuit_gate.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\gate{" + this.txt + "}";
    };

    return Qcircuit_gate;

  })();

  Qcircuit_multigate = (function() {
    function Qcircuit_multigate(c, x, y, txt) {
      var _ref;
      this.c = c;
      this.x = x;
      this.y = y;
      this.txt = txt;
      ECcnt += 1;
      this.cid = "" + ECcnt;
      if (this.x > this.y) {
        _ref = [this.y, this.x], this.x = _ref[0], this.y = _ref[1];
      }
      this.type = 'multigate';
    }

    Qcircuit_multigate.prototype.draw = function(svg) {
      var d, lc, uc, xc;
      d = sz_cfg['gate'] / 2;
      xc = Y.center(this.c);
      lc = X.center(this.y);
      uc = X.center(this.x);
      this.dom = svg.group();
      svg.rect(d * 2, d * 2 + lc - uc).move(xc - d, uc - d).addTo(this.dom).attr({
        'stroke': 'black',
        'fill': 'white',
        'fill-opacity': 1
      });
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d, d).addTo(this.dom).move(xc - 10, (lc + uc) / 2 - 10);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "multigate", "" + this.c + " " + this.x + " " + this.y + " " + this.txt);
      }
    };

    Qcircuit_multigate.prototype.apply = function(map) {
      var d, _i, _ref, _ref1, _results;
      map[this.x][this.c] += "\\multigate{" + (this.y - this.x) + "}{" + this.txt + "}";
      _results = [];
      for (d = _i = _ref = this.x + 1, _ref1 = this.y; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; d = _ref <= _ref1 ? ++_i : --_i) {
        _results.push(map[d][this.c] += "\\ghost{" + this.txt + "}");
      }
      return _results;
    };

    return Qcircuit_multigate;

  })();

  Qcircuit_label = (function() {
    function Qcircuit_label(x, y, io, dirac, txt) {
      this.x = x;
      this.y = y;
      this.io = io;
      this.dirac = dirac;
      this.txt = txt;
      this.type = "label";
      ECcnt += 1;
      this.cid = "" + ECcnt;
      if (this.dirac === 'ket') {
        this.tex = "\\left\\vert{" + this.txt + "}\\right\\rangle";
      } else {
        this.tex = "\\left\\langle{" + this.txt + "}\\right\\vert";
      }
    }

    Qcircuit_label.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['gate'] / 2;
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      this.dom = svg.group();
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.tex, d * 2, d * 2).addTo(this.dom).move(yc - d, xc - d);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "label", "" + this.x + " " + this.y + " " + this.io + " " + this.dirac + " " + this.txt);
      }
    };

    Qcircuit_label.prototype.apply = function(map) {
      var io_tex;
      io_tex = this.io === "i" ? "lstick" : "rstick";
      return map[this.x][this.y] += "\\" + io_tex + "{\\" + this.dirac + "{" + this.txt + "}}";
    };

    return Qcircuit_label;

  })();

  Qcircuit_wire = (function() {
    function Qcircuit_wire(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = "wire";
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_wire.prototype.draw = function(svg) {
      var d, x1c, x2c, y1c, y2c, _ref, _ref1;
      d = sz_cfg['classical-wire'] / 2;
      this.dom = svg.group();
      _ref = center(this.x1, this.y1), x1c = _ref[0], y1c = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      if (this.x1 === this.x2) {
        svg.line(y1c, x1c - d, y2c, x1c - d).addTo(this.dom).stroke({
          width: 2
        });
        svg.line(y1c, x1c + d, y2c, x1c + d).addTo(this.dom).stroke({
          width: 2
        });
      } else {
        svg.line(y1c - d, x1c, y2c - d, x2c).addTo(this.dom).stroke({
          width: 2
        });
        svg.line(y1c + d, x1c, y2c + d, x2c).addTo(this.dom).stroke({
          width: 2
        });
      }
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "wire", "" + this.x1 + " " + this.y1 + " " + this.x2 + " " + this.y2);
      }
    };

    Qcircuit_wire.prototype.apply = function(map) {
      var lx, ly, rx, ry, _ref, _ref1;
      if (this.x1 === this.x2) {
        _ref = this.y1 < this.y2 ? [this.y1, this.y2] : [this.y2, this.y1], ly = _ref[0], ry = _ref[1];
        return map[this.x1][ly] += "\\cw[" + (ry - ly) + "] ";
      } else {
        _ref1 = this.x1 < this.x2 ? [this.x1, this.x2] : [this.x2, this.x1], lx = _ref1[0], rx = _ref1[1];
        return map[lx][this.y1] += "\\cwx[" + (rx - lx) + "] ";
      }
    };

    return Qcircuit_wire;

  })();

  Qcircuit_meter = (function() {
    function Qcircuit_meter(x, y) {
      this.x = x;
      this.y = y;
      this.type = "meter";
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_meter.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['meter'];
      this.dom = svg.group();
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.rect(40, 32).addTo(this.dom).move(yc - 20, xc - 16).attr({
        "fill": 'white',
        "fill-opacity": 1,
        "stroke": "black",
        "stroke-width": 2
      });
      svg.path("").addTo(this.dom).attr({
        "stroke": "black",
        "stroke-width": 2,
        "fill": "white",
        "fill-opacity": 0,
        "d": "M " + (yc + 15) + " " + (xc + 8) + " A 20 20 90 0 0 " + (yc - 15) + " " + (xc + 8)
      });
      svg.line(yc, xc + 10, yc + 10, xc - 10).addTo(this.dom).stroke({
        width: 2
      });
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "meter", "" + this.x + " " + this.y);
      }
    };

    Qcircuit_meter.prototype.apply = function(map) {
      return map[this.x][this.y] += '\\meter ';
    };

    return Qcircuit_meter;

  })();

  Qcircuit_measure = (function() {
    function Qcircuit_measure(x, y, txt) {
      this.x = x;
      this.y = y;
      this.txt = txt;
      this.type = "measure";
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_measure.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = 12;
      this.dom = svg.group();
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.path("").addTo(this.dom).attr({
        "stroke": "black",
        "stroke-width": 2,
        "fill": "white",
        "fill-opacity": 0,
        "d": "M " + (yc - d) + " " + (xc - d) + "                               A " + d + " " + d + " 90 0 0 " + (yc - d) + " " + (xc + d) + "                              L " + (yc + 12) + " " + (xc + d) + "                              A " + d + " " + d + " 90 0 0 " + (yc + d) + " " + (xc - d) + "                              Z"
      });
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d * 2, d * 2).addTo(this.dom).move(yc - d, xc - d);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "measure", "" + this.x + " " + this.y + " " + this.txt);
      }
    };

    Qcircuit_measure.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\measure{@txt}";
    };

    return Qcircuit_measure;

  })();

  Qcircuit_measuretab = (function() {
    function Qcircuit_measuretab(x, y, txt) {
      this.x = x;
      this.y = y;
      this.txt = txt;
      this.type = "measuretab";
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_measuretab.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = 12;
      this.dom = svg.group();
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.polygon("" + (yc - 25) + "," + xc + " " + (yc - 15) + "," + (xc - 20) + " " + (yc + 20) + "," + (xc - 20) + " " + (yc + 20) + "," + (xc + 20) + " " + (yc - 15) + "," + (xc + 20)).addTo(this.dom).attr({
        "stroke": "black",
        "stroke-width": 2,
        "fill": "white"
      });
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d * 2, d * 2).addTo(this.dom).move(yc - d, xc - d);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "measuretab", "" + this.x + " " + this.y + " " + this.txt);
      }
    };

    Qcircuit_measuretab.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\measuretab{@txt} ";
    };

    return Qcircuit_measuretab;

  })();

  Qcircuit_measureD = (function() {
    function Qcircuit_measureD(x, y, txt) {
      this.x = x;
      this.y = y;
      this.txt = txt;
      this.type = "measureD";
      ECcnt += 1;
      this.cid = "" + ECcnt;
    }

    Qcircuit_measureD.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = 12;
      this.dom = svg.group();
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.path("").addTo(this.dom).attr({
        "stroke": "black",
        "stroke-width": 2,
        "fill": "white",
        "fill-opacity": 0,
        "d": "M " + (yc - 12) + " " + (xc - 12) + "                              L " + (yc + 12) + " " + (xc - 12) + "                              A " + 12 + " " + 12 + " 90 0 1 " + (yc + 12) + " " + (xc + 12) + "                              L " + (yc - 12) + " " + (xc + 12) + "                              Z"
      });
      svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d * 2 - 5, d * 2 - 5).addTo(this.dom).move(yc - d + 5, xc - d + 5);
      if (!this.tab) {
        return this.tab = insert_tab(this, this.cid, "measureD", "" + this.x + " " + this.y + " " + this.txt);
      }
    };

    Qcircuit_measureD.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\measureD{@txt} ";
    };

    return Qcircuit_measureD;

  })();

  Qcircuit_component = (function() {
    function Qcircuit_component() {
      this.components = {};
    }

    Qcircuit_component.prototype.redraw = function() {
      var c, id, _ref, _ref1, _ref2, _ref3, _ref4, _results;
      draw.clear();
      _ref = this.components;
      for (id in _ref) {
        c = _ref[id];
        if (c.type === "wire") {
          c.draw(draw);
        }
      }
      _ref1 = this.components;
      for (id in _ref1) {
        c = _ref1[id];
        if ((_ref2 = c.type) !== 'targ' && _ref2 !== 'gate' && _ref2 !== 'multigate' && _ref2 !== 'black-dot' && _ref2 !== 'white-dot' && _ref2 !== 'wire' && _ref2 !== 'meter') {
          c.draw(draw);
        }
      }
      _ref3 = this.components;
      _results = [];
      for (id in _ref3) {
        c = _ref3[id];
        if ((_ref4 = c.type) === 'targ' || _ref4 === 'gate' || _ref4 === 'multigate' || _ref4 === 'black-dot' || _ref4 === 'white-dot' || _ref4 === 'meter') {
          _results.push(c.draw(draw));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Qcircuit_component.prototype.add = function(comp, redraw) {
      if (redraw == null) {
        redraw = true;
      }
      this.components[comp.cid] = comp;
      return this.redraw();
    };

    Qcircuit_component.prototype.ins_row = function(x) {};

    return Qcircuit_component;

  })();

  QC = new Qcircuit_component;

  window.remove_elem = function(id) {
    var obj;
    obj = QC.components["" + id];
    obj.tab.remove();
    delete QC.components["" + id];
    return QC.redraw();
  };

  dashed_box = null;

  locate_mouse = function(x, y) {
    return [X.locate(y), Y.locate(x)];
  };

  QueueEvent = (function() {
    function QueueEvent() {
      this.Q = [];
      this.func = null;
      this.cnt = 0;
    }

    QueueEvent.prototype.push = function(args) {
      clog("push: " + args);
      this.Q.push(args);
      if (this.Q.length >= this.cnt && this.func) {
        this.func(this.Q.slice(0, +(this.cnt - 1) + 1 || 9e9));
        this.Q = [];
        this.func = null;
      }
      return clog("Queue Length " + this.Q.length);
    };

    QueueEvent.prototype.bind = function(func, cnt) {
      this.func = func;
      this.cnt = cnt;
      return this.Q = [];
    };

    return QueueEvent;

  })();

  Q = new QueueEvent;

  drawer = $("#drawing");

  get_cur_rel_pos = function(event) {
    var x, y;
    x = parseInt(event.pageX) - drawer.offset().left;
    y = parseInt(event.pageY) - drawer.offset().top;
    return [x, y];
  };

  click_event = function(event) {
    var x, y, _ref;
    _ref = get_cur_rel_pos(event), x = _ref[0], y = _ref[1];
    return Q.push(locate_mouse(x, y));
  };

  drawer.click(click_event);

  drawer.mousemove(function(event) {
    var Bx, By, X1, X2, Y1, Y2, x, x1, x2, y, y1, y2, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
    _ref = get_cur_rel_pos(event), x = _ref[0], y = _ref[1];
    $("#mouse-position").text("" + x + " " + y);
    if (dashed_box) {
      dashed_box.remove();
    }
    _ref1 = locate_mouse(x, y), Bx = _ref1[0], By = _ref1[1];
    x1 = X.left(Bx);
    x2 = X.right(Bx);
    y1 = Y.left(By);
    y2 = Y.right(By);
    clog("" + Bx + " " + By);
    dashed_box = draw.group();
    _ref2 = [[x1, y1, x2, y1], [x1, y2, x2, y2], [x2, y1, x2, y2], [x1, y1, x1, y2]];
    _results = [];
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      _ref3 = _ref2[_i], X1 = _ref3[0], Y1 = _ref3[1], X2 = _ref3[2], Y2 = _ref3[3];
      _results.push(draw.line(Y1, X1, Y2, X2).addTo(dashed_box).attr({
        'stroke': 'black',
        "stroke-dasharray": [2, 2]
      }));
    }
    return _results;
  });

  drawer.css({
    position: "absolute"
  });

  window.add_black_dot = function() {
    var func;
    func = function(arg) {
      var x1, x2, y1, y2, _ref, _ref1;
      _ref = arg[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = arg[1], x2 = _ref1[0], y2 = _ref1[1];
      if (y1 === y2) {
        return QC.add(new Qcircuit_black_dot(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  window.add_white_dot = function() {
    var func;
    func = function(arg) {
      var x1, x2, y1, y2, _ref, _ref1;
      _ref = arg[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = arg[1], x2 = _ref1[0], y2 = _ref1[1];
      if (y1 === y2) {
        return QC.add(new Qcircuit_white_dot(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  window.add_targ = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_target(x, y));
    };
    return Q.bind(func, 1);
  };

  window.add_qswap = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_qswap(x, y));
    };
    return Q.bind(func, 1);
  };

  window.add_gate = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_gate(x, y, $('#gate').val()));
    };
    return Q.bind(func, 1);
  };

  window.add_meter = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_meter(x, y));
    };
    return Q.bind(func, 1);
  };

  window.add_measure = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_measure(x, y, $('#gate').val()));
    };
    return Q.bind(func, 1);
  };

  window.add_measuretab = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_measuretab(x, y, $('#gate').val()));
    };
    return Q.bind(func, 1);
  };

  window.add_measureD = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new Qcircuit_measureD(x, y, $('#gate').val()));
    };
    return Q.bind(func, 1);
  };

  window.add_multigate = function() {
    var func;
    func = function(arg) {
      var x1, x2, y1, y2, _ref, _ref1;
      _ref = arg[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = arg[1], x2 = _ref1[0], y2 = _ref1[1];
      if (y1 === y2) {
        return QC.add(new Qcircuit_multigate(y1, x1, x2, $('#gate').val()));
      }
    };
    return Q.bind(func, 2);
  };

  window.add_line = function() {
    var func;
    func = function(arg) {
      var x1, x2, y1, y2, _ref, _ref1;
      _ref = arg[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = arg[1], x2 = _ref1[0], y2 = _ref1[1];
      if (y1 === y2 || x1 === x2) {
        return QC.add(new Qcircuit_line(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  window.insert_row = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return Q.ins_row(x);
    };
    return Q.bind(func, 1);
  };

  window.add_label = function() {
    var func;
    func = function(arg) {
      var dirac, io, x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      io = $("#label-io").prop("checked") ? "o" : "i";
      dirac = $("#label-dirac").prop("checked") ? "bra" : "ket";
      return QC.add(new Qcircuit_label(x, y, io, dirac, $('#gate').val()));
    };
    return Q.bind(func, 1);
  };

  window.add_wire = function() {
    var func;
    func = function(arg) {
      var x1, x2, y1, y2, _ref, _ref1;
      _ref = arg[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = arg[1], x2 = _ref1[0], y2 = _ref1[1];
      if (y1 === y2 || x1 === x2) {
        return QC.add(new Qcircuit_wire(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  QcircuitGrid = (function() {
    function QcircuitGrid(rows, cols) {
      var i, j, _i, _j, _ref, _ref1;
      this.rows = rows;
      this.cols = cols;
      this.map = [];
      for (i = _i = 1, _ref = this.rows; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        this.map[i] = [];
        for (j = _j = 1, _ref1 = this.cols; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 1 <= _ref1 ? ++_j : --_j) {
          this.map[i][j] = ' & ';
        }
      }
    }

    QcircuitGrid.prototype.imp_ops = function(components) {
      this.components = components;
    };

    QcircuitGrid.prototype.exp_tex = function() {
      var comp, id, ret, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
      _ref = this.components;
      for (id in _ref) {
        comp = _ref[id];
        if (comp.type !== 'line') {
          comp.apply(this.map);
        }
      }
      _ref1 = this.components;
      for (id in _ref1) {
        comp = _ref1[id];
        if (comp.type === 'line') {
          comp.apply(this.map);
        }
      }
      ret = "\\Qcircuit @C=1em @R=1em { \n";
      for (x = _i = 1, _ref2 = this.rows; 1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; x = 1 <= _ref2 ? ++_i : --_i) {
        for (y = _j = 1, _ref3 = this.cols; 1 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = 1 <= _ref3 ? ++_j : --_j) {
          ret += this.map[x][y];
        }
        ret += "\\\\ \n";
      }
      ret += "}";
      return ret;
    };

    return QcircuitGrid;

  })();

  window.export_to_latex = function() {
    var grid;
    clog("rc: " + rows + " " + cols);
    grid = new QcircuitGrid(rows, cols);
    grid.imp_ops(QC.components);
    return $('#latex-code').text(grid.exp_tex());
  };

  mk_table = function() {
    var elem, h, i, inner, j, rem, s, style, tab, w, _i, _j;
    tab = $("#table");
    rem = 20;
    for (i = _i = 0; 0 <= rows ? _i <= rows : _i >= rows; i = 0 <= rows ? ++_i : --_i) {
      h = i === 0 ? rem : X.get(i);
      s = "<tr height=" + h + "px>";
      for (j = _j = 0; 0 <= cols ? _j <= cols : _j >= cols; j = 0 <= cols ? ++_j : --_j) {
        elem = i === 0 ? "th" : "td";
        style = j === 0 ? 'style="border-right: 2px solid #CCC"' : "";
        w = j === 0 ? rem : Y.get(j);
        inner = (i === 0 && j > 0) || (i > 0 && j === 0) ? i + j : "";
        s += "<" + elem + " width=" + w + "px " + style + "> " + inner + " </" + elem + ">";
      }
      s += '</tr>';
      tab.append(s);
    }
    tab.tableresizer({
      row_border: "2px solid #CCC",
      col_border: "2px solid #CCC"
    });
    return drawer.offset({
      top: tab.offset().top + rem,
      left: tab.offset().left + rem
    });
  };

  mk_table();

  clog('init done');

}).call(this);
