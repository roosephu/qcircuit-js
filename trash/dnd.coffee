dragElem = null
point = document.getElementById "point"
pts_pos = document.getElementById "point-position"
objX = 0
objY = 0
mouseX = 0
mouseY = 0

down = (evt) ->
        console.log 'down'
        evt = evt || window.event
        dragElem = this
        objX = parseInt this.style.left
        objY = parseInt this.style.top
        mouseX = parseInt evt.clientX
        mouseY = parseInt evt.clientY

move = (evt) ->
        evt = evt || window.event
        if dragElem
                x = parseInt evt.clientX - mouseX + objX
                y = parseInt evt.clientY - mouseY + objY
                pts_pos.innerHTML = "(#{x}px, #{y}px) #{dragElem}"
                dragElem.style.left = x + "px"
                dragElem.style.top  = y + "px"

over = () ->
        this.style.cursor = "move"

dragInit = (node) ->
        if node.className == 'drag'
                node.onmousedown = down
                document.onmousemove = move
                node.onmouseover = over
                node.style.position = "relative"
                node.style.top  = "0px"
                node.style.left = "0px"
                node.dragging = false
                node.draggable = true
                console.log node
        for c in node.childNodes
                dragInit c
dragInit document

document.onmouseup = ->
        dragElem = null
        pts_pos.innerHTML = "(#{point.style.top}, #{point.style.left}) (#{objX}, #{objY}) (#{mouseX}, #{mouseY}) #{dragElem} #{Math.random()}"
console.log point.onmousedown