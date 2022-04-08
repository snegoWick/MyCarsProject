//
//  ViewController.swift
//  MyCarsProject
//
//  Created by Aleksandr Makarov on 07.04.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    var car: Car!
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    private let markLabel = UILabel.setupLabel(text: "Mark", fontSize: 18)
    private let modelLabel = UILabel.setupLabel(text: "Model", fontSize: 24)
    private let carImageView = UIImageView()
    private let lastTimeStartedLabel = UILabel.setupLabel(text: "Last Time Started:", fontSize: 18)
    private let numberOfTripsLabel = UILabel.setupLabel(text: "Number of trips", fontSize: 18)
    private let ratingLabel = UILabel.setupLabel(text: "Rating:", fontSize: 18)
    private let myChoiceImageView = UIImageView(image: UIImage(named: "myChoice"))
    private let startEngineButton = UIButton.setupButton(title: "Start Engine", cornerRadius: 8)
    private let ratingButton = UIButton.setupButton(title: "Rate", cornerRadius: 8)
    private var segmentedControl: UISegmentedControl! {
        didSet {
            updateSegmentedControl()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getDataFromFile()
        buttonsTargets()
    }
    
    //MARK: - Buttons targets
    private func buttonsTargets() {
        startEngineButton.addTarget(self, action: #selector(starEngineButtonTapped), for: .touchUpInside)
        ratingButton.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
    }
    
    @objc private func starEngineButtonTapped() {
        car.timesDriven += 1
        car.lastStarted = Date()
        
        do {
            try context.save()
            insertDataFrom(selectedCar: car)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Rating Button tapped
    @objc private func ratingButtonTapped() {
        let alertController = UIAlertController(title: "Rate it", message: "", preferredStyle: .alert)
        let rateAction = UIAlertAction(title: "Rate", style: .default) { action in
            if let text = alertController.textFields?.first?.text {
                self.update(rating: (text as NSString).doubleValue)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alertController.addAction(rateAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    //MARK: - Update SegmentedControl
    @objc private func updateSegmentedControl() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            car = results.first
            insertDataFrom(selectedCar: car!)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Inser Data from selectedCar
    private func insertDataFrom(selectedCar car: Car) {
        carImageView.image = UIImage(data: car.imageData!)
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiceImageView.isHidden = !(car.myChoice)
        ratingLabel.text = "Rating: \(car.rating) / 10"
        numberOfTripsLabel.text = "Number of trips: \(car.timesDriven)"
        lastTimeStartedLabel.text = "Last time started: \(dateFormatter.string(from: car.lastStarted!))"
        segmentedControl.backgroundColor = car.tintColor as? UIColor
    }
    
    //MARK: - Get Data from file
    private func getDataFromFile() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        do {
            records = try context.count(for: fetchRequest )
            print("Is data there already?")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        guard records == 0 else { return }
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"), let dataArray = NSArray(contentsOfFile: pathToFile) else { return }
        
        for i in dataArray {
            guard let entity = NSEntityDescription.entity(forEntityName: "Car", in: context) else { return }
            let car = NSManagedObject(entity: entity, insertInto: context) as! Car
            let carDictionary = i as! [String: AnyObject]
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoice = carDictionary["myChoice"] as! Bool
            
            guard let imageName = carDictionary["imageName"] as? String else { return }
            let image = UIImage(named: imageName)
            let imageData = image?.pngData()
            car.imageData = imageData
            
            if let colorDictionary = carDictionary["tintColor"] as? [String: Float] {
                car.tintColor = getColor(colorDictionary: colorDictionary)
            }
        }
    }
    
    //MARK: - Get color from CoreData
    private func getColor(colorDictionary: [String: Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else { return UIColor() }
        return UIColor(red: CGFloat(red / 255), green: CGFloat(green / 255), blue: CGFloat(blue / 255), alpha: 1)
    }
    
    //MARK: - Function Update
    private func update(rating: Double) {
        car.rating = rating
        
        do {
            try context.save()
            insertDataFrom(selectedCar: car)
        } catch let error as NSError {
            let alertController = UIAlertController(title: "Wrong value", message: "Wrong input text", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            print(error.localizedDescription)
        }
    }
    
    //MARK: - SetupUI
    private func setupUI() {
        view.backgroundColor = .white
        
        segmentedControl = UISegmentedControl.setupSegmentedControl(items: ["Lamborgini", "Ferrari", "Mercedes", "Nissan", "BMW"])
        segmentedControl.addTarget(self, action: #selector(updateSegmentedControl), for: .valueChanged)
        segmentedControl.selectedSegmentTintColor = .white
        let whiteTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let blackTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UISegmentedControl.appearance().setTitleTextAttributes(whiteTitleTextAttributes, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(blackTitleTextAttributes, for: .selected)
        
        view.addSubview(markLabel)
        markLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil)
        markLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(modelLabel)
        modelLabel.anchor(top: markLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 8, left: 0, bottom: 0, right: 0))
        modelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(carImageView)
        carImageView.anchor(top: modelLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 250))
        carImageView.contentMode = .scaleAspectFit
        
        view.addSubview(lastTimeStartedLabel)
        lastTimeStartedLabel.anchor(top: carImageView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0))
        
        view.addSubview(numberOfTripsLabel)
        numberOfTripsLabel.anchor(top: lastTimeStartedLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 8, bottom: 0, right: 0))
        
        view.addSubview(ratingLabel)
        ratingLabel.anchor(top: lastTimeStartedLabel.topAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 8))
        
        view.addSubview(segmentedControl)
        segmentedControl.anchor(top: numberOfTripsLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 8, bottom: 0, right: 8))
       
        view.addSubview(myChoiceImageView)
        myChoiceImageView.anchor(top: segmentedControl.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 12, left: 0, bottom: 0, right: 0), size: .init(width: 150, height: 150))
        myChoiceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(startEngineButton)
        startEngineButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 8, bottom: 12, right: 0), size: .init(width: 130, height: 30))
        
        view.addSubview(ratingButton)
        ratingButton.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 12, right: 8), size: .init(width: 130, height: 30))
    }
}

