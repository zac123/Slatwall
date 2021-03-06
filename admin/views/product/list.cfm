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
<cfparam name="rc.$" type="any" />
<cfparam name="rc.productSmartList" type="any" />

<cfoutput>
<ul id="navTask">
    <cf_SlatwallActionCaller action="admin:product.create" type="list">
</ul>

<div class="svoadminproductlist">

	<form method="get">
		<input name="Keyword" value="#rc.Keyword#" />
		<input type="hidden" name="slatAction" value="admin:product.list" />
		<button type="submit">#rc.$.Slatwall.rbKey("admin.product.search")#</button>
	</form>
<cfif rc.productSmartList.getRecordsCount()>
	<table id="ProductList" class="listing-grid stripe">
		<tr>
			<th>#rc.$.Slatwall.rbKey("entity.product.productType")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.brand")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.productCode")#</th>
			<th class="varWidth">#rc.$.Slatwall.rbKey("entity.product.productName")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.publishedFlag")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.qoh")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.qc")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.qexp")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.qia")#</th>
			<th>#rc.$.Slatwall.rbKey("entity.product.qea")#</th>
			<th>&nbsp</th>
		</tr>	
		<cfloop array="#rc.ProductSmartList.getPageRecords()#" index="local.Product">
			<tr>
				<td><a href="#buildURL(action='admin:product.detailproducttype', querystring='productTypeID=#local.Product.getProductType().getProductTypeID()#')#">#local.product.getProductType().getProductTypeName()#</a></td>
				<td><a href="#buildURL(action='admin:brand.detail', querystring='brandID=#local.Product.getBrand().getBrandID()#')#">#local.Product.getBrand().getBrandName()#</a></td>
				<td>#local.Product.getProductCode()#</td>
				<td class="varWidth"><a href="#buildURL(action='admin:product.detail', querystring='productID=#local.Product.getProductID()#')#">#local.Product.getProductName()#</a></td>
				<td>#yesNoFormat(local.Product.getPublishedFlag())#</td>
				<!--- Temporarily doing away with the getSetting("") check for the product --->
				<!---
					This was the original code that should be replaced once getSetting() is fixed.
					
				<cfif local.Product.getSetting("trackInventoryFlag")>
					<td>#local.Product.getQOH()#</td>
					<td>#local.Product.getQC()#</td>
					<td>#local.Product.getQEXP()#</td>
					<td>#local.Product.getQIA()#</td>
					<td>#local.Product.getQEA()#</td>
				<cfelse>
				--->
				<td colspan="5">
					<em>#rc.$.Slatwall.rbKey("admin.product.list.inventoryNotTracked")#</em>
				</td>
				<!---</cfif>--->
				<td class="administration">
					<cfset local.ProductID = local.Product.getProductID() />
		          <ul class="four">
                      <cf_SlatwallActionCaller action="admin:product.edit" querystring="productID=#local.ProductID#" class="edit" type="list">            
					  <cf_SlatwallActionCaller action="admin:product.detail" querystring="productID=#local.ProductID#" class="detail" type="list">
					  <li class="preview"><a href="#local.Product.getProductURL()#">Preview Product</a></li>
					  <cf_SlatwallActionCaller action="admin:product.delete" querystring="productID=#local.ProductID#" class="delete" type="list" disabled="#local.product.isNotDeletable()#" disabledText="#rc.$.Slatwall.rbKey('entity.product.delete_validateOrdered')#" confirmrequired="true">
		          </ul>     						
				</td>
				
			</tr>
		</cfloop>
	</table>
	<cf_SlatwallSmartListPager smartList="#rc.ProductSmartList#">
<cfelse>
	<em>#rc.$.Slatwall.rbKey("admin.product.noProductsDefined")#</em>
</cfif>
</div>
</cfoutput>

