//
//  MusicOBJ.swift
//  SUMusic-swift
//
//  Created by user on 17/4/11.
//  Copyright © 2017年 loda. All rights reserved.
//

import UIKit

class MusicOBJ: NSObject {

    //歌曲名称
    var name : String? = nil;
    
    //歌曲文件名称 
    var filename : String? = nil;
    
    //歌词文件名称
    var lrcname : String? = nil;
    
    /// 歌手名称 
    var singer : String? = nil;
    
    /// 歌手照片 
    var singerIcon : String?  = nil;
    
    // 背景图片 
    var icon : String? = nil;
    // 是否正在播放 
    var isPlay : Bool = false;
    
    
    
}
