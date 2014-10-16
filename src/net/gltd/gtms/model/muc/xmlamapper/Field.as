package net.gltd.gtms.model.muc.xmlamapper
{
	
	[XmlMapping(elementName="field")]
	public class Field
	{
		
		[Attribute("type")]
		public var type:String;
		
		[Attribute("var")]
		public var varible:String;
		
		[Attribute("label")]
		public var label:String;

		[ChildTextNode]
		public var value:String;
		
		public function Field()
		{
			
		}
	}
}