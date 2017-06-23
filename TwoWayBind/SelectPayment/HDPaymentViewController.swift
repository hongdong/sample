//
//  HDPaymentViewController.swift
//  TwoWayBind
//
//  Created by 洪东 on 22/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

typealias PaymentSectionModel = AnimatableSectionModel<HDDataPaymentSection, HDModelPayment>

class HDPaymentViewController: UIViewController {
    @IBOutlet weak var mainTableView: UITableView! {
        didSet{
            mainTableView
            .rx
            .enableAutoDeselect()
            .disposed(by: rx_disposeBag)
        }
    }
    
    private var dataSource:RxTableViewSectionedReloadDataSource<PaymentSectionModel> {
        
        let  _dataSource = RxTableViewSectionedReloadDataSource<PaymentSectionModel>()
        _dataSource.configureCell = { ds, tb, ip, payment in
            let cell = tb.dequeueReusableCell(withIdentifier: R.reuseIdentifier.hDPaymentCell, for: ip)!
            cell.payment = payment
            let sectionData = ds[ip.section]//拿到这个组的SectionModel,里面保存了这个组选择的是哪一个
            let selectedPayment = sectionData.model.selectPayment.asObservable()
            
            //                selectedPayment
            //                    .map { $0 == payment }
            //                    .bind(to: cell.rx.isSelectedPayment)
            //                    .disposed(by: cell.rx.prepareForReuseBag)
            
            return cell
        }
        return _dataSource
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
