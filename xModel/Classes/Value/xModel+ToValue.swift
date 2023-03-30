//
//  xModel+ToValue.swift
//  xModel
//
//  Created by Mac on 2023/3/30.
//

import Foundation

extension xModel {
    
    // MARK: - 数据转换
    /// 转换成成员属性字典
    /// - Returns: 生成的字典
    public func toDictionary() -> [String : Any]
    {
        var ret = [String : Any]()
        let filterKeyArray = ["xCreateNumber", "xDebugContent", "xOriginDictionary", "xIsLogModelNoPropertyTip"]
        for key in self.ivarList {
            // 过滤本地创建的数据
            guard !filterKeyArray.contains(key) else { continue }
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
        let dict = self.toDictionary()
        for (key, value) in dict {
            guard let str = value as? String else { continue }
            ret[key] = str
        }
        return ret
    }
}
