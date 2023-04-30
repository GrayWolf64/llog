local PropertiesPlugin = Log4g.GetPkgClsFuncs("log4g-core", "PropertiesPlugin")
local Get = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext").get
local randomString = Log4g.CoreTest.randomString
local GetContext = Log4g.API.LoggerContextFactory.GetContext

concommand.Add("log4g_coretest_propertiesPlugin", function()
    local sharedPropertyName, sharedPropertyValue = randomString(10), randomString(10)
    print("creating shared:", sharedPropertyName)
    PropertiesPlugin.registerProperty(sharedPropertyName, sharedPropertyValue, true)
    PrintTable(PropertiesPlugin.getAll())
    print("deleting shared:", sharedPropertyName)
    PropertiesPlugin.removeProperty(sharedPropertyName, true)
    PrintTable(PropertiesPlugin.getAll())
    print("\n")
    local privatePropertyName, privatePropertyValue = randomString(10), randomString(10)
    GetContext("testcontext")
    local context = Get("testcontext")
    print("creating private:", privatePropertyName)
    PropertiesPlugin.registerProperty(privatePropertyName, privatePropertyValue, false, context)
    PrintTable(PropertiesPlugin.getAll())
    print("deleting private:", privatePropertyName)
    PropertiesPlugin.removeProperty(privatePropertyName, false, context)
    PrintTable(PropertiesPlugin.getAll())
end)