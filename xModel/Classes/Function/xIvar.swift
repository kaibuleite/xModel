//
//  xIvar.swift
//  xModel
//
//  Created by Mac on 2021/6/10.
//

import Foundation

// MARK: - 获取对象的成员变量名称列表
/// 获取一个对象的成员属性列表
/// - Parameter obj: 指定的对象
/// - Returns: 成员属性列表
public func xGetIvarList(obj : NSObject) -> [String]
{
    var ret = [String]()
    if obj.isMember(of: NSObject.classForCoder()) { return ret }
    // 读取对象父类的成员变量
    guard var spClass = obj.superclass else { return ret }
    while spClass != NSObject.classForCoder() {
        let spIvarList = xGetIvarList(objClass: spClass)
        ret += spIvarList
        // 父级的父级
        guard let sspClass = spClass.superclass() else { break }
        spClass = sspClass
    }
    // 读取对象自身的成员变量
    ret += xGetIvarList(objClass: obj.classForCoder)
    // 排个序
    ret.sort()
    return ret
}

/// 获取指定类的成员属性列表
/// - Parameter objClass: 指定的类
/// - Returns: 成员属性列表
public func xGetIvarList(objClass : AnyClass) -> [String]
{
    var ret = [String]()
    var count = UInt32(0)
    let list = class_copyIvarList(objClass, &count)
    for i in 0 ..< count {
        guard let ivar = list?[Int(i)] else { continue }
        let name = ivar_getName(ivar)
        let str = String(cString: name!)
        ret.append(str)
    }
    free(list)
    return ret
}
