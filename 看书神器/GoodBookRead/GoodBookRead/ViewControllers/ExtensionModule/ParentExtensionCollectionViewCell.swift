//
//  ParentExtensionCollectionViewCell.swift
//  GoodBookRead
//
//  Created by Asun on 2019/3/26.
//  Copyright © 2019年 Asun. All rights reserved.
//

import UIKit
import HandyJSON
import YYWebImage
import Reusable

class ParentExtensionCollectionViewCell: AsunBaseCollectionViewCell {

    private lazy var extensionImageView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        return iw
    }()

    private lazy var extensionTitleLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.font = pingFangSizeRegular(size: 14)
        tl.textColor = .black
        return tl
    }()
    
    override func configUI() {
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        layer.masksToBounds = true

        contentView.addSubview(extensionTitleLabel)
        extensionTitleLabel.snp.makeConstraints{
            $0.left.bottom.right.centerX.equalToSuperview()
        }

        contentView.addSubview(extensionImageView)
        extensionImageView.snp.makeConstraints{
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(contentView.snp.width).multipliedBy(0.7)
        }
    }

    var model: ExtensionModule? {
        didSet {
            guard var model = model else { return }
            let image = model.creatImg()
            let placeholderImg = UIImage.blankImage()
            extensionImageView.yy_setImage(with: URL(string: image)!, placeholder: placeholderImg, options: [.progressiveBlur,.allowBackgroundTask,.handleCookies,.refreshImageCache], completion: nil)
            extensionTitleLabel.text = model.name
        }
    }
}
/// -- Header
class ExtensionHeaderView:AsunBaseCollectionReusableView {
    private lazy var extensionImageView: UIImageView = {
        let iw = UIImageView()
        iw.contentMode = .scaleAspectFill
        return iw
    }()

    private lazy var extensionHeaderLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.font = pingFangSizeLight(size: 14)
        tl.textColor = UIColor(r: 220, g: 104, b: 10)
        return tl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }


    override func configUI() {
        self.backgroundColor = UIColor.background
        self.addSubview(extensionHeaderLabel)
        self.addSubview(extensionImageView)
        extensionImageView.snp.makeConstraints{
            $0.leading.equalTo(self.usnp.leading).offset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 34, height: 34))
        }
        extensionHeaderLabel.snp.makeConstraints{
            $0.leading.equalTo(extensionImageView.usnp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }

    func setHeaderProprety(_ title:String,imgName:String) {
        extensionHeaderLabel.text = title
        extensionImageView.image = UIImage(named: imgName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

struct ParentExtensionModule: HandyJSON {
    var male:[ExtensionModule]?
    var female:[ExtensionModule]?
    var picture:[ExtensionModule]?
    var press:[ExtensionModule]?
    var ok:String?
}

struct ExtensionModule: HandyJSON {
    var bookCount: Int = 0
    var icon: String?
    var monthlyCount: Int = 0
    var name: String?
    var bookCover: [String]?

    mutating func creatImg() -> String {
        var image:String = ""
        if bookCover?.count ?? 0 > 0 {
            image = "http://statics.zhuishushenqi.com" + (bookCover?[0] ?? "")
        }
        return image
    }
}
