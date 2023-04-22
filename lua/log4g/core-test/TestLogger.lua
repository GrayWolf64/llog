local CreateLogger = include("log4g/core/Logger.lua").Create
local GetContext = Log4g.API.LoggerContextFactory.GetContext
local GetLevel = include("log4g/core/Level.lua").GetLevel
local CreateLoggerConfig = include("log4g/core/config/LoggerConfig.lua").Create
local CreateConsoleAppender = Log4g.Core.Appender.CreateConsoleAppender
local CreatePatternLayout = Log4g.Core.Layout.PatternLayout.CreateDefaultLayout
local print = print

local function PrintLoggerInfo(...)
    print("Logger", "Assigned LC", "LC Parent", "Level")

    for _, v in pairs({...}) do
        print(v:GetName(), v:GetLoggerConfig():GetName(), tostring(v:GetLoggerConfig():GetParent()), v:GetLevel():GetName())
    end
end

concommand.Add("log4g_coretest_LoggerConfig_Inheritance", function()
    local ctx = GetContext("TestLCInheritance", true)

    local function renew()
        ctx:Terminate()
        ctx = GetContext("TestLCInheritance", true)
    end

    PrintLoggerInfo(CreateLogger("X", ctx), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    renew()
    PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    renew()
    PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx, CreateLoggerConfig("X.Y.Z", ctx:GetConfiguration(), GetLevel("WARN"))))
    renew()
    PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx), CreateLogger("X.Y.Z", ctx))
    renew()
    PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration(), GetLevel("INFO"))), CreateLogger("X.YZ", ctx))
    renew()
    PrintLoggerInfo(CreateLogger("X", ctx, CreateLoggerConfig("X", ctx:GetConfiguration(), GetLevel("ERROR"))), CreateLogger("X.Y", ctx, CreateLoggerConfig("X.Y", ctx:GetConfiguration())), CreateLogger("X.Y.Z", ctx))
    ctx:Terminate()
end)

concommand.Add("log4g_coretest_LoggerLog", function()
    local ctx = GetContext("TestLoggerLogContext", true)
    local lc = CreateLoggerConfig("LogTester", ctx:GetConfiguration(), GetLevel("TRACE"))
    lc:AddAppender(CreateConsoleAppender("TestAppender", CreatePatternLayout("TestLayout")))
    local logger = CreateLogger("LogTester", ctx, lc)
    logger:Trace("Test TRACE message.")
    print(logger:IsAdditive())
    ctx:Terminate()
end)