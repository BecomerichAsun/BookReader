//
//  hotBookViewModel.swift
//  GoodBookRead
//
//  Created by Asun on 2019/8/2.
//  Copyright © 2019 Asun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

class HotBookViewModel: NSObject {
    
    var startCount: Int = 21
    
    lazy var dataSource = BehaviorRelay<[HotBookCellViewModel]>.init(value: [])
    
    lazy var bookListSource: Observable<BookDetailModule> = Observable.from(optional: nil)
    
    lazy var endHeaderRefreshing: Observable<Bool> = Observable.from(optional: nil)
    
    lazy var endFootRefreshing: Observable<Bool> = Observable.from(optional: nil)
    
    lazy var endReloading: Observable<Bool> = Observable.from(optional: nil)
    
    func driverData(input: (view: UITableView, requestData: BookeDetailParams), depency:(action: ActionExtensionProtocol, bag: DisposeBag)) {
        
        configCollectionView(view: input.view, requestData: input.requestData, bag: depency.bag)
        
        self.bookListSource = ExtensionNetworkService.requestHotBookList(isLoading: true, params: input.requestData, start: 0)
        
        self.bookListSource.subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            self.dataSource.accept( (value.books?.compactMap{HotBookCellViewModel(model: $0)})!)
            }, onError: { (_) in
                self.dataSource.accept([])
                input.view.asunempty?.allowShow = true
                input.view.asunHead.rx.endRefreshing.onNext(true)
                input.view.rx.beginReloadData.onNext(true)
        }).disposed(by: depency.bag)
        
        self.endReloading = self.dataSource.map{ _ in true }
        
        self.endReloading.bind(to: input.view.rx.beginReloadData).disposed(by: depency.bag)
        
        self.endHeaderRefreshing = self.dataSource.map{ _ in true }
        
        self.endFootRefreshing = self.dataSource.map{ _ in true }
        
        self.endHeaderRefreshing.bind(to: input.view.asunHead.rx.endRefreshing).disposed(by: depency.bag)
        
        self.endFootRefreshing.bind(to: input.view.asunFoot.rx.endRefreshing).disposed(by: depency.bag)
        
        input.view.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            guard let `self` = self else { return }
            depency.action.didSelected(data: self.dataSource.value[indexPath.row].id.value)
        }).disposed(by: depency.bag)
    }
    
    func configCollectionView(view: UITableView, requestData:BookeDetailParams , bag: DisposeBag) {
        
        view.delegate = self
        view.dataSource = self
        
        view.asunempty?.allowShow = false
        
        view.register(cellType: BookDetailTableViewCell.self)
        
        view.asunempty = AsunEmptyView{
            view.asunHead.beginRefreshing()
        }
        
        view.asunFoot = AsunRefreshFooter{ [weak self] in
            guard let `self` = self else { return }
            self.bookListSource = ExtensionNetworkService.requestHotBookList(isLoading: false, params: requestData, start: self.startCount)
            self.startCount += 21
            self.bookListSource.subscribe({ (event) in
                switch event {
                case .next(let element):
                    self.dataSource.accept(self.dataSource.value + (element.books?.compactMap{HotBookCellViewModel(model: $0)})!)
                case .error:
                    view.asunFoot.rx.endRefreshing.onNext(true)
                case .completed:
                    break
                }
            }).disposed(by: bag)
        }
        
        view.asunHead = AsunRefreshHeader{ [weak self] in
            guard let `self` = self else { return }
            self.bookListSource = ExtensionNetworkService.requestHotBookList(isLoading: false, params: requestData, start: 0)
            view.asunHead.isHidden = false
            self.bookListSource.subscribe({ (event) in
                switch event {
                case .next(let element):
                    self.dataSource.accept( (element.books?.compactMap{HotBookCellViewModel(model: $0)})!)
                case .error:
                    self.dataSource.accept([])
                    view.asunempty?.allowShow = true
                    view.asunHead.rx.endRefreshing.onNext(true)
                    view.rx.beginReloadData.onNext(true)
                case .completed:
                    break
                }
            }).disposed(by: bag)
        }
        
        view.asunHead.isHidden = true
        
        view.asunHead.ignoredScrollViewContentInsetTop = -80
        
        AppdelegateReachabilityStatus.subscribe(onNext: { (value) in
            if !(value ?? false) {
                view.asunempty?.titleString = ResultTips.network.rawValue
            } else {
                view.asunempty?.titleString = ResultTips.service.rawValue
            }
        }).disposed(by: bag)
    }
}

extension HotBookViewModel : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: BookDetailTableViewCell.self)
        self.dataSource.value[indexPath.row].driverToCell(cell: cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
