local config = require("vuffers.config")

---@class Logger
---@field debug fun(message: string, event?: table): nil
---@field info fun(message: string, event?: table): nil
---@field warn fun(message: string, event?: table): nil
---@field error fun(message: string, event?: table): nil

---@type Logger | nil
local logger

if config.get_config().debug.enabled then
  local ok, log = pcall(require, "structlog")

  local log_level = config.get_config().debug.log_level

  if ok then
    log.configure({
      vuffers = {
        pipelines = {
          {
            level = log.level[log_level:upper()],
            processors = {
              log.processors.StackWriter({ "line", "file" }, { max_parents = 2, stack_level = 2 }),
              log.processors.Timestamper("%H:%M:%S"),
            },
            formatter = log.formatters.FormatColorizer(
              "%s [%s] %s: %-30s",
              { "timestamp", "level", "logger_name", "msg" },
              { level = log.formatters.FormatColorizer.color_level() }
            ),
            sink = log.sinks.Console(),
          },
        },
      },
    })

    logger = log.get_logger("vuffers")
  else
    print("structlog is not installed")
  end
end

local M = {}

---@param message string
---@param event? table
function M.debug(message, event)
  if not logger then
    return
  end

  logger:debug(message, event)
end

---@param message string
---@param event? table
function M.info(message, event)
  if not logger then
    return
  end

  logger:info(message, event)
end

---@param message string
---@param event? table
function M.warn(message, event)
  if not logger then
    return
  end

  logger:warn(message, event)
end

---@param message string
---@param event? table
function M.error(message, event)
  if not logger then
    return
  end

  logger:error(message, event)
end

return M