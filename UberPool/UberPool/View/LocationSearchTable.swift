//
//  LocationSearchTable.swift
//  UberPool
//
//  Created by Jeevan on 13/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation
import MapKit
import GooglePlaces
import GoogleMaps


protocol LocationSearchTableDelegate {
    // func didSelectAnimal(_ item: Animal)
    
    func diSelectItem(item:MKMapItem)
    func didSelectPredictionItem(item:GMSAutocompletePrediction)
    
    //func didSelectButton(buttonTag:Int)
    
 //   func navigateToLogin()
}


class LocationSearchTable: UIView {
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var delegate:LocationSearchTableDelegate?
    var fetcher: GMSAutocompleteFetcher?
    var predictionData:[GMSAutocompletePrediction] = []
   
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
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment

        fetcher  = GMSAutocompleteFetcher(bounds: nil, filter: filter)

        fetcher?.delegate = self
    }
    
    func updateSearchResultsForSearchController(diestinationText: UITextField,mapRegion:GMSVisibleRegion) {

         let bound = GMSCoordinateBounds(region: mapRegion)
        fetcher?.autocompleteBoundsMode = .bias
        fetcher?.sourceTextHasChanged(diestinationText.text!)

       /* guard let mapView = mapView,
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
        } */
    }
}

extension LocationSearchTable:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return  predictionData.count
       // return self.matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       /*  let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellSub")
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.country
        return cell */

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellSub")
        let selectedItem = predictionData[indexPath.row]
        cell.textLabel?.attributedText = selectedItem.attributedFullText
        cell.detailTextLabel?.attributedText = selectedItem.attributedPrimaryText

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.superview?.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectItem = predictionData[indexPath.row]
        delegate?.didSelectPredictionItem(item: selectItem)

       // let selectedItem = matchingItems[indexPath.row]
       // delegate?.diSelectItem(item: selectedItem)
        
    }
}

extension LocationSearchTable: GMSAutocompleteFetcherDelegate {


    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {

        self.predictionData.removeAll()

        for prediction in predictions{

            self.predictionData.append(prediction)
        }
        self.tableView.reloadData()
    }

    func didFailAutocompleteWithError(_ error: Error) {
        print(error.localizedDescription)
    }



}


