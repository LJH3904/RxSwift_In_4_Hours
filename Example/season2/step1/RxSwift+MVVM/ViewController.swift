//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    func testObserver(_ url: String) -> Observable<String?> {
        return Observable.create { t in
            t.onNext("안녕")
            t.onNext("테스트")
            t.onCompleted()
            return Disposables.create()
        }
        
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: 정리
//    알엑스의 용도는 비동기적으로 생긴느 데이터를 리턴값으로 전달해주는 클래스

    // obsevable의 생명주기
    // 1. create // 만들어진다고 동작이 되는게 아님.
    // 2. subscribe // <- 가 됐을 때 동작이 된다
    // 3. onnext
    // ---- 끝 ----
    // 한번 만들어지면 2로 통해 실행되고 4로 결과가 나오고
    // 동작이 끝난 observable은 재사용 불가능 하다. 
    // 4. oncompleted / onError
    // 5. Disposed
    
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create { emm in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err ) in
                guard err == nil else {
                    emm.onError(err!)
                    return
                }
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emm.onNext(json)
                }
                emm.onCompleted()
                
            }
            task.resume()
            return Disposables.create() {
                task.cancel()
            }
        }
//        return Observable.create { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//                
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                }
//            }
//            return Disposables.create()
//        }
    }
    
 
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in
                switch event {
                case .next(let json) :
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                case .completed:
                    break
                case .error:
                    break
                }
            }
    }
}
//    그러면 다른스레드에서 처리하고 그결과를 전달하는걸 이렇게 사용함 Rx의 필요성
//    귀찮기도 하고 몇번 더쓰면 쓰레기 코드 됨 에네르기 파 생김
    // 나중에 생기는 데이터는 observable이라는 이름을 사요한다 .
