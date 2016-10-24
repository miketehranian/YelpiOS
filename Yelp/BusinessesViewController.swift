//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate {
    
    // MDT add a didset here to make a call to reloadData()
    var businesses: [Business]! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var categoryStates = [Int: Bool]()
    var distancesStates = [Int: Bool]()
    var sortByStates = [Int: Bool]()
    var hasDealState = false
    var searchTerm = "Restaurants"
    
    //    var isMoreDataLoading = false
    //    var loadingMoreView: ActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        loadSearchResults(withText: searchTerm)
    }
    
    func initializeUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        // Used for estimating scroll bar height
        tableView.estimatedRowHeight = 120
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.text = searchTerm
        
        searchBar = UISearchBar()
        // MDT see if I can avoid this and do it programmatically via constraints
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor.red;
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.isTranslucent = false;
        
        // Set up Infinite Scroll loading indicator
        //        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: ActivityView.defaultHeight)
        //        loadingMoreView = ActivityView(frame: frame)
        //        loadingMoreView!.isHidden = true
        //        tableView.addSubview(loadingMoreView!)
        //
        //        var insets = tableView.contentInset;
        //        insets.bottom += ActivityView.defaultHeight;
        //        tableView.contentInset = insets
        
        businesses = [Business]()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
        
        let navigationViewController = segue.destination as! UINavigationController
        switch navigationViewController.topViewController {
        case is FiltersViewController:
            let filtersViewController = navigationViewController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
            filtersViewController.categoriesSwitchStates = categoryStates
            filtersViewController.distancesSwitchStates = distancesStates
            filtersViewController.sortBySwitchStates = sortByStates
            filtersViewController.hasDealsState = hasDealState
            //        case is MapViewController:
            //            let mapViewController = navigationViewController.topViewController as! MapViewController
            //            mapViewController.businesses = businesses
            //            mapViewController.delegate = self
        //            break
        default:
            break
        }
    }
    
    func loadSearchResults(withText searchText: String) {
        //        if self.isMoreDataLoading == false {
        //            MBProgressHUD.showAdded(to: self.view, animated: true)
        //            businesses.removeAll()
        //            tableView.reloadData()
        //        }
        
        Business.searchWithTerm(term: searchText, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
        })
        
        
        //        if self.isMoreDataLoading == false {
        //            MBProgressHUD.showAdded(to: self.view, animated: true)
        //            businesses.removeAll()
        //            tableView.reloadData()
        //        }
        //
        //
        //        Business.searchWithTerm(term: term, offset:businesses.count, completion: { (businesses: [Business]?, error: Error?) -> Void in
        //            if self.isMoreDataLoading == false {
        //                MBProgressHUD.hide(for: self.view, animated: true)
        //            }
        //            self.isMoreDataLoading = false
        //            self.loadingMoreView!.stopAnimating()
        //            if let businesses = businesses {
        //                for business in businesses {
        //                    self.businesses.append(business)
        //                }
        //            }
        //            self.tableView.reloadData()
        //            if let businesses = businesses {
        //                for business in businesses {
        //                    print(business.name!)
        //                    print(business.address!)
        //                }
        //            }
        //
        //            }
        //        )
        //    }
        
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
}

extension BusinessesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
}

// MDT not sure if I need this
//extension BusinessesViewController: UITableViewDelegate {
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        searchBar.resignFirstResponder()
//    }
//}

extension BusinessesViewController: FilterViewControllerDelegate {
    func filterViewController(_ filtersViewController: FiltersViewController, withFilters filters: YelpFilters, withFilterTableStates filterTableStates: YelpFilterTableStates) {
        self.categoryStates = filterTableStates.categoryStates
        self.distancesStates = filterTableStates.distanceStates
        self.sortByStates = filterTableStates.sortByStates
        self.hasDealState = filterTableStates.hasDealState
        
        var searchTerm: String
        if searchBar.text == nil || searchBar.text!.isEmpty {
            searchTerm = "restaurants'"
        } else {
            searchTerm = searchBar.text!
        }
        
//        print("MDT: SEARCH ARGS: SORT:\(filters.sort) CATS:\(filters.categories) DEALS:\(filters.hasDeal) RADIUSMETERS:\(filters.distance)")
        
        Business.searchWithTerm(term: searchTerm, sort: filters.sort, categories: filters.categories, deals: filters.hasDeal, radiusMeters: filters.distance) {
            (businesses:[Business]?, error:Error?) in
            self.businesses = businesses
        }
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    // Only search when the search keyboard button was tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        let searchText = searchBar.text?.isEmpty ? "Restaurants" : searchBar.text
        
        if let searchText = searchBar.text {
            if !searchText.isEmpty {
                loadSearchResults(withText: searchText)
            } else {
                loadSearchResults(withText: "Restaurants")
            }
        }
        
        // MDT maybe use below instead?
        //        searchTerm = searchBar.text!
        //        loadSearchResults(withText: searchTerm)
        //        searchBar.resignFirstResponder()
    }
    
    // Always show the Cancel button in the Search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // Hide the software keyboard with the Search Cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
