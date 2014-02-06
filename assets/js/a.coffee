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
                clog "xs: #{@xs}"
                        
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
        ECs.append "<tr id='#{tab_id}'><td>#{id}</td><td>#{type}</td><td>#{args}</td><td><button class='btn btn-primary' onclick='remove_elem(#{id})'>Delete</button></td></tr>"
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

class Qcircuit_black_dot
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'black-dot'
                ECcnt += 1
                @cid = "#{ECcnt}"
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                @dom = svg.group()
                svg.line(yc, xc, y2c, x2c).addTo(@dom).stroke
                        width: 1
                svg.circle(rad * 2).addTo(@dom).move(yc - rad, xc - rad)
                @tab = insert_tab this, @cid, "black-dot", "#{@x1} #{@y1} #{@x2} #{@y2}" unless @tab
        apply: (map) ->
                map[@x1][@y1] += "\\ctrl{#{@x2 - @x1}}"

class Qcircuit_white_dot
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'white-dot'
                ECcnt += 1;
                @cid = "#{ECcnt}"
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                @dom = svg.group()
                svg.line(yc, xc, y2c, x2c).addTo(@dom).stroke
                        width: 1
                svg.circle(rad * 2).addTo(@dom).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill': 'white'
                        'fill-opacity': 1
                @tab = insert_tab this, @cid, "white-dot", "#{@x1} #{@y1} #{@x2} #{@y2}" unless @tab
        apply: (map) ->
                map[@x1][@y1] += "\\ctrlo{#{@x2 - @x1}} "

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
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(yc - d / 2, xc - d / 2)
                @tab = insert_tab this, @cid, "gate", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\gate{#{@txt}}"

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
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).addTo(@dom).move(xc - 10, (lc + uc) / 2 - 10)
                @tab = insert_tab this, @cid, "multigate", "#{@c} #{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@c] += "\\multigate{#{@y - @x}}{#{@txt}}"
                for d in [@x + 1 .. @y]
                        map[d][@c] += "\\ghost{#{@txt}}"

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
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @tex, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d)
                @tab = insert_tab this, @cid, "label", "#{@x} #{@y} #{@io} #{@dirac} #{@txt}" unless @tab
        apply: (map) ->
                io_tex = if @io == "i" then "lstick" else "rstick"
                map[@x][@y] += "\\#{io_tex}{\\#{@dirac}{#{@txt}}}"

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
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d)
                @tab = insert_tab this, @cid, "measure", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measure{@txt}"

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
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2, d * 2).addTo(@dom).move(yc - d, xc - d)
                @tab = insert_tab this, @cid, "measuretab", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measuretab{@txt} "

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
                        "d": "M #{yc - 12} #{xc - 12}
                              L #{yc + 12} #{xc - 12}
                              A #{12} #{12} 90 0 1 #{yc + 12} #{xc + 12}
                              L #{yc - 12} #{xc + 12}
                              Z"
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d * 2 - 5, d * 2 - 5).addTo(@dom).move(yc - d + 5, xc - d + 5)
                @tab = insert_tab this, @cid, "measureD", "#{@x} #{@y} #{@txt}" unless @tab
        apply: (map) ->
                map[@x][@y] += "\\measureD{@txt} "

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
        ins_row: (x) ->
                # for id, c of @components
                #         c.alter x

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
                # clog "new bind: #{@cnt}"

Q = new QueueEvent

drawer = $("#drawing")

get_cur_rel_pos = (event) ->
        # clog "#{event.pageX} - #{drawer.offset().left}"
        x = parseInt(event.pageX) - drawer.offset().left
        y = parseInt(event.pageY) - drawer.offset().top
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
        clog "#{Bx} #{By}"
        dashed_box = draw.group()
        for [X1, Y1, X2, Y2] in [[x1, y1, x2, y1], [x1, y2, x2, y2], [x2, y1, x2, y2], [x1, y1, x1, y2]]
                draw.line(Y1, X1, Y2, X2).addTo(dashed_box).attr
                        'stroke': 'black'
                        "stroke-dasharray": [2, 2]
drawer.css
        position: "absolute"

window.add_black_dot = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new Qcircuit_black_dot x1, y1, x2, y2
        Q.bind func, 2

window.add_white_dot = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new Qcircuit_white_dot x1, y1, x2, y2
        Q.bind func, 2

window.add_targ = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_target x, y
        Q.bind func, 1

window.add_qswap = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_qswap x, y
        Q.bind func, 1

window.add_gate = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_gate x, y, $('#gate').val()
        Q.bind func, 1

window.add_meter = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_meter x, y
        Q.bind func, 1

window.add_measure = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_measure x, y, $('#gate').val()
        Q.bind func, 1

window.add_measuretab = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_measuretab x, y, $('#gate').val()
        Q.bind func, 1

window.add_measureD = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new Qcircuit_measureD x, y, $('#gate').val()
        Q.bind func, 1

window.add_multigate = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new Qcircuit_multigate y1, x1, x2, $('#gate').val()
        Q.bind func, 2

window.add_line = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2 or x1 == x2
                        QC.add new Qcircuit_line x1, y1, x2, y2
        Q.bind func, 2

window.insert_row = () ->
        func = (arg) ->
                [x, y] = arg[0]
                Q.ins_row x
        Q.bind func, 1

window.add_label = () ->
        func = (arg) ->
                [x, y] = arg[0]
                # clog "" + $("#label-io").prop("checked") + " " + $("#label-dirac").attr('checked')
                io = if $("#label-io").prop("checked") then "o" else "i"
                dirac = if $("#label-dirac").prop("checked") then "bra" else "ket"
                QC.add new Qcircuit_label x, y, io, dirac, $('#gate').val()
        Q.bind func, 1

window.add_wire = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2 or x1 == x2
                        QC.add new Qcircuit_wire x1, y1, x2, y2
        Q.bind func, 2

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
