package
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Circ;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.MotionBlurPlugin;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	import com.greensock.plugins.TransformAroundPointPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import code.Data;
	import code.Dog;
	import code.FrameTimer;
	import code.IFrame;
	import code.GameLost;
	import code.GameModel;
	import code.GameWin;
	import code.HitTest;
	import code.Lottery;
	import code.Status;
	import code.Utils;

	//继承影片剪辑
	public class game extends MovieClip implements IFrame
	{
		
		private var dog:Dog;//狗 
		private var lottery:Lottery;		//抽奖类
		private var gameLost:GameLost;
		private var gameWin:GameWin
		//影片剪辑
		private var startFrame:MovieClip;	//场景一
		private var myCursor:MovieClip;	//自定义鼠标
		private var lrTips:MovieClip;		//左右空格提示
		private var spaceTips:MovieClip;	//空格提示.
		private var well:MovieClip;		//连击 没电中时的提示
		
		private var dogs:Array;//狗的队列
		private var power:Number;//计数器
		private var needClick:String;			//定义有效按钮
		private var needUp:String;			//定义需要弹起的按键
		private var gamePlaying:Boolean;//判断是否在游戏中
		private var lastTime:uint;		//游戏结束时间
		private var startTime:uint;		//游戏开始时间
		private var pauseStartTime:uint;		//游戏开始暂停时间
		private var pauseEndTime:uint;		//游戏结束暂停时间
		private var enterFRAME:Dictionary;
		private var enumShowSpaceTips:int;	// 0为尚未出现过  1为出现了 2 为出现过
		private var keyDownNum:int;			//按下的次数
		
		private var eggMC:Dictionary;			//砸蛋字典
		private var firstPlay:Boolean;		//是否是第一次玩游戏 如果是第一次的话 则不需要重新提示
		
		//定位
		private var bgHeight:Number;	//背景高度
		private var moonPosY:Number;	//月亮的初始位置
		private var bgPosY:Number;		//背景的初始定位
		private var frame2PosY:Number;	//场景2的初始定位
		
		private var dogStart:uint;
		private var dogDelay:int;
		
		private static const MAXPOWER:Number = 100;	//最大能量
		private static const EAT_SPEED:Number = 5;	//吃月亮的速度
		private static const ADD_SPEED:Number = 2;	//按左右加血速度
		private static const TIME_SPEED:Number = 0.1;	//自动减血速度
		private static const SPACE_SPEED:Number = 1;	//空格减血速度
		
		
		
		//构造函数
		public function game()
		{
			if(!stage)
				addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			else 
				addedToStageHandler();
			super();
			
		}
		
		protected function addedToStageHandler(e:Event = null):void{
			//移除事件
			if(hasEventListener(Event.ADDED_TO_STAGE))
				removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			Security.allowDomain('*');
			TweenPlugin.activate([AutoAlphaPlugin,MotionBlurPlugin,TransformAroundCenterPlugin, TransformAroundPointPlugin, ShortRotationPlugin,GlowFilterPlugin]);
			//性能监测
//			var statuss:Status = new Status();
//			statuss.y = 450;
//			addChild(statuss);
			
			firstPlay = true;
			
			//DEBUG时  可开启其中一个
//			asStartGame();
//			asShowLottery();
			if (ExternalInterface.available){
				try{
					//判断是第一次游戏 还是抽奖状态
					ExternalInterface.addCallback("asShowLottery",asShowLottery);
					ExternalInterface.addCallback("asStartGame",asStartGame);
					ExternalInterface.call("yxGame.showIsLottery");
				}catch(e:Error){
					asStartGame();
				}
			}else{
				asStartGame();
			}
			
			
			
			
		}
		
		/**
		 * js调用开始游戏事件
		 */
		public function asStartGame():void{
			startFrame = new StartFrame();
			startFrame.x = 539;
			startFrame.y = 418;
			addChild(startFrame);
			startFrame.btn_start.addEventListener(MouseEvent.CLICK,btnStartGame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyStartGame);
			
			function _startGame(){
				//移除事件
				startFrame.btn_start.removeEventListener(MouseEvent.CLICK,btnStartGame);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyStartGame);
				removeChild(startFrame);
				startFrame = null;
				gameInitAnimation();
			}
			/**
			 * 开始游戏
			 */
			function btnStartGame(event:MouseEvent){
				_startGame()
				return;
			};
			
			function keyStartGame(e:KeyboardEvent){
				//trace(e.keyCode,'e.keyCode')
				if(e.keyCode == Keyboard.SPACE){
					_startGame()
					return;
				}
			}
		}
		
		
		/**
		 * js调用显示抽奖环节
		 */
		public function asShowLottery():void{
			this.gotoAndStop("startGame");
			
			if(!lottery){
				lottery = new Lottery();
			}
			addChild(lottery);
			firstPlay = false;
			//毫秒转动停止
			mc_frame2.mc_status.mc_miao.gotoAndStop(1);
			//再玩一次
			lottery.mc_btns.btn_play_again.addEventListener(MouseEvent.CLICK,playAgainFirst);
			function playAgainFirst(e:MouseEvent){
				lottery.mc_btns.btn_play_again.removeEventListener(MouseEvent.CLICK,playAgainFirst);
				removeChild(lottery);
				lottery = null;
				firstPlay = false;
				gameInitAnimation();
			}
		}
		
		
		//游戏初始化时候的动画效果
		private function gameInitAnimation():void{
			this.gotoAndStop("startGame");
			
			bgHeight = mc_bg.height - 50;		//背景高度
			moonPosY = mc_frame2.mc_moon.y;
			frame2PosY = mc_frame2.y;
			bgPosY = mc_bg.y;
			
			mc_frame2.mc_people.gotoAndStop("people_down");
			//毫秒转动的停止
			mc_frame2.mc_status.mc_miao.stop();
			mc_frame2.mc_moon.mc_moon_eat.visible = false;
			
			//开场动画
			TweenMax.to(mc_frame2.mc_dog_pai, 0.5, {rotation:180,delay :0.5,ease:Bounce.easeOut,onComplete :function(){
				init();
			}});
			TweenMax.to(mc_frame2.mc_people, 0.5, {y:-219, delay :1, motionBlur:{strength:1, quality:2}, ease:Bounce.easeOut});
			//第一次玩
			if(firstPlay){
				lrTips = new LrTips();
				lrTips.x = 487;
				lrTips.y = -129;
				addChild(lrTips);
				TweenMax.to(lrTips, 0.5, {x:664.7,y:137.55, delay :1.5, motionBlur:{strength:1, quality:2}, ease:Circ.easeOut});
			}else{
				lrTips = null;
			}
			
		}
		
		private function init():void{
			trace("init");
			//聚焦画布上
			stage.focus = stage;
			
			FrameTimer.init();
			FrameTimer.add(this);
			
			dogs = [];
			power = 10;//能量条从10%开始
			
			enterFRAME = new Dictionary(true);
			gamePlaying = true;	//开始游戏
			enumShowSpaceTips = 0;	//没有显示过空格提示
			//时间初始化
			startTime = 0;
			lastTime = 0;
			pauseStartTime = 0;
			pauseEndTime = 0;
			needClick = "Left";
			needUp = "Right";
			keyDownNum = 0;
			
			//人物在第一帧
			setMcStatus({
				people:"people_ready",
				power:power/100,
				moon:"moon_start",
				time:"0:00"
			});
			mc_frame2.mc_status.mc_miao.gotoAndStop(1);
			mc_frame2.mc_moon.mc_moon_eat.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
		};
		
		/**
		 * 设置初始化和游戏结束时的状态
		 */
		private function setMcStatus(mcStatus:Object):void{
			mcStatus.people && mc_frame2.mc_people.gotoAndStop(mcStatus.people);
			mcStatus.power && (mc_frame2.mc_status.mc_power.scaleX = mcStatus.power);//缩小10%
			mcStatus.moon && mc_frame2.mc_moon.gotoAndStop(mcStatus.moon);
			mcStatus.time && (mc_frame2.mc_status.txt_time.text = mcStatus.time);
		}
		
		/**
		 * 接口方法
		 */
		public function action():void
		{
			for each(var fun:Function in enterFRAME)
			{
				fun.call();
			}	
		}
		
		/**
		 * 添加字典到循环体内 
		 */
		private function addEnterFrame(key:Object,fun:Function):void{
			if(!enterFRAME.hasOwnProperty(key)){
				enterFRAME[key]=fun;
			}
		}
		
		/**
		 * 从循环体内删除字典 停止监控
		 */
		private function removeEnterFrame(key:Object):void{
			if(enterFRAME.hasOwnProperty(key)){
				delete enterFRAME[key];
			}
		}
		
		
		private function playAgain(event:MouseEvent = null) :void{
			//隐藏相关画面
			if(gameWin){
				//移除胜利画面
				removeGameWinEvent();
				gameWin.dispose();
				gameWin = null;
			}else if(gameLost){
				gameLost.removeEventListener(MouseEvent.CLICK,playAgain);
				gameLost.dispose();
				gameLost = null;
			}else if(lottery){
				lottery.mc_btns.btn_play_again.removeEventListener(MouseEvent.CLICK,playAgain);
				lottery.dispose();
				lottery  = null;
			}
			//还原位置
			mc_bg.y = bgPosY;
			mc_frame2.y = frame2PosY;
			mc_frame2.mc_moon.y = moonPosY;
			init();
		}
		
		
		private function showWell(type:int):void{
			if(!well){
				well = new Well();
				well.x = 398;
				well.y = 304;
				well.scaleX = 0.1;
				well.scaleY = 0.1;
				addChild(well);
			}
			setChildIndex(well,numChildren-1);
			well.scaleX = 0.1;
			well.scaleY = 0.1;
			trace("stage.numChildren",numChildren)
			well.gotoAndStop(type);
			well.visible = true;
			well.alpha = 1;
			TweenMax.killTweensOf(well);
			TweenMax.to(well, 1, {scaleX:.8,scaleY:.8,autoAlpha:0});
		}
		
		
		private function keyUpHandler(e:KeyboardEvent):void{
			switch(e.keyCode){
				case Keyboard.RIGHT :
					if(needClick === "Left")
						needUp = "Right";
//					trace("Keyboard UP RIGHT")
					break;
				case Keyboard.LEFT :
					if(needClick === "Right")
						needUp = "Left";
//					trace("Keyboard UP LEFT")
					break;
			}
		}
		//事件管理
		private function keyDownHandler(e:KeyboardEvent):void{
			switch(e.keyCode){
				case Keyboard.LEFT:
				if (needClick === "Left" && needUp === "Right" && gamePlaying){
					//trace("UP RIGHT")
					trace("KEY DOWN LEFT")
					needClick = "Right";
					//实际是在这里进行初始化
					if(!startTime){
						//开始时间
						startTime = getTimer();
						mc_frame2.mc_status.mc_miao.play();
						dogStart = 0;
						
						//开始计时
						addEnterFrame("showClock",showClock);
						//开始检测第一次显示空格提示
						addEnterFrame("killDogs",killDogs);
						//开始打气状态
						mc_frame2.mc_people.gotoAndStop("people_action");
						//第一次出现之后就隐藏左右提示
						if(lrTips){
							TweenMax.to(lrTips, 1, {autoAlpha:0,onComplete:function(){
								removeChild(lrTips);
								lrTips = null;
								
							}});
						}
						
						//生成狗
						addEnterFrame("createDogs",createDogs);
						//碰撞检测
						addEnterFrame("checkForHits",checkForHits);
						//两秒后触发自动减血
						TweenMax.delayedCall(2,function(){
							trace("minusPower")
							addEnterFrame("minusPower",minusPower);
						})
					}
					keyDownAction();
					
				};
				break;
				//右方向键
				case Keyboard.RIGHT :
					if (needClick === "Right" && needUp === "Left"){
						needClick = "Left";
						trace("KEY DOWN Right")
						keyDownAction();
					}
				break;
				//空格
				case Keyboard.SPACE :
					if(!startTime) return;
					//第一次游戏 空格提示 出现了
					if(enumShowSpaceTips == 1){
						//is_space_tips = true;
						//一秒后隐藏提示
						TweenMax.to(spaceTips, 1, {autoAlpha:0,onComplete:function(){
							removeChild(spaceTips);
							spaceTips = null;
							firstPlay = false;
						}});
						enumShowSpaceTips = 2;
						continueGame();
					}
					
					power -= SPACE_SPEED;
					//雷区闪一下
					mc_frame2.mc_lightning_zone.gotoAndPlay(2);
					var _killDogs:Array = killDogs();
					var len = _killDogs.length;
					//trace(_killDogs.length,"kill_lenght");
					for each(var dog:Dog in _killDogs) 
					{
						dog.die();
						removeDog(dog,"die");
					}
					if(len >=2){
						showWell(1);
					}else if(len == 0){
						showWell(2);
					}
					moonPower();
					break;
			}
		}
		
		/**
		 * 游戏时间开始计时
		 */
		private function showClock():void{
//			trace("===")
			var timePassed:int = getTimer()  - startTime - (pauseEndTime - pauseStartTime) ;
			//获取分钟和秒数
			var second:int = Math.floor(timePassed/1000);
			var minutes:int = Math.floor(second/60);
			var costTime:String = minutes + ":" + String(second+100).substr(1,2);
			mc_frame2.mc_status.txt_time.text = costTime;
		}
		
		
		/**
		 * 不定时生成狗
		 */
		private function createDogs():void{
			if(dogStart == 0){
				dogStart = getTimer();
				dogDelay = 100 + Math.random() * 1000;
				
//				trace(dogStart,dogDelay,getTimer() );
			}else{
				if(getTimer() - dogStart >= dogDelay){
					dog = new Dog();
					addChild(dog);
					//添加进数组
					dogs.push(dog);
					dogStart = 0;
				}
			}
			
			//
		}
		
		
		/**
		 * 鼠标按下
		 */
		private function keyDownAction():void{
			//更新计数器
			power += ADD_SPEED;
			keyDownNum++;
			//人物动作循环
			peopleAction();
			//设置能量条
			moonPower();
		}
		
		/**
		 * 闪电侠打气动作
		 * 3帧循环
		 */
		private function peopleAction():void {
			var frame = mc_frame2.mc_people.currentFrame;
			if(frame >=7){
				frame = 5;
			}else{
				frame++;
			}
			//mc_frame2.mc_people["mc_hong"+frame].gotoAndPlay( Math.round(power/20) );
			mc_frame2.mc_people.gotoAndStop(frame);
			//脸红
			mc_frame2.mc_people["mc_hong"+frame].gotoAndStop( Math.round(power/20) );
		}
		
		
		
		/**
		 * 获取要电死的狗数
		 */
		private function killDogs():Array{
			var _kill:Array = [];
			var len:int = dogs.length;
			var dog:Dog;
			if(!len) return _kill;
			
			for (var i:int = 0; i<len ;i++){
				dog = dogs[i];
				
				if(HitTest.complexHitTestObject(dog,mc_frame2.mc_lightning_zone.mc_hits)){
					//第一次出现 就停止 出提示 并且是第一次游戏
					if(enumShowSpaceTips == 0 && firstPlay){
						pauseGame();
						spaceTips = new SpaceTips();
						spaceTips.x = 500;
						spaceTips.y = 225
						addChild(spaceTips);
						enumShowSpaceTips = 1;
						removeEnterFrame("killDogs");
						break;
					}
					//trace()
					_kill.push(dog);
					//trace("=======",dog_arr[dog_num]);
				}
			}
			
			return _kill;
		};
		
		/**
		 * 碰撞检测 狗吃月亮
		 */  
		private function checkForHits():void {
			var len:int = dogs.length;
			if(!len)
				return ;
			var dog:Dog;
			for (var i:int = 0; i<len ;i++){
				dog = dogs[i];
				if(HitTest.complexHitTestObject(dog,mc_frame2.mc_moon)){
					//吃月亮
					dog.eat();
					power -= EAT_SPEED;
					moonPower();
					mc_frame2.mc_moon.mc_moon_eat.visible = true;
					removeDog(dog,"eat");
					break;
				}
			}

		};
		
		/**
		 * 从数组中删除狗
		 */
		private function removeDog(dog:Dog,type:String):void{
			for (var i in dogs){
				if (dogs[i] == dog) {
					dogs.splice(i,1);
					//两秒后清除
					TweenLite.delayedCall(1.5,function(){
						dog.dispose();
						dog = null;
						if(type == "eat" && (mc_frame2.mc_moon.currentFrame <= 20)){
							mc_frame2.mc_moon.mc_moon_eat.visible = false;
						}
//						trace("delayedCall",);
					})
					break;
				}
			}
		}
		
		/**
		 * 继续游戏
		 */
		private function continueGame():void{
			pauseEndTime = getTimer();
			mc_frame2.mc_status.mc_miao.play();
			gamePlaying = true;
			//狗继续
			for each(var dog:Dog in dogs) 
			{
				dog.go();
			}
			FrameTimer.add(this);
		}
		
		/**
		 * 暂停游戏
		 */
		private function pauseGame():void{
			trace("pauseGame")
			pauseStartTime = getTimer();
			mc_frame2.mc_status.mc_miao.stop();
			//停止游戏
			gamePlaying = false;
		
			//停止狗
			for each(var dog:Dog in dogs) 
			{
				dog.stops();
			}
			FrameTimer.remove(this);
		}
		
		
		/**
		 * 月亮能量
		 */
		private function moonPower(gameStatus:int = 2):void{
			//trace("moonPower",gameStatus);
			var perPower = power/MAXPOWER;	//宽度
			
			mc_frame2.mc_status.mc_power.scaleX = perPower;
			//20为气球最大值 20*5 = 100 所以取值5
			mc_frame2.mc_moon.gotoAndStop(Math.round(perPower/0.05));
			//按10下 一滴汗
			if(keyDownNum%10 == 0){
				mc_frame2.mc_people.mc_han.gotoAndPlay(2);
			}
			
			//月亮大小一共4个状态
			if(power >= MAXPOWER){
				perPower = 1;
				power = 100;
				winGame();
				mc_frame2.mc_status.mc_power.scaleX = 1;
			}else if(power <= 0){
				power = 0;
				perPower = 0;
				lostGame(gameStatus);
				mc_frame2.mc_status.mc_power.scaleX = 0;
			}
			
		}
		
		/**
		 * 月亮能量衰减期
		 */
		private function minusPower():void{
			power -= TIME_SPEED;
			moonPower(1);
			
		};
		
		/**
		 * 赢得游戏
		 */
		private function winGame():void{
			//人物在第一帧
			setMcStatus({
				people:"people_win",
				power:1,
				moon:"moon_move"
			})
			endGame();
			//升起月亮
			TweenMax.delayedCall(2,function(){
				trace("delayedCall")
				moonLiftoff(); 
			})
		}
		
		
		/**
		 * 计算击败用户
		 */
		private function rankTime(second:Number):Number{
			var per:Number
			if(second <= 10 && second >=1){
				per = 114.353/(Math.pow(second,0.104));
			}else{
				per = 1514.41/(Math.pow(second,1.226));
			}
			if(per >= 100){
				per = 99.9
			};
			//保留一位小数
			per = Math.round(per * 10)/10
			return per;
		}
		
		/**
		 * 输了游戏
		 * gameStatus : 1为自动减血挂掉     2为被狗吃掉
		 */
		private function lostGame(gameStatus:int):void{
			//人物在第一帧
			setMcStatus({
				people:"people_lost",
				power:0
			})
			endGame();
			FrameTimer.remove(this);
			
			TweenMax.delayedCall(2,function(){
				gameLost = new GameLost();
				addChild(gameLost);
				TweenMax.to(gameLost, 1, {transformAroundCenter:{scaleX:1, scaleY:1}, ease:Bounce.easeOut});
				gameLost.btn_play_again.addEventListener(MouseEvent.CLICK,playAgain);
			})
		};
		
		/**
		 * 停止游戏
		 */
		private function endGame():void{
			trace("endGame");
			lastTime = getTimer();
			mc_frame2.mc_status.mc_miao.stop();
			removeEnterFrame("checkForHits");	//停止碰撞检测
			removeEnterFrame("showClock");	//停止计时
			removeEnterFrame("minusPower");	//停止月亮衰 退 
			removeEnterFrame("createDogs");	//停止生成狗 
			
			getGameScore();
			// 移除侦听器  
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);  
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			//清空狗数组
			if(dogs.length){
				var dog:Dog;
				for(var i in dogs) {  
					dog = dogs[i];
					dog.dispose();
					dog = null;
				}
				dogs = [];
			}
		};
		
		/**
		 * 游戏得分
		 */
		public function getGameScore():void{
			//获取分钟和秒数
			var timePassed:int = lastTime - startTime - (pauseEndTime - pauseStartTime) ;
			//获取分钟和秒数
			var second:int = Math.floor(timePassed/1000);
			var minutes:int = Math.floor(second/60);
			
			var gs:Object = {
				microseconds:timePassed,
				second : second,
				minutes : minutes,
				rank :rankTime(timePassed/1000)
			};
			//保存数据到数据层
			GameModel.getInstance().gameSocre = gs;
		}
		
		
		/**
		 * 背景移动
		 */
		private function moonLiftoff():void{
			//设置升天的月亮状态
			var bg_height:Number = mc_bg.height - 50,		//背景高度
				moon_y:Number = mc_frame2.mc_moon.y - 50;				//月亮位置
			//月亮升空状态
			addEnterFrame("bgMove",bgMove);
			//确保月亮在最后一帧
			mc_frame2.mc_moon.gotoAndStop("moon_move");
		};
		
		private function bgMove():void{
			//背景往下移动
			mc_bg.y += 10;
			//场景2往下移动
			mc_frame2.y += 10;
			//场景二的月亮往上移动，抵消场景2的移动
			mc_frame2.mc_moon.y -= 10;
			//trace(mc_bg.y,bgHeight)
			if(mc_bg.y >= bgHeight){
				removeEnterFrame("bgMove");
				//停止事件
				FrameTimer.remove(this);
				//确保月亮在最后一帧
				mc_frame2.mc_moon.gotoAndStop("moon_light");
				
				TweenMax.delayedCall(0.5,function(){
					gameWin = new GameWin();
					addChild(gameWin);
					TweenMax.to(gameWin, 1, {transformAroundCenter:{scaleX:1, scaleY:1}, ease:Bounce.easeOut});
					//添加成功事件
					addGameWinEvent();
				});
				
			};
		}
		
		/**
		 * 添加成功事件
		 */
		private function addGameWinEvent():void{
			gameWin.btn_lottery.addEventListener(MouseEvent.CLICK,showLottery);
			gameWin.btn_play_again.addEventListener(MouseEvent.CLICK,playAgain);
		};
		
		/**
		 * 移除成功事件
		 */
		private function removeGameWinEvent():void{
			gameWin.btn_lottery.removeEventListener(MouseEvent.CLICK,showLottery);
			gameWin.btn_play_again.removeEventListener(MouseEvent.CLICK,playAgain);
		};
		
		
		/**
		 * 显示抽奖
		 */
		private function showLottery(event:MouseEvent):void{
			trace("yxGame.checkLogin");
			//JS判断是否登录
//			asGotoLottery();
			if (ExternalInterface.available){
				try{
					ExternalInterface.addCallback("asGotoLottery",asGotoLottery);
					ExternalInterface.addCallback("asGotoLogin",asGotoLogin);
					trace("yxGame.call");
					ExternalInterface.call("yxGame.checkLogin");
				}catch(e:Error){
					asGotoLottery();
				}
			}else{
				asGotoLottery();
			}
		
		}; 
		
		/**
		 * JS调用AS的方法
		 */
		public function asGotoLottery(): void{
			if(!lottery){
				lottery = new Lottery();
			}
			addChild(lottery);
			lottery.mc_btns.btn_play_again.addEventListener(MouseEvent.CLICK,playAgain);
			//移除胜利画面
			removeGameWinEvent();
			gameWin.dispose();
			gameWin = null;
		};
		
		/**
		 * 去登录页面
		 */
		public function asGotoLogin():void{
			var url = Data.YX_LOGIN_URL;
			Utils.goUrl(url,"_parent");
		}
		
	}
	
	
}