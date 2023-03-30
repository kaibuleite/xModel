//
//  xModel.swift
//  Pods-xSDK_Example
//
//  Created by Mac on 2020/9/14.
//

import UIKit

@objcMembers // 使用kvc必须添加(或者在变量前添加 @objc 标识符)

open class xModel: NSObject {
    
    // MARK: - Public Property
    /// 创建编号(自增)
    public var xCreateNumber = 0
    /// 自定义测试数据
    public var xDebugContent = "测试内容:\(arc4random() % 10000)"
    /// 原始字典
    public var xOriginDictionary = [String : Any]()
    /// 是否打印服务器缺失成员变量（默认不打印）
    open var xIsLogModelNoPropertyTip : Bool { return false }
    
    // MARK: - Private Property
    /// 计数器
    static var xModelCreateCount = 0
    /// 成员变量列表
    lazy var ivarList : [String] = {
        let ret = xGetIvarList(obj: self)
        return ret
    }()
    
    // MARK: - Open Override Func
    /// 配对成员属性
    open override func setValue(_ value: Any?,
                                forKey key: String)
    {
        guard value != nil else { return }
        if let obj = value as? String {
            // 字符串类型直接赋值
            super.setValue(obj, forKey: key)
        } else if let obj = value as? Int {
            // 数字类型转换成字符串
            super.setValue(String(obj), forKey: key)
        } else if let obj = value as? Float {
            // 数字类型转换成字符串
            super.setValue(String(obj), forKey: key)
        } else if let obj = value as? Double {
            // 数字类型转换成字符串
            super.setValue(String(obj), forKey: key)
        } else if let obj = value as? Array<Any> {
            // 数组类型直接赋值
            super.setValue(obj, forKey: key)
        } else if let obj = value as? Dictionary<String, Any> {
            // 字典类型直接赋值
            super.setValue(obj, forKey: key)
        } else if let obj = value as? xModel {
            // xModel对象类型
            guard let sobj = self.value(forKey: key) as? xModel else { return }
            // xLog(sobj, obj)
            guard sobj.isMember(of: obj.classForCoder) else { return }
            sobj.xCopyIvarData(from: obj)
        } else {
            // 可能是枚举、对象啥的
            self.setUncheckedValue(value, forKey: key)
        }
    }
    /// 设置未检验的值，默认直接赋值
    open func setUncheckedValue(_ value: Any?,
                                forKey key: String)
    {
        // print("⚠️ 成员变量的数据格式不是常用类型,请确认:\(key) = \(value!), \(type(of: value))")
        super.setValue(value, forKey: key)
    }
    /// 找不到key对应的成员属性
    open override func setValue(_ value: Any?,
                                forUndefinedKey key: String)
    {
        guard self.xIsLogModelNoPropertyTip else { return }
        let classname = type(of: self)
        var str = "【\(classname)】找不到成员【\(key)】 = "
        if value != nil {
            str += "\(value!)"
        } else {
            str += "nil"
        }
        print("⚠️ \(str)")
    }
    /// 找不到key对应的value
    open override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    // MARK: - Public Override Func
    /// 在类的构造器前添加required修饰符表明所有该类的子类都必须实现该构造器,子类的子类可以不用管,默认调用子类的构造器
    required public override init() {
        super.init()
        // 通过对象锁保证唯一
        objc_sync_enter(self)
        xModel.xModelCreateCount += 1
        self.xCreateNumber = xModel.xModelCreateCount
        objc_sync_exit(self)
    }
     
    
    // MARK: - Open Func
    /// 成员参数值设置完成
    open func setPropertyValuesCompleted()
    {
        // 数据设置完成，可以进行下一步操作
    }
    
}
