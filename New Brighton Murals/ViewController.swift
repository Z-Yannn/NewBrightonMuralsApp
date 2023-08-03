//
//  ViewController.swift
//  New Brighton Murals
//
//  Created by Zhijie Yan on 29/11/2022.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import Foundation

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext
var contextArray = [NSManagedObject]()

var defaults = UserDefaults.standard
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var murals:brightonMurals? = nil
    var index = 0 // index row
    var sortedMural = [mural]()
    var muralArray = [mural]()
    var flag = 0 // perform segue: 1 means tapping on the cell, 0 means tapping on the annotation

    var favouriteMural = [String]() // store the favourite mural title
    
    @IBOutlet weak var myMap: MKMapView!
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var latitude = 0.0 // user current latitude
    var longitude = 0.0 // user current longitude
    func locationManager(_ manager:  CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0] //this method returns an array of locations
        //generally we always want the first one (usually there's only 1 anyway)
        latitude = locationOfUser.coordinate.latitude
        longitude = locationOfUser.coordinate.longitude
        //get the users location (latitude & longitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        if firstRun {
            firstRun = false
             
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            //a span defines how large an area is depicted on the map.
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                 
            //a region defines a centre and a size of area covered.
            let region = MKCoordinateRegion(center: location, span: span)
                 
            //make the map show that region we just defined.
            self.myMap.setRegion(region, animated: true)
                 
            //the following code is to prevent a bug which affects the zooming of the map to the user's location.
            //We have to leave a little time after our initial setting of the map's location and span,
            //before we can start centering on the user's location, otherwise the map never zooms in because the
            //intial zoom level and span are applied to the setCenter( ) method call, rather than our "requested" ones,
            //once they have taken effect on the map.
                 
            //we setup a timer to set our boolean to true in 5 seconds.
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:
    #selector(startUserTracking), userInfo: nil, repeats: false)
            }
             
        if startTrackingTheUser == true {
            myMap.setCenter(location, animated: true)
        }
        
        // if the network is unavailable fetch the request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "InfoMural")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
        }
        catch{
            print("Couldn't fetch results")
        }
         
        
        // calculate the distance between the user and murals and order by distance
        var distanceArray: [Double] = []
        // in case of nil mural
        if murals != nil{
            print("Got the information")
        } else{return}
        // calculate the distance between mural and user
        for i in 0...muralArray.count-1{
            let a = Double(muralArray[i].lat)
            let b = Double(muralArray[i].lon)
            let murall = CLLocation(latitude: a!, longitude: b!)
            let userr = CLLocation(latitude: latitude, longitude: longitude)
            let distance = murall.distance(from: userr)
            
            distanceArray.append(distance)
            
            // add the murals to the mapkit
            // The mural should be displayed only if the value of the enabled attribute is “1”
            if muralArray[i].enabled == "1"{
                let coordinate = CLLocationCoordinate2D(latitude: a!, longitude: b!)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = muralArray[i].title
                self.myMap.addAnnotation(annotation)
            }
        }
        
        // sort the mural array
        let combined = zip(distanceArray,muralArray).sorted{$0.0 < $1.0}
        sortedMural = combined.map{$0.1}
        
        muralArray = sortedMural
        myTable.reloadData()
        }
         
        //this method sets the startTrackingTheUser boolean class property to true. Once it's true,
       //subsequent calls to didUpdateLocations will cause the map to centre on the user's location.
        @objc func startUserTracking() {
            startTrackingTheUser = true
        }
    
    // the data is designed for tapping on the annotations, they will be loaded to the DetailViewController
    var titl = ""
    var inf = ""
    var img = [image]()
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        flag = 0
        let annotation = view.annotation!
        
        for x in myMap.annotations{
            if annotation.isEqual(x){
                for y in muralArray{
                    if x.title! == y.title{
                        titl = y.title
                        inf = y.info ?? "Currently no information is available"
                        img = y.images
                    }
                }
                
            }
        }
        
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    @IBOutlet weak var myTable: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard murals != nil else{return 0}
        var countNew = 0
        // calculte the number of new murals
        for i in 0...murals!.newbrighton_murals.count - 1{
            if murals?.newbrighton_murals[i].enabled == "1"{
                countNew = countNew + 1
            }
        }
        return countNew
       }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! myTVCell
        
        // ensure only display enabled = "1"
        if muralArray.count == 0{
            for i in 0...murals!.newbrighton_murals.count - 1{
                if murals?.newbrighton_murals[i].enabled == "1"{
                    muralArray.append((murals?.newbrighton_murals[i])!)
                }
            }
        }
        
        cell.titleLabel?.text = muralArray[indexPath.row].title
        cell.artistLabel?.text = muralArray[indexPath.row].artist ?? "Unknown author"
        cell.imageLabel.loadImage(URLAddress: muralArray[indexPath.row].thumbnail ?? "No pictures")
        
        // keep displaying the favourite star when the user is moving
        if favouriteMural.firstIndex(of: muralArray[indexPath.row].title) == nil{
            cell.favouriteButton.setImage(UIImage(named: "emptyStar"), for: .normal)
        }
        else{
            cell.favouriteButton.setImage(UIImage(named: "fullStar"), for: .normal)
        }
        
        
        return cell
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    // reload the table
    func updateTheTable() {
        myTable.reloadData()
        }
    
    // click on the cell, move to DetailViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        flag = 1
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    // transmit the data to DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let DetailViewController = segue.destination as! DetailViewController
            
            if flag == 1{
                DetailViewController.infomation = sortedMural[index].info ?? "Currently no information is available"
                 
                DetailViewController.imagesListArray = sortedMural[index].images

                DetailViewController.name = sortedMural[index].title
            }
            else if flag == 0{
                DetailViewController.infomation = inf
                 
                DetailViewController.imagesListArray = img
                
                DetailViewController.name = titl
            }

        }
    }
    
    // click on the star
    @IBAction func star(_ sender: UIButton) {
        let cell = sender.superView(of: UITableViewCell.self)!
        // know which star is tapped in the cell
        let indexPath = myTable.indexPath(for: cell)
        
        
        if (sender.currentImage == UIImage(named: "fullStar")){ // remove the mural from the list
            defaults.removeObject(forKey: "favourite")
            if let loc = favouriteMural.firstIndex(of: muralArray[indexPath![1]].title){
                favouriteMural.remove(at: loc)
            }
            sender.setImage(UIImage(named: "emptyStar"), for: .normal)
            print(favouriteMural)
        }
        else{ //add new murals
            favouriteMural.append(muralArray[indexPath![1]].title)
            sender.setImage(UIImage(named: "fullStar"), for: .normal)
            
            // store the favourite mural
            defaults.set(favouriteMural, forKey: "favourite")
            print("Favourite has been saved")
            
        }
    defaults.set(favouriteMural, forKey: "favourite")
        
}
    // know the which star button is tapped in the table cell
    func superUITableViewCell(of: UIButton) -> UITableViewCell? {
            for view in sequence(first: of.superview, next: { $0?.superview }) {
                if let cell = view as? UITableViewCell {
                    return cell
                }
            }
            return nil
        }
    
    
    // MARK: View related Stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the previous stored favourite
        if let loaded =
            defaults.object(forKey: "favourite") as? [String]{
            favouriteMural = loaded
            print("Previous favourite murals have been loaded")
        }else{
            print("No favourite mural is stored before")
        }
        
        // Make this view controller a delegate of the Location Manager, so that it
        //is able to call functions provided in this view controller.
        locationManager.delegate = self as CLLocationManagerDelegate
            
        //set the level of accuracy for the user's location.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
        //Ask the location manager to request authorisation from the user. Note that this
        //only happens once if the user selects the "when in use" option. If the user
        //denies access, then your app will not be provided with details of the user's
        //location.
        locationManager.requestWhenInUseAuthorization()
            
        //Once the user's location is being provided then ask for updates when the user
        //moves around.
        locationManager.startUpdatingLocation()
            
        //configure the map to show the user's location (with a blue dot).
        myMap.showsUserLocation = true
        // retrieve the database online
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals") {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let muralList = try decoder.decode(brightonMurals.self, from: jsonData)
                    self.murals = muralList
                    DispatchQueue.main.async {
                        self.updateTheTable()
                        }
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            //print("You are here!")
        }
        
       }
   }
    
// extend the UIImageView to load the thumbnail figure
extension UIImageView {
    func loadImage(URLAddress: String) {
        if let url = URL(string: URLAddress) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              // Error handling...
              guard let imageData = data else { return }

              DispatchQueue.main.async {
                self.image = UIImage(data: imageData)
              }
            }.resume()
          }
    }
}
// extend to know the star location in the teble cell
extension UIView {
    func superView <T: UIView> (of: T.Type) -> T? {
        for view in sequence(first: self.superview, next: { $0?.superview })
        {
            if let fatherView = view as? T {
                return fatherView
            }
        }
    
        return nil
    }
}
