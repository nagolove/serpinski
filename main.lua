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

-- рекурсивная функция создания фрактала.
-- n - количество итераций, при n == 0(или при n == 1?) рекурсия прекращается.
-- vertices - таблица с вершиннами, куда добавляются новые
-- i < j
function fractal(vertices, i, j)
    local a, b = vertices[i], vertices[j]
    local norm = (a - b):perpendicular():normalizeInplace() * 80
    print("norm", inspect(norm))
    local delta = 30
    local as = a + (b - a):normalizeInplace() * delta
    local bs = b - (b - a):normalizeInplace() * delta
    local middle = a + ((b - a) / 2) + norm
    --local middle = a + norm
    print("middle", inspect(middle))
    print("as", inspect(as))
    table.insert(vertices, i + 1, as)
    table.insert(vertices, i + 1, middle)
    table.insert(vertices, i + 1, bs)
end

function love.draw()
    lg.setColor{1, 1, 1}
    for i = 1, #verts - 1 do
        local p1, p2 = verts[i], verts[i + 1]
        lg.line(p1.x, p1.y, p2.x, p2.y)
    end
    lg.setColor{0, 0.8, 0.1}
    for _, v in ipairs(verts) do
        lg.circle("line", v.x, v.y, 3)
    end
end

function love.update(dt)
end

function love.mousepressed(x, y, btn)
    if btn == 1 then
        fractal(verts, 1, 2)
    elseif btn == 2 then
        verts = copy(defaultVerts)
    end
end

function love.keypressed(_, key)
    if key == "escape" then
        love.event.quit()
    end
end
