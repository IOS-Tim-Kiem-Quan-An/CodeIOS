//
//  CustomAnnotation.swift
//  GiaoDien
//
//  Created by Cuong on 12/5/18.
//  Copyright © 2018 Cuong. All rights reserved.
//

import MapKit

class CustomAnnotation:NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate:CLLocationCoordinate2D,title:String,subtitle:String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }

}
