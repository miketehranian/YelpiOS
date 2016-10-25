//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
    
    var businesses: [Business]!
    
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var categoryStates = [Int: Bool]()
    var distancesStates = [Int: Bool]()
    var sortByStates = [Int: Bool]()
    var hasDealState = false

    var yelpFilters: YelpFilters?
    var searchResultsOffset: Int?
    
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        loadSearchResults(withText: searchBar.text, appendResults: false)
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
        searchBar.text = "Restaurants"
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor.red;
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.isTranslucent = false;
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        businesses = [Business]()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        
        switch navigationController.topViewController {
        case is FiltersViewController:
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
            filtersViewController.categoriesSwitchStates = categoryStates
            filtersViewController.distancesSwitchStates = distancesStates
            filtersViewController.sortBySwitchStates = sortByStates
            filtersViewController.hasDealsState = hasDealState
        case is MapViewController:
            let mapViewController = navigationController.topViewController as! MapViewController
            mapViewController.businesses = businesses
        default:
            break
        }
    }
    
    func loadSearchResults(withText searchText: String?, appendResults: Bool) {
        var localSearchText: String
        
        if searchText == nil || searchText!.isEmpty {
            localSearchText = "Restaurants"
        } else {
            localSearchText = searchText!
        }
        
        if let existingYelpFilters = yelpFilters {
            Business.searchWithTerm(term: localSearchText, sort: existingYelpFilters.sort, categories: existingYelpFilters.categories, deals: existingYelpFilters.hasDeal, radiusMeters: existingYelpFilters.distance, offset: searchResultsOffset) {
                (businesses: [Business]?, error: Error?) in
                self.searchResultsCompletionHandler(businesses: businesses, error: error, appendResults: appendResults)
            }
        } else {
            Business.searchWithTerm(term: localSearchText, offset: searchResultsOffset) {
                (businesses: [Business]?, error: Error?) in
                self.searchResultsCompletionHandler(businesses: businesses, error: error, appendResults: appendResults)
            }
        }
    }
    
    func searchResultsCompletionHandler(businesses: [Business]?, error: Error?, appendResults: Bool) {
        if !isMoreDataLoading {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        self.isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        
        if appendResults {
            self.businesses.append(contentsOf: businesses!)
        } else {
            self.businesses = businesses
        }
        self.tableView.reloadData()
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

extension BusinessesViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension BusinessesViewController: FilterViewControllerDelegate {
    func filterViewController(_ filtersViewController: FiltersViewController, withFilters filters: YelpFilters, withFilterTableStates filterTableStates: YelpFilterTableStates) {
        self.categoryStates = filterTableStates.categoryStates
        self.distancesStates = filterTableStates.distanceStates
        self.sortByStates = filterTableStates.sortByStates
        self.hasDealState = filterTableStates.hasDealState
        
        self.yelpFilters = filters
        self.searchResultsOffset = 0
        
        var searchTerm: String
        if searchBar.text == nil || searchBar.text!.isEmpty {
            searchTerm = "Restaurants"
        } else {
            searchTerm = searchBar.text!
        }
        
        loadSearchResults(withText: searchTerm, appendResults: false)
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    // Only search when the search keyboard button was tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsOffset = 0
        
        if let searchText = searchBar.text {
            if !searchText.isEmpty {
                loadSearchResults(withText: searchText, appendResults: false)
            } else {
                loadSearchResults(withText: "Restaurants", appendResults: false)
            }
        }
    }
}

extension BusinessesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                searchResultsOffset = businesses.count
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y:tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadSearchResults(withText: searchBar.text, appendResults: true)
            }
        }
    }
}

