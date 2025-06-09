local utils = {}

function utils.bcMessage(msg)
  return string.format("[bluesky-comments] %s", msg)
end

function utils.abort(msg)
  -- TODO: Actually throw when Quarto has better support for exiting render from shortcodes
  error("\n" .. utils.bcMessage(msg) .. "\n")
end

function utils.log_error(msg)
  quarto.log.error(utils.bcMessage(msg))
end

function utils.log_info(msg)
  quarto.log.info(utils.bcMessage(msg))
end

function utils.log_warn(msg)
  quarto.log.warning(utils.bcMessage(msg))
end

function utils.log_output(msg)
  quarto.log.output(utils.bcMessage(msg))
end

function utils.isKeyInTable(table, keyToFind)
  for key, _ in pairs(table) do
      if key == keyToFind then
          return true
      end
  end
  return false
end

function utils.toCamelCase(x)
  return x:gsub("%-(%w)", function(match) return match:upper() end)
end

return utils
