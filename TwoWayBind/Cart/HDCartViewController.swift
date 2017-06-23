//
//  HDCartViewController.swift
//  sample
//
//  Created by 洪东 on 21/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import UIKit
import NSObject_Rx
import RxDataSources
import RxSwift

typealias ProductSectionModel = AnimatableSectionModel<String, HDModelProduct>

class HDCartViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView! {
        didSet{
            mainTableView
            .rx
            .enableAutoDeselect()
            .disposed(by:rx_disposeBag)
        }
    }
    @IBOutlet weak var buyBtn: UIButton! {
        didSet{
            buyBtn.layer.masksToBounds = true
            buyBtn.layer.borderWidth = 0.5
            buyBtn.layer.cornerRadius = 5
            buyBtn.layer.borderColor = UIColor.blue.cgColor
        }
    }
    @IBOutlet weak var priceLbl: UILabel!
    private let dataSource = RxTableViewSectionedReloadDataSource<ProductSectionModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let products = [1, 2, 3, 4]
            .map { HDModelProduct(id: 1000 + $0, name: "Product\($0)", unitPrice: $0 * 100, count: Variable(0)) }
        
        //数据源信号
        let sectionInfo = Observable.just([ProductSectionModel(model: "Section1", items: products)])
            .shareReplay(1)
        
        dataSource.configureCell = { _, tableView, indexPath, product in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.hDProductCell, for: indexPath)!
            cell.product = product
            return cell
        }
        
        sectionInfo
            .bind(to: mainTableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        let totalPrice = sectionInfo.map{  //先把所有组中的元素摊平成一个数组
            $0.flatMap{
                $0.items
            }
            }.flatMap{
                $0.reduce(.just(0)){acc,x in
                    
                    Observable.combineLatest(acc,x.count.asObservable().map{
                        x.unitPrice * $0
                    },resultSelector: +)
                    
                }
            }
            .shareReplay(1)
        
        totalPrice
            .map { "总价：\($0) 元" }
            .bind(to: priceLbl.rx.text)
            .disposed(by: rx.disposeBag)
        
        totalPrice
            .map { $0 != 0 }
            .bind(to: buyBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
