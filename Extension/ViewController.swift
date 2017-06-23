//
//  ViewController.swift
//  extension
//
//  Created by 洪东 on 20/06/2017.
//  Copyright © 2017 abner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hole = RoundHole(radius: 5.0)
        
        for i in 5...10 {
            let squarePeg = SquarePeg(width: Double(i))
            let peg: Circularity = SquarePegAdaptor(peg: squarePeg)
            let fit = hole.pegFits(peg)
            println("width:\(i), fit:\(fit)")
        }
        
        for i in 5...10 {
            let peg = SquarePeg(width: Double(i))
            let fit = hole.pegFits(peg)
            println("width:\(i), fit:\(fit)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

protocol Circularity {
  		var radius: Double { get }
}

class RoundPeg: Circularity {
  		let radius: Double
  		init(radius: Double) {
            self.radius = radius
  		}
}

class RoundHole {
  		let radius: Double
  		init(radius: Double) {
            self.radius = radius
  		}
  		func pegFits(peg: Circularity) -> Bool {
            return peg.radius <= radius
  		}
}

class SquarePeg {
  		let width: Double
  		init(width: Double) {
            self.width = width
  		}
}

class SquarePegAdaptor: Circularity {
    
  		private let peg: SquarePeg
  		var radius: Double {
            get {
                return sqrt(pow(peg.width/2, 2) * 2)
            }
	  	}
  		init(peg: SquarePeg) {
            self.peg = peg
  		}
}

// Use extension
extension SquarePeg: Circularity {
  		var radius: Double {
            get {
                return sqrt(pow(width/2, 2) * 2)
            }
  		}
}

