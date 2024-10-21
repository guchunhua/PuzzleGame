//
//  MainBottomView.swift
//  GZYPuzzleGame
//
//  Created by leslie on 2024/10/19.
//

import UIKit
import SnapKit

class MainBottomView: UIView {
    
    var imageIndex: Int! {
        didSet {
            rawImageView.image = UIImage(named: "default_\(imageIndex ?? 0)")
        }
    }

    lazy var rawImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.addSubview(cycleBtn)
        cycleBtn.snp.makeConstraints { make in
            make.bottom.right.equalTo(imageView)
            make.size.equalTo((CGSizeMake(40, 40)))
        }
        return imageView
    }()
    
    lazy var cycleBtn = {
        let cycleBtn = UIButton(type: .system)
        cycleBtn.setImage(UIImage(named: "xunhuan_cycle"), for: .normal)
        cycleBtn.addTarget(self, action: #selector(cycleImage), for: .touchUpInside)
        cycleBtn.backgroundColor = .white
        cycleBtn.layer.cornerRadius = 20
        cycleBtn.layer.masksToBounds = true
        return cycleBtn
    }()
    
    lazy var resetButton = {
        let btn = UIButton()
//        btn.backgroundColor = UIColor.blue
//        btn.setTitle("重置", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
        btn.setImage(UIImage(named: "reset"), for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return btn
    }()
    
    var toggleHitClosure: (()->())?
    var resetClosure: (()->Void)?
    
    lazy var hintSwitch = {
        let sw = UISwitch()
        sw.isOn = false
        sw.addTarget(self, action: #selector(toggleHint), for: .touchUpInside)
        return sw
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        
        imageIndex = Int.random(in: 1...10)

        addSubview(rawImageView)
        addSubview(hintSwitch)
        addSubview(resetButton)
        
        rawImageView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(20)
            make.width.equalTo(rawImageView.snp.height)
        }
        
        hintSwitch.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.centerY).offset(-20)
            make.centerX.equalTo(resetButton)
        }
        
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(self)
            make.right.equalTo(-30)
            make.width.height.equalTo(44)
        }
    }
    
    @objc func toggleHint() {
        toggleHitClosure?()
    }
    
    @objc func reset() {
        resetClosure?()
    }
    
    @objc func cycleImage() {
        rotateAnimation()
        
        if imageIndex == 10 {
            imageIndex = 1
        } else {
            imageIndex += 1
        }

        resetClosure?()
    }
    
    func rotateAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = CGFloat.pi / 2
        rotationAnimation.duration = 0.3
        
        cycleBtn.layer.add(rotationAnimation, forKey: "rotation90Animation")
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
    }
}
