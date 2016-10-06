//
//  TabMenuOption.swift
//  TabMenu
//
//  Created by K.Kawakami on 2016/10/04.
//  Copyright © 2016年 川上健太郎. All rights reserved.
//

import Foundation

public enum TabMenuOption {
    case TabMenuHeight(CGFloat)
    case TabMenuBackGroundColor(UIColor)
    case TabMenuWidthMargin(CGFloat)
    case CurrentBarColor(UIColor)
    case HighLightItemTitleTextColor(UIColor)
    case DefaultItemTitleTextColor(UIColor)
    case ItemTitleTextFont(UIFont)
}

public struct TabMenuOptionGroup {
    internal var tabMenuHeight: CGFloat = 50.0
    internal var tabMenuBackGroundColor = UIColor.white
    internal var tabMenuWidthMargin: CGFloat = 20.0
    internal var currentBarColor = UIColor.black
    internal var highLightItemTitleTextColor = UIColor.black
    internal var defaultItemTitleTextColor = UIColor.lightGray
    internal var itemTitleTextFont = UIFont.systemFont(ofSize: 17.0)
    
    init() {
        
    }
    
    init(options: [TabMenuOption]?) {
        guard let options = options else {
            return
        }
        
        for option in options {
            switch option {
            case .TabMenuHeight(let height):
                tabMenuHeight = height
            case .TabMenuBackGroundColor(let color):
                tabMenuBackGroundColor = color
            case .TabMenuWidthMargin(let margin):
                tabMenuWidthMargin = margin
            case .CurrentBarColor(let color):
                currentBarColor = color
            case .HighLightItemTitleTextColor(let color):
                highLightItemTitleTextColor = color
            case .DefaultItemTitleTextColor(let color):
                defaultItemTitleTextColor = color
            case .ItemTitleTextFont(let font):
                itemTitleTextFont = font
            }
        }
        
        
    }
    
}
