<cfoutput>
<h1>#arguments.wheelsError.type#</h1>
<p><strong>#REReplace(arguments.wheelsError.message, "`([^`]*)`", "<tt>\1</tt>", "all")#</strong></p>
<cfif StructKeyExists(arguments.wheelsError, "extendedInfo") AND Len(arguments.wheelsError.extendedInfo)>
	<h2>Suggested action</h2>
	<p>#REReplace(arguments.wheelsError.extendedInfo, "`([^`]*)`", "<tt>\1</tt>", "all")#</p>
</cfif>
<cfset loc.path = GetDirectoryFromPath(GetBaseTemplatePath())>
<cfset loc.errorPos = 0>
<cfloop array="#arguments.wheelsError.tagContext#" index="loc.i">
	<cfset loc.errorPos = loc.errorPos + 1>
	<cfif loc.i.template Does Not Contain loc.path & "wheels" AND loc.i.template IS NOT loc.path & "root.cfm" AND loc.i.template IS NOT loc.path & "index.cfm" AND loc.i.template IS NOT loc.path & "rewrite.cfm" AND loc.i.template IS NOT loc.path & "Application.cfc" AND loc.i.template Does Not Contain loc.path & "plugins">
		<cfset loc.lookupWorked = true>
		<cftry>
			<cfsavecontent variable="loc.fileContents"><cfset loc.pos = 0><pre><code><cfloop file="#arguments.wheelsError.tagContext[loc.errorPos].template#" index="loc.i"><cfset loc.pos = loc.pos + 1><cfif loc.pos GTE (arguments.wheelsError.tagContext[loc.errorPos].line-2) AND loc.pos LTE (arguments.wheelsError.tagContext[loc.errorPos].line+2)><cfif loc.pos IS arguments.wheelsError.tagContext[loc.errorPos].line><span style="color: red;">#loc.pos#: #HTMLEditFormat(loc.i)#</span><cfelse>#loc.pos#: #HTMLEditFormat(loc.i)#</cfif>#Chr(13)##Chr(10)#</cfif></cfloop></code></pre></cfsavecontent>
		<cfcatch>
			<cfset loc.lookupWorked = false>
		</cfcatch>
		</cftry>
		<cfif loc.lookupWorked>
			<h2>Error location</h2>
			<p>Line #arguments.wheelsError.tagContext[loc.errorPos].line# in #Replace(arguments.wheelsError.tagContext[loc.errorPos].template, loc.path, "")#</p>
			#loc.fileContents#
		</cfif>
		<cfbreak>
	</cfif>
</cfloop>
</cfoutput>