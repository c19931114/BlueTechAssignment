//
//  MainTableViewCell.swift
//  BlueTechAssignment
//
//  Created by Crystal on 2024/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainTableViewCell: UITableViewCell {
    
    static let id = String(describing: MainTableViewCell.self)
    private let disposeBag = DisposeBag()
    private var cellModel: TradeCellModel?

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private lazy var priceButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.cellModel?.tapPrice()
        }).disposed(by: disposeBag)
        return button
    }()

    private lazy var amountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.cellModel?.tapAmount()
        }).disposed(by: disposeBag)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        [timeLabel, priceButton, amountButton].forEach {
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func config(cellModel: TradeCellModel) {
        self.cellModel = cellModel

        timeLabel.text = cellModel.time
        priceButton.setTitle(cellModel.price, for: .normal)
        amountButton.setTitle(cellModel.amount, for: .normal)
    }
}
