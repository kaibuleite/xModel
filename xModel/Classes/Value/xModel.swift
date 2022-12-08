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
    private static var xModelCreateCount = 0
    /// 成员变量列表
    private lazy var ivarList : [String] = {
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
            sobj.copyIvarData(from: obj)
        } else {
            print("⚠️ 成员变量的数据格式不是常用类型,请确认:\(key) = \(value!), \(type(of: value))")
            super.setValue(value, forKey: key)
        }
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
    
    // MARK: - Public Func
    // TODO: 实例化对象
    /// 实例化对象
    /// - Parameter info: 对象信息字典
    /// - Returns: 对象
    public class func new(dict : [String : Any]?) -> Self?
    {
        let classNameStr = NSStringFromClass(self.classForCoder())
        guard let info = dict else {
            print("⚠️ 【\(classNameStr)】初始化失败")
            print("初始化数据格式不对")
            print(dict ?? "nil")
            print("==================")
            return nil
        }
        guard info.keys.count != 0 else {
            print("⚠️ 【\(classNameStr)】初始化失败")
            print("初始化数据内容为空")
            print(info)
            print("==================")
            return nil
        }
        // 获取类的元类型(Meta), 为 AnyClass 格式, 有 type(类型) 和 self(值) 两个参数, 可以以此调用该类下的方法(方法必须实现)
        // let test : MyModel.Type = MyModel.self
        guard let className = self.classForCoder() as? xModel.Type else {
            print("⚠️ 【\(classNameStr)】初始化失败")
            print("该对象不是继承于【xModel】")
            print("==================")
            return nil
        }
        // 因为在 init() 前加了 required 关键词,保证了 xModel 类必定有 init() 构造方法,可以放心的调用
        let model = className.init()
        model.setValuesForKeys(info)
        // 保存原始字典
        model.xOriginDictionary = info
        model.setPropertyValuesCompleted()
        return model as? Self
    }
     
    /// 格式化model数组
    /// - Parameters:
    ///   - classType: model类型
    ///   - dataSource: 数据源
    public static func newList(with dataSource : Any?) -> [xModel]
    {
        var ret = [xModel]()
        if let infoList = dataSource as? [[String : Any]] {
            // 数组嵌字典
            for info in infoList {
                guard let model = self.new(dict: info) else { continue }
                ret.append(model)
            }
        } else if let infoList = dataSource as? [String : [String : Any]] {
            // 字典嵌字典，先排序
            let keys = infoList.keys.sorted()
            for key in keys {
                let info = infoList[key]
                guard let model = self.new(dict: info) else { continue }
                ret.append(model)
            }
        }
        return ret
    }
    
    /// 创建随机数据列表
    /// - Parameter count: 数据个数
    /// - Returns: 数据列表
    public static func newRandomList(count : Int = 10) -> [xModel]
    {
        var ret = [xModel]()
        for _ in 0 ..< count {
            let model = xModel()
            ret.append(model)
        }
        return ret
    }
    
    // TODO: 从指定对象中拷贝成员变量
    /// 从指定对象中拷贝成员变量
    /// - Parameters:
    ///   - model: 要拼接的对象
    ///   - isCopyEmpty: 是否将空数据也拷进去
    ///   - isForceCopy: 是否强制拷贝，不考虑继承关系
    /// - Returns: 拼接后的结果
    public func copyIvarData(from targetModel : xModel?,
                             isCopyEmpty : Bool = false,
                             isForceCopy : Bool = false)
    {
        guard let target = targetModel else { return }
        if isForceCopy {
            // 强制拷贝不考虑其他因素
        } else {
            // 要拷贝的对象必须于self同级或是self父级，key才能都找得到对应的value
            guard self.isKind(of: target.classForCoder) else {
                print("⚠️ 数据拷贝失败")
                print("\(self.classForCoder) ≠ \(target.classForCoder)")
                print("==================")
                return
            }
        }
        for key in target.ivarList {
            let value = target.value(forKey: key)
            // 如果不执行替换空数据操作，则跳过
            if isCopyEmpty == false {
                if let obj = value as? String {
                    if obj.isEmpty { continue }
                } else if let obj = value as? Array<Any> {
                    if obj.isEmpty { continue }
                } else if let obj = value as? Dictionary<String, Any> {
                    if obj.isEmpty { continue }
                }
            }
            self.setValue(value, forKey: key)
        }
    }
    
    // TODO:  数据转换
    /// 转换成成员属性字典
    /// - Returns: 生成的字典
    public func toDictionary() -> [String : Any]
    {
        var ret = [String : Any]()
        for key in self.ivarList {
            // 过滤本地创建的数据
            guard key != "xid" else { continue }
            guard key != "xContent" else { continue }
            guard key != "xOrigin" else { continue }
            guard let value = self.value(forKey: key) else { continue }
            // 递归继续拆分
            if let subObj = value as? xModel {
                let subRet = subObj.toDictionary()
                ret[key] = subRet
            }
            else {
                ret[key] = value
            }
        }
        return ret
    }
    
    /// 转换成成员属性字典(字符串成员)
    /// - Returns: 生成的字典
    public func toStringDictionary() -> [String : String]
    {
        var ret = [String : String]()
        for key in self.ivarList {
            // 过滤本地创建的数据
            guard key != "xid" else { continue }
            guard key != "xContent" else { continue }
            guard key != "xOrigin" else { continue }
            guard let value = self.value(forKey: key) else { continue }
            guard let str = value as? String else { continue }
            ret[key] = str
        }
        return ret
    }
    // MARK: - Open Func
    /// 成员参数值设置完成
    open func setPropertyValuesCompleted()
    {
        // 数据设置完成，可以进行下一步操作
    }
    
}
