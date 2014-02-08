cols = 8
rows = 6
draw = SVG('drawing').size(cols * 60, rows * 60)
clog = console.log
# clog = (args...) ->
        
ECs = $("#ECs tbody")
ECcnt = 0

class Axis
        constructor: (@default, cnt) ->
                @dx = [0]
                for i in [1 .. cnt]
                        @dx.push @default
                @sum = (x, y) -> x + y
                @upd_xs()

        upd_xs: () ->
                @last = 0
                @xs = []
                @rep = []
                cnt = 0
                for i in @dx
                        for x in [0 .. i - 1]
                                @rep.push cnt
                        @last += i
                        @xs.push @last
                        cnt += 1
                # clog "xs: #{@xs}"
                        
        set_default: (@default) ->

        set: (col, width) ->
                @dx[col] = width
        get: (col) ->
                return @dx[col]

        left: (x) ->
                if x > @xs.length
                        x = @xs.length
                return @xs[x - 1]

        right: (x) ->
                if x >= @xs.length
                        return @last
                return @xs[x]
                
        center: (x) ->
                return @dx[x] / 2 + @xs[x - 1]

        locate: (x) ->
                if x >= @last
                        return @xs.length
                return @rep[x]

sz_cfg =
        'circle': 12
        'gate': 40
        'target': 30
        'qswap': 5
        'classical-wire': 8
        'meter': 50

X = new Axis 60, rows
Y = new Axis 60, cols

center = (x, y) ->
        # clog "center #{x} #{y} #{X.center(x)} #{Y.center(y)}"
        return [X.center(x), Y.center(y)]

insert_tab = (elem, id, type, args) ->
        clog "insert: #{type} #{args}"
        tab_id = "EC#{id}"
        ECs.append "<tr id='#{tab_id}'>
                      <td>#{id}</td>
                      <td>#{type}</td>
                      <td>#{args}</td>
                      <td><button class='btn btn-primary' onclick='remove_elem(#{id})'>Delete</button></td>
                    </tr>"
        ret = $("#" + tab_id).click (event) ->
                dom = elem.dom
                color = ''
                if dom.flagged
                        color = 'black'
                        dom.flagged = false
                else
                        color = 'red'
                        dom.flagged = true
                dom.each (_) ->
                        @stroke
                                color: color

class ReFmt_row_add
        constructor: (@pos) ->
                console.log "drd"
        point: (x, y) -> if x >= @pos then [x + 1, y] else [x, y]
        line: (x1, y1, x2, y2) -> @point(x1, y1).concat @point(x2, y2)

class ReFmt_col_add
        constructor: (@pos) ->
        point: (x, y) -> if y >= @pos then [x, y + 1] else [x, y]
        line: (x1, y1, x2, y2) -> @point(x1, y1).concat @point(x2, y2)

class ReFmt_row_del
        constructor: (@pos) ->
        point: (x, y, d = true) -> if x == @pos and d then false else if x >= @pos then [x - 1, y] else [x, y]
        line: (x1, y1, x2, y2) ->
                return false if x1 == x2 and x1 == @pos
                [x1, y1] = @point(x1, y1, false)
                [x2, y2] = @point(x2, y2, false)
                return false if [x1, y1] == [x2, y2]
                [x1, y1, x2, y2]

class ReFmt_col_del
        constructor: (@pos) ->
        point: (x, y, d = true) -> if y == @pos and d then false else if y >= @pos then [x, y - 1] else [x, y]
        line: (x1, y1, x2, y2, gate) ->
                return false if y1 == y2 and y1 == @pos
                [x1, y1] = @point(x1, y1, false)
                [x2, y2] = @point(x2, y2, false)
                return false if [x1, y1] == [x2, y2] and not gate
                [x1, y1, x2, y2]

ReFmt = (mode, pos) ->
        switch mode
                when "ra" then new ReFmt_row_add pos
                when "rd" then new ReFmt_row_del pos
                when "ca" then new ReFmt_col_add pos
                when "cd" then new ReFmt_col_del pos

class Qcircuit_black_dot
        constructor: (@c, @x, @y) ->
                @type = 'black-dot'
                ECcnt += 1
                @cid = "#{ECcnt}"
        # constructor: @constructor_point 'black-dot'
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, cc] = center @x, @c
                [yc, cc] = center @y, @c
                @dom = svg.group()
                
                svg.line(cc, xc, cc, yc).addTo(@dom).stroke
                        width: 1
                svg.circle(rad * 2).addTo(@dom).move(cc - rad, xc - rad)
                @tab = insert_tab this, @cid, "black-dot", "#{@c} #{@x} #{@y}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\ctrl{#{@y - @x}}"
        refmt: (mode) ->
                ret = mode.point @x, @c
                return false unless ret
                [@x, @c, @y, d] = mode.line @x, @c, @y, @c
                # clog "#{@c} #{@x} #{@y}"

class Qcircuit_white_dot
        constructor: (@c, @x, @y) ->
                @type = 'white-dot'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, cc] = center @x, @c
                [yc, cc] = center @y, @c
                @dom = svg.group()
                svg.line(cc, xc, cc, yc).addTo(@dom).stroke
                        width: 1
                svg.circle(rad * 2).addTo(@dom).move(cc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill': 'white'
                        'fill-opacity': 1
                @tab = insert_tab this, @cid, "white-dot", "#{@c} #{@x} #{@y}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\ctrlo{#{@y - @x}} "
        refmt: (mode) ->
                ret = mode.point @x, @c
                return false unless ret
                [@x, @c, @y, d] = mode.line @x, @c, @y, @c

class Qcircuit_target
        constructor: (@x, @y) ->
                @type = 'target'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                rad = sz_cfg['target'] / 2
                [xc, yc] = center @x, @y
                @dom = svg.group()
                svg.circle(rad * 2).addTo(@dom).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill-opacity': 0
                svg.line(yc - rad, xc, yc + rad, xc).addTo(@dom).stroke
                        width: 1
                svg.line(yc, xc - rad, yc, xc + rad).addTo(@dom).stroke
                        width: 1
                @tab = insert_tab this, @cid, "target", "#{@x} #{@y}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\targ "
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_line
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'line'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                [x1c, y1c] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2 
                @dom = svg.group()
                svg.line(y1c, x1c, y2c, x2c).addTo(@dom).stroke
                        width: 1
                @tab = insert_tab this, @cid, "line", "#{@x1} #{@y1} #{@x2} #{@y2}" unless @tab
        apply: (map) ->
                [x1, x2] = if @x1 < @x2 then [@x1, @x2] else [@x2, @x1]
                [y1, y2] = if @y1 < @y2 then [@y1, @y2] else [@y2, @y1]
                for x in [x1 .. x2]
                        for y in [y1 .. y2]
                                map[x][y] += "\\qw "
        refmt: (mode) ->
                ret = mode.line @x1, @y1, @x2, @y2
                return false unless ret
                [@x1, @y1, @x2, @y2] = ret

class Qcircuit_qswap
        constructor: (@x, @y) ->
                @type = 'qswap'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = sz_cfg['qswap']
                [xc, yc] = center @x, @y
                @dom = svg.group()
                svg.line(yc - d, xc - d, yc + d, xc + d).addTo(@dom).stroke
                        width: 3
                svg.line(yc + d, xc - d, yc - d, xc + d).addTo(@dom).stroke
                        width: 3
                @tab = insert_tab this, @cid, "qswap", "#{@x} #{@y}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\qswap "
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_gate
        constructor: (@x, @y, @txt) ->
                @type = 'gate'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                [xc, yc] = center @x, @y
                @dom = svg.group()
                svg.rect(d * 2, d * 2).move(yc - d, xc - d).addTo(@dom).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(yc - d / 2, xc - d / 2) if @txt != ""
                @tab = insert_tab this, @cid, "gate", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\gate{#{@txt}}"
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_multigate
        constructor: (@c, @x, @y, @txt) ->
                ECcnt += 1;
                @cid = "#{ECcnt}"
                if @x > @y
                        [@x, @y] = [@y, @x]
                @type = 'multigate'
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                xc = Y.center(@c)
                lc = X.center(@y)
                uc = X.center(@x)
                @dom = svg.group()
                svg.rect(d * 2, d * 2 + lc - uc).move(xc - d, uc - d).addTo(@dom).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(xc - 10, (lc + uc) / 2 - 10) if @txt != ""
                @tab = insert_tab this, @cid, "multigate", "#{@c} #{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\multigate{#{@y - @x}}{#{@txt}}"
                for d in [@x + 1 .. @y]
                        map[d][@c] += "\\ghost{#{@txt}}"
        refmt: (mode) ->
                ret = mode.line @x, @c, @y, @c
                return false unless ret
                [@x, @c, @y, _] = ret

class Qcircuit_label
        constructor: (@x, @y, @io, @dirac, @txt) ->
                @type = "label"
                ECcnt += 1
                @cid = "#{ECcnt}"
                if @dirac == 'ket'
                        @tex = "\\left\\vert{#{@txt}}\\right\\rangle"
                else 
                        @tex = "\\left\\langle{#{@txt}}\\right\\vert"
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                [xc, yc] = center @x, @y
                @dom = svg.group()
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @tex, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d) if @txt != ""
                @tab = insert_tab this, @cid, "label", "#{@x} #{@y} #{@io} #{@dirac} #{@txt}" unless @tab
        apply: (map) ->
                io_tex = if @io == "i" then "lstick" else "rstick"
                map[@x][@y] += "\\#{io_tex}{\\#{@dirac}{#{@txt}}}"
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_wire
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = "wire"
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = sz_cfg['classical-wire'] / 2
                @dom = svg.group()
                [x1c, y1c] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                if @x1 == @x2
                        svg.line(y1c, x1c - d, y2c, x1c - d).addTo(@dom).stroke
                                width: 2
                        svg.line(y1c, x1c + d, y2c, x1c + d).addTo(@dom).stroke
                                width: 2
                else
                        svg.line(y1c - d, x1c, y2c - d, x2c).addTo(@dom).stroke
                                width: 2
                        svg.line(y1c + d, x1c, y2c + d, x2c).addTo(@dom).stroke
                                width: 2
                @tab = insert_tab this, @cid, "wire", "#{@x1} #{@y1} #{@x2} #{@y2}" unless @tab
        apply: (map) ->
                if @x1 == @x2
                        [ly, ry] = if @y1 < @y2 then [@y1, @y2] else [@y2, @y1]
                        map[@x1][ly] += "\\cw[#{ry - ly}] "
                else
                        [lx, rx] = if @x1 < @x2 then [@x1, @x2] else [@x2, @x1]
                        map[lx][@y1] += "\\cwx[#{rx - lx}] "
        refmt: (mode) ->
                ret = mode.line @x1, @y1, @x2, @y2
                return false unless ret
                [@x1, @y1, @x2, @y2] = ret

class Qcircuit_meter
        constructor: (@x, @y) ->
                @type = "meter"
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = sz_cfg['meter']
                @dom = svg.group()
                [xc, yc] = center @x, @y
                svg.rect(40, 32).addTo(@dom).move(yc - 20, xc - 16).attr
                        "fill": 'white'
                        "fill-opacity": 1
                        "stroke": "black"
                        "stroke-width": 2
                svg.path("").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                        "fill-opacity": 0
                        "d": "M #{yc + 15} #{xc + 8} A 20 20 90 0 0 #{yc - 15} #{xc + 8}"
                svg.line(yc, xc + 10, yc + 10, xc - 10).addTo(@dom).stroke
                        width: 2
                # svg.image("assets/img/meter.png", 40, 32).addTo(@dom).move(yc - 20, xc - 16)
                @tab = insert_tab this, @cid, "meter", "#{@x} #{@y}" unless @tab
        apply: (map) ->
                map[@x][@y] += '\\meter '
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_measure
        constructor: (@x, @y, @txt) ->
                @type = "measure"
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = 12
                @dom = svg.group()
                [xc, yc] = center @x, @y
                svg.path("").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                        "fill-opacity": 0
                        "d": "M #{yc - d} #{xc - d} 
                              A #{d} #{d} 90 0 0 #{yc - d} #{xc + d}
                              L #{yc + 12} #{xc + d}
                              A #{d} #{d} 90 0 0 #{yc + d} #{xc - d}
                              Z"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d) if @txt != ""
                @tab = insert_tab this, @cid, "measure", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measure{@txt}"
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_measuretab
        constructor: (@x, @y, @txt) ->
                @type = "measuretab"
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = 12
                @dom = svg.group()
                [xc, yc] = center @x, @y
                svg.polygon("#{yc - 25},#{xc} #{yc - 15},#{xc - 20} #{yc + 20},#{xc - 20} #{yc + 20},#{xc+20} #{yc - 15},#{xc + 20}").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d) if @txt != ""
                @tab = insert_tab this, @cid, "measuretab", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measuretab{@txt} "
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_measureD
        constructor: (@x, @y, @txt) ->
                @type = "measureD"
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                d = 12
                @dom = svg.group()
                [xc, yc] = center @x, @y
                svg.path("").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                        "fill-opacity": 0
                        "d": "M #{yc - 20} #{xc - 12}
                              L #{yc + 12} #{xc - 12}
                              A #{12} #{12} 90 0 1 #{yc + 12} #{xc + 12}
                              L #{yc - 20} #{xc + 12}
                              Z"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2 - 5, d * 2 - 5).addTo(@dom).move(yc - d + 5, xc - d + 5) if @txt != ""
                @tab = insert_tab this, @cid, "measureD", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measureD{@txt} "
        refmt: (mode) ->
                ret = mode.point @x, @y
                return false unless ret
                [@x, @y] = ret

class Qcircuit_multimeasure
        constructor: (@c, @x, @y, @txt) ->
                ECcnt += 1;
                @cid = "#{ECcnt}"
                if @x > @y
                        [@x, @y] = [@y, @x]
                @type = 'multimeasure'
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                r = 12
                xc = Y.center(@c)
                lc = X.center(@y)
                uc = X.center(@x)
                @dom = svg.group()
                svg.path("").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                        "fill-opacity": 0
                        "d": "M #{xc - r} #{uc - r} 
                              A #{r} #{r} 90 0 0 #{xc - r * 2} #{uc}
                              L #{xc - r * 2} #{lc}
                              A #{r} #{r} 90 0 0 #{xc - r} #{lc + r}
                              L #{xc + r} #{lc + r}
                              A #{r} #{r} 90 0 0 #{xc + r * 2} #{lc}
                              L #{xc + r * 2} #{uc}
                              A #{r} #{r} 90 0 0 #{xc + r} #{uc - r}
                              Z"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(xc - 10, (lc + uc) / 2 - 10) if @txt != ""
                @tab = insert_tab this, @cid, "multimeasure", "#{@c} #{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\multimeasure{#{@y - @x}}{#{@txt}}"
                for d in [@x + 1 .. @y]
                        map[d][@c] += "\\ghost{#{@txt}}"
        refmt: (mode) ->
                ret = mode.line @x, @c, @y, @c
                return false unless ret
                [@x, @c, @y, _] = ret

class Qcircuit_multimeasureD
        constructor: (@c, @x, @y, @txt) ->
                ECcnt += 1;
                @cid = "#{ECcnt}"
                if @x > @y
                        [@x, @y] = [@y, @x]
                @type = 'multimeasureD'
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                r = 12
                xc = Y.center(@c)
                lc = X.center(@y)
                uc = X.center(@x)
                @dom = svg.group()
                svg.path("").addTo(@dom).attr
                        "stroke": "black"
                        "stroke-width": 2
                        "fill": "white"
                        "fill-opacity": 0
                        "d": "M #{xc - d} #{uc - r} 
                              L #{xc - d} #{lc + r}
                              L #{xc + r} #{lc + r}
                              A #{r} #{r} 90 0 0 #{xc + r * 2} #{lc}
                              L #{xc + r * 2} #{uc}
                              A #{r} #{r} 90 0 0 #{xc + r} #{uc - r}
                              Z"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(xc - 10, (lc + uc) / 2 - 10) if @txt != ""
                @tab = insert_tab this, @cid, "multimeasureD", "#{@c} #{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\multimeasureD{#{@y - @x}}{#{@txt}}"
                for d in [@x + 1 .. @y]
                        map[d][@c] += "\\ghost{#{@txt}}"
        refmt: (mode) ->
                ret = mode.line @x, @c, @y, @c
                return false unless ret
                [@x, @c, @y, _] = ret

class Qcircuit_component
        constructor: () ->
                @components = {}
        redraw: () ->
                # clog @components
                draw.clear()
                # $("#ECs tbody > tr").remove()
                for id, c of @components
                        if c.type == "wire"
                                c.draw draw
                for id, c of @components
                        if c.type not in ['targ', 'gate', 'multigate', 'black-dot', 'white-dot', 'wire', 'meter']
                                c.draw draw
                for id, c of @components
                        if c.type in ['targ', 'gate', 'multigate', 'black-dot', 'white-dot', 'meter']
                                c.draw draw
        add: (comp, redraw = true) ->
                @components[comp.cid] = comp
                @redraw()
        refmt: (mode, pos) ->
                refmt = ReFmt mode, pos
                for id, c of @components
                        c.tab.remove()
                        c.tab = null
                        unless c.refmt refmt
                                delete @components[id]
                @redraw()

QC = new Qcircuit_component

window.remove_elem = (id) ->
        obj = QC.components["#{id}"]
        # clog obj.tab
        obj.tab.remove()
        delete QC.components["#{id}"]
        QC.redraw()

dashed_box = null
locate_mouse = (x, y) ->
        # clog "#{x} #{y} #{X.locate(x)} #{Y.locate(Y)}"
        return [X.locate(y), Y.locate(x)]

class QueueEvent
        constructor: ->
                @Q = []
                @func = null
                @cnt = 0
        push: (args) ->
                # clog "start #{@Q} #{@Q.length}"
                clog "push: #{args}"
                @Q.push args
                if @Q.length >= @cnt and @func
                        # clog "start #{@Q} #{@cnt}"
                        @func(@Q[0 .. @cnt - 1])
                        @Q = []
                        @func = null
                clog "Queue Length #{@Q.length}"
        bind: (@func, @cnt) ->
                @Q = []
                # clog "new bind: #{@cnt} #{@func}"

Q = new QueueEvent

drawer = $("#drawing")

get_cur_rel_pos = (event) ->
        # clog "#{event.pageX} - #{drawer.offset().left} - #{drawer.position().left}"
        x = Math.round(parseInt(event.pageX) - drawer.offset().left)
        y = Math.round(parseInt(event.pageY) - drawer.offset().top)
        return [x, y]

click_event = (event) ->
        [x, y] = get_cur_rel_pos event
        Q.push locate_mouse x, y

drawer.click click_event

drawer.mousemove (event) ->
        [x, y] = get_cur_rel_pos event
        $("#mouse-position").text "#{x} #{y}"
        dashed_box.remove() if dashed_box
        [Bx, By] = locate_mouse x, y
        x1 = X.left(Bx)
        x2 = X.right(Bx)
        y1 = Y.left(By)
        y2 = Y.right(By)
        # clog "#{Bx} #{By}"
        dashed_box = draw.group()
        for [X1, Y1, X2, Y2] in [[x1, y1, x2, y1], [x1, y2, x2, y2], [x2, y1, x2, y2], [x1, y1, x1, y2]]
                draw.line(Y1, X1, Y2, X2).addTo(dashed_box).attr
                        'stroke': 'black'
                        "stroke-dasharray": [2, 2]
drawer.css
        position: "absolute"

btn_group_EC = $("#btn-group-EC")

bind_button = (Qcircuit, btn, mode) ->
        func = switch mode
                when 1 then (arg) ->
                        [x, y] = arg[0]
                        QC.add new Qcircuit x, y, $('#gate').val()
                when 2 then (arg) ->
                        [x1, y1] = arg[0]
                        [x2, y2] = arg[1]
                        if y1 == y2 and x1 != x2
                                QC.add new Qcircuit y1, x1, x2, $('#gate').val()
                when 3 then (arg) ->
                        [x1, y1] = arg[0]
                        [x2, y2] = arg[1]
                        if (y1 == y2 or x1 == x2) and ([x1, y1] != [x2, y2])
                                QC.add new Qcircuit x1, y1, x2, y2
                when 4 then (arg) ->
                        [x, y] = arg[0]
                        io = if $("#label-io").prop("checked") then "o" else "i"
                        dirac = if $("#label-dirac").prop("checked") then "bra" else "ket"
                        QC.add new Qcircuit x, y, io, dirac, $('#gate').val()
        argc = if mode == 1 then 1 else 2
        btn_group_EC.append("<button class='btn btn-primary' id='btn-#{btn}'>#{btn}</button>")
        $("#btn-#{btn}").click () ->
                Q.bind func, argc

elec_elem = [
        [Qcircuit_target        , 'target'        , 1],
        [Qcircuit_qswap         , 'qswap'         , 1],
        [Qcircuit_gate          , 'gate'          , 1], 
        [Qcircuit_meter         , 'meter'         , 1], 
        [Qcircuit_measure       , 'measure'       , 1], 
        [Qcircuit_measuretab    , 'measuretab'    , 1], 
        [Qcircuit_measureD      , 'measureD'      , 1], 
        [Qcircuit_multigate     , 'multigate'     , 2], 
        [Qcircuit_multimeasure  , 'multimeasure'  , 2], 
        [Qcircuit_multimeasureD , 'multimeasureD' , 2], 
        [Qcircuit_black_dot     , 'black-dot'     , 2],
        [Qcircuit_white_dot     , 'white-dot'     , 2],
        [Qcircuit_line          , 'line'          , 3], 
        [Qcircuit_wire          , 'wire'          , 3],
        [Qcircuit_label         , 'label'         , 4],
]

for [Qcircuit, btn, argc] in elec_elem
        bind_button Qcircuit, btn, argc

btn_group_RC = $("#btn-group-RC")
bind_RC_alter = (mode, txt) ->
        btn_group_RC.append("<button class='btn btn-primary' id='btn-RC-#{mode}'>#{txt}</button>")
        $("#btn-RC-#{mode}").click () ->
                QC.refmt mode, parseInt $("#gate").val()

for rc in ['r', 'c']
        for ad in ['a', 'd']
                bind_RC_alter (rc + ad), (rc + ad)

class QcircuitGrid
        constructor: (@rows, @cols) ->
                @map = []
                for i in [1 .. @rows]
                        @map[i] = []
                        for j in [1 .. @cols]
                                @map[i][j] = ' & '
        imp_ops: (@components) ->
        exp_tex: () ->
                for id, comp of @components
                        if comp.type != 'line'
                                comp.apply @map
                for id, comp of @components
                        if comp.type == 'line'
                                comp.apply @map
                ret = "\\Qcircuit @C=1em @R=1em { \n"
                for x in [1 .. @rows]
                        for y in [1 .. @cols]
                                ret += @map[x][y]
                        ret += "\\\\ \n"
                ret += "}"
                return ret

window.export_to_latex = () ->
        clog "rc: #{rows} #{cols}"
        grid = new QcircuitGrid rows, cols
        grid.imp_ops QC.components
        $('#latex-code').text grid.exp_tex()

mk_table = ->
        tab = $("#table")
        rem = 20
        for i in [0 .. rows]
                h = if i == 0 then rem else X.get(i)
                s = "<tr height=#{h}px>"
                for j in [0 .. cols]
                        elem = if i == 0 then "th" else "td"
                        style = if j == 0 then 'style="border-right: 2px solid #CCC"' else ""
                        w = if j == 0 then rem else Y.get(j)
                        inner = if (i == 0 and j > 0) or (i > 0 and j == 0) then i + j else ""
                        s += "<#{elem} width=#{w}px #{style}> #{inner} </#{elem}>"
                s += '</tr>'
                tab.append(s)
        tab.tableresizer
                row_border: "2px solid #CCC"
                col_border: "2px solid #CCC"

        drawer.offset
                top: tab.offset().top + rem
                left: tab.offset().left + rem

# config_table = ->
#         tab = $("#table")
#         tab.bind "mouseup", (event) ->
#                 tab.

mk_table()

# config_table()
clog 'init done'
