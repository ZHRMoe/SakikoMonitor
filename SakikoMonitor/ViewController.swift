//
//  ViewController.swift
//  SakikoMonitor
//
//  Created by ZHRMoe on 2025/6/25.
//

import UIKit

class ViewController: UIViewController {
    
    private var datePicker: UIDatePicker!
    private var secondsPicker: UIPickerView!
    private var startButton: UIButton!
    private var hideButton: UIButton!
    private var timer: Timer?
    private var statusLabel: UILabel!
    private var instructionLabel: UILabel!
    private var secondsContainer: UIView!
    
    private let seconds = Array(0...59)
    private var selectedSeconds = 0
    
    // 新增：点击计数和手势识别
    private var tapCount = 0
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var resetTapCountTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGestureRecognizer()
        setDefaultTimeToNextDay10AM()
    }
    
    private func setupTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.isEnabled = false // 初始状态下禁用
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func screenTapped() {
        tapCount += 1
        
        // 重置计数器的定时器
        resetTapCountTimer?.invalidate()
        resetTapCountTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.tapCount = 0
        }
        
        if tapCount >= 5 {
            showAllUIElements()
            tapCount = 0
            resetTapCountTimer?.invalidate()
            tapGestureRecognizer.isEnabled = false
        }
    }
    
    private func hideAllUIElements() {
        UIView.animate(withDuration: 0.5) {
            self.instructionLabel.alpha = 0
            self.datePicker.alpha = 0
            self.secondsContainer.alpha = 0
            self.statusLabel.alpha = 0
            self.startButton.alpha = 0
            self.hideButton.alpha = 0
        }
        
        // 启用点击手势识别
        tapGestureRecognizer.isEnabled = true
        tapCount = 0
    }
    
    private func showAllUIElements() {
        UIView.animate(withDuration: 0.5) {
            self.instructionLabel.alpha = 1
            self.datePicker.alpha = 1
            self.secondsContainer.alpha = 1
            self.statusLabel.alpha = 1
            self.startButton.alpha = 1
            // 只有在计时状态下才显示隐藏按钮
            if self.timer?.isValid == true {
                self.hideButton.alpha = 1
            }
        }
        
        // 禁用点击手势识别
        tapGestureRecognizer.isEnabled = false
    }
    
    @objc private func hideButtonTapped() {
        hideAllUIElements()
    }
    
    private func setupUI() {
        // 设置说明标签
        instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
        instructionLabel.center = CGPoint(x: view.center.x, y: 100)
        instructionLabel.text = "丰川祥子模拟器"
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .darkGray
        view.addSubview(instructionLabel)
        
        // 设置日期时间选择器
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date() // 不能选择过去的时间
        datePicker.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        datePicker.center = CGPoint(x: view.center.x, y: instructionLabel.frame.maxY + 120)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        view.addSubview(datePicker)
        
        // 创建秒选择器容器
        secondsContainer = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 80))
        secondsContainer.center = CGPoint(x: view.center.x, y: datePicker.frame.maxY + 60)
        view.addSubview(secondsContainer)
        
        // 秒选择器标签
        let secondsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        secondsLabel.text = "秒"
        secondsLabel.textAlignment = .center
        secondsLabel.textColor = .darkGray
        secondsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        secondsLabel.center = CGPoint(x: secondsContainer.frame.width / 2, y: 15)
        secondsContainer.addSubview(secondsLabel)
        
        // 秒选择器
        secondsPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        secondsPicker.center = CGPoint(x: secondsContainer.frame.width / 2, y: 55)
        secondsPicker.delegate = self
        secondsPicker.dataSource = self
        secondsContainer.addSubview(secondsPicker)
        
        // 设置状态标签
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        statusLabel.center = CGPoint(x: view.center.x, y: secondsContainer.frame.maxY + 30)
        statusLabel.text = "未开始计时"
        statusLabel.textAlignment = .center
        statusLabel.textColor = .darkGray
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(statusLabel)
        
        // 设置开始按钮
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        startButton.center = CGPoint(x: view.center.x, y: statusLabel.frame.maxY + 30)
        startButton.backgroundColor = .blue.withAlphaComponent(0.8)
        startButton.setTitle("开始计时", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(onButtonTouched), for: .touchUpInside)
        view.addSubview(startButton)
        
        // 设置隐藏按钮
        hideButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        hideButton.center = CGPoint(x: view.center.x, y: startButton.frame.maxY + 30)
        hideButton.backgroundColor = .orange.withAlphaComponent(0.8)
        hideButton.setTitle("隐藏界面", for: .normal)
        hideButton.setTitleColor(.white, for: .normal)
        hideButton.layer.cornerRadius = 8
        hideButton.addTarget(self, action: #selector(hideButtonTapped), for: .touchUpInside)
        hideButton.alpha = 0 // 初始状态隐藏
        view.addSubview(hideButton)
    }

    private func setDefaultTimeToNextDay10AM() {
        let calendar = Calendar.current
        let now = Date()
        
        // 获取当前时间组件
        let nowComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        
        // 确定目标日期：如果当前时间在10点前，使用今天；否则使用明天
        let targetDay: Date
        if nowComponents.hour! < 10 {
            // 当前时间在10点前，使用今天
            targetDay = now
        } else {
            // 当前时间在10点后，使用明天
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
            targetDay = tomorrow
        }
        
        // 获取目标日期的年、月、日组件
        let targetDayComponents = calendar.dateComponents([.year, .month, .day], from: targetDay)
        
        // 生成10点到10点15分之间的随机分钟数
        let randomMinutes = Int.random(in: 0...15)
        
        // 生成0到59之间的随机秒数
        let randomSeconds = Int.random(in: 0...59)
        
        // 创建目标日期上午10点到10点15分之间的随机时间
        if let randomTime = calendar.date(from: DateComponents(
            year: targetDayComponents.year,
            month: targetDayComponents.month,
            day: targetDayComponents.day,
            hour: 10,
            minute: randomMinutes,
            second: randomSeconds
        )) {
            // 设置日期选择器的值为随机时间
            datePicker.setDate(randomTime, animated: true)
            
            // 设置秒选择器为随机秒数
            secondsPicker.selectRow(randomSeconds, inComponent: 0, animated: true)
            selectedSeconds = randomSeconds
            
            // 更新状态显示
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM月dd日 HH:mm:ss"
            let targetTimeString = dateFormatter.string(from: randomTime)
            statusLabel.text = "已自动设置为: \(targetTimeString)"
            statusLabel.textColor = .systemGreen
        }
    }

    @objc func onButtonTouched() {
        // 取消之前的计时器
        timer?.invalidate()
        
        // 获取设定的目标时间（包含秒）
        var targetDate = datePicker.date
        let calendar = Calendar.current
        
        // 获取用户选择的具体时间组件
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
        
        // 创建精确的目标时间，忽略秒和纳秒
        if let preciseDate = calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: components.minute,
            second: selectedSeconds
        )) {
            targetDate = preciseDate
        }
        
        let currentDate = Date()
        
        // 检查目标时间是否在未来
        if targetDate <= currentDate {
            let alert = UIAlertController(title: "提示", message: "请选择未来的时间", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 计算时间差（秒）
        let timeInterval = targetDate.timeIntervalSince(currentDate)
        
        // 更新按钮状态
        startButton.setTitle("计时中...", for: .normal)
        startButton.backgroundColor = .gray.withAlphaComponent(0.8)
        startButton.isEnabled = false
        
        // 格式化目标时间显示
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日 HH:mm:ss"
        let targetTimeString = dateFormatter.string(from: targetDate)
        statusLabel.text = "目标时间: \(targetTimeString)"
        statusLabel.textColor = .blue
        
        // 2秒后隐藏所有界面元素
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.hideAllUIElements()
            }
        }
        
        // 显示隐藏按钮
        UIView.animate(withDuration: 0.3) {
            self.hideButton.alpha = 1
        }
        
        // 创建新的计时器
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] timer in
            DispatchQueue.main.async {
                // 恢复按钮状态
                self?.startButton.setTitle("开始计时", for: .normal)
                self?.startButton.backgroundColor = .blue.withAlphaComponent(0.8)
                self?.startButton.isEnabled = true
                self?.statusLabel.text = "时间到！"
                self?.statusLabel.textColor = .red
                
                // 隐藏隐藏按钮
                self?.hideButton.alpha = 0
                
                // 启用点击手势识别，让用户可以通过连击显示界面
                self?.tapGestureRecognizer.isEnabled = true
                self?.tapCount = 0
                
                // 执行原有逻辑
                if let url = URL(string: "https://applink.feishu.cn/client/op/open") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        
        // 启动倒计时显示
        startCountdownDisplay(targetDate: targetDate)
    }
    
    private func startCountdownDisplay(targetDate: Date) {
        // 创建一个每秒更新的计时器来显示倒计时
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            let currentDate = Date()
            let remainingTime = targetDate.timeIntervalSince(currentDate)
            
            if remainingTime <= 0 {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                let hours = Int(remainingTime) / 3600
                let minutes = (Int(remainingTime) % 3600) / 60
                let seconds = Int(remainingTime) % 60
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM月dd日 HH:mm:ss"
                let targetTimeString = dateFormatter.string(from: targetDate)
                
                self?.statusLabel.text = "目标时间: \(targetTimeString) (剩余: \(String(format: "%02d:%02d:%02d", hours, minutes, seconds)))"
            }
        }
    }
    
    @objc private func datePickerValueChanged() {
        // 当日期选择器值改变时，可以在这里添加调试信息
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("选择的日期时间: \(dateFormatter.string(from: selectedDate))")
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seconds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d", seconds[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSeconds = seconds[row]
    }
}

