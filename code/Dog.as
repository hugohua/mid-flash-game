package code
{
	
	import flash.display.MovieClip;
	
	//继承影片剪辑
	public class Dog extends MovieClip implements IFrame
	{
		//变量等
		private var speed:int;//速度
		private var size:Number;//大小
		private var dog_type:int;//狗的类型
		private var currentFrames:int;
		private var dogRunCurrentFrames:int;
		private var cLabel:String;
		private var mc:MovieClip;
		
		//构造函数
		public function Dog()
		{
			
			var y_pos = Math.round(Math.random()*50+250); //产生300--400的随机数
			speed = Math.round(Math.random()*5+5);	//速度5--10
			size = Math.random()*0.6+0.5;	//速度0.7--1.3
			//trace(speed,"speed",size)
			//狗的初始位置
			this.x = 0;
			this.y = y_pos;
			this.scaleX = size;
			this.scaleY = size;
			
			dog_type = createType();
			//显示对应的狗
			this.gotoAndStop("dog"+dog_type+"_run");
			FrameTimer.add(this);
			
		}
		
		
		//创建狗类型
		private function createType():int
		{
			var type:int = Math.round(Math.random()*2+1);//生成1--3随机数
			return type;
		}
		
		public function action():void {
			run();
		}
		
		/**
		 * 狗跑步
		 */
		public function run():void {
			var newx = this.x;
			newx +=  speed * 1;
			this.x = newx;
		}
		
		/**
		 * 狗死掉
		 */
		public function die():void {
			this.gotoAndStop("dog"+dog_type+"_die");
			//移除事件
			FrameTimer.remove(this);
		}
		
		/**
		 * 狗吃月亮
		 */
		public function eat():void {
			this.gotoAndStop("dog"+dog_type+"_eat");
			//移除事件
			FrameTimer.remove(this);
		}
		
		/**
		 * 移除舞台上的狗和事件
		 */ 
		public function dispose():void {
			FrameTimer.remove(this);
			parent.removeChild(this);
			
		}
		
		/**
		 * 狗停止跑步
		 */
		public function stops():void {
			currentFrames = this.currentFrame;
			
			this.gotoAndStop(currentFrames);
			cLabel = this.currentLabel;
			mc = this[cLabel]
			mc.stop();
			FrameTimer.remove(this);
		}
		
		public function go():void {
			this.gotoAndStop(currentFrames);
			mc.play();
			FrameTimer.add(this);
			mc = null;
		}
		
		
		
		
	}
	
}