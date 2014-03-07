package code
{
	/**
	 * 性能监管器
	 * author: cyb
	 * 2013-2-2下午01:16:28
	 *
	 **/
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class Status extends Sprite
	{
		private var _xml : XML;
		private var _label : TextField;
		private var _timer : uint;
		private var _fps : uint;
		private var _ms : uint;
		private var _prev_ms : uint;
		private var _mem : Number;
		private var _maxMem : Number;
		private var _graph : Bitmap;
		private var _rect : Rectangle;
		private var _fps_graph : uint;
		private var _mem_graph : uint;
		private var _maxMem_graph : uint;
		
		public var bgColor : uint;
		public var fpsColor : uint;
		public var msColor : uint;
		public var memColor : uint;
		public var maxMemColor : uint;
		private var _css : StyleSheet;
		
		private var _w:Number ;
		private var _h:Number;
		
		public override function get height():Number 
		{
			return _h;
		}
		
		public override function get width():Number 
		{
			return _w;
		}
		
		private function create() : void {
			_w = 70;
			_h = 100;
			bgColor = 0x000033;
			fpsColor = 0xffff00;
			msColor = 0x00ff00;
			memColor = 0x00ffff;
			maxMemColor = 0xff0070;
			_xml = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><maxMem>MAX:</maxMem></xml>;
			graphics.beginFill(bgColor);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			_label = new TextField();
			_label.width = width;
			_label.height = 50;
			var _css:StyleSheet = new StyleSheet();
			_css.setStyle("xml", {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			_css.setStyle("fps", {color:"#" + fpsColor.toString(16)});
			_css.setStyle("ms", {color:"#" + msColor.toString(16)});
			_css.setStyle("mem", {color:"#" + memColor.toString(16)});
			_css.setStyle("maxMem", {color:"#" + maxMemColor.toString(16)});
			
			_label.styleSheet = _css;
			_label.condenseWhite = true;
			_label.selectable = false;
			_label.mouseEnabled = false;
			addChild(_label);
			_graph = new Bitmap();
			_graph.y = 50;
			_graph.bitmapData = new BitmapData(width, height - 50, false, bgColor);
			_rect = new Rectangle(width - 1, 0, 1, height - 50);
			addChild(_graph);
		}
		
		public function onShow() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function onHide() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function clickHandler(event : MouseEvent) : void {
			//SystemUtil.gc();
		}
		
		private function enterFrameHandler(event : Event) : void {
			_timer = getTimer();
			if(_timer - 1000 > _prev_ms) {
				_prev_ms = _timer;
				_mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				_maxMem = _maxMem > _mem ? _maxMem : _mem;
				_fps_graph = Math.min(_graph.height, (_fps / stage.frameRate) * _graph.height);
				_mem_graph = Math.min(_graph.height, Math.sqrt(Math.sqrt(_mem * 5000))) - 2;
				_maxMem_graph = Math.min(_graph.height, Math.sqrt(Math.sqrt(_maxMem * 5000))) - 2;
				_graph.bitmapData.scroll(-1, 0);
				_graph.bitmapData.fillRect(_rect, 0x000033);
				_graph.bitmapData.setPixel(_graph.width - 1, _graph.height - _fps_graph, 0xffff00);
				_graph.bitmapData.setPixel(_graph.width - 1, _graph.height - ((_timer - _ms ) >> 1 ), 0x00ff00);
				_graph.bitmapData.setPixel(_graph.width - 1, _graph.height - _mem_graph, 0x00ffff);
				_graph.bitmapData.setPixel(_graph.width - 1, _graph.height - _maxMem_graph, 0xff0070);
				_xml.fps = "帧频: " + _fps + " / " + stage.frameRate;
				_xml.mem = "内存: " + _mem;
				_xml.maxMem = "最大内存: " + _maxMem;
				_fps = 0;
			}
			_fps++;
			_xml.ms = "耗时: " + (_timer - _ms);
			_ms = _timer;
			_label.htmlText = _xml;
		}
		
		
		public function Status()
		{
			super();
			create();
			onShow();
		}
	}
}