//
//  HDProductCell.swift
//  sample
//
//  Created by 洪东 on 21/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import UIKit

class HDProductCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton! {
        didSet{
            minusBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.product.count.value -= 1
            }
            .disposed(by: rx_disposeBag)
        }
    }
    @IBOutlet weak var plusBtn: UIButton! {
        didSet{
            plusBtn
                .rx
                .tap
                .bind { [weak self] in
                    self?.product.count.value += 1
                }
                .disposed(by: rx_disposeBag)
        }
    }
    
    var product:HDModelProduct! {
        didSet{
            if product == nil {
                fatalError()
            }
            
            nameLbl.text = product.name
            priceLbl.text = "单价: \(product.unitPrice) 元"
            
            product
            .count
            .asObservable()
            .bind { [weak self] in
                if $0 < 0 {
                    fatalError()
                }
                self?.minusBtn.isEnabled = $0 != 0
                self?.countLbl.text = String($0)
            }
            .disposed(by: rx.prepareForReuseBag)
            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
