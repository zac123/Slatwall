/*

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

*/
component displayname="Sku" entityname="SlatwallSku" table="SlatwallSku" persistent=true accessors=true output=false extends="BaseEntity" {
	
	// Persistent Properties
	property name="skuID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="skuCode" ormtype="string" unique="true" length="50";
	property name="listPrice" ormtype="big_decimal" formatType="currency" default="0";
	property name="price" ormtype="big_decimal" formatType="currency" default="0";
	property name="shippingWeight" ormtype="big_decimal" formatType="weight" dbdefault="0" default="0" hint="This Weight is used to calculate shipping charges";
	property name="imageFile" ormtype="string" length="50";

	// Remote properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" ormtype="timestamp";
	property name="createdByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" ormtype="timestamp";
	property name="modifiedByAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Related Object Properties (Many-to-One)
	property name="product" fieldtype="many-to-one" fkcolumn="productID" cfc="Product";
	
	// Related Object Properties (One-to-Many)
	property name="stocks" singularname="stock" fieldtype="one-to-many" fkcolumn="SkuID" cfc="Stock" inverse="true" cascade="all";
	property name="alternateSkuCodes" singularname="alternateSkuCode" fieldtype="one-to-many" fkcolumn="SkuID" cfc="AlternateSkuCode" inverse="true" cascade="all-delete-orphan";
	
	// Related Object Properties (Many-to-Many)
	property name="options" singularname="option" cfc="Option" fieldtype="many-to-many" linktable="SlatwallSkuOption" fkcolumn="skuID" inversejoincolumn="optionID" cascade="save-update"; 
	property name="promotionRewards" singularname="promotionReward" cfc="PromotionRewardProduct" fieldtype="many-to-many" linktable="SlatwallPromotionRewardProductSku" fkcolumn="skuID" inversejoincolumn="promotionRewardID" cascade="all" inverse="true";
	property name="priceGroupRates" singularname="priceGroupRate" cfc="PriceGroupRate" fieldtype="many-to-many" linktable="SlatwallPriceGroupRateSku" fkcolumn="skuID" inversejoincolumn="priceGroupRateID" cascade="all" inverse="true";
	
	// Non-Persistent Properties
	property name="livePrice" formatType="currency" persistent="false" hint="this property should calculate after term sale";
	property name="qoh" persistent="false" type="numeric" hint="quantity on hand";
	property name="qc" persistent="false" type="numeric" hint="quantity committed";
	property name="qexp" persistent="false" type="numeric" hint="quantity exptected";
	property name="webQOH" persistent="false" type="numeric";
	property name="webQC" persistent="false" type="numeric";
	property name="webQEXP" persistent="false" type="numeric";
	property name="webWholesaleQOH" persistent="false" type="numeric";
	property name="webWholesaleQC" persistent="false" type="numeric";
	property name="webWholesaleQEXP" persistent="false" type="numeric";
	
	public Sku function init() {
       // set default collections for association management methods
       if(isNull(variables.Options)) {
       	    variables.options=[];
       }
 	   if(isNull(variables.promotionRewards)) {
	       variables.promotionRewards = [];
	   }
      
       return super.init();
    }
    
    public boolean function isNotDefaultSku() {
    	if(getProduct().getDefaultSku().getSkuID() != getSkuID()) {
    		return true;
    	}
    	return false;
    }
    
    public string function getSimpleRepresentationPropertyName() {
    	return "skuCode";
    }
    
    public string function displayOptions(delimiter=" ") {
    	var options = getOptions(sorted=true);
    	var dspOptions = "";
    	for(var i=1;i<=arrayLen(options);i++) {
    		var thisOption = options[i];
    		dspOptions = listAppend(dspOptions,thisOption.getOptionName(),arguments.delimiter);
    	}
		return dspOptions;
    }
    
    // override generated setter to get options sorted by optiongroup sortorder
    public array function getOptions(boolean sorted = false) {
    	if(!sorted) {
    		return variables.options;
    	} else {
	    	if(!structKeyExists(variables,"sortedOptions")) {
		    	var options = ORMExecuteQuery(
		    		"select opt from SlatwallOption opt
		    		join opt.skus s
		    		where s.skuID = :skuID
		    		order by opt.optionGroup.sortOrder",
		    		{skuID = this.getSkuID()}
		    	);
		    	variables.sortedOptions = options;
	    	}
	    	return variables.sortedOptions;
	    }
    }

	/******* Association management methods for bidirectional relationships **************/
	
	// Product (many-to-one)
	
	public void function setProduct(required any Product) {
	   variables.product = arguments.product;
	   if(isNew() or !arguments.product.hasSku(this)) {
	       arrayAppend(arguments.product.getSkus(),this);
	   }
	}
	
	public void function removeProduct(any Product) {
	   if(!structKeyExists(arguments,"Product")) {
	   		arguments.Product = variables.product;
	   }
       var index = arrayFind(arguments.Product.getSkus(),this);
       if(index > 0) {
           arrayDeleteAt(arguments.Product.getSkus(),index);
       }    
       structDelete(variables,"Product");
    }
    
    // Option (many-to-many)
    public void function addOption(required any Option) {
        if(!hasOption(arguments.option)) {
        	// first add option to this Sku
        	arrayAppend(this.getOptions(),arguments.option);
        	// add this Sku to the option
        	arrayAppend(arguments.Option.getSkus(),this);
        }	
    }
    
    public void function removeOption(required any Option) {
       // first remove the option from this Sku
       if(hasOption(arguments.option)) {
	       var index = arrayFind(this.getOptions(),arguments.option);
	       if(index>0) {
	           arrayDeleteAt(this.getOptions(),index);
	       }
	      // then remove this Sku from the Option
	       var index = arrayFind(arguments.Option.getSkus(),this);
	       if(index > 0) {
	           arrayDeleteAt(arguments.Option.getSkus(),index);
	       }
	   }
    }
    
	// promotionRewards (many-to-many)
	public void function addPromotionReward(required any promotionReward) {
	   arguments.promotionReward.addSku(this);
	}
	
	public void function removePromotionReward(required any promotionReward) {
	   arguments.promotionReward.removeSku(this);
	}
	
    /************   END Association Management Methods   *******************/
    
    public string function getImageDirectory() {
    	return "#$.siteConfig().getAssetPath()#/assets/Image/Slatwall/product/default/";	
    }
    
    public string function getImagePath() {
    	return this.getImageDirectory() & this.getImageFile();
    }
    
    public numeric function getQOH() {
    	if(isNull(variables.qoh)) {
    		variables.qoh = 0;
    		var stocks = getStocks();
    		if(isDefined("stocks")) {
	    		for(var i = 1; i<= arrayLen(stocks); i++) {
	    			variables.qoh += stocks[i].getQOH();
	    		}
	    	}
    	}
    	return variables.qoh;
    }
    
    public numeric function getQC() {
    	if(isNull(variables.qc)) {
    		variables.qc = 0;
    		var stocks = getStocks();
    		if(isDefined("stocks")) {
	    		for(var i = 1; i<= arrayLen(stocks); i++) {
	    			variables.qc += stocks[i].getQC();
	    		}
	    	}
    	}
    	return variables.qc;
    }
    
    public numeric function getQEXP() {
       	if(isNull(variables.qexp)) {
    		variables.qc = 0;
    		var stocks = getStocks();
        	if(isDefined("stocks")) {
	    		for(var i = 1; i<= arrayLen(stocks); i++) {
	    			variables.qexp += stocks[i].getQEXP();
	    		}
    		}
    	}
    	return variables.qc;
    }
	
	/**
	/* @hint quantity immediately available
	*/
	public numeric function getQIA() {
		return getQOH() - getQC();
	}

	/**
	/* @hint quantity expected available
	*/	
	public numeric function getQEA() {
		return (getQOH() - getQC()) + getQEXP();
	}
	
	public string function getImage(string size, numeric width=0, numeric height=0, string alt="", string class="", string resizeMethod="scale", string cropLocation="",numeric cropXStart=0, numeric cropYStart=0,numeric scaleWidth=0,numeric scaleHeight=0) {
		// Get the expected Image Path
		var path=getImagePath();
		
		// If no image Exists use the defult missing image 
		if(!fileExists(expandPath(path))) {
			path = setting('product_missingimagepath');
		}
		
		// If there were sizes specified, get the resized image path
		if(structKeyExists(arguments, "size") || arguments.width != 0 || arguments.height != 0) {
			path = getResizedImagePath(argumentcollection=arguments);	
		}
		
		// Setup Alt & Class for the image
		if(arguments.alt == "") {
			arguments.alt = "#getProduct().getTitle()#";
		}
		if(arguments.class == "") {
			arguments.class = "skuImage";	
		}
		
		// Try to read and return the image, otherwise don't specify the height and width
		try {
			var img = imageRead(expandPath(path));
			return '<img src="#path#" width="#imageGetWidth(img)#" height="#imageGetHeight(img)#" alt="#arguments.alt#" class="#arguments.class#" />';	
		} catch(any e) {
			return '<img src="#path#" alt="#arguments.alt#" class="#arguments.class#" />';
		}
	}
	
	public string function getResizedImagePath(string size, numeric width=0, numeric height=0, string resizeMethod="scale", string cropLocation="",numeric cropXStart=0, numeric cropYStart=0,numeric scaleWidth=0,numeric scaleHeight=0) {
		if(structKeyExists(arguments, "size")) {
			arguments.size = lcase(arguments.size);
			if(arguments.size eq "l" || arguments.size eq "large") {
				arguments.size = "large";
			} else if (arguments.size eq "m" || arguments.size eq "medium") {
				arguments.size = "medium";
			} else {
				arguments.size = "small";
			}
			arguments.width = setting("product_imagewidth#arguments.size#");
			arguments.height = setting("product_imageheight#arguments.size#");
		}
		arguments.imagePath=getImagePath();
		return getService("utilityFileService").getResizedImagePath(argumentCollection=arguments);
	}
	
	public boolean function imageExists() {
		if( fileExists(expandPath(getImagePath())) ) {
			return true;
		} else {
			return false;
		}
	}
	
	public any function getOptionsByGroupIDStruct() {
		if(!structKeyExists(variables, "OptionsByGroupIDStruct")) {
			variables.OptionsByGroupIDStruct = structNew();
			var options = getOptions();
			for(var i=1; i<=arrayLen(options); i++) {
				if( !structKeyExists(variables.OptionsByGroupIDStruct, options[i].getOptionGroup().getOptionGroupID())){
					variables.OptionsByGroupIDStruct[options[i].getOptionGroup().getOptionGroupID()] = options[i];
				}
			}
		}
		return variables.OptionsByGroupIDStruct;
	}
	
	public any function getOptionByOptionGroupID(required string optionGroupID) {
		var optionsStruct = getOptionsByGroupIDStruct();
		return optionsStruct[arguments.optionGroupID];
	}
	
	// This will give the price based on User logged in, current term sales, volume discounts, ect.
	public numeric function getLivePrice() {
		var prices = [getPrice()];
		
		arrayAppend(prices, getBestPriceByLivePromotions());
		arrayAppend(prices, getPriceByCurrentAccount());
		
		arraySort(prices, "numeric", "asc");
		
		return prices[1];
	}
	
	public numeric function getBestPriceByLivePromotions() {
		//return getService("promotionService").calculateBestSkuPriceBasedOnLivePromotions(sku=this);
		return getPrice();
	}
	
	public numeric function getPriceByPromotion( required any promotion) {
		return getService("promotionService").calculateSkuPriceBasedOnPromotion(sku=this, promotion=arguments.promotion);
	}
	
	public numeric function getPriceByCurrentAccount() {
		return getService("priceGroupService").calculateSkuPriceBasedOnCurrentAccount(sku=this);
	}
	
	public numeric function getPriceByPriceGroup( required any priceGroup) {
		return getService("priceGroupService").calculateSkuPriceBasedOnPriceGroup(sku=this, priceGroup=arguments.priceGroup);
	}
	
	public any function getAppliedPriceGroupRateByPriceGroup( required any priceGroup) {
		return getService("priceGroupService").getRateForSkuBasedOnPriceGroup(sku=this, priceGroup=arguments.priceGroup);
	}
	
	// @hint this method validates that this skus has a unique option combination that no other sku has
	public any function hasUniqueOptions() {
		var optionsList = "";
		
		for(var i=1; i<=arrayLen(getOptions()); i++){
			optionsList = listAppend(optionsList, getOptions()[i].getOptionID());
		}
		
		var skus = getProduct().getSkusBySelectedOptions(selectedOptions=optionsList);
		if(!arrayLen(skus) || (arrayLen(skus) == 1 && skus[1].getSkuID() == getSkuID() )) {
			return true;
		}
		
		return false;
	}
	
	// @hint this method validates that this skus has a unique option combination that no other sku has
	public any function hasOneOptionPerOptionGroup() {
		var optionGroupList = "";
		
		for(var i=1; i<=arrayLen(getOptions()); i++){
			if(listFind(optionGroupList, getOptions()[i].getOptionGroup().getOptionGroupID())) {
				return false;
			} else {
				optionGroupList = listAppend(optionGroupList, getOptions()[i].getOptionGroup().getOptionGroupID());	
			}
		}
		
		return true;
	}
	
	//@hint Generates the image path based upon product code, and image options for this sku
	public string function generateImageFileName() {
		var optionString = "";
		for(var option in getOptions()){
			if(option.getOptionGroup().getImageGroupFlag()){
				optionString &= "-#option.getOptionCode()#";
			}
		}
		return "#getProduct().getProductCode()##optionString#.#setting('product_imageextension')#";
	}
	
	//@hint this method generated sku code based on assigned options
	public any function generateSkuCode () {
		var newSkuCode = getProduct().getProductCode();
		for(var option in getOptions() ) {
			newSkuCode = listAppend(newSkuCode,option.getOptionCode(),"-");
		}
		return newSkuCode;
	}

    // Override the preInsert method to set sku code and Image name
    public void function preInsert() {
    	if(isNull(getSkuCode()) || getSkuCode() == "") {
    		setSkuCode(generateSkuCode());
    	}
    	if(isNull(getImageFile()) || getImageFile() == "") {
    		setImageFile(generateImageFileName());
    	}
		super.preInsert();
    }
    
	
}
