/*
** dataHolder.as **  
*
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*
*
*/ 
package net.gltd.gtms.model{
	import net.gltd.gtms.controller.xmpp.Connection;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	import net.gltd.gtms.view.SearchBar;
	
	import flash.events.EventDispatcher;
	
	import mx.containers.ViewStack;
	
	import spark.components.Window;


	public class dataHolder extends EventDispatcher {

		public	static	var dH					:dataHolder;
		 
		[Bindable]
		public			var	connection			:Connection;
		
		
		/** **/
		public			var openNewWindow			:Function,
							openAlert				:Function,
							sysNotify				:Function,
							searchBar				:SearchBar,
							searchBarOption			:String,
							ignoreMessageSubjects	:Array = [],
							ignoreMessageSenders	:Object = {},
							myShow					:String,
							myStatus				:String,
							interfaces				:ViewStack,
							rosterFilter			:String ="",
							triggerEvents			:Object,
							currentSystem			:DiscoItemModel,
							globalGroupMenuItems	:Array = [],
							defaultOpenlinkInterest	:String,
							makeVideoCall			:Function,
							flashVideoEnabled		:Boolean = false;
		 
		public static function getInstance():dataHolder {
			if (dH == null) {
				dH=new dataHolder(arguments.callee);	
			}
			return dH;
		}
		public function dataHolder(caller:Function=null) {
			if (caller != dataHolder.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}
			if (dataHolder.dH != null) {
				throw new Error("Error");
			}
		}
		public function getWindow(title:String,open:Boolean=true,stick:String="none",width:uint=300,height:uint=300,minimizable:Boolean=false,maximizable:Boolean=false,closeable:Boolean=false,resizable:Boolean=false,windowName:String=null):Window{
			return openNewWindow(title, open,stick, width, height, minimizable, maximizable, closeable, resizable,windowName)
		}
	 
	
	}
}