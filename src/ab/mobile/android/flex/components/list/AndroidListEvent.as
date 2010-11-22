package ab.mobile.android.flex.components.list
{
	import flash.events.Event;
	
	public class AndroidListEvent extends Event
	{
		static public const OPTION_SELECTED:String = "androidList_optionSelectedEvent";
		
		public var item:Object;
		public var selectedOptionItem:String;
		
		public function AndroidListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}