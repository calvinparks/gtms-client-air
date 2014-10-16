package
{
	[Bindable]
	public class ColorReferences
	{
		public	static	var ContactsListBackgroundColor		:uint = Main.THIS.styleManager.getMergedStyleDeclaration('._contactsList').getStyle('contentBackgroundColor') as uint;
	}
}