package code
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.plugins.TransformAroundPointPlugin;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import code.IFrame;
	import code.LotteryBtns;
	import code.Utils;

	public class Lottery extends MovieClip
	{
		//自定义鼠标
		private var myCursor:MovieClip;
		private var lotteryBtns:MovieClip;
//		private var lottery:Array;
		private var eggMc:Array;
		
		private var textField:TextField;
		private var textSubInfo:TextField;//
		private var lotteryResult:int;		//抽奖结果
		private var loadingLottery:Boolean;	//是否正在加载抽奖结果
		
		
		/**
		 * 
		 */
		public function Lottery()
		{
			//this.visible = true;
			this.x = 500;
			this.y = 225;
			this.scaleX = 0.5;
			this.scaleY = 0.5;
			loadingLottery = false;
			
			lotteryBtns = this["mc_btns"];
			this["mc_btns"].visible = false;
			trace(this["mc_egg1"].x,this["mc_egg1"].y);
			trace(this["mc_btns"],'this["mc_btns"]');
			TweenLite.to(this, 1, {transformAroundCenter:{scaleX:1, scaleY:1}, ease:Bounce.easeOut,onComplete:onComplete });
			function onComplete(){
				init();
			}
		}
		
		/**
		 * 初始化
		 */
		private function init():void {
//			lottery = [0,5,10];//0表示没中奖 5表示中五元 10表示10元
			eggMc = [this["mc_egg1"],this["mc_egg2"],this["mc_egg3"]];
			mouseHide();
			addEvent();
		}
		
		public function dispose(){
//			lottery = [];
			eggMc = [];
			removeEventMcBtns();
			parent.removeChild(this);
		}
		
		
		/**
		 * 添加事件处理
		 */
		private function addEvent(){
			addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHander);
			addEventListener(MouseEvent.MOUSE_UP,mouseUpHander);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			for(var i in eggMc){
				eggMc[i].addEventListener(MouseEvent.MOUSE_DOWN,checkPrize);
			}
		}
		
		/**
		 * 移除事件处理
		 */
		private function removeEvent(){
			removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHander);
			removeEventListener(MouseEvent.MOUSE_UP,mouseUpHander);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			for(var i in eggMc){
				eggMc[i].removeEventListener(MouseEvent.MOUSE_DOWN,checkPrize);
			}
		}
		
		private function mouseDownHander(e:MouseEvent){
			myCursor.gotoAndStop(2);
			trace("myCursor")
		}
		private function mouseUpHander(e:MouseEvent){
			myCursor.gotoAndStop(1);
		}
		private function mouseMoveHandler(evt:MouseEvent){
			myCursor.visible = true;
			myCursor.x = evt.stageX;
			myCursor.y = evt.stageY;
		}
		private function mouseLeaveHandler(evt:Event) {
			myCursor.visible = false;
		}
		
		/**
		 * 获取抽奖接口API
		 */
		private function getLotteryApi(index) : void{
			var _url:URLRequest= new URLRequest(Data.YX_LOTTERY_URL);
			var _urlLoader:URLLoader= new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE,onXMLDataLoaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onErr);   
			_urlLoader.load(_url);
			loadingLottery = true;//加载中
			function onXMLDataLoaded(evt:Event) {  	
				trace(_urlLoader.data,"_urlLoader.data")
				var xml = new XML(_urlLoader.data);
				var errno:int = int( xml.errno );
				var message:String = xml.message;
				loadingLottery = false;
				//正常抽奖
				if(errno == 0){
					var level:int = int( xml.success_code );
					//抽到奖
					if(level==5||level==10){
						lotteryResult = level;
					}else{
						lotteryResult = 0;
					}
				} else if (errno == 1) {//未登录
					lotteryResult = 1;
				}else if (message == ''){//错误 mc里面是500标签
					lotteryResult = 500;
				}else if(errno == 50 || errno == 51){//超过次数。
					lotteryResult = 50;
				};
				lotteryAnimation(index)
			};
			
			function onErr(evt:IOErrorEvent){
				lotteryResult = 0;
				lotteryAnimation(index);
				loadingLottery = false;
			}
		};
		
		
		/**
		 * 抽奖结果
		 * index: 蛋的索引
		 * type： 抽奖结果 
		 */
		private function lotteryAnimation(index:int):void{
			TweenMax.delayedCall(0.5,function(){
				mouseShow();
				trace("aa");
				removeEvent();
			})
			
			//trace(lottery ,"--",type,"--",index,"--",lottery[index],"randomizeArray lottery");
			//跳转到对应的奖券处
			eggMc[index].gotoAndStop("lottery_" + lotteryResult)
			//未抽中 、5元、 10元 才打开盖子 
			if((lotteryResult ==0 )|| (lotteryResult == 5) || (lotteryResult== 10)){
				var quanMc:MovieClip = eggMc[index]["mc_quan_" + lotteryResult];
				quanMc.scaleX = 0.1;
				quanMc.scaleY = 0.1;
				quanMc.alpha = 0;
				
				//打开后盖
				TweenMax.to(eggMc[index]["egg_top"], 1, {delay :1,transformAroundPoint:{point:new Point(-10,-140), rotation:-90}});
				//弹出奖品
				TweenMax.to(quanMc, 1, {scaleX:1,scaleY:1,y:-250,delay :2,autoAlpha:1,ease:Bounce.easeOut,onComplete :function(){
					showResult(index);
				}})
			}else{
				showResult(index);
			}
			
		}//lotteryShowResult
		
		/**
		 * 显示结果
		 */
		private function showResult(index:int){
			//隐藏其他两个蛋
			hideOtherEgg(index);
			//当前蛋移到指定位置
			TweenMax.to(eggMc[index], 1, {x:-300, y:160,onComplete: function(){
				//912
				//跳转到相应的界面 显示分享再玩一次等功能
				lotteryBtns.gotoAndStop("quan"+lotteryResult);
				TweenMax.to(lotteryBtns, 0.5, {autoAlpha:1});
				
				var obj:Object = repTxt(lotteryResult);
				//显示文本信息
				textField = new TextField();
				textField.x = -55;
				textField.y = -100;
				textField.width = 500;
				textField.height = 50;
				textField.htmlText = obj.tit;
				//显示次要信息 912
				textSubInfo = new TextField();
				textSubInfo.x = -52;
				textSubInfo.y = -42;
				textSubInfo.width = 500;
				textSubInfo.height = 30;
				textSubInfo.htmlText = obj.subtit;
				
				trace(this,"this");
				addChild(textField);
				addChild(textSubInfo);
				addEventMcBtns();
			}});
		}
		
		/**
		 * 检测是否中奖
		 */
		private function checkPrize(evt:MouseEvent){
			if(loadingLottery) return;
			trace("checkPrize");
			var index:int;// = 1;
			trace(evt.currentTarget)
			var mc:MovieClip;
			for(var i in eggMc) {  
				if(eggMc[i] == (evt.currentTarget as MovieClip)){
					index = i;
				}
			}
			trace("checkPrize",index);
			//Utils.getLottery();
			//裂缝出现
			eggMc[index]["mc_crevice"].play();
			getLotteryApi(index);
		};
		
		/**
		 * 隐藏其他2个蛋
		 */
		private function hideOtherEgg(index){
			for(var i in eggMc){
				if(i != index){
					TweenMax.to(eggMc[i], 0.5, {autoAlpha:0});
				}
			}
		};
		
		
		/**
		 * 文本
		 */
		private function repTxt(type:int):Object{
			var obj:Object;
			switch (type){
				case 0:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_EMPTY +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_SEPT +"</B>"
				}
					break;
				case 5:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_5 +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_RULE_5 +"</B>"
				}
					break;
				case 10:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_10 +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_RULE_10 +"</B>"
				}
					break;
				//未登录
				case 1:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_ERROR +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_NO_LOGIN +"</B>"
				}
					break;
				//未登录
				case 50:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_ERROR +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_EXCEED +"</B>"
				}
					break;
				//服务繁忙等
				case 500:
				default:
					obj = {
					tit : "<FONT FACE=\"微软雅黑\" SIZE=\"36\" COLOR=\"#f6ea15\"><B>"+ Data.LOTTERY_ERROR +"</B>",
					subtit : "<FONT FACE=\"微软雅黑\" SIZE=\"14\" COLOR=\"#ffffff\"><B>"+ Data.LOTTERY_SERVER_ERROR +"</B>"
				}
					break;
			}
			return obj;
		}
		
		
		
		/**
		 * 鼠标隐藏
		 */
		private function mouseHide(){
			//添加鼠标事件
			Mouse.hide();
			myCursor = new Hammer();
			myCursor.x = stage.mouseX;
			myCursor.x = stage.mouseY;
			myCursor.mouseEnabled = false;
			myCursor.visible = false;
			stage.addChild(myCursor);
			
		}
		
		private function mouseShow(){
			//添加鼠标事件
			Mouse.show();
			stage.removeChild(myCursor);
			myCursor = null;
		}
		
		///////分享 等按钮事件
		
		private function addEventMcBtns(){
			trace("addEventMcBtns",lotteryBtns.btn_share_sina);
			lotteryBtns.btn_share_sina.addEventListener(MouseEvent.CLICK,shareSina)
			lotteryBtns.btn_share_qq.addEventListener(MouseEvent.CLICK,shareQq)
			lotteryBtns.btn_share_qzone.addEventListener(MouseEvent.CLICK,shareQzone)
			
			//查看优惠券	
			if(lotteryResult == 5 || lotteryResult == 10){
				lotteryBtns.btn_coupon.addEventListener(MouseEvent.CLICK,viewCoupon)
				lotteryBtns.btn_goto_use.addEventListener(MouseEvent.CLICK,gotoUse)
			}else if(lotteryResult == 0 || lotteryResult == 50 ||lotteryResult == 51 || lotteryResult == 500){
				lotteryBtns.btn_goto_use.addEventListener(MouseEvent.CLICK,gotoUse)
			}else{
				lotteryBtns.btn_login.addEventListener(MouseEvent.CLICK,loginYx)
			}
			trace("lotteryResult",lotteryResult);
		}
		
		private function removeEventMcBtns(){
			lotteryBtns.btn_share_sina.removeEventListener(MouseEvent.CLICK,shareSina)
			lotteryBtns.btn_share_qq.removeEventListener(MouseEvent.CLICK,shareQq)
			lotteryBtns.btn_share_qzone.removeEventListener(MouseEvent.CLICK,shareQzone)
				
			if(lotteryResult == 5 || lotteryResult == 10){
				lotteryBtns.btn_coupon.removeEventListener(MouseEvent.CLICK,viewCoupon)
				lotteryBtns.btn_goto_use.removeEventListener(MouseEvent.CLICK,gotoUse)
			}else if(lotteryResult == 0 || lotteryResult == 50 || lotteryResult == 51 ||lotteryResult == 500){
				lotteryBtns.btn_goto_use.removeEventListener(MouseEvent.CLICK,gotoUse)
			}else{
				lotteryBtns.btn_login.removeEventListener(MouseEvent.CLICK,loginYx)
			}
		}
		
		private function shareSina(e:MouseEvent){
			var url:String = Utils.shareWeiBo("sina");
			Utils.goUrl(url);
		}
		
		private function shareQq(e:MouseEvent){
			var url:String = Utils.shareWeiBo("qq");
			Utils.goUrl(url);
		}
		
		private function shareQzone(e:MouseEvent){
			var url:String = Utils.shareWeiBo("qzone");
			Utils.goUrl(url);
		}
		
		private function viewCoupon(e:MouseEvent){
			var url:String = Data.YX_COUPON_URL;
			Utils.goUrl(url);
		}
		
		private function gotoUse(e:MouseEvent){
			trace("gotoUse")
			var url:String = Data.YX_SEPT_URL;
			Utils.goUrl(url);
		}
		
		private function loginYx(e:MouseEvent){
			var url = Data.YX_LOGIN_URL;
			Utils.goUrl(url,"_parent");
		}
		
	}
}