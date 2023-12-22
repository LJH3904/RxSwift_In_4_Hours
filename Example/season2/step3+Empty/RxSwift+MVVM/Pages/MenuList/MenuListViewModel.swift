//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by LJh on 12/22/23.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    lazy var menuObservable = BehaviorRelay<[Menu]>(value: [])
    // 옵저버블
    
    lazy var itemsCount = menuObservable.map { menus in
        menus.map { $0.count }.reduce(0, +)
    } // 옵저버블
    
    lazy var totalPrice = menuObservable.map { menus in
        menus.map { $0.price * $0.count }.reduce(0, +)
    } // 옵저버블
    
    init() {
       _ = APIService.fetchAllMenusRx()
            .map { data in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item) in
                   let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
    }
    
    func onOrder() {
        
    }
    
    func clearAllItemSelections() {
        menuObservable
            .map { menus in
                menus.map { menu in
                    Menu(id: menu.id, name: menu.name, price: menu.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
            .dispose()
    }
    
    func changeCount(item: Menu, increase: Int) {
        menuObservable
            .map { menus in
                menus.map { menu in
                    if menu.id == item.id {
                        Menu(id: menu.id,
                             name: menu.name,
                             price: menu.price,
                             count: max(menu.count + increase, 0))
                    } else {
                        Menu(id: menu.id,
                             name: menu.name,
                             price: menu.price,
                             count: menu.count)
                    }
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
            .dispose()
    }
}
