//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by LJh on 12/22/23.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation

// viewModel이다. 
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
