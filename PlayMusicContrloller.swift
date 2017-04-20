//
//  PlayMusicContrloller.swift
//  SUMusic-swift
//
//  Created by user on 17/4/12.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit
//音乐管理用的API
import AVFoundation
import MediaPlayer
class PlayMusicContrloller: UIViewController {
    /** 定义 需要的 配件 ***************************************--------
     
     */
    
    /**
     *  搭建背景界面
     *  根据需要进行切换 显示歌词 或者背景图片
     */
    var backView  = UIImageView()
    
    /**
     *  返回按钮
     */
    lazy var backBtn : UIButton = {
        let tempbackBtn = UIButton(type: UIButtonType.custom)
        
        tempbackBtn.setImage(UIImage(named: "quit"), for: UIControlState.normal)
         tempbackBtn.addTarget(self, action: #selector(PlayMusicContrloller.backToList), for: UIControlEvents.touchUpInside);
        
        
        return tempbackBtn;
    }()
    
    /**
     *  切换歌词按钮
     */
    lazy var songImagebtn : UIButton = {
        let tempSongBtn = UIButton(type: UIButtonType.custom)
        tempSongBtn.setImage(UIImage(named: "lyric_normal"), for: UIControlState.normal)
        tempSongBtn.addTarget(self, action: #selector(PlayMusicContrloller.lyricOrPhoto(sender:)), for: UIControlEvents.touchUpInside)
        return tempSongBtn;
    }()

    /**
     *  显示进度
     */
    
    let show_currenttime_label = UILabel();
    
    
    /**
     *  显示歌曲信息的背景
     */
    
    let song_background_view = UIView();
    
    
    /**
     *  显示歌曲信息
     */
    
    let song_info_message_lable : UILabel = UILabel();
    
    /**
     *  显示歌词的进度界面
     */
    
    let song_lry_view = LrcView(frame: CGRect(x: 0, y: 0, width: KSCREENWIDTH, height: KSCREENHEIGHT - 100));
    
    
    /*----搭建 控制 界面 ----------------------------------------------------*/
    
    let controller_view = UIView();
    
    /**
     *  进度条背景 显示进度条的位置 包含 进度条 滑块 剩余时间
     */
    let progress_background_view = UIView()
    
    /**
     *  进度条
     */
    let progress_view = UIView()
    
    /**
     *  滑块
     */
    let  slider = UIButton(type: UIButtonType.custom)
    
    /**
     *  剩余时间
     */
    let time_lable = UILabel()
    
    
    /**
     *  三个按钮
     */
    let paly_btn = UIButton()
    let previous_btn = UIButton()
    let next_btn = UIButton()
    
    
    /* 定义运行时----------------------*/
    
    var timer_slider_runtime : Timer? //滑块的运行时
    
    var lrcview_runtime : Timer? //显示歌词的运行时
    //音乐管理
    let musicTools : MusicTools = MusicTools.shareMusictool;
    
    //系统音乐播放管理
    let audioPlay : MusicAudioManager = MusicAudioManager.shareInstance;
    
    // 接受player 用于运行时
    var player : AVAudioPlayer? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        self.setUpView()
        self.setFunctions()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    
    
    //搭建界面 
    private func setUpView(){
    
        /**
         *  搭建上半部分的 headView
         */
        self.view.addSubview(self.backView);
        
        self.backView.translatesAutoresizingMaskIntoConstraints = false; // 关闭系统默认的 autoresizing 约束
//        self.backView.backgroundColor = UIColor.green;
        self.backView.image = UIImage(named: "play_cover_pic_bg");
        self.backView.contentMode = UIViewContentMode.scaleAspectFill;
        self.backView.isUserInteractionEnabled = true;
        
        
        self.view.addSubview(self.song_lry_view);
        self.song_lry_view.translatesAutoresizingMaskIntoConstraints = false;
        self.song_lry_view.isHidden = true;
        
        
        
        
        self.view.addSubview(self.backBtn);
        self.backBtn.translatesAutoresizingMaskIntoConstraints = false;
       
       
        
        
        // 切换歌词按钮 
        self.view.addSubview(self.songImagebtn);
        self.songImagebtn.translatesAutoresizingMaskIntoConstraints = false;
        
        
        self.backView.addSubview(self.song_background_view)
        self.song_background_view.translatesAutoresizingMaskIntoConstraints = false;
        self.song_background_view.backgroundColor = UIColor(white: 0.9, alpha: 0.46)
        
        
        //MARK:-- 显示歌曲信息
        self.song_background_view.addSubview(self.song_info_message_lable);
        self.song_info_message_lable.frame = CGRect(x: 10, y: 0, width: KSCREENWIDTH, height: 50);
        self.song_info_message_lable.text = "歌曲信息 \n祖红啦啦";
        self.song_info_message_lable.font = UIFont.systemFont(ofSize: 12);
        self.song_info_message_lable.numberOfLines = 0;
        
        
        
        self.view.addSubview(self.show_currenttime_label)
        self.show_currenttime_label.translatesAutoresizingMaskIntoConstraints = false;
        self.show_currenttime_label.size = CGSize(width: 42, height: 25);
        self.show_currenttime_label.text = "1:30";
        self.show_currenttime_label.textAlignment = NSTextAlignment.center
        self.show_currenttime_label.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        self.show_currenttime_label.textColor = UIColor.white;
        self.show_currenttime_label.font = UIFont.systemFont(ofSize: 12)
        
        
        
        
        
        self.view.addSubview(self.progress_background_view)
        self.progress_background_view.translatesAutoresizingMaskIntoConstraints = false;
        self.progress_background_view.backgroundColor = UIColor(white: 0.85, alpha: 1);
        //self.progress_background_view.backgroundColor = UIColor.yellow;
        
        
        /**
         *  安装控件
         */
        self.progress_background_view.addSubview(self.progress_view); // 显示滑动距离
        self.progress_view.backgroundColor = SwitchColor(hexString: "#4876FF");
        self.progress_view.x = 0;
        self.progress_view.y = 0;
        self.progress_view.height = 10 ;
        self.progress_view.width = 21 ;
        
         self.progress_background_view.addSubview(self.time_lable);
        self.time_lable.font = UIFont.systemFont(ofSize: 10);
        self.time_lable.text = ""
        self.time_lable.textAlignment = NSTextAlignment.right;
        
        self.time_lable.translatesAutoresizingMaskIntoConstraints = false;
      
        

        
        
        self.progress_background_view.addSubview(self.slider); //添加滑块
      //  self.slider.size = CGSize(width: 42, height: 21)
        self.slider.setImage(UIImage(named: "process_thumb"), for: UIControlState.normal);
         self.slider.setImage(UIImage(named: "process_thumb"), for: UIControlState.highlighted);
        //self.slider.x = 0;
        //self.slider.y = CGFloat((10-21)/2);
        self.slider.translatesAutoresizingMaskIntoConstraints = false;
        
        
        
        
        //self.progress_background_view.addSubview(self.time_lable);
        
        //搭建 控制界面 
        //self.view.addSubview(self.controller_view);
        //self.view.insertSubview(self.controller_view, aboveSubview: self.progress_background_view)
        self.view.insertSubview(self.controller_view, belowSubview: self.progress_background_view)
        
        
        self.controller_view.translatesAutoresizingMaskIntoConstraints = false;
        self.controller_view.backgroundColor = UIColor.lightText
        
       
        self.controller_view.addSubview(self.paly_btn)
        self.paly_btn.translatesAutoresizingMaskIntoConstraints = false;
        
        self.paly_btn.setImage(UIImage(named: "play"), for: UIControlState.normal)
        self.paly_btn.setImage(UIImage(named: "pause"), for: UIControlState.selected)
        
        
        self.controller_view.addSubview(self.next_btn)
        self.next_btn.translatesAutoresizingMaskIntoConstraints = false;
        
        self.next_btn.setImage(UIImage(named: "next"), for: UIControlState.normal)
        
        
        
        self.controller_view.addSubview(self.previous_btn)
        self.previous_btn.translatesAutoresizingMaskIntoConstraints = false;
        
        self.previous_btn.setImage(UIImage(named: "previous"), for: UIControlState.normal)
        
       
        
        
        
        
        
    }
    
}


extension PlayMusicContrloller{
    func backToList() {
        self.dismiss(animated: true, completion: nil);
        
        
    }
    
    // 添加第一个运行时 关于 播放时间的 
    func addCurrentTimer()  {
        removeCurrentTime();
        self.timer_slider_runtime = Timer.init(timeInterval: 0.4, target: self, selector: #selector(PlayMusicContrloller.updateSliderCurrentTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer_slider_runtime!, forMode: RunLoopMode.commonModes);
    }
    
    func removeCurrentTime()  {
        //首先 销毁 之前的定时器
        self.timer_slider_runtime?.invalidate()
        self.timer_slider_runtime = nil;
    }
    
    
    //执行的方法 不断的刷新 滑块的位移 , 当前时间 进度条背景色 
    func updateSliderCurrentTimer()  {
        let tempx : Double = (self.player?.currentTime)!/(self.player?.duration)!;
        
        self.slider.x = CGFloat(tempx * Double(self.progress_background_view.width - self.slider.width))
        
        self.progress_view.width = self.slider.x + self.slider.width/2
    }
    
    
    
    
}


extension PlayMusicContrloller : AVAudioPlayerDelegate{
    
    //添加功能设置 
    func setFunctions()  {
        //设置 功能按钮的 功能 
        self.previous_btn.addTarget(self, action: #selector(PlayMusicContrloller.previousSong), for: UIControlEvents.touchUpInside) //上一曲 
        self.next_btn.addTarget(self, action: #selector(PlayMusicContrloller.nextSong), for: UIControlEvents.touchUpInside) //下一曲 
        self.paly_btn.addTarget(self, action: #selector(PlayMusicContrloller.playSong(button:)), for: UIControlEvents.touchUpInside)// 播放/暂停
        self.show_currenttime_label.isHidden = true
     
        // 给滑块添加 拖拽事件 
        let pan : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PlayMusicContrloller.panSlider(pan:)));
        
        self.slider.addGestureRecognizer(pan);
        
        // 进度条添加  点击事件
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayMusicContrloller.tapProgressView(tap:)))
        self.progress_background_view.addGestureRecognizer(tap);
        
        
    }
    
    //MARK:-- 切换歌词 之类的
    func lyricOrPhoto(sender : UIButton){
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.song_lry_view.isHidden = false
          
        }else{
            self.song_lry_view.isHidden = true
          
        }

        
        
    }
    
    
    //MARK:-- 拖拽进度条 
    func panSlider(pan : UIPanGestureRecognizer)  {
    
        let point : CGPoint = pan.translation(in: self.progress_background_view);
        // HFLog(message: point);
        
        pan.setTranslation(CGPoint.zero, in: pan.view)
        
        let maxPoint = self.progress_background_view.width - (pan.view?.width)!
        
        pan.view?.x = point.x + (pan.view?.x)!;
        
        if (pan.view?.x)! > maxPoint {
            pan.view?.x  = maxPoint;
        }
        let  time : TimeInterval = Double((pan.view?.x)! / (self.view.width - (pan.view?.width)!)) * (self.player?.duration)!
        self.show_currenttime_label.text = self.stringWithTime(time: time);
        self.progress_view.width = (pan.view?.width)!/2 + (pan.view?.x)!;
        if pan.state == UIGestureRecognizerState.began {
            self.removeCurrentTime()
            self.show_currenttime_label.isHidden = false;

            
            
        }else if pan.state == UIGestureRecognizerState.ended{
            self.addCurrentTimer()
            self.show_currenttime_label.isHidden = true;
            self.player?.currentTime = time;
            
        }
        
    }
    
    
    //MARK:-- 点击进度条
    func tapProgressView(tap : UITapGestureRecognizer)  {
        let point : CGPoint = tap.location(in: self.progress_background_view)
        HFLog(message: point);
        
        self.slider.center.x = point.x;
        
        //  self.progress_view.width = (self.slider.width)/2 + (self.slider.x);
        
        let  time : TimeInterval = Double(self.slider.x/(self.progress_background_view.width - self.slider.width))*(self.player?.duration)!
        
        self.player?.currentTime = time;
        
        self.updateSliderCurrentTimer()
        
    }
    
    
    
    //上一曲 
    func previousSong() {
        HFLog(message: "上一曲")
        self.changeSongClearPlayBtn()
        self.musicTools.previousSong();
        self.playSong(button: self.paly_btn)
        self.updateInfoMessage();
    }
    
    
    //下一曲 
    func nextSong() {
        HFLog(message: "下一曲")
        self.changeSongClearPlayBtn()
        self.musicTools.nextSong();
        self.playSong(button: self.paly_btn)
        self.updateInfoMessage();
    }
    
    
    //暂停/播放
    func playSong(button: UIButton) {
        HFLog(message: "播放/暂停");
        button.isSelected = !button.isSelected;
        if button.isSelected { //播放音乐
             self.player = self.audioPlay.playMusic(file_name: self.musicTools.current_play_music?.filename! ,delegate: self )

            //MARK:-- 添加关于 显示 进度的
            self.addCurrentTimer()
            self.addLrcTimer()
            
        }else{ // 暂停播放
            self.player?.pause()
        }
        

    }
    
    //切换歌曲 
    func changeSongClearPlayBtn()  {
        self.paly_btn.isSelected = false;
        self.audioPlay.stopMusicPlay(file_name: self.musicTools.current_play_music?.filename!)
        //可能还有 滑块归位
        self.removeCurrentTime()
      
        
    }
    
    //当进入界面的时候
    func setMusicAndChangeSong(music_obj : MusicOBJ) {
       
        if music_obj == self.musicTools.current_play_music {
            return;
        }
   
        changeSongClearPlayBtn()

     self.musicTools.current_play_music = music_obj
         self.playSong(button: self.paly_btn)
         self.updateInfoMessage();
        
    }
    
    //delegata  当一曲播放完毕了
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.nextSong();
        
     
    }
    
    
    //音频产生错误时
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.previousSong();
    }
    
    
    //刷新 界面信息 
    func updateInfoMessage()  {
        self.song_info_message_lable.text = "歌曲 : \((self.musicTools.current_play_music?.name)!) \n艺术家 : \((self.musicTools.current_play_music?.singer)!)"
        
        self.backView.image = UIImage(named: (self.musicTools.current_play_music?.icon)!)
        
        self.time_lable.text = "\(self.stringWithTime(time: (self.player?.duration)!))"
        
        
        updateSliderCurrentTimer()
        
            self.song_lry_view.lrcList =  MusicTools.getLrcList(lrcFileName: (self.musicTools.current_play_music?.lrcname)!)
        self.setLockView()
    }
    
    
    override func viewWillLayoutSubviews() {
        // 相对左边
        let left_backView : NSLayoutConstraint = NSLayoutConstraint(item: self.backView,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(left_backView);
        
        
        // 相对左边
        let right_backView : NSLayoutConstraint = NSLayoutConstraint(item: self.backView,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(right_backView);
        
        
        // 相对左边
        let top_backView : NSLayoutConstraint = NSLayoutConstraint(item: self.backView,
                                                                   attribute: NSLayoutAttribute.top,
                                                                   relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                   attribute: NSLayoutAttribute.top,
                                                                   multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(top_backView);
        
        // 相对左边
        let bottom_backView : NSLayoutConstraint = NSLayoutConstraint(item: self.backView,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      multiplier: 1.0, constant: -100);
        self.view.addConstraint(bottom_backView);
        
        
        // 相对左边
        let left_lrc : NSLayoutConstraint = NSLayoutConstraint(item: self.song_lry_view,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(left_lrc);
        
        
        // 相对左边
        let right_lrc : NSLayoutConstraint = NSLayoutConstraint(item: self.song_lry_view,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(right_lrc);
        
        
        // 相对左边
        let top_lrc : NSLayoutConstraint = NSLayoutConstraint(item: self.song_lry_view,
                                                                   attribute: NSLayoutAttribute.top,
                                                                   relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                   attribute: NSLayoutAttribute.top,
                                                                   multiplier: 1.0, constant: 0.0);
        self.view.addConstraint(top_lrc);
        
        // 相对左边
        let bottom_lrc : NSLayoutConstraint = NSLayoutConstraint(item: self.song_lry_view,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      relatedBy: NSLayoutRelation.equal, toItem: self.view,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      multiplier: 1.0, constant: -100);
        self.view.addConstraint(bottom_lrc);
        
        
        
     
        
        
        
        
        //相对于 左边
        let left_backbtn : NSLayoutConstraint = NSLayoutConstraint(item: self.backBtn,
                                                                   attribute: NSLayoutAttribute.left,
                                                                   relatedBy: NSLayoutRelation.equal,
                                                                   toItem: self.view,
                                                                   attribute: NSLayoutAttribute.left,
                                                                   multiplier: 1.0, constant: 10);
        
        //相对于 上边
        let top_backbtn : NSLayoutConstraint = NSLayoutConstraint(item: self.backBtn,
                                                                  attribute: NSLayoutAttribute.top,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: self.view,
                                                                  attribute: NSLayoutAttribute.top,
                                                                  multiplier: 1.0, constant: 30);
        
        //宽度
        let width_backbtn : NSLayoutConstraint = NSLayoutConstraint(item: self.backBtn,
                                                                    attribute: NSLayoutAttribute.width,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: nil, attribute: NSLayoutAttribute.notAnAttribute,
                                                                    multiplier: 1.0, constant: 42);
        
        //高度
        let height_backbtn : NSLayoutConstraint = NSLayoutConstraint(item: self.backBtn,
                                                                     attribute: NSLayoutAttribute.height,
                                                                     relatedBy: NSLayoutRelation.equal,
                                                                     toItem: nil, attribute: NSLayoutAttribute.notAnAttribute,
                                                                     multiplier: 1.0, constant: 48);
        
        
        self.view.addConstraints([left_backbtn,top_backbtn,width_backbtn,height_backbtn]);

        
        //相对于 左边
        let right_song : NSLayoutConstraint = NSLayoutConstraint(item: self.songImagebtn,
                                                                 attribute: NSLayoutAttribute.right,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: self.view,
                                                                 attribute: NSLayoutAttribute.right,
                                                                 multiplier: 1.0, constant: -10);
        
        //相对于 上边
        let top_song : NSLayoutConstraint = NSLayoutConstraint(item: self.songImagebtn,
                                                               attribute: NSLayoutAttribute.top,
                                                               relatedBy: NSLayoutRelation.equal,
                                                               toItem: self.view,
                                                               attribute: NSLayoutAttribute.top,
                                                               multiplier: 1.0, constant: 30);
        
        //宽度
        let width_song : NSLayoutConstraint = NSLayoutConstraint(item: self.songImagebtn,
                                                                 attribute: NSLayoutAttribute.width,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: nil,
                                                                 attribute: NSLayoutAttribute.notAnAttribute,
                                                                 multiplier: 1.0, constant: 42);
        
        //高度
        let height_song : NSLayoutConstraint = NSLayoutConstraint(item: self.songImagebtn,
                                                                  attribute: NSLayoutAttribute.height,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: nil,
                                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                                  multiplier: 1.0, constant: 48);
        
        
        self.view.addConstraints([right_song,top_song,width_song,height_song]);

        
        //相当于下边
        let bottom_songback : NSLayoutConstraint = NSLayoutConstraint(item: self.song_background_view,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: self.backView,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      multiplier: 1.0, constant: 0)
        
        //左边的
        let left_songback : NSLayoutConstraint = NSLayoutConstraint(item: self.song_background_view,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: self.backView,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    multiplier: 1.0, constant: 0);
        //右边的
        let right_songback : NSLayoutConstraint = NSLayoutConstraint(item: self.song_background_view,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     relatedBy: NSLayoutRelation.equal,
                                                                     toItem: self.backView,
                                                                     attribute: NSLayoutAttribute.right,
                                                                     multiplier: 1.0, constant: 0);
        
        //高度
        let height_songback : NSLayoutConstraint = NSLayoutConstraint(item: self.song_background_view,
                                                                      attribute: NSLayoutAttribute.height,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: nil, attribute: NSLayoutAttribute.notAnAttribute,
                                                                      multiplier: 1.0, constant:50 );
        
        self.backView.addConstraints([bottom_songback,left_songback,right_songback,height_songback])

        
        // 定位到中间
        let center_showtime : NSLayoutConstraint = NSLayoutConstraint(item: self.show_currenttime_label,
                                                                      attribute: NSLayoutAttribute.centerX,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: self.view,
                                                                      attribute: NSLayoutAttribute.centerX,
                                                                      multiplier: 1.0,
                                                                      constant: 0)
        
        // 距离 底边 有一定的高度
        let height_showtime : NSLayoutConstraint = NSLayoutConstraint(item: self.show_currenttime_label,
                                                                      attribute: NSLayoutAttribute.bottom,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: self.view,
                                                                      attribute: NSLayoutAttribute.top,
                                                                      multiplier: 1.0, constant: -100);
        
        //宽高
        let width_showtime : NSLayoutConstraint = NSLayoutConstraint(item: self.show_currenttime_label,
                                                                     attribute: NSLayoutAttribute.width,
                                                                     relatedBy: NSLayoutRelation.equal,
                                                                     toItem: nil,
                                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                                     multiplier: 1.0,
                                                                     constant: 42)
        
        let width_height_showtime : NSLayoutConstraint = NSLayoutConstraint(item: self.show_currenttime_label,
                                                                            attribute: NSLayoutAttribute.height,
                                                                            relatedBy: NSLayoutRelation.equal,
                                                                            toItem: nil,
                                                                            attribute: NSLayoutAttribute.notAnAttribute,
                                                                            multiplier: 1.0,
                                                                            constant: 25)
        
        
        
        self.view.addConstraints([center_showtime,height_showtime,width_showtime,width_height_showtime])
        
        //上下左右都为零
        let top_progress_backview : NSLayoutConstraint = NSLayoutConstraint(item: self.progress_background_view,
                                                                            attribute: NSLayoutAttribute.top,
                                                                            relatedBy: NSLayoutRelation.equal,
                                                                            toItem: self.backView,
                                                                            attribute: NSLayoutAttribute.bottom,
                                                                            multiplier: 1.0, constant: 0.0)
        
        let left_progress_backview : NSLayoutConstraint = NSLayoutConstraint(item: self.progress_background_view,
                                                                             attribute: NSLayoutAttribute.left,
                                                                             relatedBy: NSLayoutRelation.equal,
                                                                             toItem: self.view,
                                                                             attribute: NSLayoutAttribute.left,
                                                                             multiplier: 1.0, constant: 0.0)
        
        let right_progress_backview : NSLayoutConstraint = NSLayoutConstraint(item: self.progress_background_view,
                                                                              attribute: NSLayoutAttribute.right,
                                                                              relatedBy: NSLayoutRelation.equal,
                                                                              toItem: self.view,
                                                                              attribute: NSLayoutAttribute.right,
                                                                              multiplier: 1.0, constant: 0.0)
        
        let height_progress_backview : NSLayoutConstraint = NSLayoutConstraint(item: self.progress_background_view,
                                                                               attribute: NSLayoutAttribute.height,
                                                                               relatedBy: NSLayoutRelation.equal,
                                                                               toItem: nil,
                                                                               attribute: NSLayoutAttribute.notAnAttribute,
                                                                               multiplier: 1.0, constant: 10)
        
        self.view.addConstraints([top_progress_backview,left_progress_backview,right_progress_backview,height_progress_backview])
        
        
        let right_time_lable : NSLayoutConstraint = NSLayoutConstraint(item: self.time_lable,
                                                                       attribute: NSLayoutAttribute.right,
                                                                       relatedBy: NSLayoutRelation.equal,
                                                                       toItem: self.progress_background_view,
                                                                       attribute: NSLayoutAttribute.right,
                                                                       multiplier: 1.0, constant: -1.0)
        
        
        self.progress_background_view.addConstraint(right_time_lable);
        
        let center_time_lable : NSLayoutConstraint = NSLayoutConstraint(item: self.time_lable,
                                                                        attribute: NSLayoutAttribute.centerY,
                                                                        relatedBy: NSLayoutRelation.equal,
                                                                        toItem: self.progress_background_view,
                                                                        attribute: NSLayoutAttribute.centerY,
                                                                        multiplier: 1.0, constant: 0.0)
        
        
        self.progress_background_view.addConstraint(center_time_lable);
        
        
        let left_slider : NSLayoutConstraint = NSLayoutConstraint(item: self.slider,
                                                                  attribute: NSLayoutAttribute.left,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: self.progress_background_view,
                                                                  attribute: NSLayoutAttribute.left,
                                                                  multiplier: 1.0, constant: 0)
        
        
        self.progress_background_view.addConstraint(left_slider);
        
        let center_slider : NSLayoutConstraint = NSLayoutConstraint(item: self.slider,
                                                                    attribute: NSLayoutAttribute.centerY,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: self.progress_background_view,
                                                                    attribute: NSLayoutAttribute.centerY,
                                                                    multiplier: 1.0, constant: 0.0)
        
        
        self.progress_background_view.addConstraint(center_slider);
        
        let left_controller : NSLayoutConstraint = NSLayoutConstraint(item: self.controller_view,
                                                                      attribute: NSLayoutAttribute.left,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: self.view,
                                                                      attribute: NSLayoutAttribute.left,
                                                                      multiplier: 1.0, constant: 0.0)
        
        let right_controller : NSLayoutConstraint = NSLayoutConstraint(item: self.controller_view,
                                                                       attribute: NSLayoutAttribute.right,
                                                                       relatedBy: NSLayoutRelation.equal,
                                                                       toItem: self.view,
                                                                       attribute: NSLayoutAttribute.right,
                                                                       multiplier: 1.0, constant: 0.0)
        
        
        let bottom_controller : NSLayoutConstraint = NSLayoutConstraint(item: self.controller_view,
                                                                        attribute: NSLayoutAttribute.bottom,
                                                                        relatedBy: NSLayoutRelation.equal,
                                                                        toItem: self.view,
                                                                        attribute: NSLayoutAttribute.bottom,
                                                                        multiplier: 1.0, constant: 0.0)
        
        let top_controller : NSLayoutConstraint = NSLayoutConstraint(item: self.controller_view,
                                                                     attribute: NSLayoutAttribute.top,
                                                                     relatedBy: NSLayoutRelation.equal,
                                                                     toItem: self.progress_background_view,
                                                                     attribute: NSLayoutAttribute.bottom,
                                                                     multiplier: 1.0, constant: 0.0);
        
        
        self.view.addConstraints([left_controller,right_controller,bottom_controller,top_controller])
        
        //定位到中间
        let center_play_x : NSLayoutConstraint = NSLayoutConstraint(item: self.paly_btn,
                                                                    attribute: NSLayoutAttribute.centerX,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: self.controller_view,
                                                                    attribute: NSLayoutAttribute.centerX,
                                                                    multiplier: 1.0, constant: 0.0)
        let center_play_y : NSLayoutConstraint = NSLayoutConstraint(item: self.paly_btn,
                                                                    attribute: NSLayoutAttribute.centerY,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: self.controller_view,
                                                                    attribute: NSLayoutAttribute.centerY,
                                                                    multiplier: 1.0, constant: 0.0)
        
        let width_play : NSLayoutConstraint = NSLayoutConstraint(item: self.paly_btn,
                                                                 attribute: NSLayoutAttribute.width,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: nil,
                                                                 attribute: NSLayoutAttribute.notAnAttribute,
                                                                 multiplier: 1.0,
                                                                 constant: 72.0)
        
        
        let height_play : NSLayoutConstraint = NSLayoutConstraint(item: self.paly_btn,
                                                                  attribute: NSLayoutAttribute.height,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: nil,
                                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                                  multiplier: 1.0,
                                                                  constant: 46)
        
        self.controller_view.addConstraints([center_play_x,center_play_y,width_play,height_play])

        
        //定位到中间
        let center_next_x : NSLayoutConstraint = NSLayoutConstraint(item: self.next_btn,
                                                                    attribute: NSLayoutAttribute.left,
                                                                    relatedBy: NSLayoutRelation.equal,
                                                                    toItem: self.paly_btn,
                                                                    attribute: NSLayoutAttribute.right,
                                                                    multiplier: 1.0, constant: 15)
        let right_next_y : NSLayoutConstraint = NSLayoutConstraint(item: self.next_btn,
                                                                   attribute: NSLayoutAttribute.centerY,
                                                                   relatedBy: NSLayoutRelation.equal,
                                                                   toItem: self.controller_view,
                                                                   attribute: NSLayoutAttribute.centerY,
                                                                   multiplier: 1.0, constant: 0.0)
        
        let width_next : NSLayoutConstraint = NSLayoutConstraint(item: self.next_btn,
                                                                 attribute: NSLayoutAttribute.width,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: nil,
                                                                 attribute: NSLayoutAttribute.notAnAttribute,
                                                                 multiplier: 1.0,
                                                                 constant: 41)
        
        
        let height_next : NSLayoutConstraint = NSLayoutConstraint(item: self.next_btn,
                                                                  attribute: NSLayoutAttribute.height,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: nil,
                                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                                  multiplier: 1.0,
                                                                  constant: 46)
        
        self.controller_view.addConstraints([center_next_x,right_next_y,width_next,height_next])
        
        //定位到中间
        let center_previous_x : NSLayoutConstraint = NSLayoutConstraint(item: self.previous_btn,
                                                                        attribute: NSLayoutAttribute.right,
                                                                        relatedBy: NSLayoutRelation.equal,
                                                                        toItem: self.paly_btn,
                                                                        attribute: NSLayoutAttribute.left,
                                                                        multiplier: 1.0, constant: -15)
        let right_previous_y : NSLayoutConstraint = NSLayoutConstraint(item: self.previous_btn,
                                                                       attribute: NSLayoutAttribute.centerY,
                                                                       relatedBy: NSLayoutRelation.equal,
                                                                       toItem: self.controller_view,
                                                                       attribute: NSLayoutAttribute.centerY,
                                                                       multiplier: 1.0, constant: 0.0)
        
        let width_previous : NSLayoutConstraint = NSLayoutConstraint(item: self.previous_btn,
                                                                     attribute: NSLayoutAttribute.width,
                                                                     relatedBy: NSLayoutRelation.equal,
                                                                     toItem: nil,
                                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                                     multiplier: 1.0,
                                                                     constant: 41)
        
        
        let height_previous : NSLayoutConstraint = NSLayoutConstraint(item: self.previous_btn,
                                                                      attribute: NSLayoutAttribute.height,
                                                                      relatedBy: NSLayoutRelation.equal,
                                                                      toItem: nil,
                                                                      attribute: NSLayoutAttribute.notAnAttribute,
                                                                      multiplier: 1.0,
                                                                      constant: 46)
        
        self.controller_view.addConstraints([center_previous_x,right_previous_y,width_previous,height_previous])
        
    }
    
    
    //将时间 转换为对应的 字符
    func stringWithTime(time: TimeInterval ) -> String {
        
        let date = NSDate(timeIntervalSince1970: time);
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "mm:ss"
        
        return dateFormatter.string(from: date as Date)
        
    }
    
    
    

}


//MARK:-- 关于歌词的运行时
extension PlayMusicContrloller{
    ///刷新歌词当前位置
    func updateLrcTimer()  {
        self.song_lry_view.currentTimeLin = self.player?.currentTime;
        
        
    }
    
    /// 添加歌词的的 运行时 
    func addLrcTimer()  {
    self.lrcview_runtime = Timer(timeInterval: 0.4, target: self, selector: #selector(PlayMusicContrloller.updateLrcTimer), userInfo: nil, repeats: true)
        
        RunLoop.main.add(self.lrcview_runtime!, forMode: RunLoopMode.commonModes);
    }
    

    ///移除歌词的 运行时
    func removeLrcTimer()  {
        self.lrcview_runtime?.invalidate()
        self.lrcview_runtime = nil
    }
    
    
    
    

    
}


extension PlayMusicContrloller{
    override func remoteControlReceived(with event: UIEvent?) {
        let type = event?.subtype;
        
        switch type! {
       case .remoteControlPlay:
            print("play")
            self.playSong(button: self.paly_btn);
        case .remoteControlPause:
            self.playSong(button: self.paly_btn);
            print("pause")
        case .remoteControlNextTrack:
            self.nextSong()
            print("next")
        case .remoteControlPreviousTrack:
         self.previousSong()
            print("pre")
        default:
            print("play - 1")
        }
 
     /*   case .motionShake:
        self.nextSong()
        print("motionShake")
            
        // for UIEventTypeRemoteControl, available in iOS 4.0
        case .remoteControlPlay:
            self.nextSong()
            print("remoteControlPlay")
        case .remoteControlPause:
            self.nextSong()
            print("remoteControlPause")
        case .remoteControlStop:
            self.nextSong()
            print("remoteControlStop")
        case .remoteControlTogglePlayPause:
            self.nextSong()
            print("remoteControlStop")
        case .remoteControlNextTrack:
            self.nextSong()
            print("remoteControlNextTrack")
        case .remoteControlPreviousTrack:
            self.nextSong()
            print("remoteControlPreviousTrack")
        case .remoteControlBeginSeekingBackward:
            self.nextSong()
            print("remoteControlBeginSeekingBackward")
        case .remoteControlEndSeekingBackward:
            self.nextSong()
            print("remoteControlEndSeekingBackward")
        case .remoteControlBeginSeekingForward:
            self.nextSong()
            print("remoteControlBeginSeekingForward")
        case .remoteControlEndSeekingForward:
            self.nextSong()
            print("remoteControlEndSeekingForward")
            
        default:
             print("play - 1")
        }*/
    }
    
    
    
    func setLockView(){

        if #available(iOS 10.0, *) {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
             
                
                // 歌曲名称
                MPMediaItemPropertyTitle: self.musicTools.current_play_music?.name ?? "莹儿",
                // 演唱者
                MPMediaItemPropertyArtist: self.musicTools.current_play_music?.singer ?? "亲亲我的宝贝",
                // 锁屏图片
           MPMediaItemPropertyArtwork : MPMediaItemArtwork(boundsSize: CGSize(width: 150, height: 150)) { (CGSize) -> UIImage in
                    let image = UIImage(named: (self.musicTools.current_play_music?.icon)!)
                    return image!;
                },
                //
                MPNowPlayingInfoPropertyPlaybackRate:1.0,
                // 总时长            MPMediaItemPropertyPlaybackDuration:audioPlayer.duration,
                // 当前时间        MPNowPlayingInfoPropertyElapsedPlaybackTime:audioPlayer.currentTime
            ]
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    
    
}










