local EntryManager = require "telescope.entry_manager"

local eq = assert.are.same

describe("process_result", function()
  it("works with one entry", function()
    local manager = EntryManager:new(5)

    manager:add_entry(nil, 1, "hello")

    eq(1, manager:get_score(1))
  end)

  it("works with two entries", function()
    local manager = EntryManager:new(5)

    manager:add_entry(nil, 1, "hello")
    manager:add_entry(nil, 2, "later")

    eq(2, manager.linked_states.size)

    eq("hello", manager:get_entry(1))
    eq("later", manager:get_entry(2))
  end)

  it("correctly sorts lower scores", function()
    local manager = EntryManager:new(5)
    manager:add_entry(nil, 5, "worse result")
    manager:add_entry(nil, 2, "better result")

    eq("better result", manager:get_entry(1))
    eq("worse result", manager:get_entry(2))
  end)

  it("respects max results", function()
    local manager = EntryManager:new(1)
    manager:add_entry(nil, 2, "better result")
    manager:add_entry(nil, 5, "worse result")

    eq("better result", manager:get_entry(1))
  end)

  it("should allow simple entries", function()
    local manager = EntryManager:new(5)

    local counts_executed = 0
    manager:add_entry(
      nil,
      1,
      setmetatable({}, {
        __index = function(t, k)
          local val = nil
          if k == "ordinal" then
            counts_executed = counts_executed + 1

            -- This could be expensive, only call later
            val = "wow"
          end

          rawset(t, k, val)
          return val
        end,
      })
    )

    eq("wow", manager:get_ordinal(1))
    eq("wow", manager:get_ordinal(1))
    eq("wow", manager:get_ordinal(1))

    eq(1, counts_executed)
  end)

  it("should update worst score in all append case", function()
    local manager = EntryManager:new(2, nil)
    manager:add_entry(nil, 2, "result 2")
    manager:add_entry(nil, 3, "result 3")
    manager:add_entry(nil, 4, "result 4")

    eq(3, manager.worst_acceptable_score)
  end)

  it("should update worst score in all prepend case", function()
    local manager = EntryManager:new(2)
    manager:add_entry(nil, 5, "worse result")
    manager:add_entry(nil, 4, "less worse result")
    manager:add_entry(nil, 2, "better result")

    eq("better result", manager:get_entry(1))
    eq(4, manager.worst_acceptable_score)
  end)

  it(":window() should return table of resuls", function()
    local manager = EntryManager:new(5, nil)

    manager:add_entry(nil, 1, "first")
    manager:add_entry(nil, 2, "second")
    manager:add_entry(nil, 3, "third")
    manager:add_entry(nil, 4, "fourth")
    manager:add_entry(nil, 5, "sixth")

    eq(5, manager.linked_states.size)

    eq({ "second", "third" }, manager:window(2, 3))
  end)
end)
