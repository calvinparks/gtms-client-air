package net.gltd.gtms.controller.app
{

	import com.adobe.ucf.UCFSignatureValidator;
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.events.ExtensionEvent;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.model.app.ExtensionModel;
	import net.gltd.gtms.model.app.PluginData;
	import net.gltd.gtms.utils.FilterArrayCollection;
	import net.gltd.gtms.view.app.utilities.extensions.LanguageSettingsContent;
	import net.gltd.gtms.view.app.utilities.extensions.ThemeSettingsContent;
	
	import flash.desktop.NativeApplication;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.utils.UIDUtil;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipEvent;
	import deng.fzip.FZipFile;
	
	import flashx.textLayout.elements.BreakElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	
	
	public class ExtensionManager extends EventDispatcher
	{
		[Bindable]
		public			var		browser				:FilterArrayCollection;
		
		public	static	var		dH					:ExtensionManager;
		
		
		private			var		_fr					:FileReference,
								_tmpDir				:File,
								_zipFileParseError	:Boolean,
								_pluginHome			:File,
								_browseFile			:File,
								_toDel				:int;
		
		[Bindable]
		private			var		pluginDP			:ArrayCollection;
		
		private const AIR_NS:Namespace = new Namespace("http://ns.adobe.com/air/application/4.0");
		//private const AIR_NS:Namespace = new Namespace("http://ns.adobe.com/air/application/3.1");
		
		
		
		public static function getInstance():ExtensionManager {
		
			if (dH == null) {
				dH=new ExtensionManager(arguments.callee);	
			}
			return dH;
		}
		public function ExtensionManager(caller:Function=null) {
			if (caller != ExtensionManager.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}else {
				init();
			}
			if (ExtensionManager.dH != null) {
				throw new Error("Error");
			}
		}
		public function init():void {
			browser = new FilterArrayCollection([],"id");
			
			addBuildIn();
			addInstalled();
			
			File.applicationDirectory
			_pluginHome = File.applicationStorageDirectory.resolvePath("plugins_v3");
			if (!_pluginHome.exists) _pluginHome.createDirectory();
			pluginDP = new ArrayCollection();
			var pluginDirs:Array = _pluginHome.getDirectoryListing();				
			for each (var pluginDir:File in pluginDirs)
			{
				var pluginData:PluginData = getPluginDataFromDir(pluginDir);
			
				if (pluginData == null)
				{
					continue;
				}
				if (pluginData.id.split(".").pop() == "muc") continue;
				pluginDP.addItem(pluginData);
				addPlugin(pluginData)
			}	
		}
		
		private function addPlugin(pd:PluginData,installing:Boolean=false,reset:Boolean=false):void {
			/*try {
				if (pd.id.split('.').pop() == "muc") {
					setTimeout(console, 200,"Plugin is incompatible","error");
					return;
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}*/
			if (reset){
				
				try {
					setTimeout(console, 200,"Restarting "+FlexGlobals.topLevelApplication.name+"...","success");
					setTimeout(FlexGlobals.topLevelApplication.reboot,5000);
				}catch (error:Error){
					MLog.Log(error.getStackTrace());
				}
				return;
			}
			var m:ExtensionModel = new ExtensionModel(null,null);
			m.addEventListener(ExtensionEvent.PLUGIN_READY,onSWFLoaded);
			m.pluginData = pd;
			browser.addItem(m);
			browser.refresh();
			m.loadContent(	getFileBytes(pd.pluginFile)	);
			if (installing) m.addEventListener(ExtensionEvent.PLUGIN_READY,onLoadingComplete,false,-1);
		}
		private function onLoadingComplete(event:ExtensionEvent):void {
			try {
				
			/*	if ( (event.currentTarget as ExtensionModel).minCoreVersion != "0"){
					//var (event.currentTarget as ExtensionModel).minCoreVersion
					if (){
						
					}
					
					console("That is an incompatible plugin version","error");	
				}*/
				
				
				if ( (event.currentTarget as ExtensionModel).needReboot === true){
					setTimeout(console, 200,"Installation Successful, Restarting "+FlexGlobals.topLevelApplication.name+"...","success");
					setTimeout(FlexGlobals.topLevelApplication.reboot,5000);
					return;
				}
				console("Installation Successful","success");
				setTimeout(closeConsole,1000);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		
		private function onSWFLoaded(event:ExtensionEvent):void {
			var m:ExtensionModel = (event.currentTarget as ExtensionModel)
			var e:ExtensionEvent = new ExtensionEvent(ExtensionEvent.PLUGIN_READY);
			e.data = event.currentTarget as ExtensionModel;
			dispatchEvent(e);
		}
		private function addBuildIn():void {
			var langauge:ExtensionModel = new ExtensionModel("Languages","/assets/_ico/language.png");
			var theme:ExtensionModel = new ExtensionModel("Themes","/assets/_ico/theme.png");
			
			langauge.id = NativeApplication.nativeApplication.applicationID+".langs";
			langauge.removable = false;
			langauge.settingsContent = new LanguageSettingsContent();
			
			theme.removable = false;
			theme.settingsContent = new ThemeSettingsContent();
			theme.id = NativeApplication.nativeApplication.applicationID+".themes";
			
			browser.addItem(langauge);
			browser.addItem(theme);
		}
		private function addInstalled():void {
			
		}
		
		
		public function browsePlugins():void {
			if (_browseFile == null)
			{
				_browseFile = File.userDirectory;
				_browseFile.addEventListener(Event.SELECT, onPluginSelected);
			}
			//[new FileFilter("Plugins", ".zip")]
			_browseFile.browseForOpen("Select the plugin you want to install.",[new FileFilter("*", "*.zip")] );
		}
		private function onPluginSelected(e:Event):void
		{
			initConsole();
			try {
				setTimeout(function(file:File):void {
					var chosenFile:File = file;
					var fileBytes:ByteArray = getFileBytes(chosenFile);
					parseZipFile(fileBytes);
				},300,e.target as File);
			}catch (error:Error) {
				console("File Error","error");	
				MLog.Log(error.getStackTrace());
			}
		}
	
	

		private function parseZipFile(data:ByteArray):void
		{
			_zipFileParseError = false;
			createTmpDir();
			var zip:FZip = new FZip();
			zip.addEventListener(FZipEvent.FILE_LOADED, onFileFound);
			zip.addEventListener(Event.COMPLETE, onZipFileComplete);
			zip.addEventListener(FZipErrorEvent.PARSE_ERROR, onZipFileParseError);
			zip.addEventListener(IOErrorEvent.IO_ERROR, onZipFileIOError);
			console("Unzipping plugin...")
			zip.loadBytes(data);
		}
		private function createTmpDir():void
		{
			var tmp:File = File.createTempDirectory();
			_tmpDir = tmp.resolvePath(UIDUtil.createUID());
			_tmpDir.createDirectory();
		}
		private function onFileFound(e:FZipEvent):void
		{
			try
			{
			
				if (e.file.filename.toLocaleLowerCase().indexOf("application.xml") > -1)
				{
					var pluginXML:XML = new XML(e.file.content);
					var pluginId:String = pluginXML.AIR_NS::id;
					var pluginV:String = pluginXML.AIR_NS::versionNumber;
					for (var i:uint = 0; i<pluginDP.length;i++)
					{
						if ( (pluginDP.getItemAt(i).id == pluginId) && (pluginDP.getItemAt(i).version != pluginV) ){
							_toDel = i;
							// delete old
						}else if ( (pluginDP.getItemAt(i).id == pluginId) && (pluginDP.getItemAt(i).version == pluginV) )
						{
							
							console("This plugin is already installed. You can't install multiple instances of the same plugin.")
							console("Installation aborted","error");
							var zip:FZip = e.target as FZip;
							zip.removeEventListener(FZipEvent.FILE_LOADED, onFileFound);
							zip.removeEventListener(Event.COMPLETE, onZipFileComplete);
							zip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onZipFileParseError);
							zip.removeEventListener(IOErrorEvent.IO_ERROR, onZipFileIOError);
							return;
						}
					}
				}
				var zFile:FZipFile = e.file;
				console("Saving " + zFile.filename)
				var f:File = _tmpDir.resolvePath(zFile.filename);
				if (zFile.content.length == 0)
				{
					f.createDirectory();
				}
				else
				{
					var fs:FileStream = new FileStream();
					fs.open(f, FileMode.WRITE);
					fs.writeBytes(zFile.content, 0, zFile.content.length);
					fs.close();
				}
			}
			catch(er:Error)
			{
				if (!_zipFileParseError)
				{
					console("Unable to unzip this plugin: " + er.message, "error")
				}
				_zipFileParseError = true;
				
				MLog.Log(er.getStackTrace());
			}
		}
		
		private function onZipFileComplete(e:Event):void
		{
			var zip:FZip = e.target as FZip;
			zip.removeEventListener(FZipEvent.FILE_LOADED, onFileFound);
			zip.removeEventListener(Event.COMPLETE, onZipFileComplete);
			zip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onZipFileParseError);
			zip.removeEventListener(IOErrorEvent.IO_ERROR, onZipFileIOError);
			if (!_zipFileParseError)
			{
				console("Plugin unzipped. Started signature validation.","success")
				startValidation();
			}
		}
		private function onZipFileParseError(e:FZipErrorEvent):void
		{
			var zip:FZip = e.target as FZip;
			zip.removeEventListener(FZipEvent.FILE_LOADED, onFileFound);
			zip.removeEventListener(Event.COMPLETE, onZipFileComplete);
			zip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onZipFileParseError);
			zip.removeEventListener(IOErrorEvent.IO_ERROR, onZipFileIOError);
			if (!_zipFileParseError)
			{
				console("Package Parse Error, Unable to unpackage this plugin: " + e.text,"error")
			}
			_zipFileParseError = true;
		}
		
		private function onZipFileIOError(e:IOErrorEvent):void
		{
			var zip:FZip = e.target as FZip;
			zip.removeEventListener(FZipEvent.FILE_LOADED, onFileFound);
			zip.removeEventListener(Event.COMPLETE, onZipFileComplete);
			zip.removeEventListener(FZipErrorEvent.PARSE_ERROR, onZipFileParseError);
			zip.removeEventListener(IOErrorEvent.IO_ERROR, onZipFileIOError);
			if (!_zipFileParseError)
			{
				console ("Package IO Error, Unable to unpackage this plugin: " + e.text, "error");
			}
			_zipFileParseError = true;
		}
		
		private function getFileBytes(f:File):ByteArray
		{
			try {
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.READ);
				var bytes:ByteArray = new ByteArray();
				fs.readBytes(bytes, 0, fs.bytesAvailable);
				fs.close();
				return bytes;
			}catch (error:Error){
				console(error.message,"error");
				trace(error.getStackTrace());
			}
			return null;
		}
		
		private function startValidation():void
		{
			console ("Beginning signature validation...")
			var validator:UCFSignatureValidator = new UCFSignatureValidator();
			validator.useSystemTrustStore = true;
			validator.packageRoot = _tmpDir;
			validator.addEventListener(ErrorEvent.ERROR, onValidationError);
			validator.addEventListener(Event.COMPLETE, onValidationComplete);
			
			try
			{
				validator.verify();
			}
			catch (e:Error)
			{
				validator.removeEventListener(ErrorEvent.ERROR, onValidationError);
				validator.removeEventListener(Event.COMPLETE, onValidationComplete);
				console ("Validation Error "+ e.message + " Plugin invalid","error");
	//this.showError("Validation Error", e.message, "Plugin invalid", true);
				trace(e.getStackTrace());
			}
		}
		
		private function onValidationComplete(e:Event):void
		{
			var validator:UCFSignatureValidator = e.target as UCFSignatureValidator;
			validator.removeEventListener(ErrorEvent.ERROR, onValidationError);
			validator.removeEventListener(Event.COMPLETE, onValidationComplete);
			console ("Signature validation complete","success")
			
			var pluginXMLFile:File = _tmpDir.resolvePath("META-INF/AIR/application.xml");
			var pluginXMLBytes:ByteArray = getFileBytes(pluginXMLFile);
			if (pluginXMLBytes == null){
				console("Signature validation error","error")
				return
			}
			var pluginXML:XML = new XML(pluginXMLBytes);
			var pub:String = validator.xmlSignatureValidator.signerCN;
			if (pub == null || pub.length == 0)pub = "UNKNOWN";
			
			var tf:TextFlow = new TextFlow();
			tf.textAlign = "left";
			tf.verticalAlign = "top";
			
			var div:ParagraphElement = new ParagraphElement()

			var _n:SpanElement = new SpanElement();
			_n.fontSize = 14;
			_n.fontWeight = "bold";
			_n.text =  pluginXML.AIR_NS::name + " v"+pluginXML.AIR_NS::versionNumber+"\n"
			div.addChild(_n);
			
			var br:BreakElement = new BreakElement();
			div.addChild(br);
			
			var pluginId:String = pluginXML.AIR_NS::id;
			var pluginV:String = pluginXML.AIR_NS::versionNumber;
			var exist:Boolean = false;
			var remId:String;
			var yesLabel:String;
			var noLabel:String;
			for (var i:uint = 0;i<pluginDP.length;i++){
				if ( (pluginDP.getItemAt(i).id == pluginId) ){
					exist = true;
					remId = pluginDP.getItemAt(i).id;
					break
				}
			}
			if (exist){
				var _ex:SpanElement = new SpanElement();
				_ex.text = "The Application you are about to install already exist.";
				_ex.fontSize = 11;
				div.addChild(_ex);
				
				br = new BreakElement();
				div.addChild(br);
				br = new BreakElement();
				div.addChild(br);
				
				var _in:SpanElement = new SpanElement();
				_in.text = "Installed Version:\t\t"+pluginDP.getItemAt(i).version;
				_in.fontSize = 11;
				div.addChild(_in);
				
				br = new BreakElement();
				div.addChild(br);
				
				var _tb:SpanElement = new SpanElement();
				_tb.text = "Version to be Installed:\t"+pluginV;
				_tb.fontSize = 11;
				div.addChild(_tb);
				_in.fontWeight = "bold";
				_tb.fontWeight = "bold"
				
				yesLabel = "Replace";
				noLabel = "Cancel";
				
			}else {
				
				yesLabel = "Yes";
				noLabel = "No";
				
				var _d:SpanElement = new SpanElement();
				_d.fontSize = 11;
				_d.text = pluginXML.AIR_NS::description+"\n"
				div.addChild(_d);
			
				br = new BreakElement();
				div.addChild(br);
			
				var _pi:SpanElement = new SpanElement();
				_pi.text = "Publisher Identity:  ";
				div.addChild(_pi);
				var _vl:SpanElement = new SpanElement();
			
				if (validator.xmlSignatureValidator.validityStatus == "valid"){
					_vl.text = "VERIFIED";
					_vl.color = 0x00eF00;
				}else {
					_vl.text = "NOT VERIFIED";
					_vl.color = 0xeF92424;
				}
				_vl.fontSize = _pi.fontSize = 11;
				_vl.fontWeight = "bold";
				div.addChild(_vl);
			}
			
			tf.addChild(div);
			dataHolder.getInstance().openAlert("Are you sure you want to install this plugin?",
				tf,
				[{label:yesLabel,callBack:onConfirm,params:[true,remId]},{label:noLabel,callBack:onConfirm,params:[false]}])
			
			//onConfirm(true);
		}
		public function onConfirm(c:Boolean,remId:String=null):void {
			if (c)
			{
					
				try {
					if (remId!=null)removePlugin(remId)
					var destination:File = _pluginHome.resolvePath(_tmpDir.name);
					_tmpDir.moveTo(destination, true);
					var newPluginDir:File = _pluginHome.resolvePath(_tmpDir.name);
					var pluginData:PluginData = getPluginDataFromDir(newPluginDir);
					
					if (pluginData==null){
						console("That is an incompatible plugin version","error");	
						newPluginDir.deleteDirectory(true);
						return;
					}
					pluginDP.addItemAt(pluginData, 0);
					addPlugin(pluginData,true,remId!=null);
					console("Copy Files...");
				}catch(e:Error){
					console ("Installation Failed, The installation of this plugin failed: " + e.message, "error");
					return;
				}
			}
			else
			{
				console("Plugin installation aborted","error");
				
			}
		}
		public function removePlugin(id:String):void {
			var pluginData:PluginData;
			for (var i:uint = 0; i<pluginDP.length;i++){
				if (pluginDP.getItemAt(i).id == id){
					pluginData = pluginDP.getItemAt(i) as PluginData;
					break;
				}
			}
			var pluginFile:File = _pluginHome.resolvePath(pluginData.pluginPath);
			try
			{
				pluginFile.deleteDirectory(true);
				
				
			}
			catch(e:IOError)
			{
				trace (e.getStackTrace());
			}
			
			
			try {
				var m:ExtensionModel = browser.getItemByID(id) as ExtensionModel;
				if (m.kill != null)m.kill()
				m.pluginData.swf.unloadAndStop();
				m.pluginData.removeAllElements();
				browser.removeByID(id);
			
				pluginDP.removeItemAt(pluginDP.getItemIndex(pluginData));
			
				var remEvent:ExtensionEvent = new ExtensionEvent(ExtensionEvent.PLUGIN_REMOVED);
				remEvent.data = m;
				dispatchEvent(remEvent);
				
			}catch (error:Error) {
				MLog.Log(error.getStackTrace());
			}
			
			
		}
		private function onValidationError(e:ErrorEvent):void
		{
			var validator:UCFSignatureValidator = e.target as UCFSignatureValidator;
			validator.removeEventListener(ErrorEvent.ERROR, onValidationError);
			validator.removeEventListener(Event.COMPLETE, onValidationComplete);
			console ("This plugin's signature could not be validated: " + e.text, "error");
	//this.showError("Signature Validation Failed", "This plugin's signature could not be validated: " + e.text, "Signature validation failed", true);
		}
		private function getPluginDataFromDir(pluginDir:File):PluginData
		{
		
			var pluginXMLFile:File = pluginDir.resolvePath("META-INF/AIR/application.xml");
			if (!pluginXMLFile.exists) return null;
			try
			{
				var xmlBytes:ByteArray = this.getFileBytes(pluginXMLFile);
				var pluginXML:XML = new XML(xmlBytes);
				var pluginData:PluginData = new PluginData();
				var name:String = pluginXML.AIR_NS::name;
				var id:String = pluginXML.AIR_NS::id;
				var description:String = pluginXML.AIR_NS::description;
				var versionNumber:String = pluginXML.AIR_NS::versionNumber;
				var copy:String = pluginXML.AIR_NS::copyright;
				var ico:String = pluginDir.resolvePath(pluginXML.AIR_NS::icon.AIR_NS::["image32x32"]).url;
				var logo:String;
				if (pluginXML.AIR_NS::icon.AIR_NS::["image48x48"]){
					logo =pluginDir.resolvePath(pluginXML.AIR_NS::icon.AIR_NS::["image48x48"]).url;
				}
				if (name.length == 0 || id.length == 0 || versionNumber.length == 0) return null;
				
				pluginData.appId = id;
				pluginData.appName = name;
				pluginData.name = name;
				pluginData.id = id;
				pluginData.pluginPath = pluginDir.nativePath;
				pluginData.description = description;
				pluginData.version = versionNumber;
				pluginData.versionNr = Number(versionNumber);
				pluginData.ico = ico;
				pluginData.logo = logo;
				pluginData.copy = copy;
				var pluginFile:File = pluginDir.resolvePath(pluginXML.AIR_NS::initialWindow.AIR_NS::content);
				if (!pluginFile.exists){
					return null;
				}
				pluginData.pluginFile = pluginFile;
				pluginData.contentPath = pluginFile.nativePath;
			}
			catch (er:Error)
			{
				return null; // Plugin is currupt.
			}
			return pluginData;
		}
		private function console(msg:String,type:String="normal"):void {
			try {
				if (_consoleContent == null)return;
				var p:ParagraphElement = new ParagraphElement();
				var s:SpanElement = new SpanElement();
				s.text = msg;
				if (type == "error"){
					s.color = 0xef2121;
				}else if (type == "success"){
					s.color = 0x00ef00;
				}else {
					s.color = 0xD9D9D0;
				}
				if (type != "normal"){
					s.fontWeight = "bold";
				}
				p.addChild(s);
				p.addChild( new BreakElement() );
				//setTimeout(_consoleContent.addChildAt,++_l*20,0,p)
				_consoleContent.addChildAt(0,p);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		private var _consoleWindow:CustomWindow;
		private var _consoleContent:TextFlow;
		private var _l:uint = 0
		private function initConsole():void {
			_l = 0;
			_consoleContent = new TextFlow();
			_consoleContent.lineHeight = 11;
			//_consoleContent.backgroundColor = 0x000000;
			_consoleContent.verticalAlign = "top";
			_consoleContent.textAlign = "left";
			_consoleContent.fontSize = 11;
			_consoleContent.backgroundAlpha = 1;
			_consoleWindow = dataHolder.getInstance().openAlert("Plugin Install",_consoleContent,null,null,true);
		}
		private function closeConsole():void { 
			if (_consoleWindow == null || _consoleWindow.closed)return;
			_consoleWindow.close();
			_consoleContent = null;
		}
	}
	
}