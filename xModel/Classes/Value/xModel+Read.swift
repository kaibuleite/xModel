//
//  xModel+Read.swift
//  xModel
//
//  Created by Mac on 2023/3/30.
//

import Foundation

extension xModel {

    // MARK: - 加载数据
    /// 加载字符串
    public func loadString(from list : [String],
                           default value : String = "") -> String
    {
        for str in list {
            guard str.count > 0 else { continue }
            return str
        }
        return value
    }
    /// 加载数字
    public func loadNumber(from list : [String],
                           default value : String = "0") -> String
    {
        for str in list {
            let num = Double(str) ?? 0
            guard num > 0 else { continue }
            return str
        }
        return value
    }
    /// 加载图片链接
    public func loadWebImage(from list : [String]) -> String
    {
        for str in list {
            guard str.count > 0 else { continue }
            guard let range = str.range(of: "http") else { continue }
            guard !range.isEmpty else { continue }
            return str
        }
        return ""
    }
    /// 加载数组
    public func loadArray(from list : [Any?],
                          model : xModel.Type) -> [xModel]
    {
        for info in list {
            let arr = model.newList(with: info)
            guard arr.count > 0 else { continue }
            return arr
        }
        return .init()
    }
    /// 加载对象
    public func loadModel(from list : [Any?],
                          model : xModel.Type) -> xModel?
    {
        for info in list {
            let dict = info as? [String : Any]
            guard let obj = model.new(dict: dict) else { continue }
            return obj
        }
        return nil
    }
    
}
