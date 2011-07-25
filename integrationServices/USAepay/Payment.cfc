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

<cfcomponent accessors="true" output="false" displayname="USA epay" implements="Slatwall.integrationServices.PaymentInterface" >
	
	<cfproperty name="key" displayname="Source Key" type="string" />
	<cfproperty name="pin" displayname="Pin Number" type="string" />
	<cfproperty name="testingFlag" displayname="Testing Mode" type="boolean" />
	
	<cffunction name="init">

		<cfreturn this />
	</cffunction>
	
	<cffunction name="getPaymentMethods">
		<cfreturn "creditCard" />
	</cffunction>
	
	<cffunction name="getSupportedTransactionTypes">
		<cfreturn "authorize,authorizeAndCharge,chargePreAuthorization,credit,void" />
	</cffunction>
		
	<cffunction name="processCreditCard" returntype="Slatwall.com.utility.payment.CreditCardTransactionResponseBean">
		<cfargument name="requestBean" type="Slatwall.com.utility.payment.CreditCardTransactionRequestBean" />
		
		<cfset var q_auth = queryNew('empty') />
		
		<cfswitch expression="#arguments.requestBean.getTransactionType()#" >
			<cfcase value="authorize">
				<cfmodule template="usaepay.cfm"
					queryname="q_auth"
					key="#getKey()#"
					pin="#getPin()#"
					sandbox="#getTestingFlag()#"
					command="authonly"
					card="#arguments.requestBean.getCreditCardNumber()#"
					expdate="#left(arguments.requestBean.getExpirationMonth(),2)##left(arguments.requestBean.getExpirationYear(),2)#"
					amount="#arguments.requestBean.getTransactionAmount()#"
					invoice="#arguments.requestBean.getOrderID()#"
					CVV="#arguments.requestBean.getSecurityCode()#"
					email="#argumetns.requestBean.getAccountPrimaryEmailAddress()#"
					emailcustomer="false"
					custname="#arguments.requestBean.getAccountFirstName()# #argumetns.requestBean.getAccountLastName()#"						  
					avsstreet="#arguments.requestBean.getBillingStreetAddress()#"
					avszip="#arguments.requestBean.getBillingPostalCode()#"
					clientip="#cgi.REMOTE_ADDR#"
				>
			</cfcase>
			<cfcase value="authorizeAndCharge">
				<cfmodule template="usaepay.cfm"
					queryname="q_auth"
					key="#getKey()#"
					pin="#getPin()#"
					sandbox="#getTestingFlag()#"
					command="sale"
					card="#arguments.requestBean.getCreditCardNumber()#"
					expdate="#left(arguments.requestBean.getExpirationMonth(),2)##left(arguments.requestBean.getExpirationYear(),2)#"
					amount="#arguments.requestBean.getTransactionAmount()#"
					invoice="#arguments.requestBean.getOrderID()#"
					CVV="#arguments.requestBean.getSecurityCode()#"
					email="#argumetns.requestBean.getAccountPrimaryEmailAddress()#"
					emailcustomer="false"
					custname="#arguments.requestBean.getAccountFirstName()# #argumetns.requestBean.getAccountLastName()#"						  
					avsstreet="#arguments.requestBean.getBillingStreetAddress()#"
					avszip="#arguments.requestBean.getBillingPostalCode()#"
					clientip="#cgi.REMOTE_ADDR#"
				>
			</cfcase>
			<cfcase value="chargePreAuthorization">
				<!--- This needs to get changed for authorization code to show up number --->
				<cfmodule template="usaepay.cfm"
					queryname="q_auth"
					key="#getKey()#"
					pin="#getPin()#"
					sandbox="#getTestingFlag()#"
					command="capture"
					refnum="#arguments.requestBean.getProviderTransactionID()#"
					amount="#arguments.requestBean.getTransactionAmount()#"
					authcode=""
					clientip="#cgi.REMOTE_ADDR#"
				>
			</cfcase>
			<cfcase value="credit">
				<cfmodule template="usaepay.cfm"
					queryname="q_auth"
					key="#getKey()#"
					pin="#getPin()#"
					sandbox="#getTestingFlag()#"
					command="refund"
					invoice="#arguments.requestBean.getOrderID()#"
					refnum="#arguments.requestBean.getProviderTransactionID()#"
					amount="#arguments.requestBean.getTransactionAmount()#"
					custname="#arguments.requestBean.getAccountFirstName()# #argumetns.requestBean.getAccountLastName()#"						  
					clientip="#cgi.REMOTE_ADDR#"
				>
			</cfcase>
			<cfcase value="void">
				<cfmodule template="usaepay.cfm"
					queryname="q_auth"
					key="#getKey()#"
					pin="#getPin()#"
					sandbox="#getTestingFlag()#"
					command="void"
					invoice="#arguments.requestBean.getOrderID()#"
					refnum="#arguments.requestBean.getProviderTransactionID()#"
					amount="#arguments.requestBean.getTransactionAmount()#"
					custname="#arguments.requestBean.getAccountFirstName()# #argumetns.requestBean.getAccountLastName()#"						  
					clientip="#cgi.REMOTE_ADDR#"
				>
			</cfcase>
		</cfswitch>
		
		<!--- Setup Response Bean --->
		<cfset var responseBean = createObject("component", "Slatwall.com.utility.payment.CreditCardTransactionResponseBean").init() />
		
		<cfreturn responseBean />
	</cffunction>
	
</cfcomponent>