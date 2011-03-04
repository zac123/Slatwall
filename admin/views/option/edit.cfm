﻿<cfparam name="rc.newOption" type="any" />
<cfparam name="rc.optionGroup" type="any" />
<cfparam name="rc.optionID" type="string" default="" />

<cfhtmlhead text="#rc.htmlheadscripts#" />

<cfset local.options = rc.optionGroup.getOptions(sortby="sortOrder",sortType="numeric") />

<ul id="navTask">
	<cfif request.action eq "admin:option.edit">
	<cf_ActionCaller action="admin:option.create" querystring="optiongroupID=#rc.optiongroup.getoptiongroupid()#" type="list">
	</cfif>
    <cf_ActionCaller action="admin:option.list" type="list">
	<cf_ActionCaller action="admin:option.editoptiongroup" querystring="optiongroupID=#rc.optiongroup.getoptiongroupid()#" type="list">
</ul>

<cfoutput>

<cfif request.action eq "admin:option.create">
<div id="buttons">
<a class="button" id="newFrmopen" href="javascript:;" onclick="jQuery('##newFrmcontainer').slideDown();this.style.display='none';jQuery('##newFrmclose').show();return false;">#rc.$.Slatwall.rbKey('admin.option.addoption')#</a>
<a class="button" href="javascript:;" style="display:none;" id="newFrmclose" onclick="jQuery('##newFrmcontainer').slideUp();this.style.display='none';jQuery('##newFrmopen').show();return false;">#rc.$.Slatwall.rbKey('admin.option.closeform')#</a>
</div>

<div style="display:none;" id="newFrmcontainer">

<form id="newOptionForm" enctype="multipart/form-data" action="#buildURL('admin:option.save')#" method="post">
    <input type="hidden" name="optionGroupID" value="#rc.optionGroup.getOptionGroupID()#" />
	<input type="hidden" name="sortOrder" value="#arrayLen(local.options)+1#"
    <dl class="oneColumn">
        <cf_PropertyDisplay object="#rc.newOption#" property="optionname" edit="true">
		<cf_PropertyDisplay object="#rc.newOption#" property="optioncode" edit="true">
		<cf_PropertyDisplay object="#rc.newOption#" property="optionImage" edit="true" tooltip="true" editType="file">
		<cf_PropertyDisplay object="#rc.newOption#" property="optionDescription" edit="true" editType="wysiwyg" toggle="show">
    </dl>
	<a class="button" href="javascript:;" onclick="jQuery('##newFrmcontainer').slideUp();jQuery('##newFrmclose').hide();jQuery('##newFrmopen').show();return false;">#rc.$.Slatwall.rbKey('sitemanager.cancel')#</a>
	<cf_ActionCaller action="admin:option.save" type="submit">
</form>  
</div>
</cfif>

<cfif arrayLen(local.options) gt 0>

<p>
<a href="javascript:;" style="display:none;" id="saveSort" onclick="saveOptionSort('optionList');return false;">[#rc.$.Slatwall.rbKey("admin.option.saveorder")#]</a>
<a href="javascript:;"  id="showSort" onclick="showSaveSort('optionList');return false;">[#rc.$.Slatwall.rbKey('admin.option.reorder')#]</a>
</p>

<ul id="optionList">
<cfloop from="1" to="#arraylen(local.options)#" index="local.i">
<cfset local.thisOption = local.options[local.i] />
<cfif local.thisOption.getOptionID() eq rc.optionID>
	<cfset local.thisOpen = true />
<cfelse>
	<cfset local.thisOpen = false />
</cfif>
	<li optionID="#local.thisOption.getOptionID()#">
		<span id="handle#local.i#" class="handle" style="display:none;">[Drag]</span>
		#local.thisOption.getOptionName()# 
		<a title="#rc.$.Slatwall.rbKey('sitemanager.edit')#" href="javascript:;" id="editFrm#local.i#open" <cfif local.thisOpen>style="display:none;"</cfif> onclick="jQuery('##editFrm#local.i#container').slideDown();this.style.display='none';jQuery('##editFrm#local.i#close').show();return false;">[#rc.$.Slatwall.rbKey("sitemanager.edit")#]</a> 
		<a title="#rc.$.Slatwall.rbKey('sitemanager.content.fields.close')#" href="javascript:;" id="editFrm#local.i#close" <cfif !local.thisOpen>style="display:none;"</cfif> onclick="jQuery('##editFrm#local.i#container').slideUp();this.style.display='none';jQuery('##editFrm#local.i#open').show();return false;">[#rc.$.Slatwall.rbKey("sitemanager.content.fields.close")#]</a>
		<cf_ActionCaller type="link" action="admin:option.delete" querystring="optionid=#local.thisOption.getOptionID()#" text="[#rc.$.Slatwall.rbKey("sitemanager.delete")#]" disabled="#local.thisOption.getIsAssigned()#" confirmrequired="true">
		<div<cfif !local.thisOpen> style="display:none;"</cfif> id="editFrm#local.i#container">

		<form name="editFrm#local.i#" enctype="multipart/form-data" action="#buildURL('admin:option.save')#" method="post">
		    <input type="hidden" name="optionGroupID" value="#rc.optionGroup.getOptionGroupID()#" />
			<input type="hidden" name="optionID" value="#local.thisOption.getOptionID()#" />
		    <dl class="oneColumn">
		        <cf_PropertyDisplay id="optionname#local.i#" object="#local.thisOption#" property="optionname" edit="true">
				<cf_PropertyDisplay id="optioncode#local.i#" object="#local.thisOption#" property="optioncode" edit="true">
				<cf_PropertyDisplay id="optioinimage#local.i#" object="#local.thisOption#" property="optionImage" edit="true" tooltip="true" editType="file">
		        <cfif local.thisOption.hasImage()>
		        <dd>
		            #local.thisOption.displayImage("40")#
		            <input type="checkbox" name="removeOptionImage" value="1" id="removeOptionImage#local.i#" /> <label for="removeOptionImage#local.i#">#rc.$.Slatwall.rbKey("admin.option.removeimage")#</label>
		        </dd>
		        </cfif>
				<cf_PropertyDisplay id="optiondescription#local.i#" object="#local.thisOption#" property="optionDescription" edit="true" editType="wysiwyg" toggle="show">
		    </dl>
			<a class="button" href="javascript:;" onclick="jQuery('##editFrm#local.i#container').slideUp();jQuery('##editFrm#local.i#open').show();jQuery('##editFrm#local.i#close').hide();return false;">#rc.$.Slatwall.rbKey('sitemanager.cancel')#</a>
			<cf_ActionCaller action="admin:option.save" type="submit">
		</form>  
		</div>
	</li>
</cfloop>
</ul>

<cfelse>
	<p><em>#rc.$.Slatwall.rbKey("admin.option.nooptionsingroup")#</em></p>
</cfif>

</cfoutput>