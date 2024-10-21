//
//  DifficultyView.swift
//  GZYPuzzleGame
//
//  Created by leslie on 2024/10/20.
//

import UIKit
import SnapKit

protocol MainHeaderViewDelegate {
    func difficultyChanged()->()
}

enum Difficulty: Int {
    case easy = 3
    case medium
    case difficult
    case veryDifficult
    
    var descDifficulty: (String, Int) {
        switch self {
        case.easy:
            return ("简单", 2)
        case.medium:
            return ("中等", 3)
        case.difficult:
            return ("难", 4)
        case.veryDifficult:
            return ("非常难", 5)
        }
    }
}

class DifficultyView: UIView {
    
    var delegate: MainHeaderViewDelegate?
    
    var difficulty : Difficulty {
        didSet {
            let (_ , index) = difficulty.descDifficulty
            for i in 0..<5 {
                let star = viewWithTag(555+i)
                star?.isHidden = i >= index
                
                if i == 4 {
                    star?.snp.updateConstraints({ make in
                        make.right.equalTo(-5 + (5 - index) * 25)
                    })
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        difficulty = .easy
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        backgroundColor = UIColor(hex: 0x3d88ec)
        layer.cornerRadius = 6
        
        let logoImageView = UIImageView(image: UIImage(named: "nandu"))
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        for index in 0..<5 {
            let starImageView = UIImageView(image: UIImage(named: "star"))
            starImageView.tag = 555 + index
            addSubview(starImageView)
            
            starImageView.snp.makeConstraints { make in
                make.centerY.equalTo(self)
                make.size.equalTo(CGSizeMake(20, 20))
                make.left.equalTo(index * 25 + 30)
                if index == 4 {
                    make.right.equalTo(-5)
                }
            }
            
           
        }
        
        difficulty = .easy
    }
    
    @objc func toggleDifficulty()  {
        difficulty = Difficulty(rawValue:difficulty.rawValue + 1) ?? .easy
        
        delegate?.difficultyChanged()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleDifficulty()
    }
}
