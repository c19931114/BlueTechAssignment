//
//  MainViewModel.swift
//  BlueTechAssignment
//
//  Created by Crystal on 2024/7/24.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewModel {

    private let disposeBag = DisposeBag()
    private var timer: Timer?

    struct Output {
        var cellModels: Driver<[TradeCellModel]> { model.cellModels.asDriver() }
        var price: Driver<String> { model.price.asDriver() }
        var amount: Driver<String> { model.amount.asDriver() }
        var total: Driver<String> { model.total.asDriver() }

        private weak var model: MainViewModel!
        fileprivate init(model: MainViewModel) {
            self.model = model
        }
    }

    private(set) lazy var output: Output = { Output(model: self) } ()

    private let cellModels = BehaviorRelay<[TradeCellModel]>(value: [])
    private let price = BehaviorRelay<String>(value: "")
    private let amount = BehaviorRelay<String>(value: "")
    private let total = BehaviorRelay<String>(value: "")

    init() {
        timing()
        bindTotal()
    }

    private func timing() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            var cellModelsCache = self.cellModels.value
            let new = generateCellModel()
            new.priceTap.bind(to: price).disposed(by: disposeBag)
            new.amountTap.bind(to: amount).disposed(by: disposeBag)
            cellModelsCache.append(new)
            self.cellModels.accept(cellModelsCache)
        })
    }

    private func generateCellModel() -> TradeCellModel {
        let now = Date()
        let timeString = now.toString()

        let randomPrice = Double.random(in: 0...100000)
        let roundedPrice = Double(round(randomPrice * 10000) / 10000)

        let randomAmount = Double.random(in: 0...100000)
        let roundedAmount = Double(round(randomAmount * 10000) / 10000)

        return TradeCellModel(time: timeString, price: String(roundedPrice), amount: String(roundedAmount))
    }

    private func bindTotal() {
        Observable.combineLatest(price, amount)
            .map({ price, amount in

                guard let priceDouble = Double(price),
                      let amountDouble = Double(amount) else { return "" }

                let total = priceDouble * amountDouble
                return String(format: "%.4f", total)
            })
            .bind(to: total)
            .disposed(by: disposeBag)
    }

    func setPrice(_ price: String) {
        self.price.accept(price)
    }

    func setAmount(_ amount: String) {
        self.amount.accept(amount)
    }

    func sortByPrice(_ sender: UIButton) {
        let sorted = cellModels.value.sorted { (item1, item2) -> Bool in
            guard let price1 = Double(item1.price), let price2 = Double(item2.price) else {
                return false
            }
            return sender.isSelected ? (price1 < price2) : (price1 > price2)
        }
        sender.isSelected.toggle()
        cellModels.accept(sorted)
    }

    func sortByAmount(_ sender: UIButton) {
        let sorted = cellModels.value.sorted { (item1, item2) -> Bool in
            guard let amount1 = Double(item1.amount), let amount2 = Double(item2.amount) else {
                return false
            }
            return sender.isSelected ? (amount1 < amount2) : (amount1 > amount2)
        }
        sender.isSelected.toggle()
        cellModels.accept(sorted)
    }
}

class TradeCellModel {

    let time: String
    let price: String
    let amount: String

    init(time: String, price: String, amount: String) {
        self.time = time
        self.price = price
        self.amount = amount
    }

    let priceTap = PublishRelay<String>()
    let amountTap = PublishRelay<String>()

    func tapPrice() {
        priceTap.accept(price)
    }

    func tapAmount() {
        amountTap.accept(amount)
    }
}

extension Date {
    func toString(dateFormat: String = "HH:mm:ss",
                  timeZoneGMT: Int = 8,
                  localeIdentifier: String = "zh_Hans_CN") -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZoneGMT * 60 * 60)
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        return dateFormatter.string(from: self)
    }
}
