package ab.mobile.android.flex.components.list
{
	import mx.collections.ArrayList;
	
	import spark.components.Label;
	import spark.components.List;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	import spark.primitives.BitmapImage;
	
	
	/**
	 * The AndroidListOptions component is used by the AndroidList
	 * component to display a set of menu options about a list item.
	 */
	public class AndroidListOptions extends SkinnableComponent
	{
		[SkinPart(required="false")]
		/**
		 * Optional skin part used to display the label of the
		 * item that the menu pertains to.
		 */
		public var optionsTitle:Label;
		
		[SkinPart(required="true")]
		/**
		 * The List component used to display the option items.
		 */
		public var optionsList:List;
		
		/**
		 * The item that the menu was opened for.
		 */
		private var _item:Object;
		/**
		 * The labelField of the parent AndroidList component, used
		 * if the _item property is not a String to display a title
		 * for the menu options.
		 */
		private var _labelField:String;
		/** 
		 * An Array of String options.
		 */
		private var _options:Array;
		
		
		/**
		 * @Constructor
		 */
		public function AndroidListOptions()
		{
			super();
			setStyle("skinClass", AndroidListOptionsSkin);
		}
		
		/**
		 * Sets the options for the menu.
		 * 
		 * @param item The selectedItem of the parent AndroidList.
		 * @param labelField The labelField property of the parent AndroidList, used if item is of type String.
		 * @param options Array of String objects used as the item menu options.
		 */
		public function initializeOptions(item:Object, labelField:String, options:Array):void
		{
			_item = item;
			_options = options;
			_labelField = labelField;
			
			_setOptionsTitle();
			_setOptionsList();
		}
		/**
		 * The partAdded() override used to set up the skin parts.
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case optionsTitle:
					_setOptionsTitle();
					break;
				
				case optionsList:
					_setOptionsList();
					break;
			}
		}
		/**
		 * Sets the options title Label component.
		 */
		private function _setOptionsTitle():void
		{
			if (!optionsTitle)
				return;
			
			if (_item is String)
			{
				optionsTitle.text = _item as String;
			}
			else
			{
				try
				{
					optionsTitle.text = _item[_labelField];
				}
				catch (e:Error)
				{
					// TODO: Handle error setting title.
				}
			}
		}
		/**
		 * Sets the List component with the menu options.
		 */
		private function _setOptionsList():void
		{
			if (_options && optionsList)
			{
				optionsList.dataProvider = new ArrayList(_options);
				optionsList.addEventListener(IndexChangeEvent.CHANGE, _handleChange,false,0,true);
			}
		}
		/**
		 * Handles an item selection on the menu options and dispatches
		 * a AndroidListEvent.OPTION_SELECTED event with references to 
		 * the selectedOptionItem and the item in question.
		 */
		private function _handleChange(event:IndexChangeEvent):void
		{
			var viewEvent:AndroidListEvent = new AndroidListEvent(AndroidListEvent.OPTION_SELECTED, true);
				viewEvent.selectedOptionItem = optionsList.selectedItem;
				viewEvent.item = _item;
			dispatchEvent(viewEvent);
		}
	}
}