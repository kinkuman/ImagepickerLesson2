//
//  ViewController.swift
//  ImagepickerLesson
//
//  Created by user on 2018/10/22.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    // 画像表示部分
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.lightGray
        // 画像の縦横比率を維持
        imageView.contentMode = .scaleAspectFit
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - targetActionEvent
    // カメラで画像取得
    @IBAction func tapCamera(_ sender: UIBarButtonItem) {
        choiceImage(buttonItem:sender, type: .camera)
    }
    
    // カメラロールから画像選択
    @IBAction func tapFolder(_ sender: UIBarButtonItem) {
        choiceImage(buttonItem:sender, type:.photoLibrary)
    }
    
    // 保存ボタン
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        // imageViewに何かしら画像があれば
        if let image = imageView.image {
            
            // 保存をする、終わったら指定のメソッドを呼ぶ
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        } else {
            // 無理なことを要求しないでほしいので、やんわりと伝える
            showAlert(msg: "画像がなければ保存できません")
        }
    }
    
    // 保存終了時に呼ばれる
    @objc func image(_ image: UIImage,
                     didFinishSavingWithError error: NSError?,
                     contextInfo: UnsafeMutableRawPointer) {
        
        if let error = error {
            print(error.code)
            showAlert(msg: "保存失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した失敗した")
        }
        
        showAlert(msg: "保存しました")
    }
    
    // フィルタボタン
    @IBAction func tapFilter(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "フィルター", message: "適用したいフィルターを選択してください", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "セピア", style: .default, handler: { (alertAction) in
            // セピアフィルター
            let filter = CIFilter(name: "CISepiaTone", withInputParameters: ["inputIntensity":0.9])!
            
            // フィルタ適用
            self.applyFilter(filter:filter)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "ブレア", style: .default, handler: { (alertAction) in
            // ブレアフィルター
            let filter = CIFilter(name: "CIBoxBlur", withInputParameters: ["inputRadius":10.0])!
            
            // フィルタ適用
            self.applyFilter(filter:filter)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    // MARK: - 自作メソッド
    
    func applyFilter(filter:CIFilter) {
        
        guard let image = self.imageView.image else {
            showAlert(msg: "画像がないんだけど")
            return
        }
        
        // UIImageをCIImage型に変換
        let ciImage = CIImage(image: image)!
        
        // 画像を指定
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        let ciContext = CIContext(options: nil)
        // 画像の生成
        let imageRef = ciContext.createCGImage((filter.outputImage)!, from: (filter.outputImage!.extent))!
        
        // CGimageからUIImageに変換
        let outputImage = UIImage(cgImage: imageRef)
        // イメージビューに設定
        self.imageView.image = outputImage
    }
    
    // 画像選択処理
    func choiceImage(buttonItem:UIBarButtonItem, type:UIImagePickerControllerSourceType) {
        
        // 選んだ機能が使えるか確認
        if false == UIImagePickerController.isSourceTypeAvailable(type) {
            showAlert(msg: "利用できません")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        // ピッカーの処理結果などのイベントはDelegateで受け取る
        imagePickerController.delegate = self
        
        // これでpopoverPresentationControllerが生成される
        imagePickerController.modalPresentationStyle = .popover
        // できたものを受け取る
        let popoverController = imagePickerController.popoverPresentationController!
        
        // デリゲート設定
        popoverController.delegate = self
        
        // 吹き出しを出す方向の指定
        popoverController.permittedArrowDirections = .any
        // 吹き出しを出すビューのバーボタンアイテムの指定
        popoverController.barButtonItem = buttonItem
        
        // 画面遷移
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    // アラート表示
    func showAlert(msg:String) {
        let alertController = UIAlertController(title: "メッセージ", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 撮ったもしくは選んだ画像の取得
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
        
        // イメージビューに設置
        self.imageView.image = image
        // ピッカーは隠す
        picker.dismiss(animated: true, completion: nil)
    }
    
    //このメソッドは特に書かなければ普通に閉じる処理をしてくれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("キャンセル")
        // ピッカーを隠す
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK:UIPopoverPresentationControllerDelegate(Phone系で確認用)
    
    // これがないとPhone系だと普通の遷移になる
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
    
}

