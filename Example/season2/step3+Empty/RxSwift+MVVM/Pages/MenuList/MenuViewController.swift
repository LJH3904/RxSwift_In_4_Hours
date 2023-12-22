//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    // MARK: - Life Cycle
    let viewModel = MenuListViewModel()
    var disposBag = DisposeBag()
    let cellId = "MenuItemTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.menuObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
            }.disposed(by: disposBag)
        
        viewModel.itemsCount
            .map { "\($0)" }
            .observe(on: MainScheduler.instance)
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposBag)
        
        viewModel.totalPrice
            .map { $0.currencyKR() }
//            .catchAndReturn("")
//            .observe(on: MainScheduler.instance)
//            .bind(to: totalPrice.rx.text)
            .asDriver(onErrorJustReturn: "")
            .drive(totalPrice.rx.text)
            .disposed(by: disposBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
           let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - InterfaceBuilder Links
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!
    
    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }
    
    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
        //        performSegue(withIdentifier: "OrderViewController", sender: nil)
        viewModel.onOrder()
    }
}
