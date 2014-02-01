clog = console.log
draw = SVG('drawing').size('400', '400')
window.ops = []
ops = window.ops

init_op = [
        # ['line', 1, 1, 3],
        # ['line', 2, 1, 4],
        # ['line', 3, 1, 3],
        # ['black-dot', 1, 1],
        # ['black-dot', 2, 2],
        # ['black-dot', 3, 2],
        # ['white-dot', 3, 3],
        # ['black-dot', 4, 2], 
        # ['targ', 1, 2],
        # ['targ', 3, 1],
        # ['gate', 1, 3, 'U'],
        # ['qswap', 4, 1],
]

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

        left: (x) ->
                if x > @xs.length
                        x = @xs.length
                return @xs[x - 1]

        right: (x) ->
                if x >= @xs.length
                        x = @xs.length - 1
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

X = new Axis 60, 10
Y = new Axis 60, 10

center = (x, y) ->
        clog "center #{x} #{y} #{X.center(x)} #{Y.center(y)}"
        return [X.center(x), Y.center(y)]

class Painter
        constructor: (@draw, @ops) ->
                # clog 'construct'

        black_dot: (x, y) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center x, y
                clog "black-dot #{xc} #{yc} #{x} #{y}"
                draw.circle(rad * 2).move(yc - rad, xc - rad)
        white_dot: (x, y) ->
                rad = sz_cfg['circle'] / 2
                [xc, yc] = center x, y
                draw.circle(rad * 2).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill': 'white'
                        'fill-opacity': 1
        targ: (x, y) ->
                rad = sz_cfg['target'] / 2
                [xc, yc] = center x, y
                draw.circle(rad * 2).move(yc - rad, xc - rad).attr
                        'stroke-width': 2
                        'fill-opacity': 0
                draw.line(yc - rad, xc, yc + rad, xc).stroke
                        width: 1
                draw.line(yc, xc - rad, yc, xc + rad).stroke
                        width: 1

        fix_line: (x1, y1, x2, y2) ->
                for op in ops
                        cmd = op[0]
                        if cmd in ['black-dot', 'white-dot', 'targ', 'gate']
                                [x, y] = op[1 .. 2]
                                if ((x1 <= x <= x2) or (x1 >= x >= x2)) and ((y1 <= y <= y2) or (y1 >= y >= y2))
                                        this.add op, false
                        else if cmd == 'multigate'
                                this.add op, false
                                        
        line: (x1, y1, x2, y2) ->
                [x1c, y1c] = center x1, y1
                [x2c, y2c] = center x2, y2
                draw.line(y1c, x1c, y2c, x2c).stroke
                        width: 1
                this.fix_line x1, y1, x2, y2
        qswap: (x, y) ->
                d = sz_cfg['qswap']
                [xc, yc] = center x, y
                draw.line(yc - d, xc - d, yc + d, xc + d).stroke
                        width: 3
                draw.line(yc + d, xc - d, yc - d, xc + d).stroke
                        width: 3
        gate: (x, y, txt) ->
                d = sz_cfg['gate'] / 2
                [xc, yc] = center x, y
                draw.rect(d * 2, d * 2).move(yc - d, xc - d).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                draw.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + txt, d, d).move(yc - d / 2, xc - d / 2)
        multigate: (c, x, y, txt) ->
                # clog "#{c}, #{x}, #{y}, #{txt}"
                if y < x
                        [x, y] = [y, x]
                d = sz_cfg['gate'] / 2
                xc = Y.center(c)
                lc = X.center(y)
                uc = X.center(x)
                draw.rect(d * 2, d * 2 + lc - uc).move(xc - d, uc - d).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                draw.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + txt, d, d).move(xc - 10, (lc + uc) / 2 - 10)
                
        add: (op, p) ->
                cmd = op[0]
                if p
                        ops.push op
                if cmd == 'black-dot'
                        [x, y] = op[1 .. 2]
                        this.black_dot x, y
                else if cmd == 'white-dot'
                        [x, y] = op[1 .. 2]
                        this.white_dot x, y
                else if cmd == 'line'
                        [x1, y1, x2, y2] = op[1 .. 4]
                        this.line x1, y1, x2, y2
                else if cmd == 'targ'
                        [x, y] = op[1 .. 2]
                        this.targ x, y
                else if cmd == 'gate'
                        [x, y, txt] = op[1 .. 3]
                        this.gate x, y, txt
                else if cmd == 'qswap'
                        [x, y] = op[1 .. 2]
                        this.qswap x, y
                else if cmd == 'multigate'
                        [c, x, y, txt] = op[1 .. 4]
                        this.multigate c, x, y, txt
        
D = new Painter draw

dashed_box = null
redraw = () ->
        draw.clear()
        # init_grids()
        for op in ops
                D.add op, false
for op in init_op
        D.add op, true
redraw()

locate_mouse = (x, y) ->
        # clog "#{x} #{y} #{X.locate(x)} #{Y.locate(Y)}"
        return [Y.locate(y), X.locate(x)]

window.cancel_op = () ->
        if ops.length == 0
                clog 'empty operation!'
        else 
                ops = ops[0 .. -2]
                redraw()

class QueueEvent
        constructor: ->
                @Q = []
                @func = null
                @cnt = 0
        push: (args) ->
                # clog "start #{@Q} #{@Q.length}"
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

window.Q = new QueueEvent
Q = window.Q

drawer_dom = document.getElementById "drawing"
drawer_dom.onmousemove = (event) ->
        x = parseInt event.clientX
        y = parseInt event.clientY
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
                'stroke-dasharray': [2, 2]
                'fill': 'white'
                'fill-opacity': 0
# clog drawer_dom

drawer_dom.onclick = (event) ->
        x = parseInt event.clientX
        y = parseInt event.clientY
        Q.push locate_mouse x, y

window.add_black_dot = () ->
        func = (arg) ->
                [x, y] = arg[0]
                # clog "black dot: #{x} #{y}"
                D.add ['black-dot', x, y], true
        Q.bind func, 1

window.add_white_dot = () ->
        func = (arg) ->
                [x, y] = arg[0]
                D.add ['white-dot', x, y], true
        Q.bind func, 1

window.add_targ = () ->
        func = (arg) ->
                [x, y] = arg[0]
                D.add ['targ', x, y], true
        Q.bind func, 1

window.add_qswap = () ->
        func = (arg) ->
                [x, y] = arg[0]
                D.add ['qswap', x, y], true
        Q.bind func, 1

window.add_gate = () ->
        func = (arg) ->
                [x, y] = arg[0]
                D.add ['gate', x, y, $('#gate').val()], true
        Q.bind func, 1

window.add_multigate = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2
                        D.add ['multigate', y1, x1, x2, $('#gate').val()], true
        Q.bind func, 2

window.add_line = () ->
        func = (arg) ->
                [x1, y1] = arg[0]
                [x2, y2] = arg[1]
                if y1 == y2 or x1 == x2
                        D.add ['line', x1, y1, x2, y2], true
        Q.bind func, 2

clog "rdr #{X.locate(301)}"

export_to_latex = () ->


$ ->
    $("table").tableresizer 
        row_border: "2px solid #CCC"
        col_border: "2px solid #000"
tab = $("#table")

# clog 'init done'
