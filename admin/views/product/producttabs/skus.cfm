﻿<!---

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
<cfoutput>
	
<!---	<script type="text/javascript">
		jQuery(function(){
			actionDialog("<input type='checkbox' style=''>test", function(){alert('clicked ok!'); return false;});	
			
		});
		
		
	</script>
	--->
	
<cfif rc.edit>
<div class="buttons">
	<cfif rc.Product.getOptionGroupCount() gt 0>
	<a class="button" id="addSKU">#rc.$.Slatwall.rbKey("admin.product.edit.addsku")#</a>
	</cfif>
	<a class="button" id="remSKU" style="display:none;">#rc.$.Slatwall.rbKey("admin.product.edit.removesku")#</a>
    <!---<a class="button" id="addOption">#rc.$.Slatwall.rbKey("admin.product.edit.addoption")#</a>--->
</div>
</cfif>
<!---<cfset local.skus = rc.SkuSmartList.getPageRecords() />--->
	<cf_SlatwallErrorDisplay object="#rc.product#" errorName="skus" displaytype="div" />
	<table id="skuTable" class="listing-grid stripe">
		<thead>
			<tr>
				<th>#rc.$.Slatwall.rbKey("entity.sku.skuCode")#</th>
				<th>#rc.$.Slatwall.rbKey("entity.sku.isDefault")#</th>
				<cfset local.optionGroups = rc.Product.getOptionGroups() />
				<cfloop array="#local.optionGroups#" index="local.thisOptionGroup">
					<th>#local.thisOptionGroup.getOptionGroupName()#</th>
				</cfloop>
				<th class="varWidth">#rc.$.Slatwall.rbKey("entity.sku.imageFile")#</th>
				<!---<th>#rc.$.Slatwall.rbKey("entity.sku.image.exists")#</th>
				<cfif rc.edit>
					<th></th>
				</cfif>--->
				<th <cfif rc.edit>class="skuPriceColumn"</cfif>>#rc.$.Slatwall.rbKey("entity.sku.price")#</th>
				
				
				<!--- Loop over all Price Groups and create column headers --->
				<cfloop from="1" to="#arrayLen(rc.priceGroupSmartList.getPageRecords())#" index="local.i">
					<cfset local.priceGroup = rc.priceGroupSmartList.getPageRecords()[local.i] />
					
					<!--- Store the value of the priceGroupRateId as a "data" property. Check what is the active rate in this price group. If the rate returned is not actaully a rate in this price group (inherited) just use a code --->
					<cfset rate = rc.product.getAppliedPriceGroupRateByPriceGroup(local.priceGroup)>
					<cfif isNull(rate)>
						<cfset dataPriceGroupRateId = "">
					<cfelseif rate.getPriceGroup().getPriceGroupId() EQ local.priceGroup.getPriceGroupId()>
						<cfset dataPriceGroupRateId = "#rate.getPriceGroupRateId()#">	
					<cfelse>
						<cfset dataPriceGroupRateId = "inherited">	
					</cfif>
					
					
					<th <cfif rc.edit>class="priceGroupSKUColumn"</cfif> data-pricegroupid="#local.priceGroup.getPriceGroupId()#" data-pricegrouprateid="#dataPriceGroupRateId#" <cfif !isNull(local.priceGroup.getParentPriceGroup())>data-inheritedpricegroupid="#local.priceGroup.getParentPriceGroup().getPriceGroupId()#"</cfif>>
						#local.priceGroup.getPriceGroupName()#
					
						<cfif !isNull(local.priceGroup.getParentPriceGroup())>
							(Inherited from #local.priceGroup.getParentPriceGroup().getPriceGroupName()#)
						</cfif>
					</th>
				</cfloop>
				
				<th <cfif rc.edit>class="skuWeightColumn"</cfif>> #rc.$.Slatwall.rbKey("entity.sku.shippingWeight")#</th>
				<cfif $.slatwall.setting("advanced_showRemoteIDFields")>
					<th>#rc.$.Slatwall.rbKey("entity.sku.remoteID")#</th>
				</cfif>
				<cfif rc.product.getSetting("trackInventoryFlag")>
					<th>#rc.$.Slatwall.rbKey("entity.sku.QOH")#</th>
					<th>#rc.$.Slatwall.rbKey("entity.sku.QEXP")#</th>
					<th>#rc.$.Slatwall.rbKey("entity.sku.QC")#</th>
					<th>#rc.$.Slatwall.rbKey("entity.sku.QIA")#</th>
					<th>#rc.$.Slatwall.rbKey("entity.sku.QEA")#</th>
				</cfif>
				<cfif rc.edit>
				  <th class="administration">&nbsp;</th>
				</cfif>
			</tr>
		</thead>
		
		
		
		<tbody>
		<cfloop from="1" to="#arrayLen(rc.skuSmartList.getPageRecords())#" index="local.skuCount">
			<cfset local.thisSku = rc.skuSmartList.getPageRecords()[local.skuCount] />
			<tr id="Sku#local.skuCount#" class="skuRow" data-skuid="#local.thisSku.getSkuId()#">
				<input type="hidden" name="skus[#local.skuCount#].skuID" value="#local.thisSku.getSkuID()#" />
				<td class="alignLeft">
					<cfif rc.edit>
						<input type="text" name="skus[#local.skuCount#].skuCode" value="#local.thisSku.getSkuCode()#" />
						<!---<cfif local.thisSku.hasErrors()>
							<br><span class="formError">#local.thisSku.getErrorBean().getError("skuCode")#</span>
						</cfif>--->
						
						<cf_SlatwallErrorDisplay object="#local.thisSku#" errorName="skuCode" />
					<cfelse>
						#local.thisSku.getSkuCode()#
					</cfif>
				</td>
				<cfif rc.edit>
					<td><input type="radio" name="defaultSku.skuID" value="#local.thisSku.getSkuID()#"<cfif rc.product.getDefaultSku().getSkuID() eq local.thisSku.getSkuID()> checked="checked"</cfif> /></td>
				<cfelse>
					<td><cfif rc.product.getDefaultSku().getSkuID() eq local.thisSku.getSkuID()><img src="#$.slatwall.getSlatwallRootPath()#/staticAssets/images/admin.ui.check_green.png" with="16" height="16" alt="#rc.$.Slatwall.rbkey('sitemanager.yes')#" title="#rc.$.Slatwall.rbkey('sitemanager.yes')#" /></cfif></td>
				</cfif>
				<cfloop array="#local.optionGroups#" index="local.thisOptionGroup">
					<td>#local.thisSku.getOptionByOptionGroupID(local.thisOptionGroup.getOptionGroupID()).getOptionName()#</td>
				</cfloop>
				<td class="varWidth">
					<cfif local.thisSku.imageExists()>
						<a href="#local.thisSku.getImagePath()#" class="lightbox preview">#local.thisSku.getImageFile()#</a>
					<cfelse>
						#local.thisSku.getImageFile()#
					</cfif>	
					
					<cfif local.thisSku.imageExists()>
						<img src="#$.slatwall.getSlatwallRootPath()#/staticAssets/images/admin.ui.check_green.png" with="16" height="16" alt="#rc.$.Slatwall.rbkey('sitemanager.yes')#" title="#rc.$.Slatwall.rbkey('sitemanager.yes')#" />
					<cfelse>
						<img src="#$.slatwall.getSlatwallRootPath()#/staticAssets/images/admin.ui.cross_red.png" with="16" height="16" alt="#rc.$.Slatwall.rbkey('sitemanager.no')#" title="#rc.$.Slatwall.rbkey('sitemanager.no')#" />
					</cfif>	
					
					<cfif rc.edit>
						<a class="button uploadImage" href="/plugins/Slatwall/?slatAction=admin:product.uploadSkuImage&skuID=#local.thisSku.getSkuID()#">#rc.$.Slatwall.rbKey("admin.sku.uploadImage")#</a>
					</cfif>
				</td>
	
				<td>
					<cfif rc.edit>
						<input type="text" size="6" name="skus[#local.skuCount#].price" value="#local.thisSku.getPrice()#" />
					<cfelse>
						#local.thisSku.getFormattedValue('price')#
					</cfif>
				</td>
				
				<!--- Loop over all Price Groups and create actual values --->
				<cfloop from="1" to="#arrayLen(rc.priceGroupSmartList.getPageRecords())#" index="local.i">
					<cfset local.priceGroup = rc.priceGroupSmartList.getPageRecords()[local.i] />
					<cfset priceGroupId = local.priceGroup.getPriceGroupId()>
					
					<!--- Store the value of the priceGroupRateId as a "data" property. Check what is the active rate in this price group. If the rate returned is not actaully a rate in this price group (inherited) just use a code --->
					<cfset rate = local.thisSku.getAppliedPriceGroupRateByPriceGroup(local.priceGroup)>
					<cfif isNull(rate)>
						<cfset dataPriceGroupRateId = "">
					<cfelseif rate.getPriceGroup().getPriceGroupId() EQ local.priceGroup.getPriceGroupId()>
						<cfset dataPriceGroupRateId = "#rate.getPriceGroupRateId()#">	
					<cfelse>
						<cfset dataPriceGroupRateId = "inherited">	
					</cfif>
					
					<td <cfif rc.edit>class="priceGroupSKUColumn"</cfif> data-pricegroupid="#priceGroupId#" data-pricegrouprateid="#dataPriceGroupRateId#">
						#$.Slatwall.formatValue(local.thisSku.getPriceByPriceGroup(priceGroup=local.priceGroup), "currency")#
						
						<cfset productRate = rc.product.getAppliedPriceGroupRateByPriceGroup(local.priceGroup)>
						<cfset skuRate = local.thisSku.getAppliedPriceGroupRateByPriceGroup(local.priceGroup)>
						<cfif !isNull(productRate) AND !isNull(skuRate) AND productRate.getPriceGroupRateId() neq skuRate.getPriceGroupRateId()>
							Overridden (#skuRate.getAmountRepresentation()#)
						</cfif>
					</td>	
				</cfloop>

				<td>
					<cfif rc.edit>
						 <input type="text" size="6" name="skus[#local.skuCount#].shippingWeight" value="#local.thisSku.getShippingWeight()#" />         
					<cfelse>
						#local.thisSku.getShippingWeight()#
					</cfif>
				</td>
				<cfif $.slatwall.setting("advanced_showRemoteIDFields")>
					<td><cf_SlatwallPropertyDisplay object="#local.thisSku#" fieldName="skus[#local.skuCount#].remoteID" property="remoteID" edit="#rc.edit#" displaytype="plain"></td>
				</cfif>
				<cfif rc.product.getSetting("trackInventoryFlag")>
				<td>#local.thisSku.getQOH()#</td>
				<td>#local.thisSku.getQEXP()#</td>
				<td>#local.thisSku.getQC()#</td>
				<td>#local.thisSku.getQIA()#</td>
				<td>#local.thisSku.getQEA()#</td>
				</cfif>
				<cfif rc.edit>
					<td class="administration">
						<cfif !local.thisSku.isNew()>
							<ul class="one">
								<cf_SlatwallActionCaller action="admin:product.deleteSku" querystring="skuID=#local.thisSku.getSkuID()#" class="delete" type="list" disabled="#local.thisSku.isNotDeletable()#" confirmrequired="true">
							</ul>
						</cfif>
					</td>
				</cfif>
			</tr>
		</cfloop>
	</tbody>
</table>

<cf_SlatwallSmartListPager smartList="#rc.SkuSmartList#">

<cfif rc.edit>
<table id="tableTemplate" class="hideElement">
<tbody>
    <tr id="temp">
        <td>
            <input type="text" name="skuCode" value="" />
			<input type="hidden" name="skuID" value="" />
        </td>
        <td><!-- default sku radio --></td>
        <cfloop array="#local.optionGroups#" index="local.thisOptionGroup">
            <td>
			   <select name="options">
                    <cfset local.options = local.thisOptionGroup.getOptions() />
                    <cfloop array="#local.options#" index="local.thisOption">
                        <option value="#local.thisOption.getOptionID()#">#local.thisOption.getOptionName()#</option>
                    </cfloop>
                </select>
			</td>
        </cfloop>
        <td class="varWidth"><!--image path --></td>
        <td>
            <input type="text" size="6" name="price" value="#rc.product.getDefaultSku().getPrice()#" />
        </td>
        
		<!--- Loop though price groups --->
		<cfloop from="1" to="#arrayLen(rc.priceGroupSmartList.getPageRecords())#" index="local.i">
			<td></td>
		</cfloop>
		
		<td>
			<input type="text" size="6" name="shippingWeight" value="#rc.product.getDefaultSku().getShippingWeight()#" />
		</td>
        <cfif rc.product.getSetting("trackInventoryFlag")>
	        <td></td>
	        <td></td>
	        <td></td>
	        <td></td>
	        <td></td>
        </cfif>
            <td class="administration">
            </td>
        </tr>
</tbody>
</table>
<cfelse>
	<div class="clear"></div>
</cfif>


</cfoutput>