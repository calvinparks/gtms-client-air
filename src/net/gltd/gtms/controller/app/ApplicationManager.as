package net.gltd.gtms.controller.app
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.contextMenu.ContextMenuItem;
	import net.gltd.gtms.GUI.window.CustomWindow;
	import net.gltd.gtms.controller.Emoticons;
	import net.gltd.gtms.controller.im.ShowStatusManager;
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.app.AppModuleModel;
	import net.gltd.gtms.model.app.UEMConnectedIcon;
	import net.gltd.gtms.model.app.UEMIcon;
	import net.gltd.gtms.model.dataHolder;
	import net.gltd.gtms.utils.StringUtils;
	import net.gltd.gtms.view.app.AlertContent;
	import net.gltd.gtms.view.app.UtilsContent;
	import net.gltd.gtms.view.im.ToolTipPanel;
	import com.greensock.TweenMax;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	import flash.desktop.SystemTrayIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.system.System;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.effects.Parallel;
	
	import org.igniterealtime.xiff.vcard.VCard;
	import org.spicefactory.parsley.core.context.Context;
	
	import spark.components.Button;
	import spark.components.HGroup;
	import spark.components.ToggleButton;
	import spark.components.VGroup;
	import spark.components.Window;
	import spark.modules.ModuleLoader;

	/**
	 * @author pinczo
	 */
	public class ApplicationManager extends EventDispatcher
	{
		public	static		var		_FIRST_RUN					:Boolean = true;
		public	static		var		ToolTipWindow				:ToolTipPanel;
		
		[Bindable]
		public				var	  	windowManager				:WindowManager = new WindowManager();
		
		[Inject]
		public				var		contect						:Context;
		[Inject]
		public				var 	sounds						:SoundsController;
	
		
		public				var		app							:Main;
		
		private				var		_modules					:Vector.<AppModuleModel> = new Vector.<AppModuleModel>(),
			
									_currentModule				:ModuleLoader,
									_currentModuleNum			:int = -1,
										
									_settingsWindow				:CustomWindow,
									_settingsButton				:ToggleButton,
										
									icon_disconnected			:UEMIcon,
									icon_connected				:UEMConnectedIcon,
										
									plugins						:ExtensionManager = ExtensionManager.getInstance(),
									
									_dh							:dataHolder,
									
									_dynamicContainer			:VGroup,
									
									_docClickFunction			:Function,
									
		
									_dynamicItems				:ArrayCollection = new ArrayCollection();
		
		
		
		[Bindable][Embed(source="../sounds/alert.mp3")]
		public var soundAlert:Class;  

		[Observe]
		public function init(app:Main):void {
			// o
			try {
				_dh = dataHolder.getInstance();
				
				_dh.openNewWindow = openNewWindow;
				_dh.openAlert = openAlert;
				_dh.sysNotify = notify;
				
				ContextMenuItem.UTILITIES_ICO = 'assets/_ico/utilities.png';
				ContextMenuItem.PROFILE_ICO = 'assets/_ico/profile.png';
				ContextMenuItem.CHAT_ICO = 'assets/_ico/chat.png';
				
				Emoticons.getInstance().ico = 'assets/emoticons/icon.png';
				
				sounds.soundAlert = new soundAlert() as Sound;
				
				new SettingsManager()
				this.app = app;
	
				
				windowManager.natWindow	= app.nativeWindow;
				windowManager.window = app;
				windowManager.hidden = true;
				windowManager.info = showInfo;
				
				icon_disconnected		= new UEMIcon();
				icon_connected			= new UEMConnectedIcon();
				
				icon_disconnected.addEventListener(Event.COMPLETE, onIconsLoaded);
				icon_connected.addEventListener(Event.COMPLETE, onIconsLoaded);
				icon_disconnected.loadImages()
				
				var iconMenu:NativeMenu = new NativeMenu();
				var showIMViewCommand:NativeMenuItem;
				var exitCommand:NativeMenuItem;
				var separator:NativeMenuItem;
				var utilsMenu:NativeMenuItem;
				
				showIMViewCommand=iconMenu.addItem(new NativeMenuItem("IM View"));
				showIMViewCommand.addEventListener(Event.SELECT, onIMView);
				
				utilsMenu=iconMenu.addItem(new NativeMenuItem("Utilities"));
				utilsMenu.submenu = new NativeMenu();
				var sI:NativeMenuItem = new NativeMenuItem("Settings");
				var eI:NativeMenuItem = new NativeMenuItem("Extensions");
				var cI:NativeMenuItem = new NativeMenuItem("Console");
				var dI:NativeMenuItem = new NativeMenuItem("Service Discovery Browser");
				
				sI.addEventListener(Event.SELECT,onSettingsMenu)
				cI.addEventListener(Event.SELECT,onConsoleMenu)
				eI.addEventListener(Event.SELECT,onExtensionMenu)
				dI.addEventListener(Event.SELECT,onDiscoMenu)
				
				utilsMenu.submenu.addItem( sI );
				utilsMenu.submenu.addItem( eI );
				utilsMenu.submenu.addItem( cI );
				utilsMenu.submenu.addItem( dI );
				
				separator = iconMenu.addItem(new NativeMenuItem("",true));
				
				exitCommand=iconMenu.addItem(new NativeMenuItem("Exit"));
				exitCommand.addEventListener(Event.SELECT, onExit);
				
				
				
				if (NativeApplication.supportsSystemTrayIcon)
				{
					var sysTray:SystemTrayIcon =app.nativeApplication.icon as SystemTrayIcon;
					sysTray.addEventListener(MouseEvent.CLICK, handleMouseClick);
					sysTray.menu = iconMenu;
					sysTray.tooltip = app.title;
				}
				if (NativeApplication.supportsDockIcon)
				{
					var sysDock:DockIcon = app.nativeApplication.icon as DockIcon;
					app.nativeApplication.addEventListener(InvokeEvent.INVOKE,handleMouseClick);
					sysDock.menu = iconMenu;
					
				}
				var loginModulePath:String = 'modules/Login_module.swf';
				var imModulePath:String = 'modules/IM_module.swf';
				try {
					var modulesDir:File = File.applicationDirectory.resolvePath('modules');
					if (!modulesDir.exists){
						MLog.Log ( "modules DIR does not exist!!");
					}else {
						var loginModule:File = modulesDir.resolvePath( 'Login_module.swf' );
						var imModule:File = modulesDir.resolvePath( 'IM_module.swf' );
						if (!loginModule.exists){
							MLog.Log ( "Login Module FILE does not exist!!");
						}else {
							loginModulePath =  loginModule.url;
						}
						if (!imModule.exists){
							MLog.Log ( "IM Module FILE does not exist!!");
						}else {
							imModulePath = imModule.url;
						}
					}
					
				}catch (error:Error){
					MLog.Log( error.getStackTrace() );
				}
				
				
				///var loginModulePath:String = File.applicationDirectory.resolvePath('modules/Login_module.swf').url
			//	var imModulePath:String = File.applicationDirectory.resolvePath('modules/IM_module.swf').url 
				_modules.push(
					new AppModuleModel("Login",loginModulePath),
					new AppModuleModel("IM",imModulePath)
				)
				
				setShowBmps();
				app.nativeWindow.addEventListener(Event.DEACTIVATE,onAppDecative);
				app.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZING,onAppResizing);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			
		
		}
		private var _r:Boolean = false;
		public function runFirstModule():void { 
			trace ("runFirstModule");
			if (_r) return;
			loadModule(0,100);
			_r = true;
			
			
		}
		//MLog.Log(error.getStackTrace());
	/*	private var modUri:Array = [
			File.applicationDirectory.resolvePath('mooooodules/Login_module.swf').url,
			File.applicationDirectory.resolvePath('mooooodules/IM_module.swf').url
			]*/
		private function loadModule(nr:uint,delay:uint=190):void { 
			try {
				if (_currentModuleNum == nr)return;
				if ( _currentModuleNum > -1 ){
					var efOut:Parallel = new Parallel(_currentModule);
					efOut.duration = 0;
					efOut.startDelay = 0;
					efOut.children = app.hideEff.children;
				}
				
				var ef:Parallel = new Parallel();
				ef.duration = 0;
				ef.startDelay = 0;
				ef.children = app.showEff.children;
				_currentModule = _modules[nr].getModule(ef,_currentModule, efOut);
				
				
				app._mainContainer.addElementAt( _currentModule , 0);
				_currentModuleNum = nr;
			}catch (error:Error){
				MLog.Log(error.getStackTrace(),"ERROR");
			}
		}
		private function onAppDecative(event:Event):void {
			if (ToolTipWindow)ToolTipWindow.visible = false;
		}
		private function createTooltip():void {
			
			var toolTipWindow:ToolTipPanel = new ToolTipPanel();
			toolTipWindow.visible = false;
			toolTipWindow.open(false);
			
			ToolTipWindow = toolTipWindow;
		}
		public function showInfo():void {
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
			var version:String =descriptor.ns::versionNumber;
			var appName:String =descriptor.ns::name;
			
			var infoText:String = appName+"\nVersion: "+version;
			Alert.show(infoText,"INFO");
			
		}
		private function onIconsLoaded(event:Event):void {
			NativeApplication.nativeApplication.icon.bitmaps = event.currentTarget.bitmaps;
		}
		private function handleMouseClick(evt:Event=null):void
		{
			try {
				windowManager.windowAction(WindowManager.SHOW_ACTION,app.nativeWindow);
				FlexGlobals.topLevelApplication.nativeWindow.orderToFront();
				FlexGlobals.topLevelApplication.nativeWindow.activate();
				
				if (_docClickFunction != null){
					_docClickFunction();
					_docClickFunction = null;
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace(),"ERROR");
			}
		}
		private function onIMView(event:Event):void { 
			FlexGlobals.topLevelApplication.nativeWindow.activate();
			FlexGlobals.topLevelApplication.nativeApplication.activate(Main.THIS.nativeWindow)
			
		}
		private function onExit(event:Event):void {
			app.exit();
		}
		private function onSettingsMenu(event:Event):void {
			openSettings(0);
		}
		private function onConsoleMenu(event:Event):void {
			openSettings(2);
		}
		private function onExtensionMenu(event:Event):void {
			openSettings(1);
		}
		private function onDiscoMenu(event:Event):void {
			openSettings(3);
		}
		
		private function openSettings(n:uint):void {
			onShowSettings(null);
			changeSettingsTab(n); 
			
		
		}
		[MessageHandler (selector="onDisconnected")]
		public function onDisconnected(event:ConnectionEvent):void {
			try {
				TweenMax.killAll(true);
				UEM.killAll();
				icon_disconnected.loadImages()
				loadModule(0);
				
				for(var i:uint=0;i<NativeApplication.nativeApplication.openedWindows.length;i++){
					if (NativeApplication.nativeApplication.openedWindows[i] == FlexGlobals.topLevelApplication.nativeWindow)continue;
					NativeApplication.nativeApplication.openedWindows[i].close()
				}
				

			 
				VCard.clearCache();
				
				System.gc();
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			
		}
		private var waitingDynItems:Array = [];
		
		public function set dynamicContainer(m:VGroup):void {
			_dynamicContainer = m;
			for (var i:uint = 0; i < waitingDynItems.length;i++){
				onNewDynamicItem(waitingDynItems.pop());
			}
		}
		public function get dynamicContainer():VGroup{
			return _dynamicContainer;
		}
		[MessageHandler (selector="onNewDynamicItem")]
		public function onNewDynamicItem(event:UserEvent):void {

			try {
				addDyn( event.dynamicItem , event.actionType == UserEvent.TypeAdd, event.dynamicItemTarget);
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}

		}
		private function addDyn(item:*,add:Boolean,target:String):void {
			try {
				if (target==null)target="contacts";
				else target = target.toLowerCase();
				if (!add){
				//dynamicContainer.removeElement( item);
					_dynamicItems.removeItemAt( _dynamicItems.getItemIndex( item ) );
				}else {	
				//dynamicContainer.addElement( item );
					if ( _dynamicItems.getItemIndex( item ) == -1)dynamicItems.addItem( item );
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		[MessageHandler (selector="onConnectionSucces")]
		public function onConnected():void {
			 
		}
		[MessageHandler (selector="onLoginSuccess")]
		public function onLoginHandler(event:ConnectionEvent):void {
			icon_connected.loadImages()
			
			loadModule(1,200);
			createTooltip();
		}
		[MessageHandler (selector="onShowSettings")]
		public function onShowSettings(event:UserEvent):void {
			if (event != null && event.actionType == UserEvent.TypeClose){
				_settingsWindow.close();
				return;
			}
			if (_settingsWindow != null && !_settingsWindow.closed){
				_settingsWindow.activate();
				FlexGlobals.topLevelApplication.nativeApplication.activate(_settingsWindow.nativeWindow);
				return
			}
			if (event!=null)_settingsButton = event.menuButton;
			
			var w:uint = Math.min(837,Screen.mainScreen.bounds.width-40);
			var h:uint = Math.min(776,Screen.mainScreen.bounds.height-120);
			
			
			_settingsWindow = openNewWindow( "Utilities",true,"none",w,h,true,true,true,true,"app_utilities_window");
			_settingsWindow.minWidth=520;
			_settingsWindow.minHeight=290;
			
			_settingsWindow.contentBackgrouond = false;
			//if (_settingsWindow.width > Screen.mainScreen.bounds.width) _settingsWindow.width = Screen.mainScreen.bounds.width - 60;
			//if (_settingsWindow.height > Screen.mainScreen.bounds.height) _settingsWindow.height = Screen.mainScreen.bounds.height - 60;
			_settingsWindow.addEventListener(Event.CLOSE,onSettingsClose);	
			var content:UtilsContent = new UtilsContent();
			content.name = "cont"
			_settingsWindow._container.addElement(content);
			
			_settingsWindow.move(Screen.mainScreen.bounds.width/2 - _settingsWindow.width/2,Screen.mainScreen.bounds.height/2 - _settingsWindow.height/2);
			
			FlexGlobals.topLevelApplication.nativeApplication.activate(_settingsWindow.nativeWindow);
			
		}
		private function changeSettingsTab(nr:uint):void {
			if (_settingsWindow != null && _settingsWindow.closed == false){
				(_settingsWindow._container.getElementAt(0) as UtilsContent).selectedTab = nr;
				return
			}
		}
		private function onSettingsClose(event:Event):void {
			if (_settingsButton!=null)_settingsButton.selected = false;
			_settingsWindow.removeEventListener(Event.CLOSE,onSettingsClose);
		}
		[Bindable]
		public function get dynamicItems():ArrayCollection {
			return _dynamicItems;
		}
		public function set dynamicItems(d:ArrayCollection):void {
			 _dynamicItems = d;
		}
		public function openAlert(title:String,message:* = null,options:Array=null,content:IVisualElement=null,asRegularWindow:Boolean=false):CustomWindow {
			try {
				var window:CustomWindow = openNewWindow(title,false,"none",410,240,asRegularWindow,asRegularWindow,asRegularWindow,true) ;
				window.alwaysInFront = true;
				window['contentBackgrouond']= true;
				
				
				var cont:AlertContent = new AlertContent();
				if (content!=null)cont._content.addElement(content)
				else {
					if (message is String)cont.message = message;
					else cont.tf = message;
				}
				
				window.open();
				window.move(Screen.mainScreen.bounds.width/2 - window.width/2 + uint(Math.random()*80) , Screen.mainScreen.bounds.height/2 - window.height/2 + uint(Math.random()*30));
				
				window['_container'].bottom = 45;
				window['_container'].addElement(cont);
				if (options == null) {
					options = [ {label:"Close",callBack:window.close,params:[]} ];
				}
				var hg:HGroup = new HGroup();
				hg.bottom = 10;
				hg.right = 10;
				for (var i:uint = 0; i<options.length;i++){
					var bt:Button = new Button();
					bt.label = options[i].label;
					bt.addEventListener(MouseEvent.CLICK,alertItemClick(options[i].callBack,options[i].params));
					hg.addElement(bt);
				}
				window.addElement(hg);
				window.orderToFront();
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
				if (window!=null)window.close();
			}
			
			
			return window as CustomWindow;
		}
		public function alertItemClick(callBack:Function,args:Array):Function {
			return function(event:MouseEvent):void {
				try {
					callBack.apply(null,args);
				}catch (error:Error){
					MLog.Log(error.getStackTrace());
				}
				try {
					(event.currentTarget as Button).parentApplication['close']();
				}catch (error:Error){
					MLog.Log(error.getStackTrace());
				}
			}
		}
		public function openNewWindow(title:String, open:Boolean=true,stick:String="none",width:uint=300,height:uint=300,minimizable:Boolean=false,maximizable:Boolean=false,closeable:Boolean=false,resizable:Boolean=false,windowName:String=null):CustomWindow {
			try {
			//	if (stick != "none" && app._topAppControls.windowManager.isMax)stick = "none";
				var w:CustomWindow = new CustomWindow();
				if (windowName!=null){
					w.name = windowName;
					w.id = windowName+StringUtils.generateRandomString(4);
				}
				w.title = title;
				w.minimizable = minimizable;
				w.maximizable = maximizable;
				w.setClosable(closeable);
				w.info = false;
				w.resizable = resizable;
				w.width = width;
				w.height = height;
				var x:int = Screen.mainScreen.bounds.width/2 - width/2;
				var y:int = Screen.mainScreen.bounds.height/2 - height/2;
				var isStick:Boolean = false;
				
				var p:Point
				if (stick != "none"){
					p = windowManager.getStickWindowPos(stick,new Point(width,height));
					x = p.x;
					y = p.y;
					w.moveable = false;
					isStick = true;
				}else {
					p = SettingsManager.getWindowPosition(w.name);
					if (p != null){
						x = Math.min(p.x, Screen.mainScreen.bounds.width-w.width);
						y = Math.min(p.y, Screen.mainScreen.bounds.height-w.height); 
					}
				}
				if (open || isStick){
					w.open(true);
					w.move(x,y);
				}
				w.windowManager.isSticky = isStick;
				if (isStick){
					for (var io:uint = 0; io<windowManager.stickWindows.length;io++){
						var sw:Window =  windowManager.stickWindows.getItemAt(io).window;
						if (sw != null && sw.closed == false && windowManager.stickWindows.getItemAt(io).stick == stick){
							sw.close()
						}
					}
					windowManager.stickWindows.addItem({
						window: w,
						stick: stick,
						manager:w.windowManager
					
					})
					if (app._topAppControls.windowManager.isMax){
						w.windowManager.unStickWindow(w,stick); 
					}
				}
				
				return w;
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			return new CustomWindow();
			
		}
		public function notify(f:Function=null):void{
			if(NativeApplication.supportsDockIcon){
				var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dock.bounce(NotificationType.CRITICAL);
			} else if (NativeApplication.supportsSystemTrayIcon){
				FlexGlobals.topLevelApplication.stage.nativeWindow.notifyUser(NotificationType.CRITICAL);
			}
			_docClickFunction = f;
		}
		
		
		
		private function onAppResizing(event:NativeWindowBoundsEvent):void {
			return;
			if (!windowManager.stickWindows) return;
			
		for (var i:uint = 0; i<	windowManager.stickWindows.length;i++)
			if ( windowManager.stickWindows.getItemAt(i).window.id.indexOf('chatWindow') == 0) {
				windowManager.stickWindows.getItemAt(i).window.height = app.nativeWindow.height - windowManager.stickWindows.getItemAt(i).window.nativeWindow.y;
			}
		}
		
		
		[Inject][Bindable]
		public var showManager:ShowStatusManager;
		private function  setShowBmps():void {
			showManager.im_available = im_available;
			showManager.im_away = im_away;
			showManager.im_dnd = im_dnd;
			showManager.im_free_chat = im_free_chat;
			showManager.im_unavailable = im_unavailable;
			showManager.on_phone = on_phone;
			showManager.on_road = on_road;
			showManager.on_video = on_video;
			showManager.im_composing = im_composing;
			showManager.im_message = im_message;
			showManager.init();
			trace (showManager.im_message,"<>");
		}
		
		
		
		[Embed(source="../assets/show_leds/im_available.png")] 
		[Bindable] 
		private var im_available:Class;
		
		[Embed(source="../assets/show_leds/im_away.png")] 
		[Bindable] 
		private var im_away:Class;
		
		[Embed(source="../assets/show_leds/im_dnd.png")] 
		[Bindable] 
		private var im_dnd:Class;
		
		[Embed(source="../assets/show_leds/im_free_chat.png")] 
		[Bindable] 
		private var im_free_chat:Class;
		
		[Embed(source="../assets/show_leds/im_unavailable.png")] 
		[Bindable] 
		private var im_unavailable:Class;
		
		[Embed(source="../assets/show_leds/on-phone.png")] 
		[Bindable] 
		private var on_phone:Class;
		
		[Embed(source="../assets/show_leds/airplane.png")] 
		[Bindable] 
		private var on_road:Class;
		
		[Embed(source="../assets/camera.png")] 
		[Bindable] 
		private var on_video:Class;
		
		[Embed(source="../assets/composing2.png")] 
		[Bindable] 
		private var im_composing:Class;
		
		[Embed(source="../assets/newmessage_icon.png")] 
		[Bindable] 
		private var im_message:Class;
	}

}