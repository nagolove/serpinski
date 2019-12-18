local inspect = require "inspect"
local vector = require "vector"
local lg = love.graphics

-- source http://lua-users.org/wiki/CopyTable 
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        --setmetatable(copy, deepcopy(getmetatable(orig)))
        setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function copy(tbl)
    local result = {}
    for k, v in pairs(tbl) do
        result[k] = v
        local mt = getmetatable(v)
        if mt then 
            print("setup mt", inspect(mt))
            setmetatable(result[k], mt) 
        end
    end
    return result
end

function love.load()
end

local defaultVerts = {vector(100, 100), vector(400, 100)}
local verts = copy(defaultVerts)

function makeVertsList(p1, p2)
    local res = copy({p1, p2})
    p1.prev = nil
    p1.next = p2
    p2.prev = p1
    p2.next = nil
    return res
end

local vertsList = makeVertsList(vector(100, 450), vector(400, 450))

function fractal2(p1, p2, n)
    --assert(p1.next == p2)
    --assert(p2.prev == p1)
    local height = (p1 - p2):len() / 3
    local part = (p2 - p1):normalizeInplace() * height
    local a = p1 + part
    local b = p2 - part
    local middle = p1 + ((p2 - p1) / 2) + (p1 - p2):perpendicular():
        normalizeInplace() * height

    --p1.next = middle
    --middle.next = p2
    p1.next = a
    a.next = middle
    middle.next = b
    b.next = p2

    p2.prev = b
    b.prev = middle
    middle.prev = a
    a.prev = p1

    if n >= 1 then
        fractal2(p1, p1.next, n - 1)
        fractal2(p2.prev, p2, n - 1)
        fractal2(middle.prev, middle, n - 1)
        fractal2(middle, middle.next, n - 1)
    end
end

-- рекурсивная функция создания фрактала.
-- n - количество итераций, при n == 0(или при n == 1?) рекурсия прекращается.
-- vertices - таблица с вершиннами, куда добавляются новые
-- i < j
function fractal(vertices, i, j)
    local a, b = vertices[i], vertices[j]
    local delta = (a - b):len() / 3
    local norm = (a - b):perpendicular():normalizeInplace() * delta
    print("norm", inspect(norm))
    local as = a + (b - a):normalizeInplace() * delta
    local bs = b - (b - a):normalizeInplace() * delta
    local middle = a + ((b - a) / 2) + norm
    --local middle = a + norm
    print("middle", inspect(middle))
    print("as", inspect(as))
    table.insert(vertices, i + 1, bs)
    table.insert(vertices, i + 1, middle)
    table.insert(vertices, i + 1, as)
end

function drawVertList(p)
    local node = p
    repeat
        local x1, y1 = node.x, node.y
        node = node.next
        if node then
            local x2, y2 = node.x, node.y
            lg.setColor{1, 0.8, 1}
            lg.line(x1, y1, x2, y2)
            lg.setColor{0.1, 0.9, 0.1}
            lg.circle("line", x2, y2, 3)
        end
        lg.setColor{0.1, 0.9, 0.1}
        lg.circle("line", x1, y1, 3)
    until not node
end

function love.draw()
    lg.setColor{1, 1, 1}
    for i = 1, #verts - 1 do
        local p1, p2 = verts[i], verts[i + 1]
        lg.line(p1.x, p1.y, p2.x, p2.y)
    end
    lg.setColor{0, 0.8, 0.1}
    for k, v in pairs(verts) do
        lg.circle("line", v.x, v.y, 3)
        lg.print(string.format("%d", k), v.x, v.y)
    end
    drawVertList(vertsList[1])
end

function love.update(dt)
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(3) then
        love.event.quit()
    end
end

function love.mousepressed(x, y, btn)
end

function love.keypressed(_, key)
    if key == "escape" then
        love.event.quit()
    elseif key == "l" then
        fractal2(vertsList[1], vertsList[2], 4)
    elseif key == "e" then
        fractal(verts, 1, 2)
        fractal(verts, 1, 2)
    elseif key == "d" then
        verts = copy(defaultVerts)
    end
end
