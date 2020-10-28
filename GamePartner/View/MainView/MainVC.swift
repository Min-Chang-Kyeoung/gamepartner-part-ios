//
//  MainVC.swift
//  GamePartner
//
//  Created by 민창경 on 2020/08/19.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxViewController
import Kingfisher

class MainVC: UIViewController, UIScrollViewDelegate{
    
    let viewModel = FriendViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<FriendInfoSection>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell") as! MainTableCell
            let imgUrl = URL(string: "https://storage.googleapis.com/gamepartner/" + element.imgUrl!)
            
            cell.imgProfile.image = element.image
            cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height/2
            cell.imgProfile.layer.masksToBounds = true
            cell.imgProfile.kf.setImage(with: imgUrl)
            cell.imgProfile.contentMode = .scaleAspectFill
            
            cell.imgSex.image = element.imageSex
            
            cell.lblNickName.text = element.nickName
            
            //print(imgUrl)
            
            if element.sex == "W"{
                cell.lblNickName.textColor = .systemPink
            }
            
            cell.lblIntroduce.text = element.introduce
            cell.lblGame.text = element.favoritGame
            
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        }
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .clear
        tableView.refreshControl = UIRefreshControl()

        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let reload = tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
            .do(onNext: { _ in self.tableView.refreshControl?.endRefreshing()})

    
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.fetchIndexApi)
            .disposed(by: disposeBag)
        
        viewModel.fetchFriendList
            .bind(to: tableView.rx.items(dataSource:self.dataSource))
            .disposed(by: disposeBag)
            
    }
    
}
