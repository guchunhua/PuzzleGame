//
//  ViewController.swift
//  GZYPuzzleGame
//
//  Created by leslie on 2024/10/19.
//

import UIKit
import SnapKit
import AudioToolbox

class MainViewController: UIViewController {
    
    lazy var headView = {
        let headView = MainHeaderView()
        headView.difficultyView.delegate = self
        return headView
    }()
    
    lazy var contentView = {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        return view
    }()
    
    lazy var bottomView = {
        let bottomView = MainBottomView()
        bottomView.toggleHitClosure = {[unowned self] in
            self.updateUI()
        }
        bottomView.resetClosure = { [unowned self] in
            self.resetState()
        }
        
        bottomView.automaticClosure = { [unowned self] in
            bottomView.isShuffle ? self.resetState() : self.solvePuzzleAutomatically()
        }
        
        return bottomView
    }()
    
    var rows: Int!
    var cols: Int!
    
    var puzzleBoard: [Int]!
    var lastIndex: Int!
    var blankRow: Int!
    var blankCol: Int!
    var tiles: [UIImage]!
    
    var margin = 2.0
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style:.light)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUI()
        resetState()
        
        feedbackGenerator.prepare()

    }
    
    func setUI() {
        
        view.addSubview(headView)
        headView.backgroundColor = UIColor.init(hex: 0xdddddd)
        headView.snp.makeConstraints {
            $0.left.right.equalTo(0)
            $0.height.equalTo(100)
            $0.top.equalTo(80)
        }
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.right.equalTo(0)
            $0.centerY.equalTo(view)
            $0.height.equalTo(view.frame.size.width)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.bottom.equalTo(-safeArea.bottom)
            $0.top.equalTo(contentView.snp.bottom).offset(30)
            $0.left.right.equalTo(0)
        }
    }
    
    func initChildImageView() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }

        let tileSize = (view.frame.size.width - 2 * margin) / CGFloat(cols)
        for row in 0..<rows {
            for col in 0..<cols {
                let childImageView = UIImageView()
                childImageView.tag = 555 + row*cols + col
                childImageView.frame = CGRect(x: CGFloat(col) * (tileSize + margin), y: CGFloat(row) * (tileSize + margin), width: tileSize, height: tileSize)
                contentView.addSubview(childImageView)
                
                let label = UILabel()
                label.tag = 1000 + row*cols + col
                label.textColor = .red
                label.font = UIFont.boldSystemFont(ofSize: 20)
                childImageView.addSubview(label)
                label.snp.makeConstraints { make in
                    make.center.equalTo(childImageView)
                }
            }
        }
    }
    
    func updateUI() {
        for row in 0..<rows {
            for col in 0..<cols {
                let childImageView = contentView.viewWithTag(555 + row*cols + col) as! UIImageView
                let label = contentView.viewWithTag(1000 + row*cols + col) as! UILabel

                let index = puzzleBoard[row*cols + col]

                if index == lastIndex && bottomView.isShuffle {
                    childImageView.image = nil
                    label.text = ""

                } else {
                    childImageView.image = tiles[index]
                    label.text = bottomView.hintSwitch.isOn ? "\(index+1)" : ""
                }
            }
        }
    }
    
    func slicingPic() {
        let image = bottomView.rawImageView.image!
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let tileWidth = imageWidth / CGFloat(cols)
        let tileHeight = imageHeight / CGFloat(rows)
        
        tiles = [UIImage]()
        for row in 0..<rows {
            for col in 0..<cols {
                let rect = CGRect(x: CGFloat(col) * tileWidth, y: CGFloat(row) * tileHeight, width: tileWidth, height: tileHeight)
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let tileImage = UIImage(cgImage: cgImage)
                    tiles.append(tileImage)
                }
            }
        }
    }


    func initializePuzzleBoard() {
        lastIndex = rows * cols - 1
        var numbers = Array(0..<rows * cols)
        numbers.shuffle()
        puzzleBoard = numbers
        
        let tempIndex = numbers.distance(from: numbers.startIndex, to: numbers.firstIndex(of: lastIndex)!)
        blankRow = tempIndex / rows
        blankCol = tempIndex % rows
    }
    
    func resetState() {
        bottomView.autoButton.isSelected = false

        rows = headView.difficultyView.difficulty.rawValue
        cols = headView.difficultyView.difficulty.rawValue
        
        slicingPic() // 切割图片
        initChildImageView() // 添加默认的子imageView
        initializePuzzleBoard() // 随机排序
        updateUI() // 子imageView显示随机的图片
        
        headView.stopTimer()
    }
}

// MARK: 手势
extension MainViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: contentView)
        let tileSize = view.frame.size.width / CGFloat(cols)
        
        guard location.y > 0 && location.y < view.frame.size.width else {return}
        
        let row = Int((location.y) / tileSize)
        let col = Int(location.x / tileSize)
        
        if row == blankRow && col == blankCol {
            return
        }
        
        if canMove(row: row, col: col) {
            print("\(row) \(col)")
            moveTile(row: row, col: col)
            
            updateUI()
            
            if let isValid = headView.timer?.isValid, isValid == true {
                
            } else {
                headView.startTimer()
            }
            
            if isPuzzleSolved() {
//                successAnimation(on: contentView, images: tiles)
                let alert = UIAlertController(title: nil, message: "恭喜!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "继续", style: .default, handler: { _ in
                    self.resetState()
                }))
                present(alert, animated: true)
                
            } else {
                
            }
        } else {
            print("can't move")
        }
    }
    
    func canMove(row: Int, col: Int) -> Bool {
        return bottomView.isShuffle && ((row == blankRow && abs(col - blankCol) == 1) || (col == blankCol && abs(row - blankRow) == 1))
    }
    
    func moveTile(row: Int, col: Int) {
        let temp = puzzleBoard[row * cols + col]
        puzzleBoard[row * cols + col] = puzzleBoard[blankRow*cols + blankCol]
        puzzleBoard[blankRow*cols + blankCol] = temp
        blankRow = row
        blankCol = col
        
        feedbackGenerator.impactOccurred()
    }
    
    func isPuzzleSolved() -> Bool {
        for row in 0..<rows {
            for col in 0..<cols {
                if puzzleBoard[row * cols + col] != row * cols + col {
                    return false
                }
            }
        }
        return true
    }
    
    func solvePuzzleAutomatically() {
        puzzleBoard = Array(0..<rows * cols)
        updateUI()
    }

}

// MARK: 顶部代理
extension MainViewController: MainHeaderViewDelegate {
    func difficultyChanged() {
        resetState()
    }
}


// MARK: success动画
func successAnimation(on view: UIView, images:[UIImage]) {
    // 1.创建发射器
     let emitter = CAEmitterLayer()
     
     // 2.设置发射器的位置
    emitter.emitterPosition = view.center
     
     // 3.开启三维效果
     emitter.preservesDepth = true
     
     // 4.创建例子, 并且设置例子相关的属性
     var cells = [CAEmitterCell]()
    for i in 0..<images.count {
         // 4.1.创建例子Cell
         let cell = CAEmitterCell()
         
         // 4.2.设置粒子速度
         cell.velocity = 150
         cell.velocityRange = 100
         
         // 4.3.设置例子的大小
         cell.scale = 0.1
         cell.scaleRange = 0.1
         
         // 4.4.设置粒子方向
         cell.emissionLongitude = CGFloat(-Double.pi/2)
         cell.emissionRange = CGFloat(Double.pi/2 / 6)
         
         // 4.5.设置例子的存活时间
         cell.lifetime = 3
         cell.lifetimeRange = 1.5
         
         // 4.6.设置粒子旋转
         cell.spin = CGFloat(Double.pi/2)
         cell.spinRange = CGFloat(Double.pi/2 / 2)
         
         // 4.6.设置例子每秒弹出的个数
         cell.birthRate = 3
         
         // 4.7.设置粒子展示的图片
         cell.contents = images[i].cgImage
         
         // 4.8.添加到数组中
         cells.append(cell)
     }
     
     // 5.将粒子设置到发射器中
     emitter.emitterCells = cells
     
     // 6.将发射器的layer添加到父layer中
     view.layer.addSublayer(emitter)
}
