<cfcomponent extends="wheelsMapping.test">

	<cfset global.controller = createobject("component", "wheelsMapping.controller") />
	
	<cffunction name="test_renderPartial_valid">
		<cfset fail()>
	</cffunction>
	
</cfcomponent>
