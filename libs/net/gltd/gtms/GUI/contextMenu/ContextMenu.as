/*
** ContextMenu.as , package net.gltd.gtms.GUI.contextMenu **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 22, 2012 
*
*
*/ 
package net.gltd.gtms.GUI.contextMenu
{
	import net.gltd.gtms.GUI.contextMenu.events.ContextEvent;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.AIREvent;
	
	import spark.components.SkinnableContainer;
	import spark.components.Window;

	public class ContextMenu
	{

		private	static	var		itemsCollection			:	ArrayCollection = new ArrayCollection();
		private	static	const	customWidth				:	uint	= 222,
								customHeight			:	uint	= 220,
								itemHeight				:	uint	= 27;
			
		private	static	var		menu					:	Window,
								content					:	SkinnableContainer,
								
								
								width					:	uint = customWidth,
								height					:	uint = customHeight,
								x						:	int,
								y						:	int,
								
								menuList				:	ContextMenuContent,
								subMenuList				:	ArrayCollection = new ArrayCollection()
								
								
								
		
		public	static	var		ED						:EventDispatcher = new EventDispatcher();
		////////////////////////////////////////////////////////////////////////////
		public	static	function get isOpen():Boolean {
			if (menu == null || menu.closed)return false;
			return true
		}
		public	static	function ShowMenu(mouseEvent:MouseEvent=null,items:Vector.<ContextMenuItem>=null):void {
			
			try {
				x = mouseEvent.currentTarget.parentApplication.nativeWindow.x + mouseEvent.stageX ;
				y = mouseEvent.currentTarget.parentApplication.nativeWindow.y + mouseEvent.stageY;
				FlexGlobals.topLevelApplication.nativeApplication.activate(mouseEvent.currentTarget.parentApplication.nativeWindow);
			}catch (error:Error){
				x = FlexGlobals.topLevelApplication.nativeApplication.activeWindow.x + FlexGlobals.topLevelApplication.nativeApplication.activeWindow.stage.mouseX;
				y = FlexGlobals.topLevelApplication.nativeApplication.activeWindow.y + FlexGlobals.topLevelApplication.nativeApplication.activeWindow.stage.mouseY;
			}			
			if (items != null)addItems(items);
			reset();
			buildMenu();
			setContent();
		
			
			
		}
		public	static	function addItem(item:ContextMenuItem,many:Boolean=false):void {
			itemsCollection.addItem(item);
			if (!many)itemsCollection.refresh();
		}
		public	static	function addItems(items:Vector.<ContextMenuItem>):void {
			itemsCollection = new ArrayCollection()// items as Array );
			for (var i:uint = 0; i<items.length;i++){
				addItem(items[i]);
			}
			itemsCollection.refresh();
		}
		public	static	function reset():void {
			
			if (menu != null) menu.visible = false
			if (content!=null)content.removeAllElements();
			if (subMenuList!=null)subMenuList.removeAll()
		}
		///////////////////////////////////////////////////////////////////////////
		private static	function setContent():void {
			menuList				= new ContextMenuContent();
			menuList.width = 222;
			menuList.dataProvider	= itemsCollection;
			content.addElement(menuList);
		}
		private static	function setProp():void {
			try {
				content.width = content.contentGroup.contentWidth;
				content.height = content.contentGroup.contentHeight;
				
				menu.width =	content.width + 40;
				menu.height =	content.height + 40;
			}catch (error:Error){
				
			}
		}
		private	static	function buildMenu():void {
			setTimeout(setProp,50);
			if (menu == null || menu.closed){
			}else {
				setPos();
				return;
			}
			menu = new Window();
			menu.title = "cm";
			menu.type			= NativeWindowType.LIGHTWEIGHT;
			menu.minHeight		= itemHeight;
			menu.transparent	= true;
			menu.showStatusBar	= false;
			menu.systemChrome	= "none";
			menu.resizable		= true;
			
			menu.addEventListener(AIREvent.WINDOW_DEACTIVATE,onDeactivate);
			menu.styleName = "contextMenu";
				
			menu.open();
			buildContent();
			
			setPos();
			if (ED.hasEventListener(ContextEvent.SHOW_SUBMENU) == false){
				ED.addEventListener(ContextEvent.SHOW_SUBMENU,onSubMenu);
			}
			
			
			
		}
		private	static	function onSubMenu(e:ContextEvent):void {
		
			try {
				setTimeout(setProp,100);
				for (var i:uint = 0; i < subMenuList.length;i++){
					var cond1:Boolean = (subMenuList.getItemAt(i) as ContextMenuContent).myItem == e.ir as ContextListItem
					var cond2:Boolean = (subMenuList.getItemAt(i) as ContextMenuContent) == e.data as ContextMenuContent;
					var cond3:Boolean =  (e.data is ContextMenuContent) && (e.data as ContextMenuContent).myParent == (subMenuList.getItemAt(i) as ContextMenuContent) 
						
					if (cond1)	return;
					if (cond2)	continue;
					if (cond3)	continue;
						if ((subMenuList.getItemAt(i) as ContextMenuContent).myParent!=null)(subMenuList.getItemAt(i) as ContextMenuContent).myParent.selectedIndex= -1;
						width -= 215;
						content.removeElement( subMenuList.getItemAt(i) as ContextMenuContent )
						subMenuList.removeItemAt(i);
						onSubMenu(e);
						return;
					
				}			
				if (e.contextItem.subMenu != null){
					var sub:ContextMenuContent = new ContextMenuContent();
					sub.myParent		= e.data as ContextMenuContent;
					sub.myItem			= e.ir	as ContextListItem;
				
					sub.dataProvider	= new ArrayCollection(e.contextItem.subMenu);
				 
					sub.y				= ((Math.floor(sub.myItem.y)/(2+itemHeight))*(2+itemHeight) )- 6;
					if (sub.myParent !=null){
						sub.y +=sub.myParent.y;
					}
					sub.x				= sub.myParent.x + sub.myParent.width - 6 
						
					
					content.addElement(sub);
					subMenuList.addItem(sub);
					sub.myParent.selectedItem = e.contextItem;
					
				}else {
					
				}
			}catch (error:Error){
				
			}
			
		}
		private	static	function onDeactivate(event:AIREvent):void {
			menu.close();
			menu = null;
		}
		
		private static function buildContent():void {
			content					= new SkinnableContainer();
			menu.addElement(content);
		}
		
		public static function setPos():void {
			content.x = 5;
			content.y = 5;
			
			menu.move(x-5,y-0);
		//	NativeApplication.nativeApplication.activate();
			
		}
		
		
		
	}
}