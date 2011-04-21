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
component output="false" {

	variables.assetWirePath = "/plugins/Slatwall/assetWire/";
	variables.baseJSAssetPath = "/plugins/Slatwall/assets/js/";
	variables.baseCSSAssetPath = "/plugins/Slatwall/assets/css/";
	variables.jQueryPath = "/admin/js/jquery/jquery.js";
	/* can't use Google CDN for local development, as sometimes I don't have network access
	variables.jQueryPath = "//ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.js";
	*/
	
	variables.framework = "";
	variables.jsVariables = [];
	variables.jsAssets = [];
	variables.cssAssets = [];
		
	public void function init(required any framework) {
		variables.framework = arguments.framework;
	}
	
	public void function wireFW1() {
		includeJSAsset("global.js");
		includeCSSAsset("global.css");
		if(structKeyExists(request, "view")) {
			addViewToAssets(request.view);	
		}
	}
	
	public any function getJSAssets() {
		return variables.jsAssets;
	}
	
	public void function addViewToAssets(required string view) {
		var frameworkConfig = variables.framework.getConfig();
		
		if(frameworkConfig.usingsubsystems) {
			// Subsystem Related
			includeJSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#.js");
			includeCSSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#.css");
			
			// Section Related
			includeJSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#-#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.js");
			includeCSSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#-#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.css");
			
			// Item Related
			includeJSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#-#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.#Replace(listLast(arguments.view,'/'),'.cfm','.js')#");
			includeCSSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-3,'/')#-#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.#Replace(listLast(arguments.view,'/'),'.cfm','.css')#");
		} else {
			// Section Related
			includeJSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.js");
			includeCSSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.css");
			
			// Item Related
			includeJSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.#Replace(listLast(arguments.view,'/'),'.cfm','.js')#");
			includeCSSAsset("#listGetAt(arguments.view,listLen(arguments.view,'/')-1,'/')#.#Replace(listLast(arguments.view,'/'),'.cfm','.css')#");
		}
	}
	
	public void function addJSVariable(required string name, required any value){
		
		if(isStruct(arguments.value) || isArray(arguments.value)) {
			arrayAppend(variables.jsVariables, {"#arguments.name#" = serializeJSON(arguments.value)});
		} else if (isNumeric(arguments.value)) {
			arrayAppend(variables.jsVariables, {"#arguments.name#" = arguments.value});
		} else if (isSimpleValue(arguments.value)) {
			arrayAppend(variables.jsVariables, {"#arguments.name#" = "'#arguments.value#'"});
		}
		
	}
	
	public void function includeJSAsset(required string asset, boolean preAppend = false, boolean lazy = true){
		if(fileExists(expandPath("#variables.baseJSAssetPath##arguments.asset#")) && !arrayContains(variables.jsAssets, arguments.asset)) {
			if(arguments.preAppend) {
				arrayInsertAt(variables.jsAssets,1,arguments.asset);	
			} else {
				arrayAppend(variables.jsAssets, arguments.asset);
			}
		}
	}
	
	public void function includeCSSAsset(required string asset, boolean preAppend = false){
		if(fileExists(expandPath("#variables.baseCSSAssetPath##arguments.asset#")) && !arrayContains(variables.cssAssets, arguments.asset)) {
			if(arguments.preAppend) {
				arrayInsertAt(variables.cssAssets,1,arguments.asset);	
			} else {
				arrayAppend(variables.cssAssets, arguments.asset);
			}
		}
	}
	
	public string function getAllAssets() {
		var allAssets = "";
		
		// Add all Scripts
		allAssets &= '#chr(10)#<!-- Asset Wire Automatic Wiring Start -->#chr(10)##chr(10)#';
		allAssets &= '<script src="#variables.jQueryPath#" type="text/javascript"></script>#chr(10)#';
		allAssets &= '<script src="#variables.assetWirePath#jquery.use.min.js" type="text/javascript"></script>#chr(10)#'; 
		
		if(arrayLen(variables.jsVariables) || arrayLen(variables.jsAssets)) {
			allAssets &= '<script type="text/javascript">#chr(10)#';
			
			for(var i=1; i<=arrayLen(variables.jsAssets); i++){
				allAssets &= "#chr(9)#$.use('#variables.baseJSAssetPath##variables.jsAssets[i]#');#chr(10)#";
			}
			allAssets &= '#chr(10)#';
			for(var i=1; i<=arrayLen(variables.jsVariables); i++){
				allAssets &= '#chr(9)#var #structKeyList(variables.jsVariables[i])# = #variables.jsVariables[i][structKeyList(variables.jsVariables[i])]#;#chr(10)#';
			}
			
			allAssets &= '</script>#chr(10)#';
		}
		
		// Add all CSS			
		for(var i=1; i<=arrayLen(variables.cssAssets); i++){
			allAssets &= '<link rel="stylesheet" href="#baseCSSAssetPath##variables.cssAssets[i]#" type="text/css" />#chr(10)#';	
		}
		allAssets &= '#chr(10)#<!-- Asset Wire Automatic Wiring End -->#chr(10)#';
		
		return allAssets;
	}
}