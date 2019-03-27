//
//  DetailViewController.swift
//  DashMe
//
//  Created by leanne on 3/11/16.
//  Copyright © 2016 Jai Rai. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
	
	// MARK: - Properties (Non-Outlets)
	
	var selectedDash: Dash!
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var imageView: UIImageView!
	
	
	// MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
		
		imageView.image = selectedDash.DashdImage
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard let segueId = segue.identifier else {
			return
		}
		
		switch segueId {
			
		case "detailViewSegueToEditor":
			// segue is to editor's navigation controller; need to reach its child view controller
			let controller = segue.destination as! EditorViewController
			controller.defaultTopText = selectedDash.topDashText
			controller.defaultBottomText = selectedDash.bottomDashText
			controller.selectedImage = selectedDash.originalImage
			
			controller.cameFromDetail = true
			
		default:
			print("unknown segue: \(segueId)")
		}
    }
	
}
