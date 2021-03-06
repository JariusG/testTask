//
//  DrawViewController.swift
//  testTask
//
//  Created by Роман Важник on 23.04.2020.
//  Copyright © 2020 Роман Важник. All rights reserved.
//

import UIKit
import Macaw
import PocketSVG

fileprivate struct Constants {
    static let paintCost = 1000
    static let magicStickCost = 5000
    static let magicLoupeCost = 3000
    static let buttonSize: CGFloat = 50
    static let bottomViewHeight: CGFloat = 128
    static let contentViewHeight: CGFloat = 50
    static let shopTopViewWidth: CGFloat = 160
    static let buttonIconSize = CGSize(width: 24, height: 24)
}

class DrawViewController: UIViewController {
    
    var drawAreaModel: DrawAreaModel!
    var colorizedNodes: [ColorizedNode] = []
    var hasUserTappedOnTheBoosters = false
    
    // current chosen color
    private var currentColor: Color = Color.white
    // current chosen colorIndex
    private var currentColorIndex = 0
    private var vc: InfoViewController?
    // blure effect when InfoViewController will be shown
    private var visualEffect: UIVisualEffectView!
    
    // MARK: - Properties
    private let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let boosterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var ananasButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let imageOne = SVGIconsManager.shared.returnImage(forResourceName: "086-search-1",
                                                          size: Constants.buttonIconSize)
        let imageTwo = SVGIconsManager.shared.returnImage(forResourceName: "020-zoom",
                                                          size: Constants.buttonIconSize)
        
        button.setImage(imageOne, for: .normal)
        button.setImage(imageTwo, for: .highlighted)
        button.addTarget(self, action: #selector(ananasButtonWasPressed), for: .touchUpInside)
        return button
    }()
    private let topContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        return view
    }()
    private let backButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let imageOne = SVGIconsManager.shared.returnImage(forResourceName: "093-back-2",
                                                          size: Constants.buttonIconSize)
        let imageTwo = SVGIconsManager.shared.returnImage(forResourceName: "012-back",
                                                          size: Constants.buttonIconSize)
        button.setImage(imageOne, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        button.setImage(imageTwo, for: .highlighted)
        button.addTarget(self, action: #selector(backButtonWasPressed), for: .touchUpInside)
        return button
    }()
    private let shopTopView: ViewWithShadow = {
        let view = ViewWithShadow()
        view.layer.cornerRadius = 25
        return view
    }()
    private let paintCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Arial Rounded MT Bold", size: 14)
        label.textColor = #colorLiteral(red: 0.9098039216, green: 0.262745098, blue: 0.5764705882, alpha: 1)
        return label
    }()
    private let goToShopButton: GoToShopButton = {
        let button = GoToShopButton()
        let image = SVGIconsManager.shared.returnImage(forResourceName: "091-plus-1",
                                                          size: Constants.buttonIconSize)
        button.setImage(image, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showShop), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let image = SVGIconsManager.shared.returnImage(forResourceName: "100-gear",
                                                                 size: Constants.buttonIconSize)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(settingsButtonWasPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var turnOffSoundButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let image = SVGIconsManager.shared.returnImage(forResourceName: "103-speaker-1",
                                                       size: Constants.buttonIconSize)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var turnVibroButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let image = SVGIconsManager.shared.returnImage(forResourceName: "102-telephone-call-1",
                                                       size: Constants.buttonIconSize)
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var magicStickButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let imageOne = SVGIconsManager.shared.returnImage(forResourceName: "magic_stick",
                                                          size: CGSize(width: 32, height: 29.41))
        let imageTwo = SVGIconsManager.shared.returnImage(forResourceName: "021-magic-wand",
                                                          size: CGSize(width: 32, height: 29.41))
        button.setImage(imageOne, for: .normal)
        button.setImage(imageTwo, for: .highlighted)
        button.addTarget(self, action: #selector(magicStickButtonWasPressed), for: .touchUpInside)
        return button
    }()
    private lazy var magicStickInfoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.393315196, green: 0.2743449807, blue: 0.8032925725, alpha: 1)
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        let image = SVGIconsManager.shared.returnImage(forResourceName: "Group 23",
                                                          size: CGSize(width: 4, height: 10))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(magicStickInfoButtonWasPressed), for: .touchUpInside)
        return button
    }()
    private lazy var loupeButton: ButtonWithShadow = {
        let button = ButtonWithShadow()
        let imageOne = SVGIconsManager.shared.returnImage(forResourceName: "magic search",
                                                          size: CGSize(width: 32.45, height: 29))
        let imageTwo = SVGIconsManager.shared.returnImage(forResourceName: "022-magic-magnifier",
                                                          size: CGSize(width: 32.45, height: 29))
        button.setImage(imageOne, for: .normal)
        button.setImage(imageTwo, for: .highlighted)
        button.addTarget(self, action: #selector(loupeButtonWasPressed), for: .touchUpInside)
        return button
    }()
    lazy var drawArea: MySVGView = {
        let svgView = MySVGView()
        svgView.translatesAutoresizingMaskIntoConstraints = false
        svgView.backgroundColor = .white
        svgView.fileName = drawAreaModel.imagePathWithoutNumbers
        svgView.contentMode = .scaleAspectFit
        return svgView
    }()
    private lazy var colorCollectionViewPicker: CollectionViewWithShadow = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 34)
        let collectionView = CollectionViewWithShadow(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 25
        collectionView.isUserInteractionEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorCollectionViewPickerCell.self,
                                forCellWithReuseIdentifier: "ColorCell")
        return collectionView
    }()
    
    let semaphore = DispatchSemaphore(value: 1)
    private var numberOfPaints: Int! {
        didSet {
            paintCountLabel.text = ConvertNumberManager.shared.convertNumberOfPaintsToString(number: numberOfPaints)
        }
    }
    
    // MARK: - Methods
    override func viewDidLoad() {
        view.backgroundColor = .white
        numberOfPaints = 20000
        drawArea.fileName = drawAreaModel.imagePathWithNumbers
        setActionsToNodes()
        layoutElements()
        checkIfUserTappedOnTheBooster()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNumberOfPaints()
    }
    
    
    @objc private func settingsButtonWasPressed() {
        var imageName = ""
        if turnVibroButton.isHidden {
            imageName = "005-settings"
        } else {
            imageName = "100-gear"
        }
        let image = SVGIconsManager.shared.returnImage(forResourceName: imageName,
                                                       size: CGSize(width: 24, height: 24))
        settingsButton.setImage(image, for: .normal)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.turnVibroButton.isHidden = !self.turnVibroButton.isHidden
            self.turnOffSoundButton.isHidden = !self.turnOffSoundButton.isHidden
        }
    }
    
    //Buttons actions
    @objc private func showShop() {
        let vc = ShopViewController()
        vc.drawId = drawAreaModel.id
        vc.numberOfPaints = numberOfPaints
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func magicStickButtonWasPressed() {
        if currentColor != Color.white {
            if !hasUserTappedOnTheBoosters {
                magicStickInfoButtonWasPressed()
                UserDefaultsManager.shared.userTapOnTheBoosterForTheFirstTime()
                hasUserTappedOnTheBoosters = true
            } else {
                // find all nodes with certain tag and colorize it
                if numberOfPaints >= Constants.magicStickCost {
                    var isAllNodesColorized = true
                    for valueTag in 1...drawAreaModel.nodes[currentColorIndex] {
                        let tag = "\(currentColorIndex+1)_\(valueTag)"
                        if isColorizedNodesContains(nodeTag: tag) { continue }
                        isAllNodesColorized = false
                        changeNodeColor(pathTag: tag, withColor: currentColor)
                        let colorizedNode = ColorizedNode(colorTag: currentColorIndex, tag: tag)
                        colorizedNodes.append(colorizedNode)
                        let cell = colorCollectionViewPicker.cellForItem(at:
                            IndexPath(item: currentColorIndex, section: 0)) as! ColorCollectionViewPickerCell
                        cell.nodeWasColorized()
                    }
                    if !isAllNodesColorized {
                        numberOfPaints-=Constants.magicStickCost
                        saveColorizedNode()
                    }
                }
            }
        }
    }
    
    @objc private func ananasButtonWasPressed() {
        if !hasUserTappedOnTheBoosters {
            magicStickInfoButtonWasPressed()
            UserDefaultsManager.shared.userTapOnTheBoosterForTheFirstTime()
            hasUserTappedOnTheBoosters = true
        }
    }
    
    private var previousColorizedColorsIndexByLoupe: [Int] = []
    @objc private func loupeButtonWasPressed() {
        if currentColor != Color.white {
            if !hasUserTappedOnTheBoosters {
                UserDefaultsManager.shared.userTapOnTheBoosterForTheFirstTime()
                hasUserTappedOnTheBoosters = true
            } else {
                if previousColorizedColorsIndexByLoupe.contains(currentColorIndex) {
                    return
                }
                previousColorizedColorsIndexByLoupe.append(currentColorIndex)
                var isAllNodesColorized = true
                if numberOfPaints >= Constants.magicLoupeCost {
                    for valueTag in 1...drawAreaModel.nodes[currentColorIndex] {
                        let tag = "\(currentColorIndex+1)_\(valueTag)"
                        if isColorizedNodesContains(nodeTag: tag) { continue }
                        isAllNodesColorized = false
                        changeNodeColor(pathTag: tag, withColor: Color.rgba(r: 174, g: 174, b: 174, a: 0.5))
                    }
                }
                if !isAllNodesColorized { numberOfPaints-=Constants.magicLoupeCost }
            }
        }
    }
    
    @objc private func backButtonWasPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func magicStickInfoButtonWasPressed() {
        // add blure on viewController
        let blure = UIBlurEffect(style: .dark)
        visualEffect = UIVisualEffectView(effect: blure)
        visualEffect.alpha = 0
        visualEffect.frame = view.frame
        
        view.addSubview(visualEffect)
        vc = InfoViewController()
        vc!.delegate = self
        vc!.view.frame = UIApplication.shared.windows[0].frame
        vc!.didMove(toParent: self)
        vc!.view.alpha = 0
        self.addChild(vc!)
        self.view.addSubview(vc!.view)
        
        UIView.animate(withDuration: 0.6) { [unowned self] in
            self.vc!.view.alpha = 1
            self.visualEffect.alpha = 0.6
        }
    }
    
    private func layoutElements() {
        layoutBottomView()
        layoutCollectionView()
        layoutBoosterView()
        layoutAnanasButton()
        layoutLoupeButton()
        layoutMagicWandButton()
        layoutMagicStickInfoButton()
        layoutTopContentView()
        layoutDrawArea()
        layoutSettingsButtons()
    }
    
    private func checkIfUserTappedOnTheBooster() {
        guard let result = UserDefaultsManager.shared.hasUserTappedOnTheBoosters() else { return }
        hasUserTappedOnTheBoosters = result
    }
    
    // get user's progress in certain painting
    private func getAllColorizedTags() {
        let dispatchWorkItem = DispatchWorkItem(qos: .userInteractive) { [unowned self] in
            guard let nodes = UserDefaultsManager.shared.getProgress(drawId: self.drawAreaModel.id) else { return }
            self.colorizedNodes = nodes
        }
        DispatchQueue.global(qos: .utility).async(execute: dispatchWorkItem)
        dispatchWorkItem.notify(queue: .main) { [unowned self] in
            if !self.colorizedNodes.isEmpty {
                self.colorizeAllSavedAreas()
            }
        }
    }
    
    // get user's number of paints in certain painting
    private func getNumberOfPaints() {
        let dispatchWorkItem = DispatchWorkItem(qos: .userInteractive) { [unowned self] in
            guard let numberOfPaints =
                UserDefaultsManager.shared.getNumberOfPaints(drawId: self.drawAreaModel.id) else { return }
            DispatchQueue.main.async { [unowned self] in
                self.numberOfPaints = numberOfPaints
            }
        }
        DispatchQueue.global(qos: .utility).async(execute: dispatchWorkItem)
    }
    
    // colorize all nodes that user colorized before
    private func colorizeAllSavedAreas() {
        for node in colorizedNodes {
            let color = drawAreaModel.correctColors[node.colorTag]
            changeNodeColor(pathTag: node.tag, withColor: color)
            let cell = colorCollectionViewPicker.cellForItem(at:
                IndexPath(item: node.colorTag, section: 0)) as! ColorCollectionViewPickerCell
            cell.nodeWasColorized()
        }
    }
    
    // save all current colorized nodes
    private func saveColorizedNode() {
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            self.semaphore.wait()
            UserDefaultsManager.shared.saveProgress(drawId: self.drawAreaModel.id, colorizedTags: self.colorizedNodes, numberOfPaints: self.numberOfPaints)
            self.semaphore.signal()
        }
    }
    
    // set actions to all nodes
    private func setActionsToNodes() {
        for pathTag in 1...drawAreaModel.nodes.count {
            for valueTag in 1...drawAreaModel.nodes[pathTag-1] {
                let tag = "\(pathTag)_\(valueTag)"
                if isColorizedNodesContains(nodeTag: tag) { continue }
                drawArea.node.nodeBy(tag: tag)?.onTouchPressed({ (touch) in
                    self.changeNodeColor(pathTag: pathTag-1, fullNodeTag: tag)
                })
            }
        }
    }
    
    // fill certain node with color
    private func changeNodeColor(pathTag: String, withColor color: Color) {
        guard let nodeShape = drawArea.node.nodeBy(tag: pathTag) as? Shape else { return }
        nodeShape.fill = color
    }
    
    // node action (user has tapped to certain node)
    private func changeNodeColor(pathTag: Int, fullNodeTag: String) {
        // if collor is correct and node is't colorized fill it
        if drawAreaModel.correctColors[pathTag] == currentColor
            && !isColorizedNodesContains(nodeTag: fullNodeTag) && numberOfPaints >= Constants.paintCost {
            changeNodeColor(pathTag: fullNodeTag, withColor: currentColor)
            let colorizedNode = ColorizedNode(colorTag: pathTag, tag: fullNodeTag)
            colorizedNodes.append(colorizedNode)
            saveColorizedNode()
            // tell UICollectionViewCell that node was colorized
            let cell = colorCollectionViewPicker.cellForItem(at:
                IndexPath(item: currentColorIndex, section: 0)) as! ColorCollectionViewPickerCell
            cell.nodeWasColorized()
            numberOfPaints-=Constants.paintCost
        }
    }
    
    private func isColorizedNodesContains(nodeTag: String) -> Bool {
        var flag = false
        for node in colorizedNodes {
            if node == nodeTag {
                flag = true
                break
            }
        }
        return flag
    }
    
    // MARK: - Elements layout
    private func layoutMagicStickInfoButton() {
        magicStickButton.addSubview(magicStickInfoButton)
        magicStickInfoButton.centerXAnchor.constraint(equalTo: magicStickButton.centerXAnchor, constant: 16).isActive = true
        magicStickInfoButton.centerYAnchor.constraint(equalTo: magicStickButton.centerYAnchor, constant: -16).isActive = true
        magicStickInfoButton.heightAnchor.constraint(equalToConstant: 18).isActive = true
        magicStickInfoButton.widthAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
    private func layoutAnanasButton() {
        boosterView.addSubview(ananasButton)
        ananasButton.leadingAnchor.constraint(equalTo: boosterView.leadingAnchor).isActive = true
        ananasButton.topAnchor.constraint(equalTo: boosterView.topAnchor).isActive = true
        ananasButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        ananasButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }
    
    private func layoutLoupeButton() {
        boosterView.addSubview(loupeButton)
        loupeButton.trailingAnchor.constraint(equalTo: boosterView.trailingAnchor).isActive = true
        loupeButton.topAnchor.constraint(equalTo: boosterView.topAnchor).isActive = true
        loupeButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        loupeButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }
    
    private func layoutMagicWandButton() {
        boosterView.addSubview(magicStickButton)
        magicStickButton.trailingAnchor.constraint(equalTo: loupeButton.leadingAnchor, constant: -15).isActive = true
        magicStickButton.topAnchor.constraint(equalTo: boosterView.topAnchor).isActive = true
        magicStickButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        magicStickButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }
    
    private func layoutCollectionView() {
        let margins = view.layoutMarginsGuide
        bottomView.addSubview(colorCollectionViewPicker)
        colorCollectionViewPicker.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -5).isActive = true
        colorCollectionViewPicker.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: 20).isActive = true
        colorCollectionViewPicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        colorCollectionViewPicker.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 1).isActive = true
    }
    
    private func layoutBottomView() {
        view.addSubview(bottomView)
        let margins = view.layoutMarginsGuide
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: Constants.bottomViewHeight).isActive = true
    }
    
    private func layoutBoosterView() {
        bottomView.addSubview(boosterView)
        boosterView.bottomAnchor.constraint(equalTo: colorCollectionViewPicker.topAnchor, constant: -15).isActive = true
        boosterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14).isActive = true
        boosterView.heightAnchor.constraint(equalToConstant: Constants.contentViewHeight).isActive = true
        boosterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
    }
    
    private func layoutTopContentView() {
        view.addSubview(topContentView)
        let margins = view.layoutMarginsGuide
        topContentView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 6).isActive = true
        topContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topContentView.heightAnchor.constraint(equalToConstant: Constants.contentViewHeight).isActive = true
        
        topContentView.addSubview(backButton)
        backButton.leadingAnchor.constraint(equalTo: topContentView.leadingAnchor, constant: 15).isActive = true
        backButton.topAnchor.constraint(equalTo: topContentView.topAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        
        topContentView.addSubview(shopTopView)
        shopTopView.centerXAnchor.constraint(equalTo: topContentView.centerXAnchor).isActive = true
        shopTopView.widthAnchor.constraint(equalToConstant: Constants.shopTopViewWidth).isActive = true
        shopTopView.topAnchor.constraint(equalTo: topContentView.topAnchor).isActive = true
        
        let image = SVGIconsManager.shared.returnImage(forResourceName: "magic fill",
                                                       size: CGSize(width: 31.47, height: 24))
        let paintImageView = UIImageView(image: image)
        paintImageView.translatesAutoresizingMaskIntoConstraints = false
        
        shopTopView.addSubview(paintImageView)
        paintImageView.leadingAnchor.constraint(equalTo: shopTopView.leadingAnchor, constant: 13).isActive = true
        paintImageView.centerYAnchor.constraint(equalTo: shopTopView.centerYAnchor).isActive = true
        paintImageView.bottomAnchor.constraint(equalTo: shopTopView.bottomAnchor, constant: -13).isActive = true
        
        shopTopView.addSubview(paintCountLabel)
        paintCountLabel.centerXAnchor.constraint(equalTo: shopTopView.centerXAnchor).isActive = true
        paintCountLabel.centerYAnchor.constraint(equalTo: shopTopView.centerYAnchor).isActive = true
        
        shopTopView.addSubview(goToShopButton)
        goToShopButton.centerYAnchor.constraint(equalTo: shopTopView.centerYAnchor).isActive = true
        goToShopButton.trailingAnchor.constraint(equalTo: shopTopView.trailingAnchor, constant: -13).isActive = true
    }
    
    private func layoutSettingsButtons() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 5
        
        turnOffSoundButton.isHidden = true
        turnVibroButton.isHidden = true
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(turnVibroButton)
        stackView.backgroundColor = .black
        stackView.addArrangedSubview(turnOffSoundButton)
        drawArea.addSubview(stackView)
        stackView.trailingAnchor.constraint(equalTo: topContentView.trailingAnchor, constant: -15).isActive = true
        stackView.topAnchor.constraint(equalTo: topContentView.topAnchor).isActive = true
        
        turnVibroButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        turnVibroButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        
        turnOffSoundButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        turnOffSoundButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        
        settingsButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
    }
    
    private func layoutDrawArea() {
        view.addSubview(drawArea)
        drawArea.topAnchor.constraint(equalTo: topContentView.bottomAnchor, constant: 34).isActive = true
        drawArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        drawArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        drawArea.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -34).isActive = true
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension DrawViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 25, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drawAreaModel.correctColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell",
                                                      for: indexPath) as! ColorCollectionViewPickerCell
        let color = drawAreaModel.correctColors[indexPath.row]
        let numberOfNodes = drawAreaModel.nodes[indexPath.row]
        cell.setImageColor(color: color, number: indexPath.row+1, numberOfNodes: numberOfNodes)
        if (indexPath.row == drawAreaModel.correctColors.count-1) { getAllColorizedTags() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentColor = drawAreaModel.correctColors[indexPath.row]
        currentColorIndex = indexPath.row
    }
    
}

// MARK: - InfoViewControllerDelegate
// remove blure effect and infoVC
extension DrawViewController: InfoViewControllerDelegate {
    func closeInfoScreen() {
        guard let vc = vc else { return }
        UIView.animate(withDuration: 0.6, animations: { [unowned self] in
            vc.view.alpha = 0
            self.visualEffect.alpha = 0
        }) {  [unowned self] (_) in
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            self.vc = nil
            self.visualEffect.removeFromSuperview()
        }
    }
}

// тк settingButton находится на MySVGView, но не в координатах superView
// переопределяю метод point и проверяю входит ли subview в координату тапа
class MySVGView: SVGView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        
        if !inside {
            for subview in subviews {
                let pointInSub = subview.convert(point, from: self)
                if subview.point(inside: pointInSub, with: event) {
                    return true
                }
            }
        }
        return inside
    }
}
