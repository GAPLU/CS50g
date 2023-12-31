--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local key_id = math.random(4)
    local lock_id = key_id + 4

    -- the x value of the key and the lock
    local key_x = math.random(width - 12)
    local lock_x = math.random(width - 12)
    -- make sure they differ 
    if key_x == lock_x then
        while key_x == lock_x do
            lock_x = math.random(width - 16)
        end
    end

    local lock_locked = true

    local spawn_goal_post = false

    -- restriction for amount of chasms, not more than 2
    local chasms = 0

    -- restriction for crawded blocks
    local block_allowed = true

    local flag_color = math.random(4)

    local frames = {7 + (flag_color - 1) * 3, 7 + (flag_color - 1) * 3 + 1, 7 + (flag_color - 1) * 3 + 2}

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x ~= 1 and x ~= width - 1 and x ~= lock_x and x ~= key_x and chasms <= 1 then
            chasms = chasms + 1
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else

            chasms = chasms == 2 and 0 or chasms 

            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 and x ~= width - 2 and x ~= lock_x and x ~= key_x then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 and x ~= width - 2 and x ~= lock_x and x ~= key_x then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            
            end

            -- chance to spawn a block
            if math.random(10) == 1 and x ~= width - 2 and x ~= lock_x and x ~= key_x and block_allowed then
                
                if blockHeight == 2 then
                    block_allowed = false
                end
                table.insert(objects,
                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            else
                block_allowed = true
            end
        end

        -- spawn the lock
        if lock_x == x then
            table.insert(objects,
                -- jump block
                GameObject {
                    texture = 'keys_and_locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (4 - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = lock_id,
                    collidable = true,
                    solid = true,

                    -- collision function takes itself
                    onCollide = function(obj)

                        -- remove the block if the key is collected
                        if not lock_locked then
                            for k, single_obj in pairs(objects) do
                                if single_obj == obj then
                                    table.remove(objects, k)
                                end
                            end
                            -- spawn the pole
                            local goal_pole = GameObject {
                                texture = 'flags',
                                x = (width - 2) * TILE_SIZE,
                                y = (6 - 3) * TILE_SIZE,
                                width = 16,
                                height = 48,
                                frame = math.random(6),
                                collidable = true,
                                consumable = true,
                                solid = false,

                                -- go to the next lvl, pass the params
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play', {
                                        score = player.score,
                                        width = width + math.random(5, 15)
                                    })
                                end
                            }
                            table.insert(objects, goal_pole)
                            -- spawn the flag
                            local goal_flag = GameObject {
                                texture = 'flags',
                                x = (width - 2) * TILE_SIZE + 8,
                                y = (6 - 3) * TILE_SIZE + 8,
                                width = 16,
                                height = 16,
                                frames = frames,
                                collidable = true,
                                consumable = true,
                                solid = false,

                                -- same as with a pole, go to the next lvl
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play', {
                                        score = player.score,
                                        width = width + math.random(5, 15)
                                    })
                                end
                            }
                            table.insert(objects, goal_flag)
                        end
                        gSounds['empty-block']:play()
                    end
                }
            )
        end

        -- spawn the key for unlocking the lock
        if key_x == x then
            table.insert(objects,
                GameObject {
                    texture = 'keys_and_locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (6 - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = key_id,
                    collidable = true,
                    consumable = true,
                    solid = false,

                    -- key has its own function to unlock the locked block
                    onConsume = function(player, object)
                        gSounds['pickup']:play()
                        lock_locked = false
                    end
                }
            )
        end
    end

    

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end