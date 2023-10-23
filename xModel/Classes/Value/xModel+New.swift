//
//  xModel+New.swift
//  xModel
//
//  Created by Mac on 2023/3/30.
//

import Foundation

extension xModel {
    
    // MARK: 实例化对象
    /// 实例化对象
    /// - Parameter info: 对象信息字典
    /// - Returns: 对象
    public class func new(dict : [String : Any]?) -> Self?
    {
        let classNameStr = NSStringFromClass(self.classForCoder())
        guard let info = dict else {
            print("⚠️ 【\(classNameStr)】初始化失败：初始化数据格式不对")
            print(dict ?? "nil")
            print("==================")
            return nil
        }
        guard info.keys.count != 0 else {
            print("⚠️ 【\(classNameStr)】初始化失败：初始化数据内容为空")
            print(info)
            print("==================")
            return nil
        }
        // 获取类的元类型(Meta), 为 AnyClass 格式, 有 type(类型) 和 self(值) 两个参数, 可以以此调用该类下的方法(方法必须实现)
        // let test : MyModel.Type = MyModel.self
        guard let className = self.classForCoder() as? xModel.Type else {
            print("⚠️ 【\(classNameStr)】初始化失败：该对象不是继承于【xModel】")
            print("==================")
            return nil
        }
        // 因为在 init() 前加了 required 关键词,保证了 xModel 类必定有 init() 构造方法,可以放心的调用
        let model = className.init()
        model.setValuesForKeys(info)
        // 保存原始字典
        model.xOriginDictionary = info
        // 创建完成后续操作
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
    
    // MARK: - 从指定对象中拷贝成员变量
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
                }
                else
                if let obj = value as? Array<Any> {
                    if obj.isEmpty { continue }
                }
                else
                if let obj = value as? Dictionary<String, Any> {
                    if obj.isEmpty { continue }
                }
            }
            self.setValue(value, forKey: key)
        }
    }
}
