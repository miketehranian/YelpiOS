//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Mike Tehranian on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit


protocol FilterViewControllerDelegate: class {
    func filterViewController(_ filtersViewController: FiltersViewController, withFilters filters: YelpFilters, withFilterTableStates filterTableStates: YelpFilterTableStates)
}

class FiltersViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FilterViewControllerDelegate?
    
    var categories: [[String:String]]!
    var categoriesSwitchStates = [Int:Bool]()
    
    var distances: [String]!
    var distancesSwitchStates = [Int: Bool]()
    
    var sortBy: [String]!
    var sortBySwitchStates = [Int: Bool]()
    
    var hasDealsState: Bool!
    
    private let sortStyles: [YelpSortMode] = [
        .bestMatched,
        .distance,
        .highestRated
    ]
    
    private let radiusDistanceMeters = [
        482, // 0.3 miles
        1609, // 1 mile
        8045, // 5 miles
        32180 // 20 miles
    ]
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        // Get a list of category names by index rows
        var selectedCategoriesByName = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategoriesByName.append(categories[row]["code"]!)
            }
        }
        
        // Determine the distance selected and convert to meters
        var selectedDistance: Int?
        for (row, isSelected) in distancesSwitchStates {
            if isSelected {
                selectedDistance = row
            }
        }
        var distMeters: Int?
        if let distanceIndex = selectedDistance {
            distMeters = radiusDistanceMeters[distanceIndex]
        }
        
        // Determine the Sort style selected
        var selectedSortStyle: Int?
        for (row, isSelected) in sortBySwitchStates {
            if isSelected {
                selectedSortStyle = row
            }
        }
        var sortStyle: YelpSortMode?
        if let sortIndex = selectedSortStyle {
            sortStyle = sortStyles[sortIndex]
        }
        
        let yelpFilters = YelpFilters(categories: selectedCategoriesByName, distance: distMeters, sort: sortStyle, hasDeal: hasDealsState)
        let yelpFilterTableStates = YelpFilterTableStates(categoryStates: categoriesSwitchStates, distanceStates: distancesSwitchStates, sortByStates: sortBySwitchStates, hasDealState: hasDealsState)
        delegate?.filterViewController(self, withFilters: yelpFilters, withFilterTableStates: yelpFilterTableStates)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeData()
        initializeUI()
    }
    
    func initializeUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = UIColor.red;
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.isTranslucent = false;
    }
    
    func initializeData() {
        categories = YelpFilters.yelpCategories()
        distances = YelpFilters.distanceCategories()
        sortBy = YelpFilters.sortByCategories()
    }
}

extension FiltersViewController: UITableViewDataSource {
    func numberOfSections(in: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            // Deals section does not have a title
            return nil
        case 1:
            return "Distance"
        case 2:
            return "Sort By"
        case 3:
            return "Category"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return distances.count
        case 2:
            return sortBy.count
        case 3:
            return categories.count
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        switch indexPath.section {
        case 0:
            cell.switchLabel.text = "Offering a Deal"
            cell.onSwitch.isOn = hasDealsState ?? false
        case 1:
            cell.switchLabel.text = distances[indexPath.row]
            cell.onSwitch.isOn = distancesSwitchStates[indexPath.row] ?? false
        case 2:
            cell.switchLabel.text = sortBy[indexPath.row]
            cell.onSwitch.isOn = sortBySwitchStates[indexPath.row] ?? false
        case 3:
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.onSwitch.isOn = categoriesSwitchStates[indexPath.row] ?? false
        default:
            break
        }
        cell.delegate = self
        return cell
    }
}

extension FiltersViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        switch indexPath.section {
        case 0:
            hasDealsState = value
        case 1:
            for (row, isSelected) in distancesSwitchStates {
                if isSelected {
                    distancesSwitchStates[row] = false
                }
            }
            distancesSwitchStates[indexPath.row] = value
            tableView.reloadData()
        case 2:
            for (row, isSelected) in sortBySwitchStates {
                if isSelected {
                    sortBySwitchStates[row] = false
                }
            }
            sortBySwitchStates[indexPath.row] = value
            tableView.reloadData()
        case 3:
            categoriesSwitchStates[indexPath.row] = value
        default:
            break
        }
    }
}

