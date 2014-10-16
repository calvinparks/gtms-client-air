package net.gltd.gtms.model.app
{
    import flash.desktop.Icon;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.net.URLRequest;
      
    public class UEMConnectedIcon extends Icon
    {		

		private var imageURLs:Array = ['assets/communified_icons/16x16.png','assets/communified_icons/32x32.png',
			'assets/communified_icons/48x48.png','assets/communified_icons/128x128.png'];
		
		/*private var imageURLs:Array = ['assets/communified_icons/16x16.png','assets/communified_icons/32x32.png',
		'assets/communified_icons/48x48.png','assets/communified_icons/128x128.png'];
	
	*/
										
        public function UEMConnectedIcon():void{
            super();
            bitmaps = new Array();
        }
        
        public function loadImages(event:Event = null):void{
        	if(event != null){
        		bitmaps.push(event.target.content.bitmapData);
        	}
        	if(imageURLs.length > 0){
        		var urlString:String = imageURLs.pop();
        		var loader:Loader = new Loader();
        		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadImages)
				loader.load(new URLRequest(urlString));
        	} else {
        		var complete:Event = new Event(Event.COMPLETE,false,false);
        		dispatchEvent(complete);
        	}
		
        }
    }
}