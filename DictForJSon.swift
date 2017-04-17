//
//  DictForJSon.swift
//  miusicPlay- swift
//
//  Created by user on 16/10/28.
//  Copyright © 2016年 loda. All rights reserved.
//

import UIKit

@objc public protocol DictModelProtocol{
    static func customClassMapping() -> [String: String]?
}


extension NSObject{
    
    //dict: 要进行转换的字典
    class func objectWithKeyValues(dict: NSDictionary)->AnyObject?{
        if HEFoundation.isClassFromFoundation(c: self) {
            print("只有自定义模型类才可以字典转模型")
            assert(true)
            return nil
        }
        
        let obj:AnyObject = self.init()
        var cls:AnyClass = self.classForCoder()                                           //当前类的类型
        
        while("NSObject" !=  "\(cls)"){
            var count:UInt32 = 0
            let properties =  class_copyPropertyList(cls, &count)                         //获取属性列表
            for i in 0..<count{
                
                let property = properties?[Int(i)]                                         //获取模型中的某一个属性
                
                var propertyType = String(cString:property_getAttributes(property))  //属性类型
                
                let propertyKey = String(cString:property_getName(property))         //属性名称
                if propertyKey == "description"{ continue  }                              //description是Foundation中的计算型属性，是实例的描述信息
                
                
                var value:AnyObject! = dict.value(forKey: propertyKey) as AnyObject!      //取得字典中的值
                if value == nil {continue}
                
                let valueType =  "\(value.classForCoder)"     //字典中保存的值得类型
                if valueType == "NSDictionary"{               //1，值是字典。 这个字典要对应一个自定义的模型类并且这个类不是Foundation中定义的类型。
                    let subModelStr:String! = HEFoundation.getType(code: &propertyType)
                    if subModelStr == nil{
                        print("你定义的模型与字典不匹配。 字典中的键\(propertyKey)  对应一个自定义的 模型")
                        assert(true)
                    }
                    if let subModelClass = NSClassFromString(subModelStr){
//                        value = subModelClass.objectWithKeyValues(value as! NSDictionary) //递归
                        value = subModelClass.objectWithKeyValues(dict: value as! NSDictionary)
                    }
                }else if valueType == "NSArray"{              //值是数组。 数组中存放字典。 将字典转换成模型。 如果协议中没有定义映射关系，就不做处理
                    
                    if self.responds(to: "customClassMapping") {
                     
                        if var subModelClassName = cls.customClassMapping()?[propertyKey]{   //子模型的类名称
                            subModelClassName =  HEFoundation.bundlePath+"."+subModelClassName
                            if let subModelClass = NSClassFromString(subModelClassName){
                                value = subModelClass.objectWithKeyValues(dict: value  as! NSDictionary);
                            }
                        }
                    }
                    
                }
                
                obj.setValue(value, forKey: propertyKey)
            }
            free(properties)                            //释放内存
            cls = cls.superclass()!                     //处理父类
        }
        return obj
    }
    
    /**
     将字典数组转换成模型数组
     array: 要转换的数组, 数组中包含的字典所对应的模型类就是 调用这个类方法的类
     
     当数组中嵌套数组， 内部的数组包含字典，cls就是内部数组中的字典对应的模型
     */
    class func objectArrayWithKeyValuesArray(array: NSArray)->NSArray?{
        if array.count == 0{
            return nil
        }
        var result = [AnyObject]()
        for item in array{
            let type = "\((item as AnyObject).classForCoder)"
            if type == "NSDictionary"{
                if let model = objectWithKeyValues(dict: item as! NSDictionary){
                    result.append(model)
                }
            }else if type == "NSArray"{
                if let model =  objectArrayWithKeyValuesArray(array: item as! NSArray){
                    result.append(model)
                }
            }else{
                result.append(item as AnyObject)
            }
        }
        if result.count==0{
            return nil
        }else{
            return result as NSArray?
        }
    }
}

//
//  HE_Model2Dict.swift
//  HEExtention
//
//  Created by 贺俊孟 on 16/4/27.
//  Copyright © 2016年 贺俊孟. All rights reserved.
//  模型传字典

import Foundation

extension NSObject{
    var keyValues:[String:AnyObject]?{                   //获取一个模型对应的字典
        get{
            var result = [String: AnyObject]()           //保存结果
            var classType:AnyClass = self.classForCoder
            while("NSObject" !=  "\(classType)" ){
                var count:UInt32 = 0
                let properties = class_copyPropertyList(classType, &count)
                for i in 0..<count{
                    let property = properties?[Int(i)]
                    let propertyKey = String(cString:property_getName(property))         //模型中属性名称
                    var propertyType = String(cString:property_getAttributes(property))  //模型中属性类型
                    
                    if "description" == propertyKey{ continue }   //描述，不是属性
                    
                    let tempValue:AnyObject!  = self.value(forKey: propertyKey) as AnyObject!
                    if  tempValue == nil { continue }
                    
                    if let _ =  HEFoundation.getType(code: &propertyType) {         //1,自定义的类
                        result[propertyKey] = tempValue.keyValues as AnyObject?
                    }else if (propertyType.contains("NSArray")){       //2, 数组, 将数组中的模型转成字典
                        result[propertyKey] = tempValue.keyValuesArray as AnyObject?       //3， 基本数据
                    }else{
                        result[propertyKey] = tempValue
                    }
                }
                free(properties)
                classType = classType.superclass()!
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}

extension NSArray{  //数组的拓展
    var keyValuesArray:[AnyObject]?{
        get{
            var result = [AnyObject]()
            for item in self{
                if !HEFoundation.isClassFromFoundation(c: (item as AnyObject).classForCoder){ //1,自定义的类
                    let subKeyValues:[String:AnyObject]! = (item as AnyObject).keyValues
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues as AnyObject)
                }else if (item as AnyObject).classForCoder == NSArray.classForCoder(){    //2, 如果item 是数组
                    let subKeyValues:[AnyObject]! = (item as AnyObject).keyValuesArray
                    if  subKeyValues == nil {continue}
                    result.append(subKeyValues as AnyObject)
                }else{                                                     //3, 基本数据类型
                    result.append(item as AnyObject)
                }
            }
            if result.count == 0{
                return nil
            }else{
                return result
            }
            
        }
    }
}
//辅助类
//
//  HEFoundation.swift
//  HEExtention
//
//  Created by 贺俊孟 on 16/4/27.
//  Copyright © 2016年 贺俊孟. All rights reserved.


import Foundation

class HEFoundation {
    
    static let set = NSSet(array: [
        NSURL.classForCoder(),
        NSDate.classForCoder(),
        NSValue.classForCoder(),
        NSData.classForCoder(),
        NSError.classForCoder(),
        NSArray.classForCoder(),
        NSDictionary.classForCoder(),
        NSString.classForCoder(),
        NSAttributedString.classForCoder()
        ])
    static let  bundlePath = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    
    /*** 判断某个类是否是 Foundation中自带的类 */
    class func isClassFromFoundation(c:AnyClass)->Bool {
        var  result = false
        if c == NSObject.classForCoder(){
            result = true
        }else{
            set.enumerateObjects({ (foundation,  stop) -> Void in
                if  c.isSubclass(of: foundation as! AnyClass) {
                    result = true
                    stop.initialize(to: true)
                }
            })
        }
        return result
    }
    
    /** 很据属性信息， 获得自定义类的 类名*/
    /**
     let propertyType = String.fromCString(property_getAttributes(property))! 获取属性类型
     到这个属性的类型是自定义的类时， 会得到下面的格式： T+@+"+..+工程的名字+数字+类名+"+,+其他,
     而我们想要的只是类名，所以要修改这个字符串
     */
    class func getType( code:inout String)->String?{
        
//        if !code.containsString(bundlePath){ //不是自定义类
//            return nil
//        }
//        code = code.componentsSeparatedByString("\"")[1]
        code = code.components(separatedBy: ("\""))[1]
        if let range = code.range(of : bundlePath){
            code = code.substring(from: range.upperBound)
            var numStr = "" //类名前面的数字
            for c:Character in code.characters{
                if c <= "9" && c >= "0"{
                    numStr+=String(c)
                }
            }
            if let numRange = code.range(of : numStr){
                code = code.substring(from: numRange.upperBound)
            }
            return bundlePath+"."+code
        }
        return nil
    }
}

//文／hejunm（简书作者）
//原文链接：http://www.jianshu.com/p/360c0136702f
//著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
