//
//  xPage.swift
//  Pods-xSDK_Example
//
//  Created by Mac on 2020/9/14.
//

import UIKit

public class xPage: NSObject {
    
    // MARK: - Public Property
    /// 当前页数
    public var current : Int = 0
    /// 总页数(默认1页,从服务器返回具体数据)
    public var total : Int = 1
    /// 每页数据数量(默认20,根据情况自己修改)
    public var size : Int = 20
    
    /// 是否还有数据(默认否,根据当前页自动判断)
    public var isMore : Bool {
        if self.current >= self.total {
            self.current = self.total
            return false
        } else {
            return true
        }
    }
    
    // MARK: - 初始页码
    /// 初始页码(全局设置）
    static var initPage : Int = 0
    /// 初始分页大小
    static var initSize : Int = 20
    /// 设置初始页码
    public static func setInitPage(_ page : Int)
    {
        xPage.initPage = page
    }
    /// 设置初始分页大小
    public static func setInitSize(_ size : Int)
    {
        xPage.initSize = size
    }
    
    /// 恢复初页码
    public func resetPage()
    {
        self.current = xPage.initPage
    }
    /// 恢复初页码
    public func resetSize()
    {
        self.size = xPage.initSize
    }
    
    // MARK: - 总页数
    /// 更新总页数
    public func updateTotalPage(_ page : Any?)
    {
        if let obj = page as? Int {
            self.total = obj
        } else
        if let obj = page as? String {
            self.total = Int(obj) ?? 0
        } else {
            print("⚠️ 总页码格式不对 \(String(describing: page))")
        }
    }
    
    /// 更新总页数
    /// - Parameters:
    ///   - list: 接口返回的数据
    ///   - size: 分页大小（一般最小单页数据大小为10）
    public func updateTotalPage(at list : [Any])
    {
        if list.count == 0 {
            // 没有多余的分页了
            self.total = self.current
        } else {
            // 默认还有下一页
            self.total = self.current + 1
        }
    }
    
}
