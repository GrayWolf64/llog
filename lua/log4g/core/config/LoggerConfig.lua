--- The LoggerConfig.
-- @classmod LoggerConfig
Log4g.Core.Config = Log4g.Core.Config or {}
Log4g.Core.Config.Builder = Log4g.Core.Config.Builder or {}
Log4g.Core.Config.LoggerConfig = Log4g.Core.Config.LoggerConfig or {}
Log4g.Core.Config.LoggerConfig.Buffer = Log4g.Core.Config.LoggerConfig.Buffer or {}
local HasKey = Log4g.Util.HasKey
local Class = include("log4g/core/impl/MiddleClass.lua")
local LoggerConfig = Class("LoggerConfig")
local SetState = Log4g.Core.LifeCycle.SetState
local IsStarted = Log4g.Core.LifeCycle.IsStarted
local INITIALIZING = Log4g.Core.LifeCycle.State.INITIALIZING
local INITIALIZED = Log4g.Core.LifeCycle.State.INITIALIZED
local STARTING = Log4g.Core.LifeCycle.State.STARTING
local STARTED = Log4g.Core.LifeCycle.State.STARTED
local STOPPING = Log4g.Core.LifeCycle.State.STOPPING
local STOPPED = Log4g.Core.LifeCycle.State.STOPPED
local AddLoggerLookupItem = Log4g.Core.Logger.Lookup.AddItem

function LoggerConfig:Initialize(tbl)
    SetState(self, INITIALIZING)
    self.name = tbl.name
    self.eventname = tbl.eventname
    self.uid = tbl.uid
    self.loggercontext = tbl.loggercontext
    self.level = tbl.level
    self.appender = tbl.appender
    self.layout = tbl.layout
    self.file = "log4g/server/loggercontext/" .. tbl.loggercontext .. "/loggerconfig/" .. tbl.name .. ".json"
    self.func = tbl.func
    SetState(self, INITIALIZED)
end

--- Remove the LoggerConfig from Buffer.
-- This will check if the LoggerConfig Buffer table contains the LoggerConfig and remove it.
function LoggerConfig:RemoveBuffer()
    hook.Run("Log4g_PreBufferedLoggerConfigRemoval", self.name)
    SetState(self, STOPPING)
    SetState(self, STOPPED)

    if HasKey(Log4g.Core.Config.LoggerConfig.Buffer, self.name) then
        Log4g.Core.Config.LoggerConfig.Buffer[self.name] = nil
        hook.Run("Log4g_PostBufferedLoggerConfigRemovalSuccess")
    else
        hook.Run("Log4g_OnBufferedLoggerConfigRemovalFailure")
    end
end

--- Remove the LoggerConfig JSON from local storge.
function LoggerConfig:RemoveFile()
    hook.Run("Log4g_PreLoggerConfigFileDeletion", self.name)

    if file.Exists(self.file, "DATA") then
        file.Delete(self.file)
        hook.Run("Log4g_PostLoggerConfigFileDeletionSuccess")
    else
        hook.Run("Log4g_OnLoggerConfigFileDeletionFailure")
    end
end

--- Start the default building procedure for the LoggerConfig.
-- It will first set the LoggerConfig's LifeCycle to STARTING.
-- Then a Logger based on the LoggerConfig will be registered, and the provided LoggerConfig will be removed from Buffer.
-- At last the registered Logger's LoggerConfig's state will be set to STARTED, and the procedure has completed.
function LoggerConfig:BuildDefault()
    if IsStarted(self) then
        error("Build not needed: LoggerConfig already started.\n")
    end

    hook.Run("Log4g_PreLoggerConfigBuild", self.name)
    SetState(self, STARTING)
    MsgN("Starting LoggerConfig...")
    local logger = Log4g.Core.Logger.RegisterLogger(self)
    AddLoggerLookupItem(self.name, self.loggercontext, self.file)

    function logger.loggerconfig:BuildDefault()
        MsgN("LoggerConfig build not needed: already started.")
    end

    self:RemoveBuffer()
    SetState(logger.loggerconfig, STARTED)
    hook.Run("Log4g_PostLoggerConfigBuild")
end

--- Register a LoggerConfig.
-- If the LoggerConfig with the same name already exists, an error will be thrown without halt.
-- @param tbl The table containing data that a LoggerConfig needs
-- @return object loggerconfig
function Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig(tbl)
    hook.Run("Log4g_PreLoggerConfigRegistration", tbl.name)

    if not HasKey(Log4g.Core.Config.LoggerConfig.Buffer, tbl.name) then
        local loggerconfig = LoggerConfig:New(tbl)
        Log4g.Core.Config.LoggerConfig.Buffer[tbl.name] = loggerconfig
        file.Write(loggerconfig.file, util.TableToJSON(tbl, true))
        hook.Run("Log4g_PostLoggerConfigRegistration")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    else
        hook.Run("Log4g_OnLoggerConfigRegistrationFailure")

        return Log4g.Core.Config.LoggerConfig.Buffer[tbl.name]
    end
end

--- Get all the file paths of the LoggerConfigs in Buffer in the form of a string table.
-- If the LoggerConfig Buffer table is empty, an error will be thrown.
-- @return tbl filepaths
function Log4g.Core.Config.LoggerConfig.GetFiles()
    if not table.IsEmpty(Log4g.Core.Config.LoggerConfig.Buffer) then
        local tbl = {}

        for _, v in pairs(Log4g.Core.Config.LoggerConfig.Buffer) do
            table.insert(tbl, v.file)
        end

        return tbl
    else
        return nil
    end
end