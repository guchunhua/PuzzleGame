//
//  MainHeaderView.swift
//  GZYPuzzleGame
//
//  Created by leslie on 2024/10/19.
//

import UIKit
import SnapKit

class MainHeaderView: UIView {
    
    lazy var difficultyView = DifficultyView()
    
//    lazy var heartImageView = {
//        let trashIcon = UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold))?.withTintColor(.red, renderingMode: .alwaysOriginal)
//        return UIImageView(image: trashIcon)
//    }()
    
//    lazy var scaleAnimation = {
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnimation.fromValue = 1.0
//        scaleAnimation.toValue = 1.2
//        scaleAnimation.duration = 1.8
//        scaleAnimation.autoreverses = true // 自动反向播放动画
//        scaleAnimation.repeatCount = Float.infinity // 无限重复
//        return scaleAnimation
//    }()
    
    var timer: Timer?
    var elapsedSeconds = 0 {
        didSet {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60
            timeLabel.text = String(format: "%02d : %02d : %02d", hours, minutes, seconds)
        }
    }
    
    let timeLabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = UIFont.boldSystemFont(ofSize: 16)
        lb.text = "00 : 00 : 00"
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        addSubview(difficultyView)
        difficultyView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.height.equalTo(40)
            make.bottom.equalTo(-10)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(difficultyView.snp_topMargin).offset(-4)
            make.height.equalTo(40)
            make.width.equalTo(110)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        elapsedSeconds = 0
    }
    
    @objc func updateTimer() {
        elapsedSeconds += 1
    }
    
//    func startHeartAnimation() {
//        heartImageView.layer.add(scaleAnimation, forKey: "scaleAnimation")
//    }
//    
//    func stopHeartAnimation() {
//        heartImageView.layer.removeAnimation(forKey: "scaleAnimation")
//    }
}
