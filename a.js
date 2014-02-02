// Generated by CoffeeScript 1.6.3
(function() {
  var Axis, Q, QC, QCircuitGrid, QCircuit_black_dot, QCircuit_component, QCircuit_gate, QCircuit_line, QCircuit_multigate, QCircuit_qswap, QCircuit_target, QCircuit_white_dot, QueueEvent, X, Y, center, click_event, clog, cols, dashed_box, draw, drawer, get_cur_rel_pos, locate_mouse, mk_table, rows, sz_cfg;

  clog = console.log;

  draw = SVG('drawing').size(360, 360);

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
    'qswap': 5
  };

  cols = 6;

  rows = 6;

  X = new Axis(60, rows);

  Y = new Axis(60, cols);

  center = function(x, y) {
    return [X.center(x), Y.center(y)];
  };

  QCircuit_black_dot = (function() {
    function QCircuit_black_dot(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'black-dot';
    }

    QCircuit_black_dot.prototype.draw = function(svg) {
      var rad, x2c, xc, y2c, yc, _ref, _ref1;
      rad = sz_cfg['circle'] / 2;
      _ref = center(this.x1, this.y1), xc = _ref[0], yc = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      svg.line(yc, xc, y2c, x2c).stroke({
        width: 1
      });
      return svg.circle(rad * 2).move(yc - rad, xc - rad);
    };

    QCircuit_black_dot.prototype.apply = function(map) {
      return map[this.x1][this.y1] += "\\ctrl{" + (this.x2 - this.x1) + "}";
    };

    return QCircuit_black_dot;

  })();

  QCircuit_white_dot = (function() {
    function QCircuit_white_dot(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'white-dot';
    }

    QCircuit_white_dot.prototype.draw = function(svg) {
      var rad, x2c, xc, y2c, yc, _ref, _ref1;
      rad = sz_cfg['circle'] / 2;
      _ref = center(this.x1, this.y1), xc = _ref[0], yc = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      svg.line(yc, xc, y2c, x2c).stroke({
        width: 1
      });
      return svg.circle(rad * 2).move(yc - rad, xc - rad).attr({
        'stroke-width': 2,
        'fill': 'white',
        'fill-opacity': 1
      });
    };

    QCircuit_white_dot.prototype.apply = function(map) {
      return map[this.x1][this.y1] += "\\ctrlo{" + (this.x2 - this.x1) + "} ";
    };

    return QCircuit_white_dot;

  })();

  QCircuit_target = (function() {
    function QCircuit_target(x, y) {
      this.x = x;
      this.y = y;
      this.type = 'target';
    }

    QCircuit_target.prototype.draw = function(svg) {
      var rad, xc, yc, _ref;
      rad = sz_cfg['target'] / 2;
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.circle(rad * 2).move(yc - rad, xc - rad).attr({
        'stroke-width': 2,
        'fill-opacity': 0
      });
      svg.line(yc - rad, xc, yc + rad, xc).stroke({
        width: 1
      });
      return svg.line(yc, xc - rad, yc, xc + rad).stroke({
        width: 1
      });
    };

    QCircuit_target.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\targ ";
    };

    return QCircuit_target;

  })();

  QCircuit_line = (function() {
    function QCircuit_line(x1, y1, x2, y2) {
      this.x1 = x1;
      this.y1 = y1;
      this.x2 = x2;
      this.y2 = y2;
      this.type = 'line';
    }

    QCircuit_line.prototype.draw = function(svg) {
      var x1c, x2c, y1c, y2c, _ref, _ref1;
      _ref = center(this.x1, this.y1), x1c = _ref[0], y1c = _ref[1];
      _ref1 = center(this.x2, this.y2), x2c = _ref1[0], y2c = _ref1[1];
      return svg.line(y1c, x1c, y2c, x2c).stroke({
        width: 1
      });
    };

    QCircuit_line.prototype.apply = function(map) {
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

    return QCircuit_line;

  })();

  QCircuit_qswap = (function() {
    function QCircuit_qswap(x, y) {
      this.x = x;
      this.y = y;
      this.type = 'qswap';
    }

    QCircuit_qswap.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['qswap'];
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      draw.line(yc - d, xc - d, yc + d, xc + d).stroke({
        width: 3
      });
      return draw.line(yc + d, xc - d, yc - d, xc + d).stroke({
        width: 3
      });
    };

    QCircuit_qswap.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\qswap ";
    };

    return QCircuit_qswap;

  })();

  QCircuit_gate = (function() {
    function QCircuit_gate(x, y, txt) {
      var _ref;
      this.x = x;
      this.y = y;
      this.txt = txt;
      this.type = 'gate';
      if (this.y < this.x) {
        _ref = [this.y, this.x], this.x = _ref[0], this.y = _ref[1];
      }
    }

    QCircuit_gate.prototype.draw = function(svg) {
      var d, xc, yc, _ref;
      d = sz_cfg['gate'] / 2;
      _ref = center(this.x, this.y), xc = _ref[0], yc = _ref[1];
      svg.rect(d * 2, d * 2).move(yc - d, xc - d).attr({
        'stroke': 'black',
        'fill': 'white',
        'fill-opacity': 1
      });
      return svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d, d).move(yc - d / 2, xc - d / 2);
    };

    QCircuit_gate.prototype.apply = function(map) {
      return map[this.x][this.y] += "\\gate{" + this.txt + "}";
    };

    return QCircuit_gate;

  })();

  QCircuit_multigate = (function() {
    function QCircuit_multigate(c, x, y, txt) {
      var _ref;
      this.c = c;
      this.x = x;
      this.y = y;
      this.txt = txt;
      if (this.x > this.y) {
        _ref = [this.y, this.x], this.x = _ref[0], this.y = _ref[1];
      }
      this.type = 'multigate';
    }

    QCircuit_multigate.prototype.draw = function(svg) {
      var d, lc, uc, xc;
      d = sz_cfg['gate'] / 2;
      xc = Y.center(this.c);
      lc = X.center(this.y);
      uc = X.center(this.x);
      svg.rect(d * 2, d * 2 + lc - uc).move(xc - d, uc - d).attr({
        'stroke': 'black',
        'fill': 'white',
        'fill-opacity': 1
      });
      return svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + this.txt, d, d).move(xc - 10, (lc + uc) / 2 - 10);
    };

    QCircuit_multigate.prototype.apply = function(map) {
      var d, _i, _ref, _ref1, _results;
      map[this.x][this.c] += "\\multigate{" + (this.y - this.x) + "}{" + this.txt + "}";
      _results = [];
      for (d = _i = _ref = this.x + 1, _ref1 = this.y; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; d = _ref <= _ref1 ? ++_i : --_i) {
        _results.push(map[d][this.c] += "\\ghost{" + this.txt + "}");
      }
      return _results;
    };

    return QCircuit_multigate;

  })();

  QCircuit_component = (function() {
    function QCircuit_component() {
      this.components = [];
    }

    QCircuit_component.prototype.fix_cover = function() {
      var c, _i, _len, _ref, _ref1, _results;
      _ref = this.components;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if ((_ref1 = c.type) === 'targ' || _ref1 === 'gate' || _ref1 === 'multigate') {
          _results.push(c.draw(draw));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    QCircuit_component.prototype.redraw = function() {
      var c, _i, _len, _ref, _ref1;
      draw.clear();
      _ref = this.components;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        c = _ref[_i];
        if ((_ref1 = c.type) !== 'targ' && _ref1 !== 'gate' && _ref1 !== 'multigate') {
          c.draw(draw);
        }
      }
      return this.fix_cover();
    };

    QCircuit_component.prototype.add = function(comp, redraw) {
      if (redraw == null) {
        redraw = true;
      }
      this.components.push(comp);
      if (redraw) {
        return this.redraw();
      }
    };

    return QCircuit_component;

  })();

  QC = new QCircuit_component;

  dashed_box = null;

  locate_mouse = function(x, y) {
    return [Y.locate(y), X.locate(x)];
  };

  window.cancel_op = function() {
    if (QC.components.length === 0) {
      return clog('empty operation!');
    } else {
      QC.components = QC.components.slice(0, -1);
      return QC.redraw();
    }
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
      clog("Queue Length " + this.Q.length);
      return $("#QLen").val("" + this.Q.length + " drd");
    };

    QueueEvent.prototype.bind = function(func, cnt) {
      this.func = func;
      this.cnt = cnt;
      this.Q = [];
      return $("#QLen").val("" + this.Q.length + " rdr");
    };

    return QueueEvent;

  })();

  Q = new QueueEvent;

  drawer = $("#drawing");

  get_cur_rel_pos = function(event) {
    var x, y;
    x = parseInt(event.pageX) - drawer.position().top;
    y = parseInt(event.pageY) - drawer.position().left;
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
        return QC.add(new QCircuit_black_dot(x1, y1, x2, y2));
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
        return QC.add(new QCircuit_white_dot(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  window.add_targ = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new QCircuit_target(x, y));
    };
    return Q.bind(func, 1);
  };

  window.add_qswap = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new QCircuit_qswap(x, y));
    };
    return Q.bind(func, 1);
  };

  window.add_gate = function() {
    var func;
    func = function(arg) {
      var x, y, _ref;
      _ref = arg[0], x = _ref[0], y = _ref[1];
      return QC.add(new QCircuit_gate(x, y, $('#gate').val()));
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
        return QC.add(new QCircuit_multigate(y1, x1, x2, $('#gate').val()));
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
        return QC.add(new QCircuit_line(x1, y1, x2, y2));
      }
    };
    return Q.bind(func, 2);
  };

  QCircuitGrid = (function() {
    function QCircuitGrid(rows, cols) {
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

    QCircuitGrid.prototype.imp_ops = function(components) {
      this.components = components;
    };

    QCircuitGrid.prototype.exp_tex = function() {
      var comp, ret, x, y, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _ref2, _ref3;
      _ref = this.components;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        comp = _ref[_i];
        if (comp.type !== 'line') {
          comp.apply(this.map);
        }
      }
      _ref1 = this.components;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        comp = _ref1[_j];
        if (comp.type === 'line') {
          comp.apply(this.map);
        }
      }
      ret = "\\Qcircuit @C=1em @R=1em { \n";
      for (x = _k = 1, _ref2 = this.rows; 1 <= _ref2 ? _k <= _ref2 : _k >= _ref2; x = 1 <= _ref2 ? ++_k : --_k) {
        for (y = _l = 1, _ref3 = this.cols; 1 <= _ref3 ? _l <= _ref3 : _l >= _ref3; y = 1 <= _ref3 ? ++_l : --_l) {
          ret += this.map[x][y];
        }
        ret += "\\\\ \n";
      }
      ret += "}";
      return ret;
    };

    return QCircuitGrid;

  })();

  window.export_to_latex = function() {
    var grid;
    clog("rc: " + rows + " " + cols);
    grid = new QCircuitGrid(rows, cols);
    grid.imp_ops(QC.components);
    return $('#latex-code').text(grid.exp_tex());
  };

  mk_table = function() {
    var elem, h, i, inner, j, rem, s, style, tab, w, _i, _j;
    tab = $("#table");
    rem = 20;
    for (i = _i = 0; 0 <= rows ? _i <= rows : _i >= rows; i = 0 <= rows ? ++_i : --_i) {
      h = i === 0 ? rem : X.get(i);
      s = "<tr height=" + (h - 2) + "px>";
      for (j = _j = 0; 0 <= cols ? _j <= cols : _j >= cols; j = 0 <= cols ? ++_j : --_j) {
        elem = i === 0 ? "th" : "td";
        style = j === 0 ? 'style="border-right: 2px solid #CCC"' : "";
        w = j === 0 ? rem : Y.get(j);
        inner = (i === 0 && j > 0) || (i > 0 && j === 0) ? i + j : "";
        s += "<" + elem + " width=" + (w - 4) + "px " + style + "> " + inner + " </" + elem + ">";
      }
      s += '</tr>';
      tab.append(s);
    }
    tab.tableresizer({
      row_border: "2px solid #CCC",
      col_border: "2px solid #CCC"
    });
    return drawer.offset({
      top: tab.offset().top + rem + 5,
      left: tab.offset().left + rem + 5
    });
  };

  mk_table();

  clog('init done');

}).call(this);
