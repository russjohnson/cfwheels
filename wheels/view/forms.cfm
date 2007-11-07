<cffunction name="startFormTag" returntype="any" access="public" output="false">
	<cfargument name="link" type="any" required="false" default="">
	<cfargument name="method" type="any" required="false" default="post">
	<cfargument name="multipart" type="any" required="false" default="false">
	<cfargument name="spam_protection" type="any" required="false" default="false">
	<cfargument name="with_token" type="any" required="false" default="false">
	<!--- Accepts URLFor arguments --->
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "link,method,multipart,spam_protection,with_token,controller,action,id,anchor,only_path,host,protocol,params">
	<cfif structKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<!--- Since a non-numeric id was passed in we assume it is meant as a HTML attribute and therefore remove it from the named arguments list so that it will be set in the attributes --->
		<cfset arguments.CFW_named_arguments = listDeleteAt(arguments.CFW_named_arguments, listFindNoCase(arguments.CFW_named_arguments, "id"))>
	</cfif>
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>
	<cfif structKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<cfset structDelete(arguments, "id")>
	</cfif>

	<cfset request.wheels.current_form_method = arguments.method>

	<cfif len(arguments.link) IS NOT 0>
		<cfset local.url = arguments.link>
	<cfelse>
		<cfset local.url = URLFor(argumentCollection=arguments)>
	</cfif>
	<cfset local.url = HTMLEditFormat(local.url)>

	<cfif arguments.spam_protection>
		<cfset local.onsubmit = "this.action='#left(local.url, int((len(local.url)/2)))#'+'#right(local.url, ceiling((len(local.url)/2)))#';">
		<cfset local.url = "">
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			<form action="#local.url#" method="#arguments.method#"<cfif arguments.multipart> enctype="multipart/form-data"</cfif><cfif structKeyExists(local, "onsubmit")> onsubmit="#local.onsubmit#"</cfif>#local.attributes#>
			<cfif arguments.with_token>
				<cfset saveFormToken()>
				#hiddenFieldTag(name="token", value=getFormToken())#
			</cfif>
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="formRemoteTag" returntype="any" access="public" output="false">
	<cfargument name="link" type="any" required="false" default="">
	<cfargument name="method" type="any" required="false" default="post">
	<cfargument name="spam_protection" type="any" required="false" default="false">
	<cfargument name="with_token" type="any" required="false" default="false">
	<cfargument name="update" type="any" required="false" default="">
	<cfargument name="insertion" type="any" required="false" default="">
	<cfargument name="serialize" type="any" required="false" default="false">
	<cfargument name="on_loading" type="any" required="false" default="">
	<cfargument name="on_complete" type="any" required="false" default="">
	<cfargument name="on_success" type="any" required="false" default="">
	<cfargument name="on_failure" type="any" required="false" default="">
	<!--- Accepts URLFor arguments --->
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "link,method,spam_protection,with_token,update,insertion,serialize,on_loading,on_complete,on_success,on_failure,controller,action,id,anchor,only_path,host,protocol,params">
	<cfif structKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<!--- Since a non-numeric id was passed in we assume it is meant as a HTML attribute and therefore remove it from the named arguments list so that it will be set in the attributes --->
		<cfset arguments.CFW_named_arguments = listDeleteAt(arguments.CFW_named_arguments, listFindNoCase(arguments.CFW_named_arguments, "id"))>
	</cfif>
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>
	<cfif structKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<cfset structDelete(arguments, "id")>
	</cfif>

	<cfif len(arguments.link) IS NOT 0>
		<cfset local.url = arguments.link>
	<cfelse>
		<cfset local.url = URLFor(argumentCollection=arguments)>
	</cfif>

	<cfset local.ajax_call = "new Ajax.">

	<!--- Figure out the parameters for the Ajax call --->
	<cfif len(arguments.update) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & "Updater('#arguments.update#',">
	<cfelse>
		<cfset local.ajax_call = local.ajax_call & "Request(">
	</cfif>

	<cfset local.ajax_call = local.ajax_call & "'#local.url#', { asynchronous:true">

	<cfif len(arguments.insertion) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & ",insertion:Insertion.#arguments.insertion#">
	</cfif>

	<cfif arguments.serialize>
		<cfset local.ajax_call = local.ajax_call & ",parameters:Form.serialize(this)">
	</cfif>

	<cfif len(arguments.on_loading) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & ",onLoading:#arguments.on_loading#">
	</cfif>

	<cfif len(arguments.on_complete) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & ",onComplete:#arguments.on_complete#">
	</cfif>

	<cfif len(arguments.on_success) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & ",onSuccess:#arguments.on_success#">
	</cfif>

	<cfif len(arguments.on_failure) IS NOT 0>
		<cfset local.ajax_call = local.ajax_call & ",onFailure:#arguments.on_failure#">
	</cfif>

	<cfset local.ajax_call = local.ajax_call & "});">

	<cfif arguments.spam_protection>
		<cfset local.url = "">
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			<form action="#local.url#" method="#arguments.method#" onsubmit="#local.ajax_call# return false;"#local.attributes#>
			<cfif arguments.with_token>
				<cfset saveFormToken()>
				#hiddenFieldTag(name="token", value=getFormToken())#
			</cfif>
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="endFormTag" returntype="any" access="public" output="false">
	<cfif structKeyExists(request.wheels, "current_form_method")>
		<cfset structDelete(request.wheels, "current_form_method")>
	</cfif>
	<cfreturn "</form>">
</cffunction>


<cffunction name="submitTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="false" default="commit">
	<cfargument name="value" type="any" required="false" default="Save changes">
	<cfargument name="image" type="string" required="false" default="">
	<cfargument name="disable" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,image,disable">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfif len(arguments.disable) IS NOT 0>
		<cfset local.onclick = "this.disabled=true;">
		<cfif len(arguments.image) IS 0 AND NOT isBoolean(arguments.disable)>
			<cfset local.onclick = local.onclick & "this.value='#arguments.disable#';">
		</cfif>
		<cfset local.onclick = local.onclick & "this.form.submit();">
	</cfif>

	<cfif len(arguments.image) IS NOT 0>
		<cfset local.source = "#application.wheels.web_path##application.settings.paths.images#/#arguments.image#">
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			<input name="#arguments.name#" id="#arguments.name#" value="#arguments.value#"<cfif len(arguments.image) IS 0> type="submit"<cfelse> type="image" src="#local.source#"</cfif><cfif len(arguments.disable) IS NOT 0> onclick="#local.onclick#"</cfif>#local.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="textField" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="text" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value="#HTMLEditFormat(CFW_formValue(argumentCollection=arguments))#"#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="radioButton" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="tag_value" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,tag_value,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="radio" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value="#arguments.tag_value#"<cfif arguments.tag_value IS CFW_formValue(argumentCollection=arguments)> checked="checked"</cfif>#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="checkBox" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="checked_value" type="any" required="false" default="1">
	<cfargument name="unchecked_value" type="any" required="false" default="0">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,checked_value,unchecked_value,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.value = CFW_formValue(argumentCollection=arguments)>
	<cfif (isBoolean(local.value) AND local.value) OR (isNumeric(local.value) AND local.value GTE 1)>
		<cfset local.checked = true>
	<cfelse>
		<cfset local.checked = false>
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="checkbox" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value="#arguments.checked_value#"<cfif local.checked> checked="checked"</cfif>#local.attributes# />
	    <input name="#listLast(arguments.object_name,".")#[#arguments.field#]" type="hidden" value="#arguments.unchecked_value#" />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="passwordField" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="password" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value="#HTMLEditFormat(CFW_formValue(argumentCollection=arguments))#"#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="hiddenField" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.value = CFW_formValue(argumentCollection=arguments)>
	<cfif structKeyExists(request.wheels, "current_form_method") AND request.wheels.current_form_method IS "get">
		<cfset local.value = encryptParam(local.value)>
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			<input type="hidden" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value="#HTMLEditFormat(local.value)#"#local.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="textArea" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.output = "">
	<cfset local.output = local.output & CFW_formBeforeElement(argumentCollection=arguments)>
	<cfset local.output = local.output & "<textarea name=""#listLast(arguments.object_name, '.')#[#arguments.field#]"" id=""#listLast(arguments.object_name, '.')#_#arguments.field#""#local.attributes#>">
	<cfset local.output = local.output & CFW_formValue(argumentCollection=arguments)>
	<cfset local.output = local.output & "</textarea>">
	<cfset local.output = local.output & CFW_formAfterElement(argumentCollection=arguments)>

	<cfreturn local.output>
</cffunction>


<cffunction name="fileField" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="file" name="#listLast(arguments.object_name,".")#[#arguments.field#]" id="#listLast(arguments.object_name,".")#_#arguments.field#" value=""#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="select" returntype="any" access="public" output="false">
	<cfargument name="object_name" type="any" required="true">
	<cfargument name="field" type="any" required="true">
	<cfargument name="options" type="any" required="true">
	<cfargument name="include_blank" type="any" required="false" default="false">
	<cfargument name="multiple" type="any" required="false" default="false">
	<cfargument name="value_field" type="any" required="false" default="id">
	<cfargument name="text_field" type="any" required="false" default="name">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="error_element" type="any" required="false" default="div">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "object_name,field,options,include_blank,multiple,value_field,text_field,label,wrap_label,prepend,append,prepend_to_label,append_to_label,error_element">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.output = "">
	<cfset local.output = local.output & CFW_formBeforeElement(argumentCollection=arguments)>
	<cfset local.output = local.output & "<select name=""#listLast(arguments.object_name,'.')#[#arguments.field#]"" id=""#listLast(arguments.object_name,'.')#_#arguments.field#"">">
	<cfif arguments.multiple>
		<cfset local.output = local.output & " multiple">
	</cfif>
	<cfset local.output = local.output & local.attributes>
	<cfif NOT isBoolean(arguments.include_blank) OR arguments.include_blank>
		<cfif NOT isBoolean(arguments.include_blank)>
			<cfset local.text = arguments.include_blank>
		<cfelse>
			<cfset local.text = "">
		</cfif>
		<cfset local.output = local.output & "<option value="""">#local.text#</option>">
	</cfif>
	<cfset local.output = local.output & CFW_optionsForSelect(argumentCollection=arguments)>
	<cfset local.output = local.output & "</select>">
	<cfset local.output = local.output & CFW_formAfterElement(argumentCollection=arguments)>

	<cfreturn local.output>
</cffunction>


<cffunction name="textFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="text" value="#HTMLEditFormat(CFW_formValue(argumentCollection=arguments))#"#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="radioButtonTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="checked" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,checked,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="radio" value="#CFW_formValue(argumentCollection=arguments)#"<cfif arguments.checked> checked="checked"</cfif>#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="checkBoxTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="1">
	<cfargument name="checked" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,checked,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="checkbox" value="#arguments.value#"<cfif arguments.checked> checked="checked"</cfif>#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="passwordFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="password" value="#HTMLEditFormat(CFW_formValue(argumentCollection=arguments))#"#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="hiddenFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.value = CFW_formValue(argumentCollection=arguments)>
	<cfif structKeyExists(request.wheels, "current_form_method") AND request.wheels.current_form_method IS "get">
		<cfset local.value = encryptParam(local.value)>
	</cfif>

	<cfsavecontent variable="local.output">
		<cfoutput>
			<input name="#arguments.name#" id="#arguments.name#" type="hidden" value="#HTMLEditFormat(local.value)#"#local.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="textAreaTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfset local.output = "">
	<cfset local.output = local.output & CFW_formBeforeElement(argumentCollection=arguments)>
	<cfset local.output = local.output & "<textarea name=""#arguments.name#"" id=""#arguments.name#""#local.attributes#>">
	<cfset local.output = local.output & CFW_formValue(argumentCollection=arguments)>
	<cfset local.output = local.output & "</textarea>">
	<cfset local.output = local.output & CFW_formAfterElement(argumentCollection=arguments)>

	<cfreturn local.output>
</cffunction>


<cffunction name="fileFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<input type="file" name="#arguments.name#" id="#arguments.name#" value="#HTMLEditFormat(CFW_formValue(argumentCollection=arguments))#"#local.attributes# />
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="selectTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="options" type="any" required="true">
	<cfargument name="include_blank" type="any" required="false" default="false">
	<cfargument name="multiple" type="any" required="false" default="false">
	<cfargument name="value_field" type="any" required="false" default="id">
	<cfargument name="text_field" type="any" required="false" default="name">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,options,include_blank,multiple,value_field,text_field,label,wrap_label,prepend,append,prepend_to_label,append_to_label">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="local.output">
		<cfoutput>
			#CFW_formBeforeElement(argumentCollection=arguments)#
			<select name="#arguments.name#" id="#arguments.name#"<cfif arguments.multiple> multiple</cfif>#local.attributes#>
			<cfif NOT isBoolean(arguments.include_blank) OR arguments.include_blank>
				<cfif NOT isBoolean(arguments.include_blank)>
					<cfset local.text = arguments.include_blank>
				<cfelse>
					<cfset local.text = "">
				</cfif>
				<option value="">#local.text#</option>
			</cfif>
			#CFW_optionsForSelect(argumentCollection=arguments)#
			</select>
			#CFW_formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn CFW_trimHTML(local.output)>
</cffunction>


<cffunction name="yearSelectTag" returntype="any" access="public" output="false">
	<cfargument name="start_year" type="any" required="false" default="#year(now())-5#">
	<cfargument name="end_year" type="any" required="false" default="#year(now())+5#">
	<cfset arguments.CFW_loop_from = arguments.start_year>
	<cfset arguments.CFW_loop_to = arguments.end_year>
	<cfset arguments.CFW_type = "year">
	<cfset arguments.CFW_step = 1>
	<cfset structDelete(arguments, "start_year")>
	<cfset structDelete(arguments, "end_year")>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>


<cffunction name="monthSelectTag" returntype="any" access="public" output="false">
	<cfargument name="month_display" type="any" required="false" default="names">
	<cfset arguments.CFW_loop_from = 1>
	<cfset arguments.CFW_loop_to = 12>
	<cfset arguments.CFW_type = "month">
	<cfset arguments.CFW_step = 1>
	<cfif arguments.month_display IS "abbreviations">
		<cfset arguments.CFW_option_names = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec">
	<cfelseif month_display IS "names">
		<cfset arguments.CFW_option_names = "January,February,March,April,May,June,July,August,September,October,November,December">
	</cfif>
	<cfset structDelete(arguments, "month_display")>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>


<cffunction name="daySelectTag" returntype="any" access="public" output="false">
	<cfset arguments.CFW_loop_from = 1>
	<cfset arguments.CFW_loop_to = 31>
	<cfset arguments.CFW_type = "day">
	<cfset arguments.CFW_step = 1>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>


<cffunction name="hourSelectTag" returntype="any" access="public" output="false">
	<cfset arguments.CFW_loop_from = 0>
	<cfset arguments.CFW_loop_to = 23>
	<cfset arguments.CFW_type = "hour">
	<cfset arguments.CFW_step = 1>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>


<cffunction name="minuteSelectTag" returntype="any" access="public" output="false">
	<cfargument name="minute_step" type="any" required="false" default="1">
	<cfset arguments.CFW_loop_from = 0>
	<cfset arguments.CFW_loop_to = 59>
	<cfset arguments.CFW_type = "minute">
	<cfset arguments.CFW_step = arguments.minute_step>
	<cfset structDelete(arguments, "minute_step")>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="secondSelectTag" returntype="any" access="public" output="false">
	<cfset arguments.CFW_loop_from = 0>
	<cfset arguments.CFW_loop_to = 59>
	<cfset arguments.CFW_type = "second">
	<cfset arguments.CFW_step = 1>
	<cfreturn CFW_yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>


<cffunction name="CFW_yearMonthHourMinuteSecondSelectTag" returntype="any" access="private" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="include_blank" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrap_label" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prepend_to_label" type="any" required="false" default="">
	<cfargument name="append_to_label" type="any" required="false" default="">
	<cfargument name="CFW_type" type="any" required="true" default="">
	<cfargument name="CFW_loop_from" type="any" required="true" default="">
	<cfargument name="CFW_loop_to" type="any" required="true" default="">
	<cfargument name="CFW_id" type="any" required="false" default="#arguments.name#">
	<cfargument name="CFW_option_names" type="any" required="false" default="">
	<cfargument name="CFW_step" type="any" required="false" default="">
	<cfset var local = structNew()>
	<cfset arguments.CFW_named_arguments = "name,value,include_blank,label,wrap_label,prepend,append,prepend_to_label,append_to_label,CFW_type,CFW_loop_from,CFW_loop_to,CFW_id,CFW_option_names,CFW_step">
	<cfset local.attributes = CFW_getAttributes(argumentCollection=arguments)>

	<cfif arguments.value IS "" AND NOT arguments.include_blank>
		<cfset arguments.value = evaluate("#arguments.CFW_type#(now())")>
	</cfif>

	<cfset local.html = "">
	<cfset local.html = local.html & CFW_formBeforeElement(argumentCollection=arguments)>
	<cfset local.html = local.html & "<select name=""#arguments.name#"" id=""#arguments.CFW_id#""#local.attributes#>">
	<cfif NOT isBoolean(arguments.include_blank) OR arguments.include_blank>
		<cfif NOT isBoolean(arguments.include_blank)>
			<cfset local.text = arguments.include_blank>
		<cfelse>
			<cfset local.text = "">
		</cfif>
		<cfset local.html = local.html & "<option value="""">#local.text#</option>">
	</cfif>
	<cfloop from="#arguments.CFW_loop_from#" to="#arguments.CFW_loop_to#" index="local.i" step="#arguments.CFW_step#">
		<cfif arguments.value IS local.i>
			<cfset local.selected = " selected=""selected""">
		<cfelse>
			<cfset local.selected = "">
		</cfif>
		<cfif arguments.CFW_option_names IS NOT "">
			<cfset local.option_name = listGetAt(arguments.CFW_option_names, local.i)>
		<cfelse>
			<cfset local.option_name = local.i>
		</cfif>
		<cfif arguments.CFW_type IS "minute" OR arguments.CFW_type IS "second">
			<cfset local.option_name = numberFormat(local.option_name, "09")>
		</cfif>
		<cfset local.html = local.html & "<option value=""#local.i#""#local.selected#>#local.option_name#</option>">
	</cfloop>
	<cfset local.html = local.html & "</select>">
	<cfset local.html = local.html & CFW_formAfterElement(argumentCollection=arguments)>

	<cfreturn local.html>
</cffunction>


<cffunction name="dateTimeSelect" returntype="any" access="public" output="false">
	<cfset arguments.CFW_function_name = "dateTimeSelect">
	<cfreturn CFW_dateTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="dateTimeSelectTag" returntype="any" access="public" output="false">
	<cfset arguments.CFW_function_name = "dateTimeSelectTag">
	<cfreturn CFW_dateTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="dateSelect" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="month,day,year">
	<cfargument name="separator" type="any" required="false" default=" ">
	<cfset arguments.CFW_function_name = "dateSelect">
	<cfreturn CFW_dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="dateSelectTag" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="month,day,year">
	<cfargument name="separator" type="any" required="false" default=" ">
	<cfset arguments.CFW_function_name = "dateSelectTag">
	<cfreturn CFW_dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="timeSelect" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="hour,minute,second">
	<cfargument name="separator" type="any" required="false" default=":">
	<cfset arguments.CFW_function_name = "timeSelect">
	<cfreturn CFW_dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="timeSelectTag" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="hour,minute,second">
	<cfargument name="separator" type="any" required="false" default=":">
	<cfset arguments.CFW_function_name = "timeSelectTag">
	<cfreturn CFW_dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>


<cffunction name="CFW_dateTimeSelect" returntype="any" access="public" output="false">
	<cfargument name="date_order" type="any" required="false" default="month,day,year">
	<cfargument name="time_order" type="any" required="false" default="hour,minute,second">
	<cfargument name="date_separator" type="any" required="false" default=" ">
	<cfargument name="time_separator" type="any" required="false" default=":">
	<cfargument name="separator" type="any" required="false" default=" - ">
	<cfargument name="CFW_function_name" type="any" required="true">
	<cfset var local = structNew()>

	<cfset local.html = "">
	<cfset local.separator = arguments.separator>

	<cfset arguments.order = arguments.date_order>
	<cfset arguments.separator = arguments.date_separator>
	<cfif arguments.CFW_function_name IS "dateTimeSelect">
		<cfset local.html = local.html & dateSelect(argumentCollection=arguments)>
	<cfelseif  arguments.CFW_function_name IS "dateTimeSelectTag">
		<cfset local.html = local.html & dateSelectTag(argumentCollection=arguments)>
	</cfif>
	<cfset local.html = local.html & local.separator>
	<cfset arguments.order = arguments.time_order>
	<cfset arguments.separator = arguments.time_separator>
	<cfif arguments.CFW_function_name IS "dateTimeSelect">
		<cfset local.html = local.html & timeSelect(argumentCollection=arguments)>
	<cfelseif  arguments.CFW_function_name IS "dateTimeSelectTag">
		<cfset local.html = local.html & timeSelectTag(argumentCollection=arguments)>
	</cfif>

	<cfreturn local.html>
</cffunction>


<cffunction name="CFW_dateOrTimeSelect" returntype="any" access="private" output="false">
	<cfargument name="name" type="any" required="false" default="">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="object_name" type="any" required="false" default="">
	<cfargument name="field" type="any" required="false" default="">
	<cfargument name="CFW_function_name" type="any" required="true">
	<cfset var local = structNew()>

	<cfif len(arguments.object_name) IS NOT 0>
		<cfset local.name = "#listLast(arguments.object_name,".")#[#arguments.field#]">
		<cfset arguments.CFW_id = "#listLast(arguments.object_name,".")#_#arguments.field#">
		<cfset local.value = CFW_formValue(argumentCollection=arguments)>
	<cfelse>
		<cfset local.name = arguments.name>
		<cfset arguments.CFW_id = arguments.name>
		<cfset local.value = arguments.value>
	</cfif>

	<cfset local.html = "">
	<cfset local.first_done = false>
	<cfloop list="#arguments.order#" index="local.i">
		<cfset arguments.name = local.name & "(CFW_" & local.i & ")">
		<cfif local.value IS NOT "">
			<cfset arguments.value = evaluate("#local.i#(local.value)")>
		<cfelse>
			<cfset arguments.value = "">
		</cfif>
		<cfif local.first_done>
			<cfset local.html = local.html & arguments.separator>
		</cfif>
		<cfset local.html = local.html & evaluate("#local.i#SelectTag(argumentCollection=arguments)")>
		<cfset local.first_done = true>
	</cfloop>

	<cfreturn local.html>
</cffunction>