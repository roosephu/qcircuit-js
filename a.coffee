clog = console.log
draw = SVG('drawing').size(360, 360)

class Axis
        constructor: (@default, cnt) ->
                @dx = [0]
                for i in [1 .. cnt]
                        @dx.push @default
                @sum = (x, y) -> x + y
                this.upd_xs()
                # clog "drdrd #{@dx}"

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

cols = 6
rows = 6
X = new Axis 60, rows
Y = new Axis 60, cols

center = (x, y) ->
        # clog "center #{x} #{y} #{X.center(x)} #{Y.center(y)}"
        return [X.center(x), Y.center(y)]

class QCircuit_black_dot
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'black-dot'
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                svg.line(yc, xc, y2c, x2c).stroke
                        width: 1
                svg.circle(rad * 2).move(yc - rad, xc - rad)
        apply: (map) ->
                map[@x1][@y1] += "\\ctrl{#{@x2 - @x1}}"

class QCircuit_white_dot
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'white-dot'
        draw: (svg) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                svg.line(yc, xc, y2c, x2c).stroke
                        width: 1
                svg.circle(rad * 2).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill': 'white'
                        'fill-opacity': 1
        apply: (map) ->
                map[@x1][@y1] += "\\ctrlo{#{@x2 - @x1}} "

class QCircuit_target
        constructor: (@x, @y) ->
                @type = 'target'
        draw: (svg) ->
                rad = sz_cfg['target'] / 2
                [xc, yc] = center @x, @y
                svg.circle(rad * 2).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill-opacity': 0
                svg.line(yc - rad, xc, yc + rad, xc).stroke
                        width: 1
                svg.line(yc, xc - rad, yc, xc + rad).stroke
                        width: 1
        apply: (map) ->
                map[@x][@y] += "\\targ "

class QCircuit_line
        constructor: (@x1, @y1, @x2, @y2) ->
                @type = 'line'
        draw: (svg) ->
                [x1c, y1c] = center @x1, @y1
                [x2c, y2c] = center @x2, @y2
                svg.line(y1c, x1c, y2c, x2c).stroke
                        width: 1
        apply: (map) ->
                [x1, x2] = if @x1 < @x2 then [@x1, @x2] else [@x2, @x1]
                [y1, y2] = if @y1 < @y2 then [@y1, @y2] else [@y2, @y1]
                for x in [x1 .. x2]
                        for y in [y1 .. y2]
                                map[x][y] += "\\qw "
class QCircuit_qswap
        constructor: (@x, @y) ->
                @type = 'qswap'
        draw: (svg) ->
                d = sz_cfg['qswap']
                [xc, yc] = center @x, @y
                draw.line(yc - d, xc - d, yc + d, xc + d).stroke
                        width: 3
                draw.line(yc + d, xc - d, yc - d, xc + d).stroke
                        width: 3
        apply: (map) ->
                map[@x][@y] += "\\qswap "

class QCircuit_gate
        constructor: (@x, @y, @txt) ->
                @type = 'gate'
                if @y < @x
                        [@x, @y] = [@y, @x]
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                [xc, yc] = center @x, @y
                svg.rect(d * 2, d * 2).move(yc - d, xc - d).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).move(yc - d / 2, xc - d / 2)
        apply: (map) ->
                map[@x][@y] += "\\gate{#{@txt}}"

class QCircuit_multigate
        constructor: (@c, @x, @y, @txt) ->
                if @x > @y
                        [@x, @y] = [@y, @x]
                @type = 'multigate'
        draw: (svg) ->
                d = sz_cfg['gate'] / 2
                xc = Y.center(@c)
                lc = X.center(@y)
                uc = X.center(@x)
                svg.rect(d * 2, d * 2 + lc - uc).move(xc - d, uc - d).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                svg.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + @txt, d, d).move(xc - 10, (lc + uc) / 2 - 10)
        apply: (map) ->
                map[@x][@c] += "\\multigate{#{@y - @x}}{#{@txt}}"
                for d in [@x + 1 .. @y]
                        map[d][@c] += "\\ghost{#{@txt}}"

class QCircuit_component
        constructor: () ->
                @components = []
        fix_cover: () ->
                for c in @components
                        if c.type in ['targ', 'gate', 'multigate']
                                c.draw draw
        redraw: () ->
                draw.clear()
                for c in @components
                        if c.type not in [ 'targ', 'gate', 'multigate']
                                c.draw draw
                this.fix_cover()
        add: (comp, redraw = true) ->
                @components.push comp
                this.redraw() if redraw

QC = new QCircuit_component

# for c in [
#         new QCircuit_black_dot(1, 1, 2, 1),
#         new QCircuit_black_dot(2, 2, 3, 2),
#         new QCircuit_target(1, 2),
#         new QCircuit_target(3, 1),
#         new QCircuit_gate(1, 3, 'U'),
#         new QCircuit_qswap(4, 1), ]
#         QC.add c, false
# QC.redraw()

dashed_box = null
locate_mouse = (x, y) ->
        # clog "#{x} #{y} #{X.locate(x)} #{Y.locate(Y)}"
        return [Y.locate(y), X.locate(x)]

window.cancel_op = () ->
        if QC.components.length == 0
                clog 'empty operation!'
        else 
                QC.components = QC.components[0 .. -2]
                QC.redraw()

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
                $("#QLen").val("#{@Q.length} drd")
        bind: (@func, @cnt) ->
                @Q = []
                $("#QLen").val("#{@Q.length} rdr")
                # clog "new bind: #{@cnt}"

Q = new QueueEvent

drawer = $("#drawing")

get_cur_rel_pos = (event) ->
        x = parseInt(event.pageX) - drawer.position().top
        y = parseInt(event.pageY) - drawer.position().left
        return [x, y]

drawer.mousemove (event) ->
        [x, y] = get_cur_rel_pos event
        $("#mouse-position").text "#{x} #{y}"
        # clog "#{event.clientX} #{event.pageX} #{drawer.position().top} #{drawer.offset().top}"
        if dashed_box
                dashed_box.remove()
        [Bx, By] = locate_mouse x, y
        x1 = X.left(Bx)
        x2 = X.right(Bx)
        y1 = Y.left(By)
        y2 = Y.right(By)
        clog "#{Bx} #{By}"
        dashed_box = draw.rect(y2 - y1, x2 - x1).move(y1, x1).attr
                'stroke': 'black'
                "stroke-dasharray": [2, 2]
                'fill': 'white'
                'fill-opacity': 0
# clog drawer_dom

drawer.click (event) ->
        [x, y] = get_cur_rel_pos event
        Q.push locate_mouse x, y

drawer.css
        position: "absolute"

window.add_black_dot = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new QCircuit_black_dot x1, y1, x2, y2
        Q.bind func, 2

window.add_white_dot = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new QCircuit_white_dot x1, y1, x2, y2
        Q.bind func, 2

window.add_targ = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new QCircuit_target x, y
        Q.bind func, 1

window.add_qswap = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new QCircuit_qswap x, y
        Q.bind func, 1

window.add_gate = () ->
        func = (arg) ->
                [x, y] = arg[0]
                QC.add new QCircuit_gate x, y, $('#gate').val()
        Q.bind func, 1

window.add_multigate = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        QC.add new QCircuit_multigate y1, x1, x2, $('#gate').val()
        Q.bind func, 2

window.add_line = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2 or x1 == x2
                        QC.add new QCircuit_line x1, y1, x2, y2
        Q.bind func, 2

class QCircuitGrid
        constructor: (@rows, @cols) ->
                @map = []
                for i in [1 .. @rows]
                        @map[i] = []
                        for j in [1 .. @cols]
                                @map[i][j] = ' & '
        imp_ops: (@components) ->
        exp_tex: () ->
                for comp in @components
                        if comp.type != 'line'
                                comp.apply @map
                for comp in @components
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
        grid = new QCircuitGrid rows, cols
        grid.imp_ops QC.components
        $('#latex-code').text grid.exp_tex()

mk_table = ->
        tab = $("#table")
        rem = 20
        for i in [0 .. rows]
                h = if i == 0 then rem else X.get(i)
                s = "<tr height=#{h - 2}px>"
                for j in [0 .. cols]
                        elem = if i == 0 then "th" else "td"
                        style = if j == 0 then 'style="border-right: 2px solid #CCC"' else ""
                        w = if j == 0 then rem else Y.get(j)
                        inner = if (i == 0 and j > 0) or (i > 0 and j == 0) then i + j else ""
                        s += "<#{elem} width=#{w - 4}px #{style}> #{inner} </#{elem}>"
                s += '</tr>'
                tab.append(s)
        tab.tableresizer
                row_border: "2px solid #CCC"
                col_border: "2px solid #CCC"

        drawer.offset
                top: tab.offset().top + rem + 5
                left: tab.offset().left + rem + 5

# config_table = ->
#         tab = $("#table")
#         tab.bind "mouseup", (event) ->
#                 tab.

mk_table()

# config_table()
clog 'init done'
