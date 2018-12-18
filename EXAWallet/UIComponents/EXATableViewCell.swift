//
// Created by Igor Efremov on 20/07/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

class EXATableViewCell: UITableViewCell, EXAUIStylesSupport {
    
    required init() {
        super.init(style: .default, reuseIdentifier: "\(type(of: self))")
    }
    
    init(style: UITableViewCell.CellStyle = .default) {
        super.init(style: style, reuseIdentifier: "\(type(of: self))")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ? UIColor.mainColor : UIColor.screenBackgroundColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? UIColor.mainColor : UIColor.screenBackgroundColor
        if highlighted {
            setHighlighted(false, animated: true)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func applyStyles() {}
}
