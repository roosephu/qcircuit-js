clog = console.log
draw = SVG('drawing').size('400', '400')
dist = 60
U_size = 40
C_size = 30
D_size = 12
clog "ck"

init_grids = ->
        for i in [1 .. 6] 
                draw.line(0, i * dist, 6 * dist, i * dist).stroke
                        width: 2

window.ops = []
ops = window.ops

init_op = [
        ['line', 1, 1, 3],
        ['line', 2, 1, 4],
        ['line', 3, 1, 3],
        ['black-dot', 1, 1],
        ['black-dot', 2, 2],
        ['black-dot', 3, 2],
        ['white-dot', 3, 3],
        ['black-dot', 4, 2], 
        ['targ', 1, 2],
        ['targ', 3, 1],
        ['gate', 1, 3, 'U'],
        ['qswap', 4, 1],
]

class Painter
        constructor: (@draw, @ops) ->
                # clog 'construct'

        black_dot: (x, y) ->
                draw.circle(D_size).move(y * dist - D_size / 2, x * dist - D_size / 2)
        white_dot: (x, y) ->
                draw.circle(D_size).move(y * dist - D_size / 2, x * dist - D_size / 2).attr
                        'stroke-width': 2
                        'fill': 'white'
                        'fill-opacity': 1
        targ: (x, y) ->
                draw.circle(C_size).move(y * dist - C_size / 2, x * dist - C_size / 2).attr
                        'stroke-width': 2
                        'fill-opacity': 0
                draw.line(y * dist - C_size / 2, x * dist, y * dist + C_size / 2, x * dist).stroke
                        width: 1
                draw.line(y * dist, x * dist - C_size / 2, y * dist, x * dist + C_size / 2).stroke
                        width: 1

        fix_line: (c, L, R) ->
                for op in ops
                        cmd = op[0]
                        if cmd in ['black-dot', 'white-dot', 'targ', 'gate', 'multigate']
                                [x, y] = op[1 .. 2]
                                if y == c and ((L <= x <= R) or (L >= x >= R))
                                        this.add op, false
        line: (c, x, y) ->
                draw.line(c * dist, x * dist, c * dist, y * dist).stroke
                        width: 1
                this.fix_line c, x, y
        qswap: (x, y) ->
                draw.line(y * dist - 5, x * dist - 5, y * dist + 5, x * dist + 5).stroke
                        width: 3
                draw.line(y * dist + 5, x * dist - 5, y * dist - 5, x * dist + 5).stroke
                        width: 3
        gate: (x, y, txt) ->
                draw.rect(U_size, U_size).move(y * dist - U_size / 2, x * dist - U_size / 2).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                draw.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + txt, 20, 20).move(y * dist - 10, x * dist - 10)
        multigate: (c, x, y, txt) ->
                clog "#{c}, #{x}, #{y}, #{txt}"
                draw.rect(U_size, U_size + dist * Math.abs(y - x)).move(c * dist - U_size / 2, Math.min(x, y) * dist - U_size / 2).attr
                        'stroke': 'black'
                        'fill': 'white'
                        'fill-opacity': 1
                draw.image("http://frog.isima.fr/cgi-bin/bruno/tex2png--10.cgi?" + txt, 20, 20).move(c * dist - 10, (x + y) / 2 * dist - 10)
                
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
                        [c, x, y] = op[1 .. 3]
                        this.line c, x, y
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
        init_grids()
        for op in ops
                D.add op, false
for op in init_op
        D.add op, true
redraw()

locate_mouse = (x, y) ->
        [Math.floor(y / dist + 0.5), Math.floor(x / dist + 0.5)]

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
        bind: (@func, @cnt) ->
                @Q = []
                clog "new bind: #{@cnt}"

window.Q = new QueueEvent
Q = window.Q

drawer_dom = document.getElementById "drawing"
drawer_dom.onmousemove = (event) ->
        x = parseInt event.clientX
        y = parseInt event.clientY
        if dashed_box
                dashed_box.remove()
        [Bx, By] = locate_mouse x, y
        # clog "box: " + Bx + " " + By
        dashed_box = draw.rect(dist, dist).move(By * dist - dist / 2, Bx * dist - dist / 2).attr
                'stroke': 'black'
                'stroke-dasharray': [2, 2]
                'fill': 'white'
                'fill-opacity': 0
clog drawer_dom

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
                if y1 == y2
                        D.add ['line', y1, x1, x2], true
        Q.bind func, 2

clog 'init done'
