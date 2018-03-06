//
//  LocationSearchTable.swift
//  UberPool
//
//  Created by Jeevan on 13/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation
import MapKit

protocol LocationSearchTableDelegate {
    // func didSelectAnimal(_ item: Animal)
    
    func diSelectItem(item:MKMapItem)
    
    //func didSelectButton(buttonTag:Int)
    
 //   func navigateToLogin()
}


class LocationSearchTable: UIView {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var delegate:LocationSearchTableDelegate?
   
    @IBOutlet var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func updateSearchResultsForSearchController(diestinationText: UITextField) {
        guard let mapView = mapView,
        let searchBarText = diestinationText.text else { return }
       
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}

extension LocationSearchTable:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellSub")
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.country
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.superview?.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row]
        delegate?.diSelectItem(item: selectedItem)
        
    }
}


