local Queue = {}

Queue.new = function()
  local queue = { _head = 1, _tail = 1 }
  return queue
end

Queue.clear = function(queue)
  for k, _ in pairs(queue) do
    queue[k] = nil
  end
  queue._head, queue._tail = 1, 1
end

Queue.size = function(queue)
  return queue._head - queue._tail
end

Queue.push = function(queue, element)
  local index = queue._head
  queue[index] = element
  queue._head = index + 1
end

--- Pushes the element such that it would be the next element pop'ed.
Queue.push_to_end = function(queue, element)
  local index = queue._tail - 1
  queue[index] = element
  queue._tail = index
end

Queue.swap = function(queue, idx_a, idx_b)
  local elem_a = queue[idx_a]
  local elem_b = queue[idx_b]

  if elem_a and elem_b then
    queue[idx_a], queue[idx_b] = elem_b, elem_a
  end
end

Queue.peek = function(queue)
  return queue[queue._tail]
end

Queue.peek_start = function(queue)
  return queue[queue._head - 1]
end

Queue.peek_index = function(queue, index)
  return queue[queue._tail + index - 1]
end

Queue.pop = function(queue)
  local index = queue._tail

  local element = queue[index]
  queue[index] = nil

  if element then
    queue._tail = index + 1
  end

  return element
end

Queue.pop_start = function(queue)
  local index = queue._head - 1

  local element = queue[index]
  queue[index] = nil

  if element then
    queue._head = index
  end

  return element
end

--- Removes an item from an array in O(1) time.
-- The catch is that fast_remove doesn't guarantee to maintain the order of items in the array
Queue.fast_remove = function(queue, index)
  Queue.swap(queue, index, queue._head - 1)
  return Queue.pop_start(queue)
end

Queue.to_array = function(queue)
  local n = 1
  local res = {}

  for i = queue._tail, queue._head - 1 do
    res[n] = queue[i]
    n = n + 1
  end

  return res
end

Queue.pairs = function(queue)
  local index = queue._tail
  return function()
    local element = queue[index]

    if element then
      local old = index
      index = index + 1
      return old, element
    else
      return nil
    end
  end
end

return Queue