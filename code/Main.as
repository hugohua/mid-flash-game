package code
{

	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;
	import flash.ui.Keyboard;
	import flash.net.*;
	import com.greensock.*;
	import com.greensock.easing.*;

	//继承影片剪辑
	public class Main extends MovieClip
	{

		private var dog:Dog;//狗 
		private var dogs:Array;//狗的队列
		private var addSpeed:Number;;//加速度
		private var minusSpeed:Number;;	//减速度
		private var power:Number;//计数器
		private static const MAXPOWER:Number = 100;	//最大能量
		private var needClick;			//定义有效按钮
		private var nextDog1:Timer;		//不定时生成狗的计时器
		private var minusTimer:int;		//能量power的衰退期
		private var gamePlaying:Boolean;//判断是否在游戏中
		private var lastTime:uint;		//游戏结束时间
		private var startTime:uint;		//游戏开始时间
		private var pauseTime:uint;		//游戏暂停时间

		//private var interval_dog:uint;//碰撞检测
		
		

		
		
		//private var game_score:int = 0;//分数
		
		//设置升天的月亮状态
		//private var balloon_pos:Number;		//月亮位置
		
		//private var speed:Number = 0;//定义速度
		
		
		
		
		
		private var game_playing:Boolean;//判断是否在游戏中
		private var is_lr_tips:Boolean;	//是否显示左右空格提示
		private var is_space_tips:Boolean;	//空格放电提示
		
		private var kill_dog_num:int;//狗的数量
		
		private var pause_play_time:uint;//暂停时间
		private var pause_stop_time:uint;//暂停时间
		private var is_pause_game:Boolean = false;;//是否暂停
		

		//构造函数
		public function Main()
		{
			
			if (this.stage){
                this.addedToStageHandler();
            }
            else{
                this.addEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
            }
					
		}
		
		protected function addedToStageHandler(e:Event = null){
			//移除事件
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
			//聚焦画布上
			stage.focus = stage;
			
			
            //点击按钮开始游戏
			mc_frame1.btn_start.addEventListener(MouseEvent.CLICK,btnStartGame);
			//空格键开始
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyStartGame);
			
			/**
			 * 开始游戏
			 */
			function btnStartGame(event:MouseEvent){
				//移除事件
				_startGame();
				//init();
				return;
			};
			
			function keyStartGame(e:KeyboardEvent){
				//trace(e.keyCode,'e.keyCode')
				if(e.keyCode == Keyboard.SPACE){
					trace("keyStart");
					_startGame();
					return;
				}
			}

			function _startGame(){
				btn_start.removeEventListener(MouseEvent.CLICK,btnStartGame);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyStartGame);
				gameInitAnimation();
			}
		}


		//游戏初始化时候的动画效果
		private gameInitAnimation(){
			this.gotoAndStop("startGame");
			//隐藏
			mc_game_win.visible = false;
			mc_game_lost.visible = false;
			TweenMax.to(mc, 1, {x:0, y:0, ease:Back.easeOut});
			

		}

		
			
			
			
			
			

		}
		
		

	}

}