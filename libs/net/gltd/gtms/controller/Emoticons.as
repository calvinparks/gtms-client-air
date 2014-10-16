package net.gltd.gtms.controller
{
	import net.gltd.gtms.controller.im.ShowStatusManager;
	import net.gltd.gtms.model.EmoticonModel;
	
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	

	public class Emoticons
	{
		public	static	var dH					:Emoticons;
		
		[Bindable]
		public  var ico:*;
		
		public var icons:Object = {};
		public var incosList:Vector.<EmoticonModel> = new Vector.<EmoticonModel>();
		
	
		public static function getInstance():Emoticons {
			if (dH == null) {
				dH=new Emoticons(arguments.callee);	
				dH.init();
			}
			return dH;
		}
		public function Emoticons(caller:Function=null) {
			if (caller != Emoticons.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}
			if (Emoticons.dH != null) {
				throw new Error("Error");
			}
		}
		
		public function init():void
		{
			
			icons[":)"] = new EmoticonModel("Smile","assets/emoticons/(21).png");
			icons[":-)"] = icons[":)"]
		
				
			icons[":D"] = new EmoticonModel("lol","assets/emoticons/(18).png");
			icons[":-D"] = icons[":D"];
			
			icons[":("] = new EmoticonModel("Sad","assets/emoticons/(32).png");
			icons[":-("] = icons[":("];
			
			icons[":'("] = new EmoticonModel("Crying","assets/emoticons/(29).png");
			
			icons[":p"] = new EmoticonModel("Stick that tongue out","assets/emoticons/(15).png");
			icons[":P"] = icons[":-P"] = icons[":-p"] = icons[":p"];
			
			icons[":o"] = new EmoticonModel("Shocked","assets/emoticons/(35).png");
			icons["=8-0"] = icons[":o"];
		
			icons[":@"] = new EmoticonModel("Angry","assets/emoticons/(10).png");

			
			icons[":s"] = new EmoticonModel("Confused","assets/emoticons/(11).png");
			icons[":S"] = icons[":s"];
			
			
			icons[";)"] = new EmoticonModel("Wink","assets/emoticons/(17).png");
			icons[";-)"] = icons[";)"];
			
			icons[":$"] = new EmoticonModel("Embarrassed","assets/emoticons/(22).png");
			
			icons[":|"] = new EmoticonModel("Disappointed","assets/emoticons/(24).png");
			
			icons["+o("] = new EmoticonModel("Sick","assets/emoticons/(23).png");
			
			//icons[":-#"] = new EmoticonModel("Shut Mouth","assets/emoticons/(23).png");
			
		
			incosList.push(icons[":-)"])
			incosList.push(icons[":D"])
			incosList.push(icons[":("])
			incosList.push(icons[":'("])
			incosList.push(icons[":p"])
			incosList.push(icons[":o"])
			incosList.push(icons[":@"])
			incosList.push(icons[":s"])
			incosList.push(icons[";)"])
			incosList.push(icons[":$"])
			incosList.push(icons[":|"])
			incosList.push(icons["+o("])
		}
	
		private function sliceBody(s:String,index:int):Array {
			var items:Array = [];//getIndexes(s);
			var i:int = -1;
			for (var ind:String in icons){
				if (s.indexOf(ind) > -1){
					i = s.indexOf(ind);
					var a:String =  s.slice(0,i);
					var b:String = s.slice(i+ind.length,s.length);
					items =	items.concat( sliceBody(a,i) );
					items.push( {index:i,key:ind} );
					items = items.concat( sliceBody(b,i+ind.length)  );
					break;
				}
			}
			if (i==-1){
				items.push({index:index,string:s});
			}
			return items;
		}
			
		public function find(s:String):Array 
		{
			
			var indexes:Array = sliceBody(s,0);
			var nodes:Array = [];
			for (var i:uint = 0; i<indexes.length;i++){
				if ( indexes[i].hasOwnProperty("key") ){
					var img:InlineGraphicElement = new InlineGraphicElement();
					img.height = 32;
					img.width = 32;
					img.paddingBottom  = -6;
					img.verticalAlign = "bottom";
					img.source = icons[indexes[i]["key"]].ico;
					nodes.push( img );
					continue;
				}
				nodes = nodes.concat( searchForLink( indexes[i]["string"] ) );
			}
			return nodes;
		
		}
		
		public function showTyping(dn:String=null):ParagraphElement {
			var p:ParagraphElement = new ParagraphElement();
			
			var img:InlineGraphicElement = new InlineGraphicElement();
			img.source = ShowStatusManager.getIco("imcomposing");
			img.paddingLeft = 5;
			if (dn!=null){
				var info:SpanElement = new SpanElement();
				info.text = dn ;
				p.addChild( info );
			}
			p.color = 0xBCBCBC;
			p.addChild( img );
			p.lineHeight = 20;
			p.paddingTop = 4;
			p.textAlign = "center";
			return p;
			
		}
		private function searchForLink(messageBody:String):Array {
		
			if (messageBody.toLowerCase().indexOf("http://") > -1  || messageBody.toLowerCase().indexOf("https://") > -1 || messageBody.toLowerCase().indexOf("www.") > -1){
				var nodes:Array = [];
				var protocol:String;
				if (messageBody.toLowerCase().indexOf("https://") > -1)protocol = "https://";
				else if (messageBody.toLowerCase().indexOf("www.") > -1 && messageBody.toLowerCase().indexOf("://") != messageBody.toLowerCase().indexOf("www.")-3) protocol = "www.";
				else protocol = "http://";
				
				var _bodyArray:Array = messageBody.split(protocol);
				var sliceTo:int = (_bodyArray[1] as String).indexOf(" ");
				if (sliceTo == -1) {
					sliceTo = (_bodyArray[1] as String).indexOf("<");
					if (sliceTo == -1){
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).indexOf(">");
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).indexOf("[");
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).indexOf("]");
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).indexOf("{");
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).indexOf("}");
						
						if (sliceTo == -1)sliceTo = (_bodyArray[1] as String).length;
					}
				}
				var href:String = protocol+(_bodyArray[1] as String).slice(0,sliceTo)
				_bodyArray[1] =_bodyArray[1].toString().slice(sliceTo,(_bodyArray[1] as String).length)
				messageBody = _bodyArray[0] + "<s:a href='"+href+"'>"+href+"</s:a>"+_bodyArray[1];
				
				var p1:SpanElement = new SpanElement();
				p1.text =  _bodyArray[0];
				nodes.push(p1);
				
				var p2link:SpanElement = new SpanElement();
				p2link.text =  href;
				var link:LinkElement = new LinkElement();
				link.href  = href;
				link.addChild(p2link);
				nodes.push(link);
				
				var p3:SpanElement = new SpanElement();
				p3.text =  _bodyArray[1];
				nodes.push(p3)
				
				return nodes;
			}
			var pb:SpanElement = new SpanElement();
			pb.text = messageBody;
			return [pb];
		}
	}
}