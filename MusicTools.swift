//
//  MusicTools.swift
//  SUMusic-swift
//
//  Created by user on 17/4/11.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit

class MusicTools: NSObject {
    //获取 所有的 资源
    
    lazy var all_musics : NSArray? = {

        let path = Bundle.main.path(forResource: "Musics.plist", ofType: nil);

        if path == nil{
            return nil;
        }
        
        let arr = NSArray(contentsOfFile: path!);
        HFLog(message: arr);
        
        
        if (arr?.count)! > 0 {
             let musicList = NSMutableArray(capacity: arr!.count)
            
            for index in 0...arr!.count-1{
                
                let musicObj : MusicOBJ = MusicOBJ.objectWithKeyValues(dict: arr![index] as! NSDictionary) as! MusicOBJ;
                
                musicList.add(musicObj)
                
            }
            
            return musicList;
            
        }
        
        
        return arr;
    }()
    
    //当前正在播放的歌曲
    var current_play_music : MusicOBJ? = nil;
    
    
    //单例 
    static let shareMusictool : MusicTools = {
        let instace = MusicTools();
        
        return instace;
    }()
    
}


extension MusicTools{
    //上一曲 
    func previousSong() {
        if self.all_musics?.count == 0 || self.current_play_music == nil {
            return;
        }
        
        var index : Int = 0;
        
        let currentIndex : Int = (self.all_musics?.index(of: self.current_play_music! ))!
        
        if currentIndex <= 0  {
            index = (self.all_musics?.count)! - 1;
        }else{
            index = currentIndex - 1;
        }
        HFLog(message: "current_play_music\(self.current_play_music?.name)")
        self.current_play_music = self.all_musics?.object(at: index) as? MusicOBJ
        HFLog(message: "上一曲之后current_play_music\(self.current_play_music?.name)")
        
    }
    //下一曲
    func nextSong() {
        if self.all_musics?.count == 0 || self.current_play_music == nil {
            return;
        }
        
        var index : Int = 0;
        
        let currentIndex : Int = (self.all_musics?.index(of: self.current_play_music! ))!
        
        if currentIndex <  (self.all_musics?.count)!-1  {
            index = currentIndex+1;
        }
         HFLog(message: "current_play_music\(self.current_play_music?.name)")
        self.current_play_music = self.all_musics?.object(at: index) as? MusicOBJ
          HFLog(message: "下一曲之后current_play_music\(self.current_play_music?.name)")
    }
    
   
    //获取歌词
    class func getLrcList(lrcFileName : String) -> NSMutableArray{
        //定义个返回数组
        let lrcMutableList = NSMutableArray()
        //获取文件地址
        let url = Bundle.main.url(forResource: lrcFileName, withExtension: nil)
        //讲文件 读取为字符串
        var lrcString : String?
        do {
            try lrcString = String.init(contentsOf: url!, encoding: String.Encoding.utf8)
        } catch  {
            HFLog(message: "字符串装换出错")
        }
        
        //分割字符
        let lrcTempArr = lrcString?.components(separatedBy: "\n")
        //HFLog(message: lrcTempArr)
        
        for i in 0  ..< (lrcTempArr?.count)!  {
            
            let lineString = lrcTempArr?[i]
            
            let lineObj = PYLineOBJ()
            
            var word : String?
            var time : String?
            //判断是否为头部信息
            if ((lineString?.hasPrefix("[ti"))! || (lineString?.hasPrefix("[ar"))! || (lineString?.hasPrefix("[al"))!) {
                
                word = lineString?.components(separatedBy: ":").last
                
                lineObj.words = word?.replacingOccurrences(of: "]", with: "")
                
                lrcMutableList.add(lineObj)
                
            }else{
                
                word = lineString?.components(separatedBy: "]").last
                
                time = lineString?.components(separatedBy: "]").first
                
                lineObj.words = word?.replacingOccurrences(of: "[", with: "")
                lineObj.time = time?.replacingOccurrences(of: "[", with: "")
                
                       //HFLog(message: "lineObj.time : \(lineObj.time) lineObj.words: \(lineObj.words)" )
                lrcMutableList.add(lineObj)
            }
            
            
            
        }
        
        
        return lrcMutableList
        
        
        
    }

    
}
