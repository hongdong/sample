//
//  HDPaymentCell.swift
//  TwoWayBind
//
//  Created by 洪东 on 22/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HDPaymentCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isSelectImageView: UIImageView!
    
    var payment:HDModelPayment! {
        didSet{
            iconImageView.image = payment.iconAndName.icon
            nameLbl.text = payment.iconAndName.name
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

extension Reactive where Base: HDPaymentCell {
    var isSelectedPayment: UIBindingObserver<UIImageView, Bool> {
        return UIBindingObserver<UIImageView, Bool>(UIElement: self.base.isSelectImageView) { imageView,isSelected in
            imageView.image = isSelected ? #imageLiteral(resourceName: "ic_selected") : #imageLiteral(resourceName: "ic_select")
        }
    }
}
