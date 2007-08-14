<!--- Database --->
<cfset application.settings.dsn = application.applicationname>
<cfset application.settings.username = "">
<cfset application.settings.password = "">

<!--- Caching --->
<cfset application.settings.perform_caching = false>
<cfset application.settings.default_cache_time = 3600>
<cfset application.settings.maximum_items_to_cache = 1000>
<cfset application.settings.cache_cull_percentage = 10>
<cfset application.settings.cache_cull_interval = 300>

<!--- Routing --->
<cfset application.settings.default_controller = "home">
<cfset application.settings.default_action = "index">
<cfset application.settings.obfuscate_urls = false>