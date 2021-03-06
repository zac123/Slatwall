<!---

    Slatwall - An e-commerce plugin for Mura CMS
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->
<cfparam name="rc.edit" default="false" >
<cfparam name="rc.productType" type="any" />
<cfparam name="rc.parentProductTypeID" type="string" default="" />

<cfoutput>
	<ul id="navTask">
	    <cf_SlatwallActionCaller action="admin:product.listproducttypes" type="list">
		<cfif !rc.edit><cf_SlatwallActionCaller action="admin:product.editproducttype" querystring="productTypeID=#rc.productType.getProductTypeID()#" type="list"></cfif>
	</ul>
	
	<cfif rc.edit>
		<form name="ProductTypeForm" id="ProductTypeForm" action="#buildURL(action='admin:product.saveproducttype')#" method="post">
		<input type="hidden" id="productTypeID" name="productTypeID" value="#rc.productType.getProductTypeID()#" />
	</cfif>

    <dl class="twoColumn">
    	<cf_SlatwallPropertyDisplay object="#rc.productType#" property="productTypeName" edit="#rc.edit#" first="true">
		
		<cfset local.parentLink = rc.productType.hasParentProductType() ? buildURL(action='admin:product.detailProductType', queryString='productTypeID=#rc.productType.getParentProductType().getProductTypeID()#') : "" />
		<cf_SlatwallPropertyDisplay object="#rc.productType#" property="parentProductType" valueLink="#local.parentLink#" edit="#rc.edit#">
		
		<!---
		<cfif rc.edit>
			<cfset local.tree = rc.productType.getProductTypeTree() />
			<dt><label for="parentProductType.productTypeID">#$.Slatwall.rbKey('entity.producttype.parentProductType')#</label></dt>
			<dd>
				<select name="parentProductType.productTypeID" id="parentProductType.productTypeID" onchange="alertDialog('#$.Slatwall.rbKey("admin.product.changeParentProductType_confirm")#');">
		            <option value=""<cfif isNull(rc.productType.getParentProductType())> selected</cfif>>None</option>
			        <cfloop query="local.tree">
					    <cfif not listFind(local.tree.productTypeNamePath,rc.productType.getProductTypeName())><!--- can't be child of itself or any of its children --->
			            <cfset ThisDepth = local.tree.TreeDepth />
			            <cfif ThisDepth><cfset bullet="-"><cfelse><cfset bullet=""></cfif>
			            <option value="#local.tree.productTypeID#"<cfif (!isNull(rc.productType.getParentProductType()) and rc.productType.getParentProductType().getProductTypeID() eq local.tree.productTypeID) or rc.parentProductTypeID eq local.tree.productTypeID> selected="selected"</cfif>>
			                #RepeatString("&nbsp;&nbsp;&nbsp;",ThisDepth)##bullet##local.tree.productTypeName#
			            </option>
						</cfif>
			        </cfloop>
		        </select>
			</dd>
		<cfelse>
			<cfset local.parentLink = rc.productType.hasParentProductType() ? buildURL(action='admin:product.detailProductType', queryString='productTypeID=#rc.productType.getParentProductType().getProductTypeID()#') : "" />
			<cf_SlatwallPropertyDisplay object="#rc.productType#" property="parentProductType" valueLink="#local.parentLink#" edit="false">
		</cfif>
		--->
		
		<cfif $.slatwall.setting('advanced_showRemoteIDFields')>
			<cf_SlatwallPropertyDisplay object="#rc.productType#" property="remoteID" edit="#rc.edit#">	
		</cfif>
		
	</dl>
	<div class="tabs initActiveTab ui-tabs ui-widget ui-widget-content ui-corner-all">
		<ul>
			<li><a href="##tabDescription" onclick="return false;"><span>#rc.$.Slatwall.rbKey('admin.product.detailProductType.tabDescription')#</span></a></li>
			<li><a href="##tabSettings" onclick="return false;"><span>#rc.$.Slatwall.rbKey('admin.product.detailProductType.tabSettings')#</span></a></li>	
			<li><a href="##tabAttributeSets" onclick="return false;"><span>#rc.$.Slatwall.rbKey('admin.product.detailProductType.tabAttributeSets')#</span></a></li>
		</ul>
		<div id="tabDescription">
			<cf_SlatwallPropertyDisplay object="#rc.productType#" property="productTypeDescription" edit="#rc.edit#" fieldType="wysiwyg">
		</div>
		<div id="tabSettings">
			#view("product/producttypetabs/settings")#
		</div>
		<div id="tabAttributeSets">
			#view("product/producttypetabs/attributesets")#
		</div>
	</div>
	<cfif rc.edit>
		<div id="actionButtons" class="clearfix">
			<cf_SlatwallActionCaller action="admin:product.listProductTypes" class="button" text="#rc.$.Slatwall.rbKey('sitemanager.cancel')#">
			<cfif !rc.productType.isNew() and !rc.productType.hasProduct() and !rc.productType.hasSubProductType()>
			<cf_SlatwallActionCaller action="admin:product.deleteproducttype" querystring="producttypeid=#rc.producttype.getproducttypeID()#" class="button" type="link" confirmrequired="true">
			</cfif>
			<cf_SlatwallActionCaller action="admin:product.saveproducttype" type="submit" class="button">
		</div>
	</form>
	</cfif>
</cfoutput>
