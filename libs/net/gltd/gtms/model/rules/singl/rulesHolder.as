package net.gltd.gtms.model.rules.singl{
	
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	import net.gltd.gtms.model.rules.RuleModel;
	import net.gltd.gtms.model.rules.RuleStystemModel;
	import net.gltd.gtms.model.rules.RuleSubsystemModel;
	import net.gltd.gtms.model.rules.RuleTriggerEvent;
	import net.gltd.gtms.utils.FilterArrayCollection;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;

	
	
	public class rulesHolder extends EventDispatcher {

		public static  	var dH						:rulesHolder;
		
		[Bindable]
		public			var	systems					:FilterArrayCollection = new FilterArrayCollection([]);
		
		public			var	triggerEventsObject		:Object = {};
		
		[Bindable]
		public			var	actionType				:ArrayCollection = new ArrayCollection([{label:"Screenpop",value:"screenpop"},{label:"Create Event",value:"CreateEvent",enabled:false},{label:"Create Action",value:"CreateAction",enabled:false}]);			
		
		 
		
		public static function getInstance(): rulesHolder {
			if (dH == null) {
				dH = new rulesHolder(arguments.callee);
			}
			return dH;

		}
		
		public static function destroy():void {
			dH = null;
		}

		public function rulesHolder(caller:Function=null) {
			
			if (caller != rulesHolder.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}else {
		//		resetRules();
			}
			
			if (rulesHolder.dH != null) {
				throw new Error("Error");
			}
		}	
		public function resetRules():void {
			trace ("\n\n\ resetRules \n\n");
			//systems = new FilterArrayCollection([]);
		}
		public function addRule(systemName:String,systemValue:String,subsystems:FilterArrayCollection=null,events:ArrayCollection=null):RuleStystemModel {
			var model:RuleStystemModel = new RuleStystemModel(systemName,systemValue);
			model.triggerEvent = events;
			model.subsystems = subsystems;
			systems.addItem( model );
			return model;
		}
		public function addEventToRule(system:String,label:String,value:String):void {
			try {
				var _sys:RuleStystemModel = systems.getItemByID( system ) as RuleStystemModel;
				_sys.addTriggerEvent(  new RuleTriggerEvent(label,value) );
			}catch (error:Error){
				
			}
			
		}
		public function addSubsystemToRule(system:String,label:String,value:String):void {
			try {
				var _sys:RuleStystemModel = systems.getItemByID( system ) as RuleStystemModel;
				_sys.addSubsystem(   new RuleSubsystemModel(label,value)  );
			}catch (error:Error){
				
			}
			
		}
		
		public function initLookupFields():ArrayCollection {
			try {
				var paramsLookup:ArrayCollection = new ArrayCollection();
				var vCardHomeFields:Object = {};
				var vCardWorkFields:Object = {};
				var rosterFields:Object = {};
				rosterFields['roster'] = "JID";
				rosterFields['nickname'] = "Display Name";
				
				var ind:String;
				var _bh:buddiesHolder = buddiesHolder.getInstance();
				for (var i:uint = 0; i<_bh.length;i++){
					var bd:BuddyModel = _bh.getBuddy(i);
					if (bd.hasOwnProperty("gtmsVCard")){
				
						for ( var iin:uint = 0; iin< bd['gtmsVCard'].customFields.length;iin++){
							if (bd['gtmsVCard'].customFields[iin].type.toLowerCase() == "home"){
								vCardHomeFields[ bd['gtmsVCard'].customFields[iin].name ] = bd['gtmsVCard'].customFields[iin].name;
							}else if (bd['gtmsVCard'].customFields[iin].type.toLowerCase() == "work"){
								vCardWorkFields[  bd['gtmsVCard'].customFields[iin].name ] = bd['gtmsVCard'].customFields[iin].name;
							}
						}
						for ( ind in bd['gtmsVCard'].phones){
							if (bd['gtmsVCard'].phones[ind].type.text[0] == "Home"){
								vCardHomeFields[ bd['gtmsVCard'].phones[ind].name ] = bd['gtmsVCard'].phones[ind].type.text[1]
							}else if (bd['gtmsVCard'].phones[ind].type.text[0] == "Work"){
								vCardWorkFields[ bd['gtmsVCard'].phones[ind].name ] = bd['gtmsVCard'].phones[ind].type.text[1]
							}
						}
					}
				}
			
				var indI:uint = 0;
				for (ind in rosterFields){
					paramsLookup.addItem({label:rosterFields[ind],value:ind,enabled:true});
				}
			//	paramsLookup.addItem({label:"Work:",velue:"",enabled:false});
				indI = 0;
				for (ind in vCardWorkFields){
					if (indI++==0)paramsLookup.addItem({label:"Work:",velue:"",enabled:false});
					paramsLookup.addItem({label:vCardWorkFields[ind],value:ind,enabled:true});
				}
				indI = 0;
				for (ind in vCardHomeFields){
					if (indI++==0)paramsLookup.addItem({label:"Home:",velue:"",enabled:false});
					paramsLookup.addItem({label:vCardHomeFields[ind],value:ind,enabled:true});
				}
				
				
			}catch (error:Error){
				
			}
			return paramsLookup;
			
		}
		public function addContact(scope:Array):void {
			
		}
		public function linkContacts(scope:Array):void {
			
		}
		public function lookup(scope:Array,param:String):String {
			var phs:Object;
			var i:int;
			var ind:String;
			
			try {
				if (param == "jid" ){
					for (i=0;i<scope.length;i++){
						if (scope[0].hasOwnProperty('roster')){
							return scope[0]['roster'].jid.bareJID;
						}
					}
				}else {
					for (i=0;i<scope.length;i++){
						if (scope[0].hasOwnProperty(param)){
							return scope[0][param].toString();
						}
					}
				}
			}catch (error:Error){
				
			}
			
		
			for (i=0;i<scope.length;i++){
				try {
					var custf:Array = scope[i]["gtmsVCard"]["customFields"];
					for (var iind:uint =0; iind<custf.length;iind++){
						try {
							if (custf[iind].name.toLowerCase() == param.toLowerCase() || (custf[iind].name as String).toLowerCase().indexOf( param.toLowerCase() ) == 0){
								return custf[iind].value.toString();
							}
						}catch (error:Error){
							
						}
					}
				}catch (er1:Error){
					
				}
				try {
					phs = scope[i]["phones"];
					for (ind in phs){
						try {
							if (phs[ind].name.toLowerCase() == param.toLowerCase() || (phs[ind].name as String).toLowerCase().indexOf( param.toLowerCase() ) == 0){
								return phs[ind].phone.toString();
							}
						}catch (error:Error){
							
						}
					}
			
				}catch (er2:Error){
					
				}
			}
			return null
		}
		public function getURL(rule:RuleModel,vars:Object):URLRequest {
			var urlString:String = rule.actionURL;
			var ind:String;
			var paramsString:String = "";
			if (urlString.indexOf("://") < 0){
				urlString="http://"+urlString;
			}
			if (rule.urlType == "#"){
			
			//	if (urlString.indexOf("/") != urlString.length-1)urlString+="/";
				urlString+="#";
				var i:uint = 0;
				for (ind in vars){
					if (i>0)paramsString+="&"
					paramsString += ind+"="+vars[ind];
					i++;
				}
				trace ("urlString+paramsString",urlString+paramsString)
				return new URLRequest(urlString+paramsString);
			}else if (rule.urlType == "/"){
				if (urlString.lastIndexOf("/") != urlString.length-1)urlString+="/";
				for (ind in vars){
					if (i>0)paramsString+="/"
					paramsString += vars[ind];
					i++;
				}
				trace ("urlString+paramsString",urlString+paramsString)
				return new URLRequest(urlString+paramsString);
			}
			var params:URLVariables = new URLVariables();
			for (ind in vars){
				params[ind] = vars[ind]
			}
			var urlR:URLRequest = new URLRequest(urlString);
			urlR.method = rule.urlType;
			urlR.data = params;
			
			trace(	urlR.url);
			return urlR;
		}
		
		
	}
}