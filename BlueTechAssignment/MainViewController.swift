//
//  MainViewController.swift
//  BlueTechAssignment
//
//  Created by Crystal on 2024/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()

    enum Action {
        case price
        case amount
    }
    let action = PublishRelay<Action>()

    private lazy var typeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        ["時間", "最新价", "交易量"].forEach {
            let label = UILabel()
            label.textColor = .black
            label.text = $0
            label.layer.borderColor = UIColor.black.cgColor
            label.layer.borderWidth = 1
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()

    private lazy var priceButton: UIButton = {
        let button = UIButton()
        button.setTitle("↕️", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.priceButtonClicked(button)
        }.disposed(by: disposeBag)
        return button
    }()

    private lazy var amountButton: UIButton = {
        let button = UIButton()
        button.setTitle("↕️", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.amountButtonClicked(button)
        }.disposed(by: disposeBag)
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(priceButton)
        stackView.addArrangedSubview(amountButton)
        return stackView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(MainTableViewCell.self,
                           forCellReuseIdentifier: MainTableViewCell.id)
        return tableView
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price:"
        label.textColor = .black
        return label
    }()

    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .lightGray
        return textField
    }()

    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(priceTextField)
        priceTextField.snp.makeConstraints {
            $0.width.equalTo(200)
        }
        return stackView
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount:"
        label.textColor = .black
        return label
    }()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .lightGray
        return textField
    }()

    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total:"
        label.textColor = .black
        return label
    }()

    private lazy var amountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.addArrangedSubview(amountLabel)
        stackView.addArrangedSubview(amountTextField)
        amountTextField.snp.makeConstraints {
            $0.width.equalTo(200)
        }
        return stackView
    }()

    private lazy var orderButton: UIButton = {
        let button = UIButton()
        button.setTitle("Order", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.orderButtonClicked(button)
        }.disposed(by: disposeBag)
        return button
    }()

    private lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        [priceStackView, amountStackView, totalLabel, orderButton].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(40)
                $0.width.equalTo(300)
            }
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
            stackView.addArrangedSubview($0)
        }
        return stackView
    }()

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(typeStackView)
        view.addSubview(buttonStackView)
        view.addSubview(tableView)
        view.addSubview(inputStackView)
        typeStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(typeStackView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.67)
            $0.height.equalTo(40)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
        }
        inputStackView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private var dataSource: [TradeCellModel] = []

    private func bindViewModel() {
        viewModel.output.cellModels.drive(onNext: { [weak self] cellModels in
            guard let self = self else { return }
            self.dataSource = cellModels
            self.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.output.price.drive(onNext: { [weak self] price in
            guard let self = self else { return }
            self.priceTextField.text = "\(price)"
        }).disposed(by: disposeBag)

        viewModel.output.amount.drive(onNext: { [weak self] amount in
            guard let self = self else { return }
            self.amountTextField.text = "\(amount)"
        }).disposed(by: disposeBag)

        viewModel.output.total.drive(onNext: { [weak self] total in
            guard let self = self else { return }
            self.totalLabel.text = "Total: \(total)"
        }).disposed(by: disposeBag)
    }

    private func priceButtonClicked(_ sender: UIButton) {
        viewModel.sortByPrice(sender)
    }

    private func amountButtonClicked(_ sender: UIButton) {
        viewModel.sortByAmount(sender)
    }

    private func orderButtonClicked(_ sender: UIButton) {
        showAlert()
    }

    private func showAlert() {
        Driver.combineLatest(viewModel.output.price,
                             viewModel.output.amount,
                             viewModel.output.total)
        .drive(onNext: { [weak self] (price, amount, total) in
            guard let self else { return }

            let alertController = UIAlertController(title: "當前",
                                                    message: "Price: \(price)\nAmount: \(amount)\n\(total)",
                                                    preferredStyle: .alert)

            let okAction = UIAlertAction(title: "確定", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.priceTextField.text = ""
                self.amountTextField.text = ""
                self.totalLabel.text = "Total:"
            }

            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)

        }).disposed(by: DisposeBag())
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.id,
                                                       for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        cell.config(cellModel: dataSource[indexPath.row])
        return cell
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if textField == priceTextField {
            viewModel.setPrice(text)
        } else if textField == amountTextField {
            viewModel.setAmount(text)
        }
    }
}
