package net.gltd.gtms.model.app
{
	import net.gltd.gtms.events.ExtensionEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Application;
	
	
	public class ExtensionModel extends EventDispatcher
	{
		private		var	_name				:String,
						_ico				:Object,
						_removable			:Boolean = true,
						_settingsContent	:Object,
						_pluginData			:PluginData,
						_btIco				:Class;
						
		[Bindable]
		public 		var	label				:String;
		
		public		var	id					:String,
						btCallBack			:Function,
						kill				:Function,
						needReboot			:Boolean,
						minCoreVersion		:String = "0";
						
		
		
		
		public function ExtensionModel(name:String,ico:Object)
		{
			this.name = name;
			this.ico = ico;
			this.label = name;
			
		}
		public function set pluginData(pd:PluginData):void {
			_pluginData = pd;
			name		= _pluginData.name;
			label		= name;
			id			= _pluginData.id;
			ico			= _pluginData.ico;
			removable	= true;
			
		}
		public function loadContent(data:ByteArray):void {
			try {
				var pluginLoaderContext:LoaderContext = new LoaderContext();
				pluginLoaderContext.allowLoadBytesCodeExecution = true;

				var swf:SWFLoader = _pluginData.swf;
				swf.loaderContext = pluginLoaderContext;
				swf.addEventListener(Event.INIT,onComplete);
				swf.load ( data );	
			}catch (error:Error){
	
	
			}
		}
		private function onComplete(event:Event):void {
			var swf:SWFLoader = event.currentTarget as SWFLoader;
			SystemManager(swf.content).addEventListener(FlexEvent.APPLICATION_COMPLETE,onAppComp);
		}
		private function onAppComp(event:FlexEvent):void {
			_pluginData.plugin = ((event.currentTarget as SystemManager).application as Application);
			if (_pluginData.plugin.hasOwnProperty('settings') ) {
				settingsContent = _pluginData.plugin['settings'];
			}
			if (_pluginData.plugin.hasOwnProperty('kill') ) {
				kill = _pluginData.plugin['kill'];
			}
			if (_pluginData.plugin.hasOwnProperty('needRestartAfterInstall') ) {
				needReboot = _pluginData.plugin['needRestartAfterInstall'];
			}
			if (_pluginData.plugin.hasOwnProperty('minCoreVersion') ) {
				minCoreVersion = _pluginData.plugin['minCoreVersion'];
			}
			
			
			dispatchEvent( new ExtensionEvent(ExtensionEvent.PLUGIN_READY) )
		}
		
		private function onError(event:ErrorEvent):void {
			trace (event.errorID)
		}
		private function onIOError(e:IOErrorEvent):void {
			trace ("onIOError",e.errorID);
		}
		public function get pluginData():PluginData{
			return _pluginData;	
		}
		
		
		public function set name(n:String):void {
			_name = n;
		}
		[Bindable]
		public function get name():String {
			return _name;
		}
		
		public function set ico(n:Object):void {
			_ico = n;
		}
		[Bindable]
		public function get ico():Object {
			return _ico;
		}
		
		public function set removable(b:Boolean):void {
			_removable = b;
		}
		[Bindable]
		public function get removable():Boolean {
			return _removable;
		}
		
		public function set settingsContent(b:*):void {
			_settingsContent = b;
		}
		[Bindable]
		public function get settingsContent():* {
			return _settingsContent;
		}
		
		public function set btIco(b:Class):void {
			_btIco = b;
		}
		[Bindable]
		public function get btIco():Class {
			return _btIco;
		}
		
		
	}
}