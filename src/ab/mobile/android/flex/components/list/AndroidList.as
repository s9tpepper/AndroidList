package ab.mobile.android.flex.components.list
{
	[SkinState("normal")]
	[SkinState("showingItemMenu")]
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import spark.components.List;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.SkinnableComponent;
	/**
	 * The AndroidList class extends the Spark List component to provide
	 * the capability to bring up an options menu pop up on touch and hold
	 * in the same style as the Android native list component.
	 * 
	 * @author Omar Gonzalez :: omar@almerblank.com
	 * 
	 */	
	public class AndroidList extends List
	{
		[SkinPart(required="true")]
		/**
		 * The modalLayer container is the container that displays the
		 * itemMenu.  
		 */
		public var modalLayer:SkinnableContainer;
		
		[SkinPart(required="true")]
		/**
		 * Component item to use when an item in the list
		 * is held for a predetermined amount of time, set
		 * by the itemMenuTouchTime property, the default is
		 * 2000 milliseconds.
		 */
		public var itemMenu:AndroidListOptions;
		/**
		 * @private
		 */
		private var _itemOptions:Array;
		/**
		 * Set to true when it goes into item menu pop up state.
		 */
		private var _showItemMenu:Boolean;
		
		/**
		 * @private
		 */
		private var _optionsLabelField:String = "label";
		public function set optionsLabelField(value:String):void
		{
			_optionsLabelField = value;
		}
		/**
		 * The field on the item that is touch/held to display as
		 * the title in the options menu.
		 */
		public function get optionsLabelField():String
		{
			return _optionsLabelField;
		}
		
		/**
		 * @private
		 */
		private var _enableItemOptions:Boolean = false;
		public function set enableItemOptions(value:Boolean):void
		{
			_enableItemOptions = value;
		}
		/**
		 * When set to true and an itemOptions Array has been set
		 * the List will prompt a set of options to choose from.
		 * Choosing an option will dispatch a ListEvent.OPTION_CHOSEN
		 * event with an item property and the option label selected.
		 */
		public function get enableItemOptions():Boolean
		{
			return _enableItemOptions;
		}
		
		/**
		 * @private
		 */
		private var _itemMenuTouchTime:uint = 2000;
		/**
		 * Returns the amount of time in milliseconds it takes
		 * to invoke the menu of an item
		 */
		public function get itemMenuTouchTime():uint
		{
			return _itemMenuTouchTime;
		}
		public function set itemMenuTouchTime(value:uint):void
		{
			_itemMenuTouchTime = value;
		}
		
		/**
		 * @private
		 */
		private var _optionsPopUpSkinClass:Class = AndroidListOptionsSkin;
		public function set optionsPopUpSkinClass( value:Class ):void
		{
			_optionsPopUpSkinClass = value;
			
			if (itemMenu)
			{
				itemMenu.setStyle("skinClass", optionsPopUpSkinClass);
			}
		}
		/**
		 * Sets the skin class to use for the AndroidListOptions component. The
		 * component defaults to ab.mobile.android.flex.components.list.AndroidListOptionsSkin.
		 */
		public function get optionsPopUpSkinClass():Class
		{
			return _optionsPopUpSkinClass;
		}
		
		
		/**
		 * Timer used to fire off opening the menu.
		 */
		private var _touchTimer:Timer;
		/**
		 * Keeps track of whether the touch has stood in the same
		 * spot for the duration of itemMenuTouchTime.
		 */
		private var _beginningTouch:Point;
		
		/**
		 * @Constructor
		 * 
		 */		
		public function AndroidList()
		{
			super();
			_init();
		}
		
		/**
		 * Sets the options for a menu item.  Currently only has
		 * been tested/works with Strings only for the options.
		 */
		public function set itemOptions(options:Array):void
		{
			_itemOptions = options;
			
			if (_showItemMenu && itemMenu && selectedIndex > -1)
			{
				itemMenu.initializeOptions(selectedItem, optionsLabelField, _itemOptions);
			}
		}
		/**
		 * Returns the Array of options currently being used.
		 */
		public function get itemOptions():Array
		{
			return _itemOptions;
		}
		/**
		 * Initializes the component.
		 */
		private function _init():void
		{
			setStyle("interactionMode", "touch");
			setStyle("skinClass", AndroidListSkin);
			addEventListener(FlexEvent.CREATION_COMPLETE, _handleCreationComplete,false,0,true);
		}
		/**
		 * Handles the MouseEvents dispatched by this List.
		 */
		private function _handleCreationComplete(event:FlexEvent):void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, _handleTouchBegin,false,0,true);
			addEventListener(MouseEvent.MOUSE_UP, _handleMouseUp,false,0,true);
			addEventListener(MouseEvent.MOUSE_MOVE, _handleMouseMove, false, 0, true);
		}
		/**
		 * Handles the MOUSE_UP event and kills the menu pop up trigger
		 * timer if it still is running.
		 */
		private function _handleMouseUp(event:MouseEvent):void
		{
			if (_touchTimer)
			{
				if (_touchTimer.running)
				{
					_touchTimer.stop();
				}
				_killTimer();
			}
			
			if (!hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				addEventListener(MouseEvent.MOUSE_DOWN, _handleTouchBegin,false,0,true);
			}
		}
		/**
		 * Destroys the Timer object.
		 */
		private function _killTimer():void
		{
			if (_touchTimer)
			{
				_touchTimer.removeEventListener(TouchEvent.TOUCH_BEGIN, _handleTouchBegin);
				_touchTimer = null;
			}
		}
		/**
		 * Handles the beginning of a touch on the AndroidList component.  Starts the
		 * Timer object to trigger opening the list.
		 */
		private function _handleTouchBegin(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, _handleTouchBegin);
			
			_beginningTouch = new Point(event.localX, event.localY);
			
			if (_touchTimer && _touchTimer.running)
			{
				_touchTimer.stop();
				_killTimer();
			}
			
			_touchTimer = new Timer(itemMenuTouchTime, 1);
			_touchTimer.addEventListener(TimerEvent.TIMER, _handleTimer,false,0,true);
			_touchTimer.start();
		}
		/**
		 * Handles the trigger for the menu options to display.
		 */
		private function _handleTimer(event:TimerEvent):void
		{
			_killTimer();
			
			if (_beginningTouch && !_showItemMenu)
			{
				// TODO: Remove this hack to trigger the validation on the list on
				// the first touch, validateNow() does not work in this case.
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				
				if (selectedItem)
				{
					_showItemMenu = true;
					
					if (itemMenu && itemMenu.optionsTitle)
					{
						itemMenu.initializeOptions(selectedItem, labelField, itemOptions);
					}
					
					invalidateSkinState();
				}
				
				_beginningTouch = null;
			}
		}
		/**
		 * Handles a MOUSE_MOVE event.  If the "mouse" is moved more than the set
		 * threshold while holding an item for options the _beginningTouch object
		 * is cleared, preventing the menu from displaying until a new touch 
		 * interaction is started.
		 */
		protected function _handleMouseMove(event:MouseEvent):void
		{
			if (!_beginningTouch)
				return;
			
			if (event.localX - _beginningTouch.x > 3)
			{
				_beginningTouch = null;
				return;
			}

			if (event.localY - _beginningTouch.y > 3)
			{
				_beginningTouch = null;
				return;
			}
		}
		/**
		 * Override to set the component into custom states.
		 */
		override protected function getCurrentSkinState():String
		{
			if (_showItemMenu)
				return "showingItemMenu";
			
			return "normal";
		}
		/**
		 * Override to set up skin parts when added.
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch (instance)
			{
				case itemMenu:
					itemMenu.initializeOptions(selectedItem, labelField, _itemOptions);
					itemMenu.addEventListener(AndroidListEvent.OPTION_SELECTED, _handleAndroidListEvent,false,0,true);
					itemMenu.setStyle("skinClass", optionsPopUpSkinClass);
					break;
			}
		}
		/**
		 * Handler for the AndroidListEvent.OPTION_SELECTED event, when this
		 * event is heard it triggers the AndroidList component back into 'normal'
		 * state, closing the menu options.
		 */
		private function _handleAndroidListEvent(event:AndroidListEvent):void
		{
			switch (event.type)
			{
				case AndroidListEvent.OPTION_SELECTED:
					_showItemMenu = false;
					invalidateSkinState();
					break;
			}
		}
	}
}