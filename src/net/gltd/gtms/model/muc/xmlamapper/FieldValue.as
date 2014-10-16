package net.gltd.gtms.model.muc.xmlamapper
{
	[XmlMapping(elementName="value")]
	public class FieldValue
	{
	
		[ChildTextNode]
		public var value:String;
		
		public function FieldValue()
		{
		}
	}
}